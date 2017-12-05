---
title: "Output rotation with logstash"
created_at: 2015-01-08 11:58:49 +0100
layout: post
tags: ['logstash']
---
I love [logstash](http://logstash.net/), it is a really powerfull tool,
and it also leverages jruby so it is really self-contained and portable.


Let's say you want to use `n` different outputs based on current date.
Here is the solution I use.

<!-- more -->

## Configuration ##

Lets write logstash [configuration](http://logstash.net/docs/1.4.2/configuration).
First, we'll be using [stdin](http://logstash.net/docs/1.4.2/inputs/stdin)
as input.

    #!ruby
    input { stdin { } }

Then, lets [add a field](http://logstash.net/docs/1.4.2/filters/mutate#add_field) named `t` containing the time.
Logstash configuration have a nice feature called
[sprintf](http://logstash.net/docs/1.4.2/configuration#sprintf),
which allows you to set a value based on a field or on a java
[DateTimeFormat](http://joda-time.sourceforge.net/apidocs/org/joda/time/format/DateTimeFormat.html).

Here, I will use the seconds in current minute, but you could, for example
use the day (by replacing `ss` with `dd`):

    #!ruby
    filter
    {
            mutate { add_field => { "t" => "%{+ss}" } }
    }

Now, lets write our output (we'll write on [stdout](http://logstash.net/docs/1.4.2/outputs/stdout) for tests purpose) using
[conditionals](http://logstash.net/docs/1.4.2/configuration#conditionals):

    #!ruby
    output
    {

If the time field is even, we will display events with rubydebug codec:

    #!ruby
        if [t] =~ /.*[02468]$/ { stdout { codec => rubydebug } }

If it is odd, we will display events with json codec:

    #!ruby
        if [t] =~ /.*[13579]$/ { stdout { codec => json } }

Let's close the output bracket:

    #!ruby
    }

Here is the whole configuration:

    #!ruby
    input { stdin { } }
    filter
    {
            mutate { add_field => { "t" => "%{+ss}" } }
    }
    output
    {
        if [t] =~ /.*[02468]$/ { stdout { codec => rubydebug } }
        if [t] =~ /.*[13579]$/ { stdout { codec => json } }
    }

## Testing it ##

Lets run the previous configuration with logstash sending an input.
Here, on an odd second:

    #!bash
    $ echo blax | ./bin/logstash agent -f /tmp/logstash ; echo
    {"message":"blax","@version":"1","@timestamp":"2015-01-09T19:14:15.517Z","host":"machine","t":"15"}

Here, on an even second:

    #!bash
    $ echo blax | ./bin/logstash agent -f /tmp/logstash ; echo
    {
           "message" => "blax",
          "@version" => "1",
        "@timestamp" => "2015-01-09T19:14:24.232Z",
              "host" => "machine",
                 "t" => "24"
    }


##Conclusion##

Here, we chose the output based on the second parity using regexes.

But we may have chosen another criteria, for example,
we might have chosen an output on the two first seconds via this conditional:

    #!ruby
    if [t] in ["01", "02"]

We also have chosen the output based on the `@timestamp` field, but I wanted to use
an output based on the actual current time, not based on the time associated with an event
(both may differ).
