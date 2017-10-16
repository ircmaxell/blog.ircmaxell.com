---
layout: post
title: Reinvent The Wheel!
permalink: reinvent-wheel
date: 2012-08-03
comments: true
categories:
- Meta
tags:
- Best Practice
- Good Enough
- Language Agnostic
- Learning
- PHP
- Programming
---

*"Don't Reinvent The Wheel"* is a phrase that we hear used all the time in software development. Usually it's used in the context where a library exists to do what the user wants, but they are writing their own. While the sentiment is usually correct, I can't stand the implication of the phrase. Therefore, I can't stand it when people use that phrase without understanding what it really means. Let me explain:<!--more-->


## What Is A Wheel

The only reason the phrase "*Don't Reinvent The Wheel*" makes sense is that the wheel is assumed to be perfect. So any attempt to re-invent the wheel is doomed to fail, because you can't improve upon perfection. Therefore, you shouldn't reinvent the wheel. The implication that the wheel is perfect is not only justification for the phrase, but it's required by the phrase. If the wheel wasn't perfect, it would absolutely make sense to reinvent it.

## But The Wheel Isn't Perfect!

As it turns out, the wheel isn't perfect. It can be improved upon significantly. The catch is that for a general purpose usage, the wheel is just about as close to perfection as you can get. But not all problems demand a general purpose solution. In fact, for some problems, a general purpose solution is entirely sub-optimal. For example, let's say you had a track that has semi-circular humps as the driving surface. A round wheel would fail, because it would be bouncing in and out of those humps. But a square wheel would instead work much better:

[![](http://upload.wikimedia.org/wikipedia/commons/e/e5/Rolling-Square.gif)](http://en.wikipedia.org/wiki/Square_wheel)

This is a perfect example of where something that's assumed to be perfect fails for a specific use-case. In fact, this isn't just limited to that specific of a problem set. We see it all the time with special use vehicles. Tanks and earth moving machines don't use round wheels, they use tracks (the tracks use round wheels to drive them, but not as the interface between the vehicle and the ground). So we see examples all the time where the wheel isn't perfect (for a specific use-case).

## So Why Does The Saying Make Sense?

If the wheel is obviously not perfect for all uses, why do we still use the phrase "*Don't Reinvent The Wheel*"? We use the phrase because it's a useful abstraction of a concept. If something else exists that's perfect for a particular use-case, why try to reinvent it? Why waste your time searching for a better solution if one that's good enough is there?

## Two Cases Where That Logic Fails

As it turns out, there are two very significant cases where it's not only good to reinvent the wheel, but actually justified. The first is when you're dealing with a problem where a generalized solution just won't cut it. This does happen more often than we want to admit, but not often enough to be the norm. In these cases, it's absolutely worth rewriting functionality to solve a very specific problem rather than dealing with an abstraction.

The second case happens a lot more often. This is when you're just trying to push the boundaries of what's possible for the educational and research perspective. How can you truly understand how the proverbial "*wheel*" works if you've never tried to build one yourself? How can we as an industry ever come up with a better way of doing things if everyone just accepts the status-quo as perfect? If we did, we'd never have any of the advancements that have been made in the past 20 years. 

## Junior Developers Should Reinvent The Wheel

I firmly believe that junior developers, and new developers should absolutely reinvent the wheel. In fact, I would argue that it's a necessary step towards learning generalized concepts. This is one reason that I encourage every junior developer to write their own framework and libraries. Not because they can do better, but because there's so much to learn by writing one that you just won't learn by using a production framework. How can you understand the subtle architecture decisions if you've never tried writing code using that architecture?

Now, I'm not saying that junior developers should go using their libraries for commercial usages. But for their own personal projects, the educational value is immeasurable. There are some lessons that just can't be learned any other way than by either making mistakes or by seeing **why** something doesn't work. And telling someone who's asking questions "not to reinvent the wheel" is doing a grave dis-justice to them and to the community as a whole (which depends on people reinventing the wheel to innovate).

## Complacency Kills

In my fire department days, we had a saying: "*Complacency Kills*". No two calls are ever the same, and if you fall into the trap of "oh, this is just another one of those", you may get away with it 99 times out of a 100. Or even 999 times out of 1000. But eventually, complacency will catch up to you and get you (or worse, others) killed. The best way that we combated complacency was to train. The more we trained, the harder it was to fall into that deadly groove.

As developers, we don't have such a mortal threat from our complacency. Or do we? If we sit back and rest on our prior knowledge without trying to push the boundaries of what we're capable of, we'll become useless. And worse, we'll become those same "old people" that the up-and-comers usually make fun of: "*Back in my day, 640k of memory was more than enough*". Those developers that have stopped trying to push themselves and have fallen out of the times.

What does that have to do with reinventing the wheel? Even as a senior developer, if you never try to reinvent the wheel from time to time, you'll never push your capabilities. You'll never expand your conceptual model of problems. And if you never do that, the world will blow past you. 

## Conclusion

So I say, reinvent the wheel! Reinvent it over and over again. And don't ever tell someone else not to reinvent it. Suggest they use an existing solution if one exists, but don't downtrodden the effort they are putting in. The educational and innovation value of reinventing the wheel is far too significant to undervalue. So encourage people to reinvent the wheel! Otherwise, what's the point?

Questions? Comments? Snide remarks? Comment away, follow up on twitter, or reply on your own blog.