---
layout: post
title: On Templating
permalink: 2012/12/on-templating.html
date: 2012-12-10
comments: true
categories:
- Programming
tags:
- Object Oriented Programming
- PHP
- Programming
- Templates
- Unit Testing
---

I've been playing around with tempting engines a lot lately. For a recent project, I needed the ability to re-use the same template set in both JS and PHP (coupled with the History API, providing seamless dynamic behavior, yet still having raw content pages). Realistically today, there's only one choice for that sort of requirement: [Mustache](http://mustache.github.com/). I've learned a lot while playing with Mustache, and it's really changed my entire viewpoint on presentation layer construction.
<!--more-->

## The Past


If you would have talked to me two years ago, I would have told you that I felt that templating engines are overkill in PHP, and that you should just use raw PHP instead. My rationale was that the templating engine (such as [Smarty](http://www.smarty.net/)) gives you SO little that it's hard to justify both the performance degradation and the different syntax. At that point, templating engines didn't even really escape variables for you (you had to append a weird filter to each variable). After all, what benefit did using the template engine give you other than syntax?

Then came [Twig](http://twig.sensiolabs.org/). I saw the auto-escaping feature and was instantly sold. Finally, a solid reason to use templating engines over raw PHP. While I didn't quite 100% leave raw PHP templates, I started recommending that people use Twig. It had nice syntax and nice code. And best of all, it was simple!

But then, over the recent months, I started to notice that what was once a very simple templating engine has grown out. Now, it supports all sorts of features. It supports hooking into the parser to define your own DSL (Domain Specific Languages). It supports multiple inheritance. Now, maybe it supported all of this before hand and I just didn't see it. But it feels like even Twig is too heavy and cumbersome...

Another thing to consider is that I never unit tested the presentation layer of my applications. I have always found it to be a PITA, accounting for layout changes, etc. So I would implement what amounted to behavioral tests using Selenium (or other tools). But I never was happy with them. They were always the most fragile layers in the test suite. And they never really got me anything except for a small bump in test coverage.

## Enter Mustache


I had played around with Mustache before on side projects, but never used it for anything serious. Then very recently, I pulled it in to work on a new application. My initial impression was that it was a pain in the neck to use. After all, the ONLY logic that you have to work with is a foreach loop and an if-but-not-really-an-if structure (in fact, they are the same operator)... Due to this limitation, the data that you feed into the template needs to be structured in a very specific way. Seems quite limiting...

I came to an interesting realization though. Since the template itself has **no** logic, it becomes nothing more than a transform. And if it's just a transform, there's nothing `TO` test in it. Instead, I put all of that logic that would have gone into the template back into a view object. And guess what? That view object is actually quite easy to unit test! My coverage increased, but better yet, the quality of the tests themselves improved drastically!

## Not A Tool, An Approach


There's an important point here: the tool isn't what helped me. It only showed me the path. The thing that got me the benefit was the realization that the template is just a data transform. Now Mustache enforces that constraint, but there's nothing to say that you can't do it with any other tool.

The approach here is simple: separate a view into an object and a template. The object runs the logic needed (pulling data from models, formatting it, and any other presentational logic) and then passes that data into a template. The template simply acts as a data transform, taking an array of one format, and producing output in a different one. That's it.

## Wrapping Up

The take-away here is pretty simple: if you're doing anything in a template that's not a simple for or an if, then it doesn't belong in a template. You're calling functions? You'll lose the benefits of abstracting the presentation. You're not testing the presentation layer at all? Shame on you. You're not escaping the output? Bad developer, no donut.