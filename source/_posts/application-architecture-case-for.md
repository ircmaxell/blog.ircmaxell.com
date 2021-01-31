---
layout: post
title: Application Architecture - The Case For Layers
permalink: 2012/06/application-architecture-case-for.html
date: 2012-06-07
comments: true
categories:
- Architecture
tags:
- Architecture
- Design Patterns
- Framework
- Language Agnostic
- Library
- PHP
- Programming
---

Very often when we look at a class diagram for a new application, it's quite overwhelming. There are tons of classes, all interacting with each other. These interactions are everywhere. It actually resembles a spider web of interaction. Trying to decode this web to figure out what the application is doing can be a lesson in futility for some applications. 
[![](http://sonivis.org/wiki/images/thumb/4/40/ClassDiagram.png/800px-ClassDiagram.png)](http://sonivis.org/wiki/images/thumb/4/40/ClassDiagram.png/800px-ClassDiagram.png)
How then, can we design an application such that it's easy to follow? How can we build an application that's easy to understand on all levels? The answer is deceptively simple: by using layers. Let's explore how we can use layers to help build our applications in a clean, easy to follow and maintainable manner.<!--more-->
## The Layer


So the easiest way to start this journey would be to describe what a layer really is. Well, when we are talking about layers here, we're really talking about Abstraction Layers. Wikipedia describes [Abstraction Layers](http://en.wikipedia.org/wiki/Abstraction_layer) as:> `<span style="background-color: white; font-family: sans-serif; font-size: 13px; line-height: 19px;">An </span>**abstraction layer**<span style="background-color: white; font-family: sans-serif; font-size: 13px; line-height: 19px;"> </span><span style="background-color: white; font-family: sans-serif; font-size: 13px; line-height: 19px;">is a way of hiding the implementation details of a particular set of functionality.</span>`


So, what the heck does that mean? Basically, it just means that a layer represents functionality, but hides how it's implemented. That way, we can work with the abstract concept of the functionality without having to worry about how it's actually implemented. The important thing to note is that there's no mention of what the layer is actually made of, except the funky term `implementation details`... There's a very good reason for that.## The Fractal Of Abstraction


Good abstractions follow a fractal pattern. That is to say that no matter how you zoom in or out, it looks very similar. That means that routines (methods and functions) abstract statements. Classes abstract routines. Packages abstract Classes. Libraries abstract Packages. And both Applications and Frameworks abstract Libraries. And so on.

But there's another dimension to the abstraction: detail. You can have low level libraries which interact with individual sub-systems (such as a database or filesystem), and you can have high level libraries which work with lower level libraries. One key point here is that the two types of abstractions are independent. A single class can abstract an entire low level library (such as in a [facade pattern](http://sourcemaking.com/design_patterns/facade)).

For the purposes of this article, we're only going to focus on the detail oriented abstraction layers. The other method (class to library relationships) will automatically be structured correctly if we structure our detail abstraction layers properly. So let's look at how these detail abstraction layers should depend on each other...## The Dependency Direction


One of the keys to good application architecture is to manage the dependencies of the components of the application. In this case, we're not talking about managing class dependencies, but managing an abstraction layer's dependencies. There's a very basic rule that will almost always lead to a solid application architecture:> Abstractions should only depend upon abstractions at a lower level than itself, and only very rarely on an abstraction at the same level.


If you expand that logic out a bit, you can clearly see that an abstraction should **never** depend upon an abstraction layer above itself. And if you follow this simple rule, more often than not a clean and easy to maintain architecture will evolve in your codebase. But I'm going to extend that slightly to be even better:> A particular abstraction should only ever depend on a single layer of abstraction that's below its own layer, and only rarely at the same level.


This is the real key to abstraction layers. Each layer should only depend upon a single other layer. Now, it can depend on multiple components of that other layer. It can depend on multiple different abstractions at that same level. But it should not depend on multiple layers. If you can do that, something very interesting will happen.## The Not So Hidden Structure


If you've followed along so far, you should see a picture starting to form. It should look really like a tree. Each layer depending upon layers below it. Each layer below it depending on layers even further below it. And so on. And so on. Something like this:[![](http://cia.sourceforge.net/legacy/apidocs/com/hack23/cia/web/viewfactory/api/admin/com.hack23.cia.web.viewfactory.api.admin.png)](http://cia.sourceforge.net/legacy/apidocs/com/hack23/cia/web/viewfactory/api/admin/com.hack23.cia.web.viewfactory.api.admin.png)

The beauty of this structure is that it's incredibly understandable. And the reason for that, is that each abstraction layer can be isolated from every other one above it without doing `anything`. So if you want to see how a Session package works, all you need to focus upon is the session layer and its dependencies which are always at or lower than itself. You can ignore the higher components of the application, since the dependencies are only ever one-way. 

This is an extremely powerful concept that should not be undervalued. One of the common criticisms of this style of design is that it tends to produce a lot of classes all over the place. That's completely true. But because those classes are organized into layers and each layer completely abstracts what it's supposed to be doing (it's responsibility), we can ignore the vast majority of them at any one point in time. 

If you're looking at a session class, you shouldn't have to worry about how it works to work with it. That's an implementation detail that's below the abstraction. All you need to know is the details of that layer of abstraction. How it works internally, and how it works with its dependencies is moot. Additionally, if you need to debug a problem, you can debug at the problematic layer without having to worry about the rest of the application.## The Hidden Benefit


There's another hidden benefit to structuring your application in this manner: Refactoring becomes really easy. If you decide that you have too many layers (because of performance problems, or other reasons), you can easily collapse layers. The reason that it's easy, is that the dependency is always downward. So if you eliminate a layer, you're just changing the dependency of the upper layer. You don't have to worry about ripple effects, since an upper level abstraction can't impact a lower level one.

Conversely, if you need to refactor out an additional layer, you can just split the existing layer in two into an upper and a lower level. The lower would connect to the existing dependencies, and the upper would connect to the new lower layer. If you keep the upper level the same, then you don't even need to change the layers that depend on the refactored layer!## The Approach


If you've followed this far, and what I've said has resonated, you may be able to guess at what I'm going to say next. Following this approach, Object Oriented Architecture ceases to focus around objects and classes. Instead, the focus becomes the abstraction layers that make up the application. By treating these abstraction layers as first class, instead of an afterthought, objects themselves become little more than an implementation detail. In fact, they become an unimportant detail. So much so, that they can be replaced with any other construct: functions and procedural constructs.

For this reason, I am going to coin a new term for this approach: > `Abstraction Oriented Architecture`


Realistically, it allows for a cross paradigm architecture that's really easy to understand, really easy to maintain and most importantly really easy to implement.

Give it a try, and let me know what you think! Feel free to leave a comment, post on twitter or follow up in your own blog post...