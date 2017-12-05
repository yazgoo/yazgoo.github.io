---
layout: post
title: "Neovim terminal: one week without tmux"
created_at: 2017-11-29 21:22:18 +0100
categories: neovim terminal multiplexer tmux
---
Disclaimer:

- not an advanced vim user
- not an advanced tmux user


tnoremap jj <C-\><C-n>

http://www.michaelabrahamsen.com/posts/replace-tmux-with-neovim/

on enter terminal buffer keep in non insert mode, not a big deal to push i when I want to write to them

copy paste:

  - just the usual y p
  - when want to pass stuff to the os, use "+ register

resizing:

  - vertical-resize, resize work! 

zooming:

  - vim-zoom: kinda works, but buffer needs to be saved and you have to save your buffers
  - ZoomWin: 
    - big lag 
    - doesn't play well with pandoc and other plugins, many errors when zooming/restoring
    - bad with swap files

  - szw/vim-maximizer: 
    - just equivalent to doing a resize, so other windows don't disappear just minimized
    - fast and simple => my choice

nesting:

  - no protection against it:
    just have to forget the worflow of:
      1. navigating in a terminal
      2. launching vim
    instead:
      1. navigate in a terminal (or better in NERD)
      2. open file in a split
    will work, but some escape sequence won't

detaching:

  tmux is a terminal multiplexer, but it also supports detaching/attaching
  this is really a usefull feature I'm not ready to lose yet.
  For example, it allows me to upgrade my terminal emulator without loosing my session.

  As mentioned here https://github.com/neovim/neovim/issues/5035#issuecomment-288144900 ,
  lets use abduco (a detach clone) for that:

    alias vmux="abduco -e '^q' -A nvim-session nvim"

  Just use CTRL+q to detach from the session

completion:

  ^n completion will pick up everything managed by vim, including stuff written in your terminal !

controlling vim session from within terminal:

  One usual workflow I have is:

  1. open a terminal
  2. find files in a directory
  3. open a file in the directory

  With tmux, I just had to do

  `vim myfile`

  At first, I just copied the name of a file in a buffer, then open it in my vim session.
  But I find it complicated.
  What I'd like to do is, from within my terminal, call
  - vsplit myfile
  - split myfile
  - e myfile
  Let's change our vmux command to:

  alias vmux="(abduco -l|grep nvim-session) || rm -f /tmp/vim-server;abduco -e '^g' -A nvim-session nvim --cmd \"let g:server_addr = serverstart('/tmp/vim-server')\""

  let's create '$HOME/.config/nvim/send_command_to_vim_session.py :vsplit"

  #!/usr/bin/env python3
  import neovim
  import sys
  nvim = neovim.attach('socket', path='/tmp/vim-server')
  nvim.command(" ".join(sys.argv[1:]))

  alias vmux-send="$HOME/.config/nvim/send_command_to_vim_session.py"
  for cmd in split vsplit e tabnew
  do
    alias $cmd="vmux-send :$cmd"
  done

  Now in a :terminal, we will be able to call split or vsplit command !
