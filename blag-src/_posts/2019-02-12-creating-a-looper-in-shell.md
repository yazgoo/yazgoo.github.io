---
title: "Creating a looper in shell"
created_at: 2019-02-12 21:22:18 +0100
layout: post
tags: shell linux loop
---

On my free time I like to play the guitar.

I have a descent microphone, and I'd like to be able to loop a part and then play over it.

Here is a script to do just that.

First, let's create a function which will wait for any key to be pressed:

```bash
input() {
	stty raw
	dd bs=1 count=1 2> /dev/null
	stty -raw
}
```

Then let's call it:

```bash
input
```

Then let's start recording.

arecord is configured for my mic (which is on hardware device 1,0).

This also runs the command in the background and keeps its pid:


```bash
arecord -f S16_LE -r 48000 -D hw:1,0 out.wav &
pid=$?
```

We wait one second (to avoid double taps to be taken into account),
and wait for a key to be pushed again:

```bash
sleep 1
input
```

Then we stop arecord via kill:

```bash
kill $pid
```

We then can play the recorded file in a loop, 
and break the loop when aplay return code is not 0 (which happens when you it Ctrl+C)

```bash
while true
do
	aplay out.wav
	[ $? -ne 0 ] && break
done
```

Here is the whole script:

```bash
#!/usr/bin/env sh

input() {
	stty raw
	dd bs=1 count=1 2> /dev/null
	stty -raw
}

input
arecord -f S16_LE -r 48000 -D hw:1,0 out.wav &
pid=$!
sleep 1
input

kill $pid
while true
do
	aplay out.wav
	[ $? -ne 0 ] && break
done
```

For now I can use an additional keyboard as a poor's man pedal, here is how to use it:

  - launch the script
  - push a key to start recording
  - push a key to stop recording and start playback
  - hit Ctrl+C to stop playback

I like this script as it is super useful and really simple !
