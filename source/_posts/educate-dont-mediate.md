---
layout: post
title: Educate, Don't Mediate
permalink: educate-dont-mediate
date: 2014-10-20
comments: true
categories:
- Rant
tags:
- Best Practice
- Education
- Good Enough
- Learning
- Meta
- Philosophy
- PHP
- Rant
---
Recently, there has been a spout of attention about how to deal with `eval(base64_decode("blah"));` style attacks. A number of posts about ["The Dreaded eval(base64_decode()) - And how to protect your site and visitors"](http://www.totalcomputersusa.com/2012/05/evalbase64_decodehardening-php-how-to-protect-your-site-and-your-visitors/) have appeared lately. They have been suggesting how to mitigate the attacks. This is downright bad.
<!--more-->


## Mitigation As A Solution

The problem is that these posts have been suggesting things like "Disable `eval()`" and "Disable `base64_decode()`" as possible solutions. And while tecnically that would work, it completely misses the point, and does nothing to protect users.

## The Real Problem

The real problem is that an attacker managed to get code onto the filesystem. The fact that they used eval just obfuscates that fact. They could write an arbitrary payload, and still be able to do anything they wanted. Disabling `eval()` doesn't fix the vulnerability. It just masks it.

## The proper solution

The proper solution is to fix the vulnerability that allowed an attacker to inject code in the first place. That's the only way to actually fix the issue.

The problem is that there's no easy way to fix arbitrary vulnerabilities. It requires looking deep into the code and the problem at hand to figure out what to do. So instead of suggesting how to properly fix the problem, people suggest workarounds or "quick fixes".

## The Cancer

This is a pervasive problem that goes far deeper than just software blogs. It's embeded in our society. It's pervasive. It's killing us, without us even realizing it.

We tend to favor quick solutions instead of actually understanding the problem or putting the effort into the proper solution. Entire industries are built on this mentality. And it's killing us slowly (or quickly, who knows).

Need to build a website? Just use WordPress!

Need to encrypt some data? Just use XYZ library!

Need to store data in a database? Just use an ORM!

If you undestand why, that's fine. But if not, it's just a band-aid on a gunshot wound.

## The Simple Solution

There is a very simple solution (conceptually at least). As the title of this post implies, don't go for the mediating "quick fix". Instead, go for education instead. It's not easy to do. It requires effort on everyone's parts. But it's the right thing to do.

If you educate people, you only need to do it once. If you mitigate, you need to do it every time (and it likely won't work in the first place). It's the proverabial:

> *Build a man a fire, and keep him warm for a night. Set him on fire, and keep him warm for the rest of his life.*

Wait, no, that's not right... What about this one:

> *You can give a man a fish, and feed him for a day. Or you can teach the man how to fish, and feed him for life.*

Ah yes, that's the one.

## The Deeper Problem

The deeper problem is that, as a society, we've been shunning education in favor of letting it be someone else's problem. I'm not talking about college education, I'm talking about education as a whole.

If a student gets a bad grade in school, it's either the student's fault or the teacher's fault. If someone comes into a community and doesn't know the rules, they are the bad one. If someone doesn't know that `md5()` is bad for passwords, oh the humanity!

In reality, people learn in different ways. Perhaps the fault wasn't the teacher's nor the student's. Perhaps it was just that the student wasn't inspired. That's not to say that the teach was bad. It's to say that the teacher wasn't a right fit for this particular case.

## Motivation

Motivation, I think, is the key. We tend to learn **significantly** better if we are motivated. And I'm not talking about the "do this or else" motivation. I'm talking about that spark, that self-motivation that we get when we're interested in something.

But how do you motivate someone who doesn't want to be motivated?

How do you educate someone who just wants an easy solution? A short cut?

The only answer I have is: *By Trying To*.

It's not the easy answer. It requires a lot of effort. But it's worth it.

And if you take the effort to teach someone, every once in a while, that person will take the effort to teach someone else. That passion will multiply and thrive...

So next time someone asks you a simple question, don't just give them the short-cut, but take the time to teach. Take the time to educate.

