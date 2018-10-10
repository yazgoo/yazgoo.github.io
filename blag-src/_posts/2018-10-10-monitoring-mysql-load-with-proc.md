---
title: "Monitoring MySQL load with /proc"
created_at: 2018-10-10 21:22:18 +0100
layout: post
tags: mysql proc linux
---

On a MySQL server, I launched the following command

```sql
load data local infile '/tmp/bar' into table foo.bar;
```

The command was running for quite some time, and I was looking for a fast way 
to know its progress,
withouth having to restart it or reload MySQL server changing some option.

The idea is to find how much of `/tmp/bar` MySQL has read.

First, lets find mysql PID:

```shell
$ pgrep mysql
1337
```

Then, lets find `/tmp/bar` file descriptor in `/proc`


```shell
$ ls -l /proc/1337/fd |grep /tmp/bar
total 0
lr-x------. 1 user user 64 Oct 10 21:55 4 -> /tmp/bar
```

This is file descriptor #4.

fdinfo allows to know more about file descriptor #4.

```shell
$ cat /proc/1337/fdinfo/4
pos:    84443136
flags:  0100000
mnt_id: 650
```

The first line gives us the read position in the file.
We then just have to divide it by the total size of the file:

```shell
$ echo $[$(cat /proc/1337/fdinfo/4|head -1|sed 's/.*\t//')00 \
/ $(ls -nl /tmp/bar | awk '{print $5}')]%
42%
```

So 42% of the file was processed !
