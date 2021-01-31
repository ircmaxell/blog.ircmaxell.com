---
layout: post
title: Garbage In, Gold Out
permalink: 2012/08/garbage-in-gold-out.html
date: 2012-08-06
comments: true
categories:
- Programming
tags:
- Anti-Paradigm
- Best Practice
- Good Enough
- Language Agnostic
- PHP
- Programming
---

Every developer who studies computer science (and most who haven't) has heard the phrase "`Garbage In, Garbage Out`" before. It's such a logical concept that it's almost beyond refuting. Almost. While the phrase still definitely holds true for some situations, it doesn't hold for most. How can such a logical and straight forward saying lead us down the wrong path?<!--more-->

## The Truth


The saying originates from a very famous quote by Charles Babbage (mid 1800's):> `Pray, Mr. Babbage, if you put into the machine wrong figures, will the right answers come out?`


This directly led to the saying "Garbage In, Garbage Out". If you supply any algorithm with garbage data, the results are going to be garbage as well. It's only logical. In engineering, the quality of the numbers that you use as input are going to lead to the quality of the output. That's why schools spend a lot of time teaching how to analyze the significant digits of a calculation. That way, you can always know what part of the output you can trust, and what part is going to be meaningless.

If we extend that to development, we can apply it to the routine level. The quality of the output of a specific routine is going to directly effect the quality of the output of that routine. If you want to add 2 + 2, and you feed in 3 and 3 as the inputs, the result isn't going to match what you expect. This much is pure logic. And shouldn't be a surprise for any of you (if it is, you may want to consider another line of work).
## The Fallacy


The problem comes when you try to apply the rule to larger components of a system. Sometimes, it will work. But often, we can extract gold from the garbage. How do we do that? Well, it depends a lot on the nature of the application, and of the garbage. If you ask a calculator what 3+3 is, you'll never get 4 (the answer to 2+2) out. And you shouldn't. But in realistic cases, we're not dealing with such simple input. Let's look at a real world example of garbage in, gold out.

The simplest example is Google. If you mis-spell a Google search, the chances are quite high that you'll still get the correct answer out. If you search for "Drunning Kruger", you'll likely see the first result as "Dunning-Kruger Effect". You asked the wrong question, but got the right answer. This is a best case scenario (simple spelling error) that should be pretty easy to automate. But Google can do far more dramatic corrections. It's able to do this because it uses complex heuristics and personal information to try to determine now what you asked, but what it thinks you meant.
## Identifying Garbage


Another approach to producing gold from garbage is far more applicable to a lot of applications. Google is able to "correct" garbage, because it has a huge knowledge base to look through. But most applications don't have that luxury. Usually, they can take another road. Instead of trying to "fix" garbage, they flag it for their users to correct. By trying to identify garbage to the user, a human can realize their error and recover.

A good example of this is with Microsoft Excel. If you have a column with data in it, and you format that column, it will tell you which data cells contain data that is invalid for that format (or contain an invalid formula, etc). While this seems simple, it's a very important step in producing a useful product to your end users. If you can identify a piece of data as garbage (or even potentially garbage), your users can then attempt to fix it.
## No Silver Bullet


There's no silver bullet here. You may not be able to produce gold from garbage for your particular application. It really depends on the details of your application. But what I would stress, is that you should think about it. Don't just assume that the data is good (or is solid), think how the data could go bad, and how you can detect it. When you're designing your user interfaces and business logic, always think about how you can turn garbage into gold.