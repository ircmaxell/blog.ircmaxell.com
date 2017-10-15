---
layout: post
title: Beyond Design Patterns
permalink: beyond-design-patterns
date: 2013-09-18
comments: true
categories:
- Architecture
tags:
- Architecture
- Beyond
- Design Patterns
- Language Agnostic
- Learning
- Library
- Object Oriented Programming
- PHP
- Programming
---

Many people teach design patterns as a fundamental step to Object Oriented Programming. They are so universally seen as important that almost every single conference that I have been to has had at least one talk about them. They are quite often used as interview questions to test a candidate's OOP knowledge. However, just like inheritance, they are not needed for OOP. And just like inheritance, they are a distraction rather than a foundation. Instead of focusing on patterns, I suggest focusing on learning about abstraction and communication. Why? Let's talk it out...<!--more-->
## 
Three Types Of Patterns


In traditional dealings with patterns, we are taught that there are three types of patterns:
 * `**Creational Patterns**` - These deal with object creation.
     * Abstract Factory
     * Builder
     * Factory Method
     * Object Pool
     * Prototype
 * **`Structural Patterns`** - These deal with object architecture.
     * Adapter
     * Bridge
     * Composite
     * Decorator
     * Facade
     * Flyweight
     * Proxy
 * **`Behavioral Patterns`** - These deal with object "communication" or behavior.
     * Chain Of Responsibility
     * Command
     * Interpreter
     * Iterator
     * Mediator
     * Memento
     * Null Object
     * Observer
     * Strategy
     * Template Method

This model seems pretty handy, because if you run into a problem creating new objects, you can check for a Creational pattern that may be appropriate.

Sounds great, right? It's almost like a menu. You look up the problem you're having, and it'll give you a few choices of patterns to use to solve the problem. What could be wrong with that?

Well, let me first propose a different categorization system. Instead of breaking the patterns around "what" the problem is, let's try breaking it around "why" the problem is happening in the first place. So that leaves us with three basic types of patterns:
 * **`Shim Patterns`** - These patterns exist because the underlying programming language can't deal with a situation well. 
     * Flyweight
     * Iterator
     * Null Object
     * Object Pool
     * Prototype
 * `**Compositional Patterns**` - These patterns exist because you have a series of objects which need to be assembled together. (Used When Authoring)
     * Adapter
     * Builder
     * Composite
     * Decorator
     * Facade
     * Interpreter
     * Mediator
     * Observer
     * Proxy
 * `**Decompositional Patterns**` - These patterns exist because you have a single object that you need to break apart into several objects. (Used When Refactoring)
     * Abstract Factory
     * Bridge
     * Chain Of Responsibility
     * Command
     * Factory Method
     * Mediator
     * Memento
     * Observer
     * Proxy
     * Strategy
     * Template Method

Notice that there are a few patterns that live in multiple groups. Memento lives in both Compositional and Decompositional groups. The reason is that it can be useful when building communication channels, and it can be useful in refactoring complex communications as well. And this starts to highlight part of the problem with "traditional" patterns.

Let's create a table to compare the two categorizations:
<table id="matrix"><tr><th> </th><th>Creational</th><th>Structural</th><th>Behavioral</th></tr><tr><th>Shim</th><td>Abstract Factory, Object Pool, Prototype</td><td>Flyweight</td><td>Iterator, Null Object</td></tr><tr><th>Compositional</th><td>Builder</td><td>Composite, Decorator, Facade, Proxy</td><td>Interpreter, Mediator, Observer</td></tr><tr><th>Decompositional</th><td>Factory Method</td><td>Bridge, Composite, Proxy</td><td>Chain of Responsibility, Command, Mediator, Memento, Observer, Strategy, Template Method</td></tr></table><style type="text/css">
#matrix {
 border-spacing: 0px;
 border: 1px solid black;
}
#matrix td, #matrix th {
 border: 1px solid black;
}
</style>

Before we go too much deeper, let's explore four specific patterns.
## 
Adapter, Facade, Bridge and Proxy


