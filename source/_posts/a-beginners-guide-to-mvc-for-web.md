---
layout: post
title: A Beginner's Guide To MVC For The Web
permalink: a-beginners-guide-to-mvc-for-web
date: 2014-11-21
comments: true
categories:
- Programming
tags:
- Anti-Pattern
- Architecture
- Best Practice
- Framework
- MVC
- Object Oriented Programming
- PHP
- Programming
- Rant
---
There are a bunch of guides out there that claim to be a guide to MVC. It's almost like writing your own framework in that it's "one of those things" that everyone does. I realized that I never wrote my "beginners guide to MVC". So I've decided to do exactly that. Here's my "beginners guide to MVC for the web":

<!--more-->
## Lesson 1

You don't need "MVC".

There, I said it.

The best advice I can give beginners (and senior people alike) is that you don't need to learn "MVC".

In fact, I think it's bad to learn MVC specifically. The reason is that there are two things that "MVC" means. The pattern, and the concept. Nobody uses the pattern (I'll talk about it in the next section), and everyone uses a different concept. So really, if you learn "MVC", it'll be different from what the person sitting next to you thinks "MVC" is.

That's the first lesson: there is no "one thing" that you can describe as "MVC". It is a collection of concepts.

*Side-note*: I'm going to use `"MVC"` to describe the concept, and `MVC` to describe the pattern. It should be pretty clear which I am talking about at any given time (mostly the concept).

## What Is MVC As A Pattern

MVC is "Model View Controller". It describes a very specific arrangement of the three:

[![MVC](http://4.bp.blogspot.com/-qViNoB3CaeU/VG9t9RXKAaI/AAAAAAAAPUE/tbdf5O-fR3E/s320/MVC%2B(1).png)](http://4.bp.blogspot.com/-qViNoB3CaeU/VG9t9RXKAaI/AAAAAAAAPUE/tbdf5O-fR3E/s320/MVC%2B(1).png)

Each part is responsible for the following:

 * **Model** - Responsible for representing and persisting application data. If you're building a blog for example, this set of objects would represent individual blog posts, and be able to save them to the database (as well as load them). It also issues events when it changes (via the [Observer Pattern](http://sourcemaking.com/design_patterns/observer)).
 * **View** - Responsible for rendering data from the Model to the user. So it pulls the data that it needs from the instance of the model. The other *key* point is that it then binds as an Observer to that model. So any future updates to it will automatically update the User Interface.
    
    It's important to note that the View is the thing doing the rendering itself. It *is* the final output.
 * **Controller** - Responsible for intercepting user interaction and converting it to Model and View instructions. So if the user edits the title of a blog post, the controller sees the interaction, and edits the title in the model.
The pattern is explicitly clear about the relationships of the objects. Controllers update Models, Models tell Views they has been updated, and then the Views pull the new data from the Models and present it.

This sounds easy!

## What Is "MVC" As A Concept

"MVC" is a concept that centers around *separation of concerns*.

What does that mean?

Well, to put it simply, you want to separate parts of your application. Some parts are going to deal with presentation (displaying things to the user). Some parts are going to deal with persistence (storing data in a database). Other parts are going to deal with user interaction (figuring out what to do with the request the user sent). And finally, you have a whole bunch of other things that simply don't fit into the above (such as sending email, logging, etc).

That sounds awfully similar to the description of the pattern, doesn't it?

That's part of the problem, they are quite different.

MVC as a pattern describes the *specific* interactions between each individual layer. Most of which aren't useful for internet usages.

One example in server-side usage, is that the View cannot actually render anything. Since it's on the server, all it can do is output instructions (HTML, or some other intermediary) which the client will then render. This is an extremely important difference because it means that the View cannot be stateful of its representation. Therefore, if the View wants to change something it has already rendered, it cannot. And as such, the entire premise of MVC falls flat.

This means that the Observer functionality, where the View watches the Model, is completely impractical for web requests. That's because the HTTP, and the internet as a whole is stateless.

## It's All About State

MVC is a stateful pattern. It is designed to simplify the management of state across the lifetime of the program. By having events emitted and consumed between the layers, the program can be greatly simplified.

This is incredibly useful for desktop applications.

For web servers though, it's extremely expensive. Because it means we need to either keep every users state alive on the server between requests (a lot of memory wasted, especially for visitors that only make 1 request) or we need to rebuild the state on every request (a lot of CPU wasted reconstructing the state).

So instead, every implementation of server-side "MVC" that I've ever seen removes the state from the equation. They have made "MVC" stateless. So by definition, they can't be using the MVC pattern.

## So what are they using?

Every framework that uses "MVC" that you look at, when you look at how it actually works, will be different.

Every implementation will have different details around exactly what goes where, and how it all relates together.

For example, some will be "controller push", where the controller fetches data from the model and pushes it into the view. Some will be "view pull", where the view gets the model, and fetches the data from it. Some will be "controller push, view pull", where the controller pushes the model into the view, and the view pulls the data it needs. And that's just talking about how data gets into the view. There are other massive differences as well. Just google "thin model vs thin controller" and see how much people disagree on it.

And this is why I say "don't bother learning MVC". There's no "one thing" to learn. And there are far more useful things to spend your time learning...

## The Underlying Lesson

There is a very useful lesson that MVC brings: *Separation Of Concerns*. Meaning that you should separate different responsibilities into different sections of your application.

This is a tenant that comes up in OOP over and over again. We talk about it with [SOLID's Single Responsibility Principle](https://www.youtube.com/watch?v=z_LxkB-Pgf0). Actually, all of the SOLID principles are directly related to separating concerns from one another (all 5 principles are really [just different angles of the same concept](https://yow.eventer.com/yow-2013-1080/the-solid-design-principles-deconstructed-by-kevlin-henney-1386)).

Separation of Concerns is a necessary step in dealing with [Abstraction](http://en.wikipedia.org/wiki/Abstraction_%28computer_science%29).

Instead of latching on to MVC, latch on to abstraction. Latch on to separation of concerns. Latch on to architecture.

There are far better ways to architect and abstract user interaction for server-based applications than MVC.

But more on that in a later post...

## Followups:

 1. [Alternatives To MVC](http://blog.ircmaxell.com/2014/11/alternatives-to-mvc.html)
