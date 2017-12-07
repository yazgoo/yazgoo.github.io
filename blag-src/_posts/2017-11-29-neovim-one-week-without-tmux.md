---
layout: post
title: "Neovim terminal: one week without tmux"
created_at: 2017-11-29 21:22:18 +0100
categories: neovim terminal multiplexer tmux
---

For a while now there has been a [terminal feature integrated in neovim](https://neovim.io/doc/user/nvim_terminal_emulator.html).

[There's a vimcast](http://vimcasts.org/episodes/neovim-terminal/) on it if you want more info.

Vim has buffers, tabs, and splits.
The question I've been asking myself is simple:
Is it possible to replace my use of tmux with neovim ?
Here is my feedback, of one week leaving tmux.

Disclaimer:

1. I am not an advanced vim/neovim user
2. Nor do am I am an advanced tmux user


Basic usage and configuration
=============================

To use the terminal in vim, just type:

  `:terminal`

This will replace the current buffer you're focused on with a terminal emulator.
You can write in the terminal by switching to insert mode.

To leave the emulator, just type `^\^n`.

I find it kind of complicated, so I've done the following re-mapping based on
[Michael Abrahamsen blogpost](http://www.michaelabrahamsen.com/posts/replace-tmux-with-neovim/):

    tnoremap jj <C-\><C-n>

Basic stuff
===========

- To copy paste, the usual `y` and `p` work, I mostly use the `+` register.

- `:resize`, `:vertical-resize` works, which is awesome.

- `^n` completion will pick up everything managed by vim, including stuff written in your terminal ! 

Zooming
=======

tmux has a really nice [zooming feature](https://sanctum.geek.nz/arabesque/zooming-tmux-panes/).
I checked a few solutions to do that with vim.

  - [vim-zoom](https://github.com/dhruvasagar/vim-zoom): kinda works, but your buffer needs to be saved
  - [ZoomWin](https://github.com/regedarek/ZoomWin): 
    - When I used it it had a few second lags when zooming
    - It did not play well with pandoc and other plugins, I got many errors when zooming/restoring
  - [vim-maximizer](https://github.com/szw/vim-maximizer): 
    - It is equivalent to doing a resize, so other windows don't disappear, they are just minimized
    - It is fast and simple => my goto choice


Nesting
=======

  There is no protection against running vim in vim:
  It will work, but some escape sequence might not.

Detaching
=========

  tmux is a terminal multiplexer, but it also supports detaching/attaching
  this is really a usefull feature I'm not ready to lose yet.
  For example, it allows me to upgrade my terminal emulator without loosing my session or to keep a session over SSH.

  As mentioned [here](https://github.com/neovim/neovim/issues/5035#issuecomment-288144900),
  let's use abduco (a detach clone) for that:

    #!/bin/sh
    alias vmux="abduco -e '^g' -A nvim-session nvim"

  When we want to run vim as a terminal multiplexer, we'll just have to run `vmux`.
  Just use `CTRL+g` to detach from the session.


Controlling vim session from within terminal
=============================================

One usual workflow I have is:

  1. open a terminal
  2. find files in a directory
  3. open a file in the directory

With tmux, I just had to do

  `$ vim myfile`

At first, I just copied the name of a file in a buffer, then opened it in my vim session.
But I find it complicated.
What I'd like to do is, from within my terminal, call:

    $ vsplit myfile
    $ split myfile
    $ e myfile

Let's change our vmux command to:

    #!/usr/bin/sh
    alias vmux="(abduco -l|grep nvim-session) || rm -f /tmp/vim-server;\
      abduco -e '^g' -A nvim-session nvim --cmd \
        \"let g:server_addr = serverstart('/tmp/vim-server')\""

This will create a `/tmp/vim-server` file used to comunicate with neovim.

As a command line client to the vim server, 
Let's create `$HOME/.config/nvim/send_command_to_vim_session.py`

    #!/usr/bin/env python
    import neovim
    import sys
    nvim = neovim.attach('socket', path='/tmp/vim-server')
    nvim.command(" ".join(sys.argv[1:]))

In `.bashrc` or `.zshrc`, let's declare new commands:

    #!/usr/bin/sh
    alias vmux-send="$HOME/.config/nvim/send_command_to_vim_session.py"
    for cmd in split vsplit e tabnew
    do
      alias $cmd="vmux-send :$cmd"
    done

Now in a `:terminal` session, we will be able to call split or vsplit command !

cd with terminal
================

When in terminal mode, when I change directory (`cd`), I would like vim to also change its
working directory (`:cd`).
You can do so by adding this in your `.zshrc` or `.bashrc`:

    #!/usr/bin/sh
    function cd() {  
      builtin cd "$@";
      # if the parent process is nvim, do a vim cd 
      (ps -o comm= $PPID | grep nvim > /dev/null) && vmux-send :cd "$@"
    }
    export cd



What's next
===========

I loved my tmux status bar, so maybe I will try and find a replacement.
My window managers have their own status bars, so it is not that important to me though.

Currently, my setup only supports one `vmux` session, I need to fix that.

Maybe I could create a vim plugin integrating most of the stuff I described in here.

A protection against nesting could be nice.

Finally, I would like to protect vim from closing with a prompt when in `vmux` mode.

Conclusion
==========

So far, I'm having fun using neovim instead of tmux.
To me there is currently no obvious reason to switch back to tmux.
