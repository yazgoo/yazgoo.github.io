---
title: "Creating a looper in shell part 2: adding a layer"
created_at: 2019-02-18 21:22:18 +0100
layout: post
tags: shell linux loop
---

# What we're aiming for

In the [previous article](../12/creating-a-looper-in-shell.html), we saw how to create a basic looper in shell.

This creates our background sound.

Lets add an "overdub" function, which is a way to add a layer on top of the background,

Here is a diagram showing what we're aiming for:

![timeline]({{"/images/looper_with_layer_timeline.png"|absolute_url}} "looper with layer timeline")

If it's still not clear, here is a video which explains how to use a looper
pedal from JustinGuitar youtube channel (see 8:10 timecode):

<iframe width="560" height="315" src="https://www.youtube.com/embed/Gd0NhglZWtw" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

# how we'll proceed

Like in previous part, we'll record the background in its own wav file (background.wav), based on pedal pushes.
Then we'll play it in a loop.
On the third push, we'll record the layer in layer.wav, and play it in subsequent loops, in parallel with background.wav.

# IPC

Because terminal input can only be done in the foreground, 
We'll have to capture the overdub pedal push in the foreground, and transfer the push to the main loop running in the background.

To do that, we'll use a very basic aproach: a text file which will contain false if the pedal was not pushed, and true if the pedal was pushed.


```

[ main loop ] === reads ===> [ text file ] <==== writes ==== [ pedal push ]

```

# let's do it


First, we will start the script by removing files from previous recordings:

```shell
rm background.wav layer.wav
```

then, let's record background.wav (this is the same thing as [previous article](../12/creating-a-looper-in-shell.html)

```shell
record_background() {
  input
  arecord -f S16_LE -r 48000 -D hw:1,0 background.wav &
  pid=$!
  sleep 1
  input
  kill $pid
}
```

As mentioned earlier, we'll be using a file named `should_record_layer` to notify the main_loop that it should start recording the layer (when it contains `true`), and initialize it at `false`.

```shell
  echo false > should_record_layer
```

# main loop

then let's start the main loop

```shell
  while true
  do
    play_layer
    record_layer  
    aplay background.wav
    [ $? -ne 0 ] && break
    [ -n $record_layer_pid ] && kill $record_layer_pid
    [ -n $play_layer_pid ] && kill $play_layer_pid
  done
```

Let's have a look at what we do here.

First, if a layer was recorded, we play it in the background, and set a variable with aplay pid:

```shell
play_layer() {
  play_layer_pid=""
  if [ -e "layer.wav" ]
  then
    aplay layer.wav &
    play_layer_pid=$!
  fi
}
```

Then, if `should_record_layer` file contains `true`, we record in the background, and set a variable with arecord pid.
Once arecord is started, we can set `should_record_layer` to false.

```shell
record_layer() {
  record_layer_pid=""
  if $(cat should_record_layer)
  then
    arecord -f S16_LE -r 48000 -D hw:1,0 layer.wav &
    record_layer_pid=$!
    echo false > should_record_layer
  fi
}
```

Then we can start playing background.wav:

```shell
aplay background.wav
```

When we're done playing background.wav, we kill arecord (the layer recorder) if it is running.
We also kill aplay (the layer player) if it is running.

```shell
    [ -n $record_layer_pid ] && kill $record_layer_pid
    [ -n $play_layer_pid ] && kill $play_layer_pid
```

# let's finish it

Then, we call main_loop in the background, wait for a pedal push, and notify main_loop
via `should_record_layer` file.

```shell
main_loop &
main_loop_pid=$!
input
echo true > should_record_layer
```

Finally, we wait for main_loop to stop:

```shell
wait $main_loop_pid
```

# The whole script

Here is the whole script

```shell
#!/usr/bin/env sh

input() {
	stty raw
	dd bs=1 count=1 2> /dev/null
	stty -raw
}

record_background() {
  input
  arecord -f S16_LE -r 48000 -D hw:1,0 background.wav &
  pid=$!
  sleep 1
  input
  kill $pid
}

play_layer() {
  play_layer_pid=""
  if [ -e "layer.wav" ]
  then
    aplay layer.wav &
    play_layer_pid=$!
  fi
}

record_layer() {
  record_layer_pid=""
  if $(cat should_record_layer)
  then
    arecord -f S16_LE -r 48000 -D hw:1,0 layer.wav &
    record_layer_pid=$!
    echo false > should_record_layer
  fi
}

main_loop() {
  echo false > should_record_layer
  while true
  do
    play_layer
    record_layer  
    aplay background.wav
    [ $? -ne 0 ] && break
    [ -n $record_layer_pid ] && kill $record_layer_pid
    [ -n $play_layer_pid ] && kill $play_layer_pid
  done
}

rm background.wav layer.wav
record_background
main_loop &
main_loop_pid=$!
input
echo true > should_record_layer
wait $main_loop_pid
```

# to conclude

With less than 60 lines of shell, we've made a software pedal with a layer.

With a cheap USB pedal like this which sends a key press, this script is really nice to use:

![timeline]({{"/images/pedal.jpg"|absolute_url}} "pedal")
