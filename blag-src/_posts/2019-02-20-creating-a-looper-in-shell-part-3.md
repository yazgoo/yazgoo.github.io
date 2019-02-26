---
title: "Creating a looper in shell part 3: multiple layers"
created_at: 2019-02-20 21:22:18 +0100
layout: post
tags: shell linux loop
---
# Creating a looper in shell part 3: multiple layers

To understand this article better it is advised to have read the [previous one](../18/creating-a-looper-in-shell-part-2.html).

In the [previous article](../18/creating-a-looper-in-shell-part-2.html), we saw how to add a layer to the loop, here was the script behavior:

![timeline]({{"/blag/images/looper_with_layer_timeline.png"}} "looper with layer timeline")

This aims at adding multiple layers by pressing any key, and being able to remove last layer by pressing `a` (pedal #2).

![timeline]({{"/blag/images/pedal2.png"}} "looper with multiple layer timeline")

# programming pedals

As mentionned earlier, I'm using cheap pedals.

I'm using [footswitch](https://github.com/rgerganov/footswitch) to program pedals.

For example, here is how to get one of them to simulate a `a` keypress:

```shell
$ sudo ./footswitch -k a
```

I'll be using two pedals, one for adding a layer, one for removing last layer.


# Let's add layers

Here are diffs between [last version](../18/creating-a-looper-in-shell-part-2.html) and new one (in red are the old lines and in green the new ones).

<style>
#wrapper {
display: inline-block;
margin-top: 1em;
min-width: 800px;
text-align: left;
}
h2 {
background: #fafafa;
background: -moz-linear-gradient(#fafafa, #eaeaea);
background: -webkit-linear-gradient(#fafafa, #eaeaea);
-ms-filter: "progid:DXImageTransform.Microsoft.gradient(startColorstr='#fafafa',endColorstr='#eaeaea')";
border: 1px solid #d8d8d8;
border-bottom: 0;
color: #555;
font: 14px sans-serif;
overflow: hidden;
padding: 10px 6px;
text-shadow: 0 1px 0 white;
margin: 0;
}
.file-diff {
border: 1px solid #d8d8d8;
margin-bottom: 1em;
overflow: auto;
padding: 0.5em 0;
}
.file-diff > div {
width: 100%:
}
pre {
margin: 0;
font-family: "Bitstream Vera Sans Mono", Courier, monospace;
font-size: 12px;
line-height: 1.4em;
text-indent: 0.5em;
}
.file {
color: #aaa;
}
.delete {
background-color: #fdd;
}
.insert {
background-color: #dfd;
}
.info {
color: #a0b;
}
</style>

Let's modify the input function so that it returns `dd` return code
and so that it sets a variable (`key` with the key that was pressed):

<div id="wrapper">
<pre class='context'> input() {</pre>
<pre class='context'>   stty raw</pre>
<pre class='delete'>-  dd bs=1 count=1 2&gt; /dev/null</pre>
<pre class='insert'>+  key=$(dd bs=1 count=1 2&gt; /dev/null)</pre>
<pre class='insert'>+  rc=$?</pre>
<pre class='insert'>+  [ $rc -ne 0 ] &amp;&amp; return $rc</pre>
<pre class='context'>   stty -raw</pre>
<pre class='insert'>+  return 0</pre>
<pre class='context'> }</pre>
</div>
<div id="wrapper">
</div>


Instead of playing one layer (`layer.wav`), we play a bunch of them (`layer1.wav`, `layer2.wav`, ...) based on `$layer_number` variable.
Instead of returning one pid, we return a list op PIDs.

<div id="wrapper">
<pre class='context'> input() {</pre>
<pre class='delete'>-play_layer() {</pre>
<pre class='delete'>-  play_layer_pid=""</pre>
<pre class='delete'>-  if [ -e "layer.wav" ]</pre>
<pre class='delete'>-  then</pre>
<pre class='delete'>-    aplay layer.wav &amp;</pre>
<pre class='delete'>-    play_layer_pid=$!</pre>
<pre class='delete'>-  fi</pre>
<pre class='insert'>+play_layers() {</pre>
<pre class='insert'>+  play_layer_pids=""</pre>
<pre class='insert'>+  for i in $(seq $layer_number)</pre>
<pre class='insert'>+  do</pre>
<pre class='insert'>+    aplay layer$i.wav &amp;</pre>
<pre class='insert'>+    play_layer_pids="$! $play_layer_pids"</pre>
<pre class='insert'>+  done</pre>
<pre class='context'> }</pre>
</div>
<div id="wrapper">
</div>

We change current layer to record name to `layer${layer_number}.wav` instead of `layer.wav` (after incrementing it): 

<div id="wrapper">
<pre class='context'> record_layer() {</pre>
<pre class='context'>   record_layer_pid=""</pre>
<pre class='context'>   if $(cat should_record_layer)</pre>
<pre class='context'>   then</pre>
<pre class='delete'>-    arecord -f S16_LE -r 48000 -D hw:1,0 layer.wav &amp;</pre>
<pre class='insert'>+    layer_number=$[ $layer_number + 1 ]</pre>
<pre class='insert'>+    arecord -f S16_LE -r 48000 -D hw:1,0 layer${layer_number}.wav &amp;</pre>
<pre class='context'>     record_layer_pid=$!</pre>
<pre class='context'>     echo false &gt; should_record_layer</pre>
<pre class='context'>   fi</pre>
<pre class='context'> }</pre>
</div>
<div id="wrapper">
</div>

We add a function to remove the last layer registered if `should_remove_layer` file contains `true`, by decrementing `$layer_number`:

<div id="wrapper">
<pre class='insert'>+remove_layer() {</pre>
<pre class='insert'>+  record_layer_pid=""</pre>
<pre class='insert'>+  if $(cat should_remove_layer)</pre>
<pre class='insert'>+  then</pre>
<pre class='insert'>+    layer_number=$[ $layer_number - 1 ]</pre>
<pre class='insert'>+    echo false &gt; should_remove_layer</pre>
<pre class='insert'>+  fi</pre>
<pre class='insert'>+}</pre>
<pre class='insert'>+</pre>
</div>
<div id="wrapper">
</div>

We initialize `should_remove_layer` to false, layer_number to 0, and rename `play_layer` to `play_layers` and `play_layer_pid` to `play_layer_pids`:

<div id="wrapper">
<pre class='context'> main_loop() {</pre>
<pre class='context'>   echo false &gt; should_record_layer</pre>
<pre class='insert'>+  echo false &gt; should_remove_layer</pre>
<pre class='insert'>+  layer_number=0</pre>
<pre class='context'>   while true</pre>
<pre class='context'>   do</pre>
<pre class='delete'>-    play_layer</pre>
<pre class='delete'>-    record_layer  </pre>
<pre class='insert'>+    remove_layer</pre>
<pre class='insert'>+    play_layers</pre>
<pre class='insert'>+    record_layer</pre>
<pre class='context'>     aplay background.wav</pre>
<pre class='context'>     [ $? -ne 0 ] &amp;&amp; break</pre>
<pre class='delete'>-    [ -n $record_layer_pid ] &amp;&amp; kill $record_layer_pid</pre>
<pre class='delete'>-    [ -n $play_layer_pid ] &amp;&amp; kill $play_layer_pid</pre>
<pre class='insert'>+    [ -n "$record_layer_pid" ] &amp;&amp; kill $record_layer_pid</pre>
<pre class='insert'>+    [ -n "$play_layer_pids" ] &amp;&amp; kill $play_layer_pids</pre>
<pre class='context'>   done</pre>
<pre class='context'> }</pre>
</div>
<div id="wrapper">
</div>

Instead of waiting for only one input (since there was only one layer), we wait for multiple input in a loop.
If "a" is pressed, we notify that we `should_remove_layer`.
Overwise, we notify that we `should_record_layer`:

<div id="wrapper">
<pre class='insert'>+input_loop() {</pre>
<pre class='insert'>+  while true</pre>
<pre class='insert'>+  do</pre>
<pre class='insert'>+    input</pre>
<pre class='insert'>+    [ "$key" = $'\003' ] &amp;&amp; break</pre>
<pre class='insert'>+    if [ "$key" = "a" ]</pre>
<pre class='insert'>+    then</pre>
<pre class='insert'>+      echo true &gt; should_remove_layer</pre>
<pre class='insert'>+    else</pre>
<pre class='insert'>+      echo true &gt; should_record_layer</pre>
<pre class='insert'>+    fi</pre>
<pre class='insert'>+    sleep 1</pre>
<pre class='insert'>+  done</pre>
<pre class='insert'>+}</pre>
<pre class='insert'>+</pre>
<pre class='context'> record_background</pre>
<pre class='context'> main_loop &amp;</pre>
<pre class='context'> main_loop_pid=$!</pre>
<pre class='delete'>-input</pre>
<pre class='delete'>-echo true &gt; should_record_layer</pre>
<pre class='insert'>+input_loop</pre>
<pre class='context'> wait $main_loop_pid</pre>
</div>
<div id="wrapper">
</div>

# The whole script

```shell
#!/usr/bin/env sh

input() {
  stty raw
  key=$(dd bs=1 count=1 2> /dev/null)
  rc=$?
  [ $rc -ne 0 ] && return $rc
  stty -raw
  return 0
}

record_background() {
  input
  arecord -f S16_LE -r 48000 -D hw:1,0 background.wav &
  pid=$!
  sleep 1
  input
  kill $pid
}

play_layers() {
  play_layer_pids=""
  for i in $(seq $layer_number)
  do
    aplay layer$i.wav &
    play_layer_pids="$! $play_layer_pids"
  done
}

record_layer() {
  record_layer_pid=""
  if $(cat should_record_layer)
  then
    layer_number=$[ $layer_number + 1 ]
    arecord -f S16_LE -r 48000 -D hw:1,0 layer${layer_number}.wav &
    record_layer_pid=$!
    echo false > should_record_layer
  fi
}

remove_layer() {
  record_layer_pid=""
  if $(cat should_remove_layer)
  then
    layer_number=$[ $layer_number - 1 ]
    echo false > should_remove_layer
  fi
}

main_loop() {
  echo false > should_record_layer
  echo false > should_remove_layer
  layer_number=0
  while true
  do
    remove_layer
    play_layers
    record_layer
    aplay background.wav
    [ $? -ne 0 ] && break
    [ -n "$record_layer_pid" ] && kill $record_layer_pid
    [ -n "$play_layer_pids" ] && kill $play_layer_pids
  done
}

input_loop() {
  while true
  do
    input
    [ "$key" = $'\003' ] && break
    if [ "$key" = "a" ]
    then
      echo true > should_remove_layer
    else
      echo true > should_record_layer
    fi
    sleep 1
  done
}

record_background
main_loop &
main_loop_pid=$!
input_loop
wait $main_loop_pid
```
# Conclusion

The whole script is now available [in its own repo](https://github.com/yazgoo/looperish).
Of course, patches are welcome !

I use this script on a daily basis, and there are tons of things that could be polished.
Maybe I'll rewrite it in some other language :)
