---
layout: post
title: The Difference Between Good And Good Enough
permalink: difference-between-good-and-good-enough
date: 2011-03-18
comments: true
categories:
tags:
- Best Practice
- Good Enough
- Programming
---

Quite often we see people talking about the best way to approach a problem.  Usually this involves taking a relatively simple concept and making it fairly complicated to make it as flexible and maintainable as possible.  While I'm all for maintainability, I think that sometimes we miss the point that it all depends on context.  It seems like most people don't understand the difference between `good` and `good enough`.


Part of being a developer is making design decisions based on conflicting goals. Our job is to choose the line that's appropriate based upon our experience and the needs of what we're doing. But there-in lies the problem:  How do we know where that line really is?  How do we know when we've actually reached the point of `good enough`?

<!--more-->


## Understanding the Root Problem

If you don't understand the problem you're trying to solve, how can you **possibly** know if you've solved it?  It's actually more complicated than that, since there are multiple layers involved with understanding a problem.  You can understand the basics of the problem and get by the majority of your career without worrying about anything deeper.  However if you want to be the best developer that you can be, you will likely need to start analyzing the true problem at hand rather than the "surface problem".


To better understand what I'm talking about, let's take an example.  Let's say we are working on a web site.  Our client comes to us and says `"We'd like for our users to be able to register on the site."`  At first glance, we can identify the "surface problem" right away (The "surface problem" in this case it to create a page where users can register).  However the problem goes far deeper than that.  Some questions that come to mind are `"What is the user registering for?"`, `"What should happen after they register?"` and perhaps more importantly `"What does the word 'register' mean in this context?"`.  Remember, the client thinks they know what they want.  It's your job to figure out what they actually need.  If you don't actually understand what they need at a fairly low level, you cannot possibly know if your solution is `good enough`...

## Understanding the Problem Scope

OK, so now we understand the root problem at a fairly low level.  The next step that we need to look at is the scope of the problem.  When I say "scope", I'm talking about the meta-details of the problem (or the details describing not the problem itself, but about the problem).  So if we take our registration example from above, some scope related questions could be: `"Is this a one-off feature, or do you want it in multiple applications?"`, `"What kind of future changes are likely relating to this feature?"` and most importantly `"How important is this feature in relation to the application as a whole?"`.  By understanding the details about the problem as well as the problem itself you're able to actually start making decisions and weighing trade-offs.


The problem's scope is probably one of the most important but also most commonly overlooked steps in deciding if a solution is `good enough`.  After all, if the code is only a stop-gap measure that's going to be replaced in a few weeks, a little bit of technical debt can be incurred by choosing a slightly easier solution over a slightly better solution.  However, anyone with experience will tell you that just because the plan says it will only be in the code base for a few weeks, don't count on things going to plan.

## Understanding the Solution

If you don't understand the solution you're implemented, how can you possibly, in your right mind, consider it `good enough`?  I know that this seems almost too obvious to even state.  But I think that we all have had those moments of `"It works, I'm not sure why, but at least it works!"`  My argument is that it is not enough for a solution to work for it to possibly fit in the category of `good enough`.  You also need to understand **why** it works in order to be in a position to make that decision.  Incidentally, that's also the distinction between decent Unit Tests and good Unit Tests (tests that try to prove that the code works are OK.  Tests that try to prove that the code is correct are far better).

## Experience

A huge part of understanding the difference between good and good enough comes down to nothing more than sheer experience. From my standpoint, that's the biggest -and most important- difference between a seasoned senior developer and a just-out-of-college junior developer.  On the other hand, experience only really matters as long as it's relevant to the problem at hand.  A developer with 40 years of experience writing enterprise financial applications will have very little relevant experience for developing a website.  So the next time you are tempted to jump in and say `"In my experience it should be done this way,"` make sure your experience really is relevant to the problem.

## Common Sense

> `Common Sense: If it takes longer to explain the solution than the problem, maybe the solution is too complex...`

Common sense is something that you simply cannot learn.  Either you have common sense, or you don't.  And if you don't have it, I'm sorry but you're in the wrong industry.  Unfortunately, a [fair](http://thedailywtf.com/Articles/What_Is_Truth_0x3f_.aspx) [bit](http://thedailywtf.com/Articles/YesNo.aspx) [of](http://thedailywtf.com/Articles/Masquerading-as-a-Loop.aspx) [code](http://thedailywtf.com/Articles/Database-Abnormalization-101.aspx) [has](http://thedailywtf.com/Articles/The-Tautology-Type.aspx) [been](http://thedailywtf.com/Articles/The-Int-Divide.aspx) [written](http://thedailywtf.com/Series/CodeSOD.aspx) without any shred of common sense whatsoever.  Even more unfortunate is that the lack of common sense goes both ways.  There's a huge trend in the industry to use a framework for all problems, but is really necessary to bootstrap an entire framework to write a simple script that will be thrown away in 10 minutes anyway (Most will say no, and that's my point)...  A little bit of common sense will go a very long way towards understanding not only your problem, but your solution. 

## Conclusion

> `In theory, theory and practice are the same. In practice, they're not.`



The next time that you want to make a recommendation about how someone else should solve a problem (or judge their solution), make sure that you understand the problem, its scope and that you have enough relevant experience to actually make the suggestion.  Likewise, the next time somebody reviews code that you wrote, make sure that they understand the problem, understand the scope of the problem, understand the solution that you wrote, have the relevant experience to judge your solution and have enough common sense to realize if the solution is really `good enough`.
