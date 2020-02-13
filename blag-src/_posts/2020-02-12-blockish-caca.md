---
title: "Videos in the terminal with unicode blocks: blockish-caca"
created_at: 2020-02-12 21:22:18 +0100
layout: post
tags: rust blockish libcaca terminal LD_PRELOAD
---

# Overview

Over the past weeks I've been working on blockish,
a rust crate to render images in the terminal using unicode characters and ANSI escape codes.

Since it was quite fast, I was wondering if I could render videos with it.

# How a video player works


<pre style="line-height:15px;">
 ╭──────────────────────────╮
 │                          │
 │                          │
 │                          │
 │        Video Player      │
 │                          │
 │                          │            ╭────────────────────────────╮
 │                          │            │                            │
 ╰────────────┬─────────────╯            │                            │
              │                          │                            │
              │send frame                │         terminal           │
              │                          │                            │
              ▼                          │                            │
 ╭──────────────────────────╮            │                            │
 │                          │            ╰────────────────────────────╯
 │                          │                        ▲ 
 │                          │                        │
 │        libcaca           │                        │
 │                          ├────────────────────────╯
 │                          │          print frame
 │                          │
 ╰──────────────────────────╯
</pre>

# test

blixobulle
