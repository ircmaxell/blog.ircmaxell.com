---
layout: post
title: Thoughts On Space Shuttle Code Process
permalink: thoughts-on-space-shuttle-code-process
date: 2012-08-08
comments: true
categories:
tags:
- Best Practice
- Code Review
- Good Enough
- Language Agnostic
- PHP
- Rant
---

Today's post is in response to an article that I read yesterday entitled [`They Write The Right Stuff`](http://www.fastcompany.com/28121/they-write-right-stuff). It's a very interesting and insightful look into one of the most complex and critical pieces of software ever produced (also one of the most expensive). I think we can learn a lot from what they are doing, but I also think we should avoid copying what they are doing. The point that's missed is practicality.<!--more-->


## The Cost Of A Bug


When you're dealing with a $1.7 billion dollar ship, with a launch cost of nearly $450 million, the cost of a bug in the wrong place can be enormous. A non-trivial bug could scrub the mission (costing $450 million), or at worst the ship ($1.7 billion, and far more critical the lives of the 7 to 8 people on board). With costs so high, the quality demands on the software are severe. 

Contrast that to the average web application, where the cost of a single bug may be a few lost customers. And that's even stretching it. For a site the scale of Amazon, a bug may cost a lot more (potentially into the millions of dollars). But for the average site, it's likely only a few dollars to a few thousand dollars. And that's for a bug in a critical system. For bugs in non-critical systems (such as a wish list), the cost may be completely negligible.

When the cost of a single bug can be in the billions of dollars, it's worth spending a few million dollars per year to try to keep the software completely bug free. The cost of a bug far exceeds the expense in locating and eliminating them. But for the average web application, it's likely not worth the time and effort to eliminate all of the bugs before entering production.
## Not All Bugs Are Created Equal


This is completely common sense, but not all bugs are created equal. The way I see it, there are basically three classes of bugs in an application * Critical - Prevents the primary use of the software (not being able to check out from Amazon)
 * Major - Interferes with the primary use of the software (not being able to search Amazon)
 * Minor - Interferes or prevents other uses of the software (wish list not working on Amazon)

I used Amazon here, as it's a defined application that most people have experience using. It's absolutely worth a significant amount of time and effort to prevent all critical defects from entering the system. It's worth a significant amount of time and effort to prevent most major defects as well. And it's not worth that much time trying to prevent minor defects.

The reason is simple. It would be silly to spend a million dollars trying to prevent a defect that could cost you ten dollars. At some point there's a tradeoff where the cost to finding and fixing the defect in production is less than the cost to try to find it before release.
## It's Heresy!


Yes, I just said that releasing with bugs is ok, and actually makes business sense. I'm sure some of you testing fanatics have already stopped reading at that line, but for the rest of you I'd like to make an important point. Tests are not perfect. Just because you have 100% unit test coverage doesn't mean that your code is error free. In fact, a lot of times those tests can actually test for the existence of a bug. So nothing that I've said so far is actually saying you shouldn't test you code. Nothing is saying that even the most minor subsystem shouldn't have good unit tests.

Instead, what I am saying is that those very same unit tests won't catch most bugs. They will catch the simple ones. They will catch the isolated bugs. But they won't catch integration level bugs (where you're testing the integration points of multiple units). And they won't catch system level bugs (design flaws). That's why most companies have human quality control in addition to the automated testing. That's where NASA's procedures come in to play (manual code review, extensive testing, log analysis, etc).

So as counterintuitive as it may seem, releasing code with bugs in it may be more beneficial and better business than releasing perfect code. The exact tradeoff point depends on the specific application. And that's what we need to realize. That we need to understand what's an acceptable level of quality, and making sure to hit that mark.

Have a question that you want me to answer? Have a topic you want to hear me rant about? Shoot me the idea at `ircmaxell **[at]** php **[dot]** net`, and I'll see if I can answer it!

## Edit


It appears that I didn't quite make clear my point about unit tests. I'm not saying that they don't have value. I'm not saying that they shouldn't be used for low value software. What I'm saying is that they are not designed to catch most bugs. They are designed to make software that is easy to test. They are designed to catch architectural bugs. They are designed to make refactoring and changes safer.

What they are not designed to do is catch design related bugs (since it's only testing the implementation, not the requirements). It's not designed to catch edge-case bugs (although well designed unit tests often do). Even with excellent coverage, there's no replacement for a formalized quality control process with human testers. Bugs they find should be converted to automated tests (for regression tests), but usually the bug is found first, and then the test is written (the opposite of normal TDD).
