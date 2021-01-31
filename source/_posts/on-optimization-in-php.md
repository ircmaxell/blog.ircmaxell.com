---
layout: post
title: On Optimization in PHP
permalink: 2011/08/on-optimization-in-php.html
date: 2011-08-09
comments: true
categories:
- Performance
tags:
- Best Practice
- Language Agnostic
- Optimization
- PHP
- Rant
---

When it comes to optimization, there are two competing viewpoints in the PHP community.  Some say that optimization should only ever be an after thought and to avoid premature optimization at all costs.  Others will say that this is impractical, and you should make your application fast as you write it, since then you won’t have to go back and clean it up to make it faster.  While I can understand the viewpoints of both sides, I am firmly in the former category. Given the number of discussions that I’ve had as of late on the topic, I’ve decided to write a post as to why I believe my viewpoint is better and more sustainable in the long run.

<!--more-->
Let's start off by taking a look at one of my favorite quotes on Optimization:
> `Code should run as fast as necessary, but no faster; something important is always traded away to increase speed`. - R. Pattis

As you may have gathered from some of my other posts, I'm a big proponent of readable code.  To me, maintainability is FAR more important than performance.  The reason for that is simple, some of the qualities that make code clean, also make it slower to execute.  By breaking your code into multiple clean routines and classes, you're adding a fair bit of overhead to function calls and stack frames.  That's not to say it's impossible to write clean and fast code, it's just a great deal harder to do than writing either clean or fast code.  In my experience, it's often a trade-off between the two...

## The 90/10 Rule

> `There is a famous rule in performance optimization called the 90/10 rule: 90% of a program's execution time is spent in only 10% of its code. The standard inference from this rule is that programmers should find that 10% of the code and optimize it, because that's the only code where improvements make a difference in the overall system performance. But a second inference is just as important: programmers can deoptimize the other 90% of the code (in order to make it easier to use, maintain, etc.), because deterioration (of performance) of that code won't make much of a diffence in the overall system performance.` - R. Pattis

It's kind of odd to think that we might want to intentionally slow down a piece of an application.  But given that there is a trade-off between clean and fast, we can make that trade-off intelligently based upon the criticality of the code.  If we stopped here, it may seem like premature optimization is actually a good thing, as long as it's for a piece of code that you think will be critical.

## The Critical 10%



So that brings us to another point: unless we have a working system, how can we know which is the critical 10% of the code?  Where should we focus our efforts in making code fast before we complete it?  You could make a gamble and guess which areas are critical.  Even if you have a high success rate, you're still setting yourself up for disaster because how can you know if you got it right?  Are you going to go around de-optimizing that code to see if it makes a big difference?  Likely not.  So now you're left with an application that has optimized code that you're not sure is even necessary.  When it comes time to maintain that code, you'll be paying a price.


The better way would be to build the code as clean and maintainable as you can, completely ignoring performance concerns.  Then, once it's working, profile the application.  If it's fast enough as it sits, then you're completely done.  If it's not, then profile to determine which parts of the code are too slow (and contributing the most towards the slowness), and optimize only those parts.  That way, when you're done, you have maintainable code everywhere you can, and optimized code only where you really need it.  And you know that the optimized code is really necessary...  After all:

> `The greatest performance improvement of all is when a system goes from not-working to working`. - John Ousterhout

 If you prematurely optimize your code, you're actually optimizing a system that doesn't work.  Working and slow will `**always**` be better than not working and fast.  Focus on writing working clean code, and leave the optimization for after the code is working.


## The 60/60 Rule

