---
layout: post
title: Simple, Easy, Risk and Change
permalink: 2015/11/simple-easy-risk-and-change.html
date: 2015-11-02
comments: true
categories:
- Programming
tags:
- Architecture
- Best Practice
- Beyond
- Framework
- PHP
- Programming
---
I've been thinking a lot about change lately. Things finally resonated to me after listening to [Uncle Bob Martin on No Capes](https://www.youtube.com/watch?v=7gv6oK8nAzE). He made an amazingly interesting point about change and different methods for minimizing the risk over time of change.

I want to share some of what I've been thinking about along those lines. What follows is a collection of some of my evolving thoughts relating to change and complexity. Let me know your thoughts in the comments.

<!--more-->
## Simple vs Easy

A few years ago, Rich Hickey -the creator of Clojure- did a talk called ["Simple made Easy"](http://www.infoq.com/presentations/Simple-Made-Easy). It's an excellent talk, and I highly encourage you to watch it. In the talk, he talks about the difference between simple and easy. One is a measure of complexity, the other of effort.

One of the really interesting takeaways, is that we need to measure complexity separately from the effort that it takes to produce. The reason is that effort is highly coupled to both skill and tacit knowledge about a problem. Familiarity with a code base can significantly reduce the effort required to work on it, but it doesn't affect the code base's complexity.

Quite often in life though, we tend to equate the easy solution with the simple one. *"One line of code is all it takes to do X"*. That seems simple enough, right? Well, if that one line of code causes a significant amount of complexity "behind the scenes", then no, it's not simple. It's easy, but not simple.

Why is this an important distinction? There are a few reasons, but one of the most significant is the [Law of Leaky Abstractions](http://www.joelonsoftware.com/articles/LeakyAbstractions.html). All abstractions leak. That one line of code is by definition a leaky abstraction. So what looks like one line of code today, may in the future require you to know what's going on behind the scenes because it's an imperfect abstraction.

Another significant distinction is that all abstractions require assumptions. And when the abstraction is "easy", it's easy because many of those assumptions are hidden away from you. This leads to coupling your code base to hidden assumptions which often will have very significant maintenance overhead in the future.

## Change and Risk

All change introduces risk. Period. The amount of risk that is introduced does vary wildly with each change. Are you changing well understood code? Are you changing simple code? Are you changing well tested code? Are the changes well peer-reviewed?

Change is so risky, that decades ago we started writing software in a manner that reduced the amount of change we would have to do. We built plugin systems. We built configuration files. We built hooks and event systems to try to isolate change to minimize risk. We made principles like Open/Closed to encourage building for minimal change. All in an effort to minimize risk.

All of these practices increase complexity significantly. In many cases, it's nearly impossible to understand exactly how these pluggable systems work due to this unbounded complexity. The Drupal community even built plugins to help understand the complexity of the plugin system (there's a bit of irony for you).

There is a better way of handling risk that actually results in *reduced* complexity instead of increased complexity. It's something that many people have been advocating for years. It's something that many people practice today. It's called: Testing. Specifically Unit Testing, but all forms of testing are a risk reduction tool.

With a well tested code base, the risks associated with making a change are drastically reduced. The fear of change is all but eliminated. If you practice TDD, it even encourages you to change your code at every step in the way.

So why do we fear testing? Many of us are quick to say *"testing? we don't have time for that!"*. Yet we spend countless hours building pluggable and over-abstracted systems. Why do we waste our time building event-based and pluggable systems that are **MUCH** harder to understand rather than starting off with a simple system and testing it?

## Optimizing for Simple

I think the reason is that we've trained ourselves to optimize for Easy. If you look at frameworks and libraries, they try as hard as possible to make themselves easy to use. They use the term "easy" as a tag-line. And they do so for good reason (marketing).

When you optimize for "easy" it becomes trivial to say *"well, I don't need a test here, the code is too hard to test"*. When you optimize for "easy" you can fall into the trap of saying *"this is just glue code, it doesn't need a test"*. And if you let yourself get away with not testing one part of a system, it gets easier to justify not testing another part.

All the while, the complexity introduced by all of these hidden assumptions keeps building up (after all, it wouldn't be easy if it made those assumptions apparent). And building up. And building up. Until you realize that you can't make the change you want because some hidden assumption prevents it.

Or worse, one of those abstractions leaks in the wrong way, and all of a sudden you're left with a code base that's failing **and you don't know why**.

And worst of all, you've let yourself get away without testing everything properly and therefore can't change the situation to make it better without taking on *yet more risk*. It's a vicious cycle.

When you optimize for simple, clarity is king. Magic is the enemy. That doesn't mean there isn't complexity, but it means that complexity is never introduced to enable change. Instead, we allow change, we embrace change. But we do that responsibly through the use of testing.

## Hard Is Relative, Complex Is Not

This is one of the fundamental problems that I have with modern web application frameworks. They focus on the easy/hard distinction. They very rarely focus on the simple/complex distinction.

A simple example is the way many PHP frameworks have adopted "Dependency Injection" (not to be confused with actual Dependency Injection, which has almost nothing to do with what they are doing). Almost every single framework today has a "DI Container" and some way of configuring that container.

Why change code if you need to change a dependency, just change a YAML file and regenerate the container! Easy, right?

But what if instead of using this complex system, we just created a series of functions? Real code that you can debug and understand. Simple:

```php
function makeFoo(): Foo {
    return new Foo();
}
```

Need a dependency? Then wire it up:

```php
function makeBar(Foo $foo = null): Bar {
    return new Bar($foo ?: makeFoo());
}
```

Want to share instances? Then only call that function once!!! Simple. We were able to avoid a few thousand lines of code and an amazing amount of complexity by simply trusting each other.

## Focus on Simple

Many people will look at the last statement I wrote and say *"but I don't trust the other programmers to do it correctly, I need my container to prevent them from making multiple instances"*.

Stop doing that.

Defensive programming is just another way of introducing complexity to avoid change and reduce its risks.

Instead, empower developers. Give them the tools to embrace change. Give them the tools to do it safely. Focus on Simple, don't fall into the trap of Easy. After all, change is our friend. Without it, we can never move forward.




