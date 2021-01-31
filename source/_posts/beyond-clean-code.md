---
layout: post
title: Beyond Clean Code
permalink: 2013/11/beyond-clean-code.html
date: 2013-11-25
comments: true
categories:
- Programming
tags:
- Beyond
- Good Enough
- Language Agnostic
- PHP
- Programming
- Unit Testing
---

This is the fourth post in my ["Beyond" series](http://blog.ircmaxell.com/search/label/Beyond). The previous three posts focused on re-imagining OOP and questioning some of the core beliefs that we have come to take for granted. This one is going to be slightly different, in that I want to talk about another angle of writing code: the process itself. We always talk about how code should be clean, but how do you write clean code?<!--more-->
## 
What Is Clean Code


Depending on who you ask, and what metrics you use, there are a number of ways that code is judged. Here are a few common ones:
 * Descriptive Naming
 * Code Formatting Consistency
 * Proper Abstractions
 * Readable
 * Clear code flow
 * Good and easy to follow architecture
 * Uses libraries for complex tasks
 * Uses industry-standard best practices
 * Has no security vulnerabilities
 * Short routines
 * Low complexity routines


Etc. You can insert your favorite rules in there...## 
How To Write Clean Code


This is a hotly-debated topic. I think the best explanation of how to write clean code that has been documented to date:<table align="center" cellpadding="0" cellspacing="0" class="tr-caption-container" style="margin-left: auto; margin-right: auto; text-align: center;"><tbody><tr><td style="text-align: center;">[![](http://3.bp.blogspot.com/-lcAjDyJMDzw/UpOnmQVcPyI/AAAAAAAALYQ/Zqf4yEU-z-s/s640/good_code.png)](http://xkcd.com/844/)</td></tr><tr><td class="tr-caption" style="text-align: center;">XKCD 844</td></tr></tbody></table>

Obviously that is a bit of a joke, but it's completely true. Most developers have a very difficult time writing clean code. So how can we do it?
## 
Change The Premise


I'm going to start out by saying something here. Something controversial. Something that may sound odd:
> There are only two types of code, code that delivers business value, and code that doesn't.



As an industry, we have come to value code that looks pretty. We have come to value readability and correctness. But for some reason, we never really talk about the fact that said code needs to deliver business value. The cleanest code that doesn't deliver value is still crap.

I touched on this a little bit 2.5 years ago in my very first blog post on this site [The Difference Between Good And Good Enough](http://blog.ircmaxell.com/2011/03/difference-between-good-and-good-enough.html).

So, if we compare traditional "clean code" metrics with "business value delivery", we wind up with 4 types of code:
<table id="businessvalue" style="border: 1px solid black;"><tbody><tr><th></th><th>Good Business Value</th><th>Poor Business Value</th></tr><tr><th>Clean Code</th><td>Excellent Code</td><td>Bad Code</td></tr><tr><th>Dirty Code</th><td>Good Code</td><td>Garbage Code</td></tr></tbody></table><style type="text/css">
#businessvalue {
    border: 1px solid black;
    border-spacing: 0px;
    width: 100%;
}
#businessvalue td, #businessvalue th {
    border: 1px solid black;
}
</style>

Yes. If code delivers good business value, then it's good code. That doesn't mean we can't improve it. It just means that it is doing what it needs to!
## 
The Next Step


Taking that to the next logical step, it's better to focus on delivering business value than "cleanliness". Focusing on clean will at best leave you with bad code. Focusing on delivering business value will leave to at worst good code...

So, how do we focus on delivering business value?
## 
The DIRTI Method


I focus on delivering business value by writing DIRTI code (pronounced just like Dirty). Here's how it works:
 1. **Develop** - Write the dirtiest code that you can that actually solves the business problem. Don't worry about abstractions or formatting or anything. Just get the code written.
 2. **Isolate** - Isolate the abstractions that you identify in the prior implementation. These will become refactoring points.
 3. **Refactor** - Refactor out the abstractions that you've found, cleaning the code in the process.
 4. **Test** - Once your abstractions are reasonable, start writing tests for them (unit tests).
 5. **Integrate** - Once your abstractions are unit tested, integrate them into your application (with appropriate integration and behavioral tests)

The real beauty of this approach is that it assumes that you **don't** know your abstractions before you start. This will help you understand the problem (and the solution) as you write it.

Contrast this with TDD (Test Driven Development) which really expects that you understand the code you're trying to write before you write it (after all, your test acts like a specification).

This actually takes us to an interesting point. Using the DIRTI method will have two main phases of development: the `DIR` loop, and the `RTI` loop.

Initially, when you don't fully understand the solution, you will develop, isolate and refactor over and over until you fully understand the solution that you're building. Once that understanding solidifies, you're going to tend to spend more time in the later parts (Refactor Test and Integrate).
## 
Why This Works


Why am I sitting here telling you to try the DIRTI method? It works. Why does it work? Well, as alluded to in the last section, the DIRTI method helps you find the code to write. It helps you figure out how to solve the problem.

But most importantly, it gives you the power and the tools to make an informed decision about Good vs Good Enough!

So, remember that code that delivers good business value is good code. So that means that when you leave the `Develop` stage, your code is already ready to deliver business value. It solves the problem at hand!

The entire process is iterative. So you can keep isolating behavior and refactoring over and over until you are happy with the code. But the entire time you're doing that, you're refactoring **working** code. And this is AWESOME! This allows you to consistently judge "Is this code good enough". And once you're happy with it, move it on to the next step.

This lets you focus on what's really important: business value, and lets you choose how much to focus on code quality. It also lets you let the architecture of the code evolve.
## 
Not A Solution, A Tool


I really want to make one point clear. This is not intended to replace TDD or Pair Programming or whatever other methodology you may be using. This is meant to be another tool in your toolbox. Pick which tool to use based on the problem that you're facing...

Do you understand what needs to be written? Then use TDD. Do you understand the problem, but not the solution (at least fully)? Use DIRTI. Do you not understand the problem? Then go back to the business to figure that out!
