---
title: "Scala for comprehensions in Ruby"
created_at: 2025-01-08 21:22:18 +0100
layout: post
tags: ruby scala
---

# Porting scala for comprehensions to Ruby

## Context: `map` and `flatMap`

Scala is a functional language, so the operators `map` and `flatMap` are widely used.

To recap:

- `map` applies a function to each element of a data structure.
- `flatMap` applies a function that returns a data structure to each element of a data structure and "flattens" the result.

This applies to lists but not only to them.

### Examples of `map`

With a list:

```scala
val list = List(1, 2, 3)
val result = list.map(x => x * 2)
// result: List(2, 4, 6)
```

With an `Option`:

```scala
val option = Some(1)
val result = option.map(x => x * 2)
// result: Some(2)

val option = None
val result = option.map(x => x * 2)
// result: None
```

### Examples of `flatMap`

With a list:

```scala
val list = List(1, 2, 3)
val result = list.flatMap(x => List(x, x * 2))
// result: List(1, 2, 2, 4, 3, 6)
```

With an `Either` (a type that can hold either a value (Right) or an error (Left)):

```scala
val either = Right(1)
val result = either.flatMap(x => Right(x * 2))
// result: Right(2)

val either = Left("error")
val result = either.flatMap(x => Right(x * 2))
// result: Left("error")
```

### Context: Functional Programming

In Scala, it is common to chain `map`, `flatMap`, and `filter` to write functional programs.

For example, suppose we want to compute all tuples from 0 to 9 whose sum equals 10:

```scala
val result = (0 to 9).flatMap { x =>
  (0 to 9).map { y =>
    (x, y)
  }
}.filter { case (x, y) =>
  x + y == 10
}
// result: Vector((1,9), (2,8), (3,7), (4,6), (5,5), (6,4), (7,3), (8,2), (9,1))
```

### For Comprehensions

This can quickly become hard to read. To address this, Scala offers `for comprehensions`, which allow for more readable code.

Using a `for comprehension`, the previous code becomes:

```scala
val result = for {
    x <- 0 to 9
    y <- 0 to 9 if x + y == 10
} yield (x, y)
// result: Vector((1,9), (2,8), (3,7), (4,6), (5,5), (6,4), (7,3), (8,2), (9,1))
```

- `<-` denotes a generator (a data structure to iterate over).
- `if` (a guard) filters elements.
- `yield` returns the result (in this case, a tuple).

In practice, `<-` is a shortcut for `flatMap`.

It is also possible to use `map` with the `=` operator. For example, to multiply each element of a list by 2 and associate these elements with their double:

```scala
val result = for {
    x <- List(1, 2, 3)
    y = x * 2
} yield (x, y)
// result: List((1,2), (2,4), (3,6))
```

## Port to Ruby

To explore whether a Ruby syntax is feasible, I attempted to replicate `for comprehensions`.

Here’s the proposed syntax, inspired by Scala while keeping Ruby's spirit:

```ruby
result = for_c(
    gen(:x) { (0..9) },
    gen(:y, if_c { x + y == 10 }) { (0..9) },
) { [x, y] }
# result: [[1, 9], [2, 8], [3, 7], [4, 6], [5, 5], [6, 4], [7, 3], [8, 2], [9, 1]]
```

```ruby
result = for_c(
    gen(:x) { [1, 2, 3] },
    let(:y) { x * 2 }
) { [x, y] }
# result: [[1, 2], [2, 4], [3, 6]]
```

By reimplementing Scala's `Either`, error handling can be simplified without using exceptions:

```ruby
def validate_username(username)
  if username.length < 8
    Either.left("Username is too short (8 characters minimum)")
  else
    Either.right(username.downcase)
  end
end

def validate_date_of_birth(dob, today)
  if dob.next_year(18) > today
    Either.left("User must be 18 years old or older")
  else
    Either.right(dob)
  end
end

def validate_user(username, dob)
  for_c(
    gen(:username) { validate_username(username) },
    gen(:dob) { validate_date_of_birth(dob, Date.today) },
  ) { User.new(username, dob) }
end

puts validate_user("Bob", Date.new(2000, 12, 1))
# Left("Username is too short (8 characters minimum)")
puts validate_user("Bob_12345", Date.new(1960, 3, 5))
# Right(Bob_12345 (1960-03-05))
```

## Implementation of `for_c`

Here’s the core implementation:

```ruby
# Makes variables declared at each step available in code blocks
def with_binding_from_hash(variables, &block)
  obj = Object.new
  variables.each do |key, value|
    obj.instance_variable_set("@#{key}", value)
    obj.define_singleton_method(key) { instance_variable_get("@#{key}") }
  end
  obj.instance_eval(&block)
end

# Interprets code blocks with guards
def for_comprehension_with_guard(head, env)
  with_binding_from_hash(env, &head).map do |value|
    new_env = env.clone.merge({ head.name => value })
    [new_env, value]
  end.select do |new_env, value|
    head.guard.nil? || with_binding_from_hash(new_env, &head.guard)
  end
end

# Main method
def for_comprehension(ranges, env = {}, &block)
  if ranges.empty?
    with_binding_from_hash(env, &block)
  else
    head, *tail = ranges
    # If at the end or the next element is a `let`, perform a map; otherwise, flat_map
    mapping = tail.empty? || tail[0].is_a?(Let) ? :map : :flat_map
    if head.is_a? Gen
      # For generators, iterate over values
      for_comprehension_with_guard(head, env).send(mapping) do |new_env, value|
        for_comprehension(tail, new_env, &block)
      end
    elsif head.is_a? Let
      # For `let`, associate the value with the variable
      value = with_binding_from_hash(env, &head)
      new_env = env.clone.merge({ head.name => value })
      for_comprehension(tail, new_env, &block)
    end
  end
end
```

The complete implementation of `for_c` is available on [gist.github.com](https://gist.github.com/yazgoo/e897b5d31b0fae7bb0b299c6a1225ecd).

### Conclusion

The reader can judge the readability and utility of this syntax. The code is not optimized; it remains an experiment.

I am currently exploring implementing effects (IOs) similar to Haskell/cats-effect/ZIO in Ruby, and this syntax will simplify the code significantly.
