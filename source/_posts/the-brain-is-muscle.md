---
layout: post
title: The Brain Is A Muscle
permalink: the-brain-is-muscle
date: 2012-12-24
comments: true
categories:
tags:
- Language Agnostic
- Learning
- Object Oriented Programming
- PHP
- Programming
- Video
---

The brain is a muscle, and as all muscles, it needs regular exercise to keep sharp. Or at least that's what the old adage says. This is a post that I've been meaning to write for a long time now, but never got around to (until now that is). Sparked by a twitter conversation with Mr Grumpy himself ([Chris Hartjes](https://twitter.com/grmpyprogrammer)), I decided that the time was right for it. So, here's my method for staying sharp and exercising my brain...
<!--more-->

## Revisiting Simple Problems


One of the most effective ways of exploring your skills and advances in your programming ability is to constantly revisit some relatively simple programming problems. When I say simple, I don't mean simple to solve, I mean simple in the sense that you can write the code to solve them in about 20 minutes to 2 hours. So we're not talking about building a full-stack framework (although that wouldn't quality as "simple" either), but reasonably easy to understand problems.

Here are a few of the ones that I do regularly:
 * `Fizz Buzz` - [Fizz Buzz](http://content.codersdojo.org/code-kata-catalogue/fizz-buzz/) is a pretty standard exercise in the programming world. It's trivially easy to solve (if it takes you longer than about 5 minutes, step back and think about it), but it's surprisingly difficult to solve cleanly...
 * `Prime Factors` - Write a program to find the [Prime Factors](http://en.wikipedia.org/wiki/Prime_factor) of a given integer. It's pretty easy to do with brute forcing, but writing an efficient algorithm takes some time, patience and practice.
 * `Shunting Yard Math Parser - `The [Shunting Yard algorithm](http://en.wikipedia.org/wiki/Shunting-yard_algorithm) is a reasonably easy to understand algorithm for parsing and interpreting mathematical formulas (`2 + 3 \* 4`). One reason that I like this one, is that while it's really straight forward, it can be rather tricky to make a good object oriented design out of.
 * `BrainFuck Interpreter `- [BrainFuck](http://en.wikipedia.org/wiki/Brainfuck) is an esoteric language that's actually quite simple to parse and execute. This is a nice challenge because it's quite straight forward, with the exception of parsing the loop/if structures (which can present challenges).
 * `Maximum Path Sums` - This is a [Project Euler](http://projecteuler.net/problem=18) problem. It's really easy to brute force. It's also really easy to do an efficient algorithm once you see the trick. But to write clean and efficient code (both CPU and Memory efficient) is non-trivial.


Now, an important thing to talk about is what I mean by `regularly`. I try to revisit each one of those problems (and more) at least once per year. I will also revisit them when I learn about a new programming method or design technique. I use them to "practice" the new technique and see how it fares. I also save the old versions so that I can go back from time to time and watch how my coding style is progressing over the years.
## BrainFuck


I personally like the BrainFuck problem for a few reasons. First, it's a fun language to write in (it really requires rethinking how you approach programming and structuring your program). Second, it can be written in as little as [2 lines of (really obscure) code](http://j.mearie.org/post/1181041789/brainfuck-interpreter-in-2-lines-of-c). Third, it's really easy to understand the concepts of the language (and its semantics), even if reading existing code is near imposible.

I recently revisited the BrainFuck interpreter in PHP. I did a screen recording of the process from start to finish. And I also pushed each stage to GitHub so you can follow along. The whole process took about 2.5 hours, so I cut a lot of the sequences shorter, and only provided a high level narrative. The final video is about 17 minutes long, and moves pretty fast (but any slower and I feared it would be pushing the boring boundary a bit too far)... Here it is on [YouTube](https://www.youtube.com/watch?v=s3CncuzRzFA) (Make sure to watch it in full screen):
<iframe width="525" height="295" src="http://www.youtube.com/embed/s3CncuzRzFA" frameborder="0" allowfullscreen=""></iframe>

You also can follow the GitHub activity here: 1. Commit [295b](https://github.com/ircmaxell/PHP-BrainFuck/commit/295b0d4b9749c5bcccbe56171068ba0159c6af79)
 2. Commit [05ce](https://github.com/ircmaxell/PHP-BrainFuck/commit/05cec05a6e3ac140d4cb0b94f1acba41e31e5842)
 3. Commit [2739](https://github.com/ircmaxell/PHP-BrainFuck/commit/27393466603c24add41c1b38de376e82fa5c0880)
 4. Commit [7d00](https://github.com/ircmaxell/PHP-BrainFuck/commit/7d0058bb968bd752b1f8818a08c27705127d8f2f)
 5. Commit [2669](https://github.com/ircmaxell/PHP-BrainFuck/commit/2669358302c7874dd59abb9b265c665fa7ac1cf4)
 6. Commit [f4a2](https://github.com/ircmaxell/PHP-BrainFuck/commit/f4a28d57f2a55dfbd308fe68ebb01eec8a9ed9d3)

## What Do You Do?


Do you have any problems that you revisit to stay "sharp"? How do you fight off the cobwebs and keep your "basic skills" up to snuff? 

If you liked the video and/or this post, please like and/or share it. It took a LOT of work to record and edit it together (more time then I've spent on the entire [Programming With Anthony](https://www.youtube.com/playlist?list=PLM-218uGSX3DQ3KsB5NJnuOqPqc5CW2kW&feature=view_all) series to date). So sharing would mean a lot to me! Thanks!