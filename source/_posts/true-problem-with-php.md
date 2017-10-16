---
layout: post
title: The True Problem With PHP
permalink: true-problem-with-php
date: 2012-07-06
comments: true
categories:
- Rant
tags:
- Learning
- Open Source
- Open Standards
- PHP
- Rant
---

There's been a lot of traffic lately about what's [wrong](http://me.veekun.com/blog/2012/04/09/php-a-fractal-of-bad-design/) with [PHP](http://www.codinghorror.com/blog/2012/06/the-php-singularity.html), and counter [posts](http://ilikekillnerds.com/2012/05/php-sucks-so-what/) about how [good](http://fabien.potencier.org/article/64/php-is-much-better-than-you-think) it is. I've even fallen into the fray in an [earlier article](http://blog.ircmaxell.com/2012/04/php-sucks-but-i-like-it.html) trying to step up and defend the language. The problem with almost all of these posts is that they focus on the language itself and what's wrong (or right) with it. This is not one of those posts.
<!--more-->
## The True Problem

The true problem with PHP lies in the community. Not the majority of the community mind you, but the fringes. The core of the PHP community is filled with a lot of really talented and smart developers doing some really amazing things. But on the fringes, there are a lot of people who are writing articles, tutorials, and posts designed to help beginners learn the language (and usually how to program). The problem with this is that the majority of those authors frankly don't have a clue what they are talking about. 

The simple fact that a site like [w3schools](http://w3fools.com/) still exists as a top result from a Google search is proof enough of that point. But if you watch the blog rolls often enough (or reddit), you'll notice that bad advice is all over the place. I've [responded](http://blog.ircmaxell.com/2011/06/in-response-to-building-secured-web.html) to [a few](http://blog.ircmaxell.com/2011/08/security-review-creating-secure-php.html) of them myself. I saw another one [pop up today](http://www.developerdrive.com/2012/07/5-php-security-measures/), and decided that responding isn't worth the effort. People will still write them, and people will still read them. And that's a problem that we cannot ignore.

## Why Is It A Problem?

This is something I've struggled with. On one hand, they have a right to post what they want. Who am I to say that they are wrong. But on the other hand, ignorance tends to cascade. Someone justifies their position by saying "I read it somewhere"... Then they teach that to other people. Before long the misinformation is spread so far that it's almost impossible for someone starting out to tell good advice from poor advice.

Even if we just look at tutorials talking about accessing data from a database, we get loads of bad information. It ranges from [awkward](http://www.developerdrive.com/2012/06/create-your-own-crud-app-with-php-mysql-part-2/) (really poor code structuring and bad practices) to [wrong](http://www.siteground.com/tutorials/php-mysql/display_table_data.htm) (code that literally won't run), and from to [bad](http://www.tutorialspoint.com/php/mysql_select_php.htm) (recommending deprecated functionality like `mysql_\*`) to downright [dangerous](http://www.w3schools.com/php/php_mysql_insert.asp) (code with major security vulnerabilities).

## What Can We Do About It?

Part of the problem there is that there hasn't been a good, authoritative tutorial repository for PHP. There are tons of good blogs or resources out there, but they are buried in the weeds among the bad ones. And even the best authors and sites get it wrong from time to time.

I'm not really a huge fan of the idea that the php.net documentation should contain tutorials and non-language related content. I think the PHP docs are very good, but they are not really conducive to the style of tutorial that I think can really help. However, there is a format that the PHP community could adopt that would solve a lot of these problems. It's the same format that WikiHow adopted: a Wiki...

What I'm throwing out here is a simple idea: to start a core tutorial site as a wiki (perhaps tutorials.php.net). Leverage the community to provide content. Encourage people to post the tutorials to that site. Welcome any PHP related content. Let the community vet the posts, making corrections or pruning content. Over time, and with enough community support, it can become a valuable knowledge base of information.

## What Do You Think?


Is the idea perfect? Absolutely not. Will it solve the problem? Definitely not. Can it help? Maybe, I don't know. The point is that the first step to fixing the problem, is to admit that it's a problem in the first place. I think it's a big enough problem to warrant reaching out to the community to figure out how to solve it.


What do you think? Do you agree it's a problem? Do you have any ideas how we can combat the spread of bad information? Respond on twitter, in a comment or on your own blog!