> `Fully 60% of the lifecycle costs of software systems come from maintenance, with a relatively measly 40% coming from development. That is an average, of course. The actual cost of maintenance may vary from 40% to 80%, depending on the system type and the environment it is deployed into. During maintenance, 60% of the costs on average relate to user-generated enhancements (changing requirements), 23% to migration activities, and 17% to bug fixes.` - [David Wood](http://programmer.97things.oreilly.com/wiki/index.php/The_60/60_Rule)

Basically, maintenance will be the biggest expense a software project will incur.  Based on that, the biggest cost saving measure that you can make in writing code, is making your code maintainable.  Don't worry about speeding up development time, as it's usually a fairly small portion of the overall cost and time.  Focus on making maintainable code, and you'll be better off in the long run.

## But What About Muscle Memory?



One of the arguments that I've heard people give in relation to why they optimize as they write, is that they do it out of instinct.  In other words, they don't think about it, it's just muscle memory.  To that, I would argue three things.  First, if you're not thinking about the code you are writing, why are you writing it?  It's my belief that every single line of code that you write should be well thought out and implemented because it fits, not because you just typed it.  So if your argument is that you don't have to think about making the optimizations, I'd argue that you have bigger issues with how you write your code than premature optimization.


The second argument against muscle memory comes from the fact that optimization is not an easy problem to deal with.  Sure, you could say that "`function x is faster than function y, so I avoid function x`".  I would then say that the two functions are for different purposes, and should be used as such.  Don't just make blind distinctions like that, it won't work.  Write code that is correct, and then only optimize later if necessary.


The third argument is simple.  Some people will say that common sense things such as not running database queries in a loop is an "optimization".  I would argue that not putting queries in a loop is not an optimization, but the proper way of writing code in the first place.  So that doesn't really qualify as a muscle memory optimization, it's more simply using the correct architecture and clean code.  Sure it does have a performance benefit, but that's not the primary reason you should avoid those kind of code constructs.

## But Benchmark X Says Y Is Faster!



There's a funny thing about benchmarks that's often overlooked: they lie.  Well, not exactly a lie, but close enough for us to consider them lies.  What is a benchmark supposed to prove?  Not that operation X is better than operation Y.  All a good benchmark does is say that given a number of assumptions (usually a large number), operation X appears to be better than operation Y.  If you violate a single one of those assumptions,  the benchmark (and its results) go out the window. 


A good example would be using single quotes with concatenation in PHP is slightly faster than double quotes when benchmarked.  It's true, but based on what assumptions?  One of those assumptions is that you're not using something like APC which includes a second-pass optimizer which actually makes basically equivalent.  Another example would be saying ``$array === (array) $array`` is faster than ``is_array($array)``...  Sure, for small arrays it is (since it avoids the function call).  But for larger arrays (even as small as 10 elements) it becomes significantly slower since it requires a full memory copy of the $array variable.


Never trust benchmarks.  And don't benchmark your own pieces of code unless you really know all of the assumptions that you're making.  Instead, profile your working application.  If you're profiling properly, you should be able to tell the constructs that are causing you difficulty quite easily.  Once you have identified them, create a benchmark that will carry the assumptions that your code is making to the benchmark.  Only then can the results of the benchmark be trusted and used successfully.

## Tying It Together



The best way I can sum up this article is with a single quote:
> `It is easier to optimize correct code than to correct optimized code. Premature optimization actually hinders optimization in the long run. Unnecessary optimization distorts designs, destroys modularity and information-hiding, and makes code much harder to modify. Latent bugs take longer to find. We often discover by profiling, or by changing machines or compilers, that we misjudged the computational effort of our code. Guess what? Now, optimization is much harder than it had to be.` - [Bill Harlan](http://billharlan.com/pub/papers/A_Tirade_Against_the_Cult_of_Performance.html) 

Value maintainability over all else.  After all, it's likely significantly cheaper to throw hardware at a problem than it is to spend a significant amount of time trying to optimize the code.  But it will always be cheaper in the long run to invest time to making code maintainable than it will be to make it fast.  After all, a good developer may run you over $100,000 per year (on the medium to low end), but adding another server will likely only cost you $5,000 per year (on the high end).  Which would you rather save?  Spend a lot of developer time reducing hardware costs?  Or spend that same developer time reducing developer cost in the long run (due to maintainability improvements)...?
