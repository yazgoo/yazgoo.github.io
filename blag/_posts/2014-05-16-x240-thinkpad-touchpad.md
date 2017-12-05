---
title: "X240 Thinkpad touchpad"
created_at: 2014-05-26 21:22:18 +0100
layout: post
tags: thinkpad x240 touchpad
---


Out of the box, the suport for x240 touchpad under Ubuntu is poor.
Here is what I did to fix it, based on [this article](
        http://mydevelopedworld.wordpress.com/2013/11/30/how-to-configure-new-lenovo-x240-touchpad-on-ubuntu-13-10/).

<!-- more -->

####The problems####

The touchpad is in only one part (it's also called a clickpad):

![clickpad image]({{"/images/clickpad.png"|absolute_url}} "clickpad")

On ubuntu, by default, there are problems with it:

  1.  When you click, you move the mouse.
  1.  Right click is configured on the lower right corner: 
     I would expect it to be on the upper right one.
  1.  There is no middle click.


####The xorg synaptic configuration####

The file we'll be editing is: 
`/usr/share/X11/xorg.conf.d/50-synaptics.conf`.

So you should back it up.

####Fix with no explanation####

Here is a summary of the fix (if you want explanations, skip this part):

In this section:

    Section "InputClass"
            Identifier "Default clickpad buttons"

replace: `Option "SoftButtonAreas" "50% 0 82% 0 0 0 0 0"`

with: `Option "SoftButtonAreas" "65% 0 0 10% 35% 60% 0 10%"`


And in the same section, add: `Option "AreaTopEdge" "10%"`

Then restart Xorg: (e.g. `sudo service lightdm restart`).  
You're done.

To sum it up, here is a diff (run `patch 50-synaptics.conf $with_this`):

    34c34
    <         Option "SoftButtonAreas" "50% 0 82% 0 0 0 0 0"
    ---
    >       Option "SoftButtonAreas" "65% 0 0 10% 35% 65% 0 10%"
    37c37
    < #       Option "AreaBottomEdge" "82%"
    ---
    >         Option "AreaTopEdge" "10%"


####Fixing the click problem#####

in the following section:

    Section "InputClass"
            Identifier "Default clickpad buttons"

We have to update the SoftButtonAreas field which has height parameters.
From `man snyaptics`:

    Option "SoftButtonAreas" "RBL RBR RBT RBB MBL MBR MBT MBB"

    This option is only available on ClickPad devices.
    Enable soft button click area support on ClickPad devices.
    The first four parameters are the left, right, top, bottom edge of the right button, respectively,
    the second four parameters are  the  left, right, top, bottom edge of the middle button, respectively.
    [...]
    If any edge is set to 0 (not 0%), the button is assumed to extend  to  infinity 

Here is the initial value: `Option "SoftButtonAreas" "50% 0 82% 0 0 0 0 0"`

So the right button is starting at half the left of the clickpad and starting at 82% of its top.
Also, the manual states that:

    Setting all values to 0 (not 0%) disables soft button areas.
    test

So the middle button is disabled.
So here is the right click zone (clicking anywhere else is considered as a left click):

<div style="width:520px; height:370px; background-image:url('{{"/images/clickpad.png"|absolute_url}}')">
<div style="position:relative; left: 50%; top: 82%; width: 42%; height:16.65%; background-color: green; border-bottom-right-radius: 10px; opacity: 0.8;">
</div>
</div>

Say we want the right button to start at 65% of the left and stop at 10% of the top.
If we want the middle button to start at 35% of the left and end at 10% of the top, here is what we should write:


`Option "SoftButtonAreas" "65% 0 0 10% 35% 65% 0 10%"`

The resulting zones are (blue is middle click, green is right click):

<div style="width:520px; height:370px; background-image:url('{{"/images/clickpad.png"|absolute_url}}')">
<div style="position: relative; float: left; left: 38%; top: 6%; width: 27%; height:10%; background-color: blue; opacity: 0.8;">
</div>
<div style="position: relative; left: 65%; top: 6%; width: 26%; height:10%; background-color: green; opacity: 0.8;">
</div>
</div>

####Do not move the mouse while clicking####

Again from the manual, there's this option:

    Option "AreaTopEdge" "integer"

    Ignore  movements,  scrolling  and  tapping  which  take  place above this edge.

So we'd like enable that below the buttons which are located at 10% of the touchpad.
So let's add:

`Option "AreaTopEdge" "10%"`

Then, restart Xorg: (e.g. `sudo service lightdm restart`).  
We're done.
