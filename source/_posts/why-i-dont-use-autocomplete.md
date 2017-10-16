---
layout: post
title: Why I Don’t Use Autocomplete
permalink: why-i-dont-use-autocomplete
date: 2011-07-26
comments: true
categories:
- Meta
tags:
- Best Practice
- Language Agnostic
- Programming
- Rant
---

Today’s IDEs (Integrated Development Environments) provide a lot of features that make development significantly easier.  From error checking and debugging to intelligent syntax highlighting and refactoring, there are a significant amount of time saving features available.  One of these commonly loved features I have disabled, and found it has made my life easier as well as the code I write better.  The feature I am speaking of is autocompletion…
<!--more-->

## What is Autocomplete?

In a sentence, autocomplete (also known as code completion) is basically just predictive guessing on the function/method/variable you’re typing.  So if you type `str_` in a function context, it will give you a set of defined functions that match that prefix (str_replace being one of them).  The concept is that you wind up having to type less, and don’t need to know what to type before you type it (as the IDE will give you options to choose from).  

It’s often used with object oriented programming where the consumer of an object doesn’t know the methods that are available.  Once you type the object operator `$foo->`, the IDE will try to determine what’s publically available and show you a list of options.  For more on what it is, I'd suggest reading the Wikipedia entry on [autocompletion](http://en.wikipedia.org/wiki/Autocomplete).

## The First Flaw in the Logic

Autocompletion is not an aid to make it easier to write code.  It does not do that.  What it does actually do is make it easier to architect code.  Writing code is easy; all it involves is writing text.  Any trained monkey can write code.  Deciding what to write is decidedly harder.  That’s the true task that programmers do.  Following from that assertion, writing code and deciding what code to write (designing or architecting) are distinctly separate tasks.  Therefore you should not decide what to write as you are writing code.

It turns out that this is a primary tenant of a fair number of programming paradigms such as test driven development, behavior driven development, extreme programming, design driven development, etc.  You should write code to solve a problem, not to figure out how to solve the problem.  My philosophy is that you should write a whole method at one point in time.  Think about what the method should do, think of how it should do it and only when you understand both should you write the first line of code.  

By developing in this manner, you’ll never write a single line of code that you don’t understand.  And you’ll never wind up in a situation of “it works, but I’m not sure why”.  Writing code in this way will yield cleaner, better structured and more maintainable code in the long run.

Using autocompletion is the antithesis of this approach to writing code.  It lets you design and decide what to write as you write it.  In fact, it doesn’t just let you do that, it encourages you to do that. 

## The Law of Demeter

The [Law of Demeter](http://en.wikipedia.org/wiki/Law_of_Demeter) (The Principle of Least Knowledge) says that an object should only talk to its immediate friends (see the Wikipedia entry for more about it).  That means that if your object has a dependency on another object, you should only call methods and access properties on that object itself, not on any return value of the object.  So code like `$obj->getSomeObject()->doSomething()` violates the Law of Demeter.  

The reason that I bring this up is that autocompletion knows about more than an objects friends.  It knows about everything.  So a feature makes it easier to violate the principle and write tightly coupled code.  Now sure, turning off autocompletion won’t prevent you from violating the Law of Demeter, but it does make it every so slightly harder.

## The Real Reason

This is the same reason that I don’t use Google Instant Search:  I actually think before I start typing.  I know what I want to type before I starting typing it.  Features such as Instant Search and Autocomplete serve to simply distract me from what I’m primarily trying to do: express my thoughts into typed content.  I know what I want to write, so let me write it.  Don’t pop up annoying windows to distract me.  Don’t try to guess what I’m saying.  And most of all, don’t slow down the interface by doing complex lookups trying to figure out what I mean (NetBeans, I’m looking at you).

So I disable autocomplete because I see it as a distraction.  Sure, it does have uses in some cases, but the majority of the time it does nothing but vie for my attention with my current task at hand (writing working code).  

## I Am Not Suggesting

I am not suggesting that you are doing something wrong if you use autocomplete.  I’m not suggesting that everyone go out and turn it off.  I turned it off, and I found that my productivity and the quality of my output has increased.  You may or may not experience the same results.  But be sure that if you do use autocomplete that you’re not leaning on it as a crutch.  Be sure that you’re not deciding what to write as you write it.  And be sure that you are structuring your code well, and not just using a method because the IDE tells you it’s available.

Like any tool, the tool itself is neither good or bad, it’s how you use it that makes all the difference.
