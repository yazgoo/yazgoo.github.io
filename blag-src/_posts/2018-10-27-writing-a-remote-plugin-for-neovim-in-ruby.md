---
title: "Writing a remote plugin for neovim in ruby"
created_at: 2018-10-27 21:22:18 +0100
layout: post
tags: vim neovim ruby plugin
---

One of the features that made me switch to [neovim](https://neovim.io/) was that
at the time I was writing a [plugin](https://github.com/ensime/ensime-vim) 
for vim and I was surprised that
there was no easy way to do asynchronous calls.

Meaning that if your command was taking too long, it freezed the UI.
A famous example of that is SQL client plugin, 
[dbext](https://github.com/vim-scripts/dbext.vim), which will freeze
vim when your sql request takes too long.

# Remote plugins

Remote plugins are one of the best features of neovim.
Neovim will spawn a separate process, and communicate with it
via [msgpack](https://github.com/msgpack/msgpack/blob/0b8f5ac/spec.md) RPC API.

So now plugins can process stuff in the background without vim freezing.

# neovim-ruby

[neovim-ruby README](https://github.com/neovim/neovim-ruby#neovim-ruby) is
well writen and will get you started, you should read it if you're going
to write a remote plugin.

# winds-up-client

I like kiteboarding, which depends on wind conditions.
The thing is that its good to always have an eye on these conditions.
There's a very good website which is called [winds-up](http://winds-up.com/)

I had already written a [ruby gem](https://rubygems.org/gems/winds-up-client) to get a ultrashort report from winds-up, 
here is what it looks like

```shell
$ winds-up-client --lpass --ultrashort
B3↓S1↘P2↘S13↘V2↘
```

- `lpass` option tells the client to log in winds-up.com with lastpass
- `ultrashort` tells that we want the shortest status report

The ultrashort report will contain all your favorite spots (first letter of each spot),
the wind speed (in nautical knots) and the wind direction (an arrow), 

For example `S13↘` means that my spot 'S' has 13 knots comming from north-west.

# writing the plugin

I'm installing it in the same repo as my gem, so that when
it is installed via a plugin manager like vim-plug,
it already has the gem embeded with it.
Here is what it looks like:

(rplugin/ruby/winds-up-client.rb)[/winds-up-client/blob/master/rplugin/ruby/winds-up-client.rb]
```ruby
require 'neovim'
require_relative '../../lib/winds-up-client'
Neovim.plugin do |plug|
  client = WindsUpClient.new(lpass: true, ultrashort: true)
  last_check = nil
  plug.command(:WindsUp) do |nvim|
    if last_check.nil? or Time.new - last_check > 60 
      begin
        nvim.set_var "windsup", client.favorites_spots_text.chomp
      rescue Exception
      end
      last_check = Time.new
    end
  end
end
```

Let's break it down.

I install it in `rplugin/ruby/winds-up-client.rb` which is the path which neovim
uses to load ruby neovim plugin.

I require my ruby library (which is in the same repo):

```ruby
require_relative '../../lib/winds-up-client'
```

Within my plugin context, I instantiate my client with 
the same arguments as the command line shown before:

```ruby
Neovim.plugin do |plug|
  client = WindsUpClient.new(lpass: true, ultrashort: true)
```

I declare a variable which will contain the timestamp of the last call to my command.

```ruby
  last_check = nil
```

Then I declare my command, which can now be invoked via :WindsUp
It has an `nvim` client object to interract with neovim.
I make sure it only gets called every 60 seconds, using last_check variable:

```ruby
  plug.command(:WindsUp) do |nvim|
    if last_check.nil? or Time.new - last_check > 60 
      # ... do stuff
      last_check = Time.new
    end
  end
```

Then I call my command, and set a neovim variable (`windsup`) contents 
with my ultrashort report.

[Here](https://www.rubydoc.info/github/neovim/neovim-ruby/master/Neovim/Client) 
is more documentation on what you can do with `nvim` object

```ruby
begin
  nvim.set_var "windsup", client.favorites_spots_text.chomp
rescue Exception
end
```

I also catch any exception, because I don't want my plugin to echo
its errors into vim (which it will do in case of exception).
You should definitely not do that when you're developing your plugin.

# using it


I then use it in my [tabbar](https://github.com/yazgoo/vmux-c98tabbar/blob/master/plugin/vmux-c98tabbar.vim#L9) vimscript (which is based on a fork of [c98tabbar.vim](https://github.com/yazgoo/c98tabbar.vim/tree/master/plugin)), by calling my command

```vimscript
if exists(":WindsUp")
  :WindsUp
endif
```

end then retrieving the `g:windup` variable contents to display them.

```
if exists("g:windsup")
  let l:s .= g:windsup
endif
```

Here is the result:

![tabbar](../../../images/ruby-wuc-bar.png)


# conclusion

So here was my very simple plugin, you can have a look at it [here](https://github.com/yazgoo/winds-up-client#neovim-plugin).

As you can see, neovim ruby plugins are really easy to write.

Hope it can help you if you want to write your own plugin !
