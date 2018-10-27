---
title: "Querying CSV with SQL with q"
created_at: 2018-10-27 21:22:18 +0100
layout: post
tags: sql csv shell q
---

Have you ever needed to explore CSV files in your shell ?

I've always found it quite painful.

You usually have to :

- find the data you need (usually with `grep`)
- extract it (e.g. `cut -d, -f1`)
- then do aggregations with it

(You could also use [csvkit](https://csvkit.readthedocs.io/en/latest/) to do all these).
Wouldn't it be nice if there was an integrated way to get data from those
multiple tabular data sources and aggregate them ?

Sounds familiar ? Yep, SQL does that.

[q](https://harelba.github.io/q/) is a command line tool that does exactly
that for CSV files.

Let's explore what it can do on concrete examples.

# installing

- install [q](https://harelba.github.io/q/install.html)
- `pip install csvkit` to display CSV with csvlook

# finding

# aggregating

# merging

# customizing it