If you look at implementations of these 4 patterns, you likely wouldn't be able to tell them apart. Indeed, their UML is identical. They solve the same exact problem. The difference between them is not `how` they solve the problem, but `why` they are solving the problem. Let's explore the standard definitions of each (from [SourceMaking](http://sourcemaking.com/design_patterns)):
 * **`Adapter`** - `makes things work after they’re designed`
 * **`Bridge`** - `makes them work before they are designed`
 * **`Facade`** - `defines a new interface, whereas Adapter uses an old interface`
 * **`Proxy`** - `Adapter provides a different interface to its subject. Proxy provides the same interface.`


Notice that all 4 of these patterns are considered "Structural Patterns". But notice that I've considered two of them (Adapter and Facade) as Compositional patters, Bridge as a Decompositional pattern and Proxy as both.

I think it's worth stressing here that all 4 patterns do **exactly** the same thing. The difference between them is the reason that you apply it. It describes the causation, not the implementation.

Now I'm all for documenting the reasons for writing code, but having 4 different patterns that do the same thing, because there are different reasons to do it? Really?
## 
Implementation Patterns


So let's de-duplicate the list. Let's throw out the Shim patterns, and then we'll pick one of each implementation to show how many `unique` patterns exist:
 * **`Adapter`** - This has a single class which makes one or more other classes behave as a single interface.
 * **`Composite`** - This abstracts a recursive structure.
 * **`Command`** - This abstracts determination of execution from actual execution
 * `**Mediator**` - This abstracts communication between several objects
 * **`Memento`** - This abstracts state representation from execution
 * **`Observer`** - This abstracts communication between two objects


Now, there definite are a few "stretches" in there. Strategy and Command are actually quite different in terms of why they are used. And the implementations `can` look different depending on which object is making which decision. But they are plenty close enough to be lumped together for my purposes here.

There are a few weird things that pop up though. First off, Observer and Memento are different from the rest of the patterns in that they dictate precisely how exactly two objects interact. In the case of Observer, it dictates how one object (the Observer) can be notified of changes by the other object (the Observable). In the case of Memento, it dictates how one object represents the state of another object. But rather than describing systems, they describe the precise relationship between two members.

Continuing on, Mediator and Adapter determine how two different systems can communicate with each other. Finally, Composite and Command determine how a single system actually represent and execute data.

So which pattern you need to choose really comes down to simple questions:
 * Are you dealing with multiple systems? * Do you need an object to control information flow?
         * Yes - `Mediator`
         * No - `Adapter`
 * Are you dealing with a single system?
     * Do you need to represent a complex structure?
         * Yes - `Composite`
         * No - `Command`
 * Are you dealing with communication between two objects?
     * Does one need to respond to changes in the other?
         * Yes - `Observer`
         * No - `Memento`


Now there's obviously a fair bit of hand waving going on here. I expect that anyone who really grasps the difference between Memento and Observer to be screaming right now "that's not how it works!", And yes, I fully understand that. That's also completely missing the point. Stay with me here.
## 
How hard are these problems?


So let's look at the individual problems we've described. And then lets look at the proposed solutions.

The Mediator pattern is intended to have a single object control information flow between several objects. But how? Well, that's up to the implementation to decide depending on business requirements. So what does the pattern actually give us? Well, it suggests having a single object be the "messenger", routing messages between objects... That sounds less like a design pattern, and more like a way to abstract method calls. It sounds like an adapter with some logic under the hood (the fact that Mediators are typically dynamic, where Adapters are typically static can be abstracted away for this argument).

So really, we've abstracted literally a dozen "patterns" down to a single responsibility: `An individual object which controls information flow and messaging between systems`...

We can distill the other patterns down just the same.

At the base level, we're left with 3 responsibilities:
 * **`Controlling Information Flow Between Multiple Systems`**
 * `**Controlling Information Flow Within An Individual System**`
 * **`Controlling Information Flow Between Individual Objects`**

Sounds great so far.
## 
Abstraction Is Everywhere


I've often said that abstraction is a hierarchy with a single "action" (or statement) at the bottom, and an entire platform at the top. In order, it would look something like this (from the bottom up):
 1. `**Statement**` - The atomic unit of abstraction
 2. **`Routine`** - A collection of related statements
 3. `**Class**` - A collection of related routines
 4. **`Package`** - A collection of related classes
 5. `**Library**` - A collection of related packages
 6. **`Platform`** - A collection of related libraries


Note: Its worth noting that I used the term "Platform" instead of "Framework" for the top collection, as a Framework is a collection of libraries which makes architectural assumptions for you. So I think it's important to distinguish the two.

So let's apply those patterns to these layers. We have one responsibility which works on the Library and Platform level. We have another that works on the Package level. And we have one which works on the Class level. Seems straight forward. 

But why do we need to distinguish between the layers of abstraction? Shouldn't a pattern work on pretty much any level? Shouldn't we be able to decouple two libraries by using an library between them? 

In practice, yes we can. And in practice, we do quite often do exactly that.
## 
The Problem With Patterns


Look at the first list on this page. That list had 22 patterns in it. We have just reduced that list to a single responsibility: Abstracting Communication Between "Components". 

Think about that for a second. We just reduced 22 patterns to 1 responsibility. All 22 patterns share the same responsibility. They have the same reason for existing.

So why does the community latch on to them so hard? Well, many people argue that it communicates what code does. If I tell you (vocally or in a comment) "this is an adapter", that should frame what the code is doing pretty well for you. It eases communication. Right?

Well, we've already discussed how there are really only a few unique implementations. So using a specific pattern in describing code describes `why` code was written, not `what` it does or `how` it does it (specifically).

And `why` is a whole lot less important to me than \*`how`\* and `what`. And since the pattern only casually answers either of those (it only saves me a few seconds), I don't think the cognitive overhead lives up to its promise.
## 
Beyond Design Patterns


Instead of focusing on design patterns, I would suggest focusing on understanding how communication between objects and components happens. How does an object "decide" what to do? How does it communicate that intention to other objects. 

Are design patterns useful? Absolutely. But I'll assert that once you understand OOP and object communication, the patterns will "fall out" of the code you write. They come from writing OOP.

So my suggestion is to not worry about `design patterns`. Worry about understanding abstraction and communication. Worry about understanding architectural patterns (Such as described in [POEAA](http://www.amazon.com/Patterns-Enterprise-Application-Architecture-Martin/dp/0321127420)). Worry about communicating `how` as opposed to `why` (only bother with `why` when it's relevant, as in "this is dirty because it's a significant optimization"). 

BTW, we should also rethink OOP. But more on that in a later post... ;-)