---
title: "impress arrows and impress circle"
created_at: 2014-06-04 23:27:22 +0200
layout: post
tags: ['javascript', 'impress.js']
---

I'd like to introduce you to the stuff I've been working on for
the last few weeks or so which are helper libraries on top of
the awesome impress.js.

<!-- more -->

####impress.js####

If you don't know about impress.js, [go check it out know](http://bartaz.github.io/impress.js).

Writing nice presentations with HTML is just really great.
I needed some more stuff so I figured I would share it.

####impress_arrows####

I first needed to add arrows to my presentation.
I then thought I could use it to draw basic graphs.
For example:

{::nomarkdown}
<img src=arrow://http://cdn.rawgit.com/yazgoo/impress_arrow/master/minimal.html#/done width=500 height=200
title=minimal />
{:/nomarkdown}


[Here](https://github.com/yazgoo/impress_arrows) is the project repository.

####arrow images####

I wanted to be able to include presentation in other HTML documents.
Here is how impress arrow allows you to do so (this includes previous graph):

    <img src=arrow://http://cdn.rawgit.com/yazgoo/impress_arrow/master/minimal.html#/done width=500 height=200 title=minimal />

You can use eithere relative or absolute URLs.
Then, issuing a load_images will include those document in your page:

    <script type=text/javascript src=https://cdn.rawgit.com/yazgoo/impress_arrows/master/impress_arrows_all.js>
    </script>
    <script>
    impress_arrows().load_images();
    </script>

####impress_circle####

I also wanted to have a presentation layout with a rotating menu.
That's why I created [impress circle](https://github.com/yazgoo/impress_circle)
(focus on the document below and press space or arrows as you would on a standalone page).

{::nomarkdown}
<img src=arrow://http://cdn.rawgit.com/yazgoo/impress_circle/master/index.html width=740 height=400
title="impress circle example" />
<script type=text/javascript src=https://cdn.rawgit.com/yazgoo/impress_arrows/master/impress_arrows_all.js>
</script>
<script>
impress_arrows().load_images();
</script>
{:/nomarkdown}

What I find nice with impress_circle is that, as for impress.js, this is only HTML.
For example here is part of the previous document source:

    <div class="circle">
        <div data-name="create document">
            <div data-name="stylesheet">
                load the stylesheet
            </div>
            <div data-name="create impress div">
                you can add as many normal impress steps as you like
            </div>
        </div> 

I hope all these can help you in some way.
