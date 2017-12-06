---
title: "ruby gem to jar and war"
created_at: 2014-06-21 08:23:08 +0200
layout: post
---

Some days ago I read the following tweet:

<div>
<blockquote class="twitter-tweet" lang="en"><p>Today is one of those days I question my time spent working on JRuby, when so many Rubyists still treat us like the great Satan.</p>&mdash; Charles Nutter (@headius) <a href="https://twitter.com/headius/statuses/478133674710679552">June 15, 2014</a></blockquote>
</div>

It made me a little sad to see headius feel this way...
His work is just so cool.

<!-- more -->

jruby
-----

If you don't know about [jruby](//www.jruby.org/), an implementation of ruby on the JVM,
check out this video:

<iframe width="560" height="315" 
src="//www.youtube.com/embed/etCJKDCbCj4"
frameborder="0" allowfullscreen></iframe>


the plan
--------

After the previous tweet, I wanted to see how you could get from
simple ruby code to a jar, and, when we're at it, why not run it in a webapp.
So this is article is a little like a step by step guide.

our little gem
--------------

First, let's build a dummy ruby gem.

You'll need bundler, which allows to develop gems quickly:

    $ sudo gem install bundler

Now, you can create your gem directory layout:

    $ bundle gem x2

This creates an empty gem project.
This dummy gem will take a number and multiply it by 2.
You may want to edit the x2.gemspec file next by updating those two lines:

~~~ ruby
spec.description = "multiply by 2"
spec.summary     = ""
~~~

Now, lets write our main code in lib/x2.rb.
When done, the file should contain:

~~~ ruby
require "x2/version"

module X2
    class X2
        def initialize x
            @value = x.to_i * 2
        end
        def to_i
            @value
        end
    end
end
~~~

Basically, we take a value, cast it to an integer, multiply it by 2.
When to_i is called, we'll return the result.

an executable for our gem
-------------------------

Now, lets make an executable we can call.

    $ mkdir bin
    $ touch bin/x2
    $ chmod +x bin/x2

Let's edit bin/x2

~~~ ruby
#!/usr/bin/env ruby
require 'x2'
puts X2::X2.new(ARGV[0]).to_i
~~~

As you can see, the x2 command takes the first argument and displays the
result.
Lets test it:

    $ ruby -Ilib ./bin/x2 21
    42

Lets add it to the bundler project:

    $ git add .

warbler
-------

Meet [warbler](//github.com/jruby/warbler).

> Warbler is a gem to make a Java jar or war file out of any Ruby,
> Rails or Rack application

a jar from our gem
------------------

Lets see how hard it is to get an "executable" jar from all this:

    $ warble
    rm -f x2.jar
    Creating x2.jar

And it's done. Now run it:

    $ java -jar x2.jar 21
    42

a web application from our gem
------------------------------

Now let's run our code in a webapp.
First, we need a web application engine, we'll use 
[sinatra](//www.sinatrarb.com/):

> Sinatra is a DSL for quickly creating web applications in Ruby
>  with minimal effort

Let's add it as a runtime dependency to the x2.gemspec:

~~~ ruby
spec.add_runtime_dependency "sinatra"
~~~

Let's write the webapp main rackup code in config.ru:

~~~ ruby
require 'bundler'
Bundler.require
require 'sinatra'
require 'x2'
get '/:number' do |number|
    X2::X2.new(number).to_i.to_s
end
run Sinatra::Application
~~~

What this does is load libraries based on bundler,
load our library and sinatra.

Then, with the "get" method, we declare an URL pattern.

Basically, when /number will be called, the number will be multiply by 2
and we'll return the result.

Then, the run statement starts sinatra engine.

To run it in development mode, just run

    $ rackup

Then, to query it:

    $ curl http://localhost:9292/21
    42

As you can see, this was pretty easy.

a war: our web application in an app server
-------------------------------------------

Now let's try and run this in an application server.
First download [tommee plus](//tomee.apache.org/downloads.html).

Then, let's uncompress it.

Now in our x2 project, let's build the war using warble:

    $ warble
    rm -f x2.war
    Creating x2.war

And yes, because you have a config.ru file,
warbler assumes you want a war!

Now, let's copy x2.war to your TomEE:

    $ cp x2.war /path/to/tomee/webapps/

And let's start TomEE:

    $ /path/to/tommee/bin/startup.sh

And lets query the webapp:

    $ curl http://localhost:8080/x2/21
    42

to conclude
-----------

As you can see, in no time, thanks to jruby,
   we got from ruby to production ready jar and webapp,
   which is, lets face it, kinda awesome.

Hence:

<div>
<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/headius">@headius</a> Don&#39;t. Your work is very usefull to me on a daily basis!</p>&mdash; yazgoo (@oogzay) <a href="https://twitter.com/oogzay/statuses/478140729974611969">June 15, 2014</a></blockquote>
</div>

references
----------

[deploying a rails application in tomcat with jruby](//thenice.tumblr.com/post/133345213/deploying-a-rails-application-in-tomcat-with-jruby-a)

[make your own gem](//guides.rubygems.org/make-your-own-gem/)
