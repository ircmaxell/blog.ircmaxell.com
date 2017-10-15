---
layout: post
title: Framework Fixation - An Anti Pattern
permalink: framework-fixation-anti-pattern
date: 2012-07-27
comments: true
categories:
tags:
- Anti-Paradigm
- Anti-Pattern
- Architecture
- Best Practice
- Framework
- Language Agnostic
- Library
- Micro Framework
- Object Oriented Programming
- PHP
- Programming
---

In this day in age, it seems that the community trend is completely and unequivocally trending towards the use of web application frameworks. So much so that the defacto first comment to someone asking how to do something seems to be `"Just use a framework, and it'll solve the problem for you." `While I completely understand why this is the case, I can't say that I agree with it. And while I do believe that frameworks serve a purpose, I think that they are vastly over-used. Let me explain why...<!--more-->

## What Is A Framework


For the purposes of this post, I'm going to define a framework in the context of why it exists rather than what it does. But to really explain the difference between a framework and a set of libraries, let's start off at the lowest level and work our way up. * **Class** - A single "unit" of functionality. I think most of us understand what a class is used for, so I won't elaborate too much on this.
 * **Library** - A collection of one or more classes that are designed to work together to accomplish a single "purpose". An example of a library would be PDO, as it is a series of multiple classes (and accompanying code) that work together to solve a common problem.
 * **Libraries** (or Collection of Libraries) - A collection of one or more libraries that are designed to work together in a more generic sense (not for a single purpose, but for a more general usage). An example of a Collection of Libraries would be the PEAR repository. For the most part, the member libraries in the collection are designed to work together in a similar fashion.

Based on those building blocks of terminology, we can then take a first stab at a definition of a framework: `A framework is a collection of libraries that makes architectural decisions for a user`. In this context, we're talking about `"architectural decisions"` as to how you structure your application, and how the major components should interact. While that's a better definition in that it delineates frameworks from libraries, I'm not sure that it grasps the difference clearly. So let's stop looking at what the library/framework does, and instead look at the relationship between it and your code.

The relationship between a library and your application is quite clear. Your application is the process-space, and you dispatch to a library for a specific task. The library may in turn dispatch some of your code, but usually it's self contained. Now, when it comes to the relationship between a framework and your code, the line gets a lot more muddy. With most frameworks, the framework is actually the process-space. Your index.php file loads the framework, not your code. The framework then in turn loads your code and dispatches to it. Then you will likely hand control back and forth over the lifecycle of the application, with the framework's code ending the execution.

Of course this is a bit of a generalization, but the overall point stands. So, with that in mind, we can now better our original definition of a framework:
> `A framework is a collection of libraries that work together to form a scaffold for an application, making architectural assumptions in exchange for solving common problems.`

## Why Would We Want To Do That?


The first question that should come to mind when reading that definition is `"Why would we want to make any assumptions?"`... Well, as it turns out, in exchange for those assumptions we do get a good amount of gain. By structuring the application the way the framework wants to, we can ignore the application architecture. We can skip all of the setup, bootstrapping and structuring phases of development and get right to solving the business problems. After all, that's what programming is all about, right? Solving problems...?

## The First Flaw In The Logic


The first (and potentially biggest) flaw in that line of logic is that it makes a damaging assumption. The simple line of `"we can skip all the setup, bootstrapping and structuring phases of development and get right to solving problems"` has a major flaw. It implies that those first three phases of application development aren't important. It implies that business problems are separate from the application's architecture. It implies that all (or even most) business problems can be solved using the same architecture.


Now, I'll admit that last implication is a bit loaded. Most business problems **can **in fact be solved using the same architecture. That doesn't mean that they **should **be solved with the same one though (meaning that it's not an optimal solution).

## The Big Benefit


So, if most problems shouldn't be solved with the same architecture, why would we ever want to use a framework that makes those decisions for us? Well, as it turns out, a lot of the software that we write doesn't really matter to the business. We're either doing a proof-of-concept, a prototype, a one-off project that isn't going to be maintained or even a small helper application that solves such a narrow use-case that it's not worth investing a significant amount of time or energy.


Those cases are where frameworks really pay off. In fact, when Ruby on Rails was originally designed, rapid prototyping was the original use-case. So if it has that many benefits, then we should use a framework on all projects except really big and really important ones. Right?

## The Flaw In That Logic


As it turns out, most of what I said just there was not really true (did I trick you?). While it is true that a fair number of development projects are small and not valuable to the business, they usually don't start out that way (If they did, the business likely wouldn't invest the time and effort into developing them). And those that do start off small and not valuable turn out a lot bigger and a lot more valuable to the business over time. So at the start of a project, it's quite difficult to understand the long term impact (and value) of a particular project. So to say that a project is big and important is nothing more than a guess (likewise, saying a project is small and not valuable is a guess as well).


As anyone who's done a lot of prototypes will tell you, often enough what starts out as prototype code very rapidly turns into production code. It's a common tale. A prototype is shown to a vice president, who likes it. He (or she) likes it so much that they want it yesterday. All of a sudden, throwing away the prototype is not an option because there's just no time to rewrite what was already written (talk about a catch-22). So the legacy assumptions that went into the prototype wind up haunting the production application for years.

## Another Benefit


Another really common benefit of using a framework is that it greatly speeds up development time. Let's be honest, formal architecture steps of an application take time. A lot of time. On the order of weeks to months depending on the scale of the project. So by using a framework, you can skip all of that time, and get straight into solving problems. So for smaller projects, it could save over half the development time! Sounds great, right! That saved time turns into saved money.

## Yet Another Flaw


So that sounds great on the surface. But as soon as we look at that figure, we realize that it's not really the case. Before we talk about why it's a flawed argument (saving money), we should talk for a second about architectural flaws. When you build an application that has a flaw in its architecture (meaning that the architecture is incorrect for the problem), the flaw usually doesn't impact primary development significantly. Usually the flaw manifests itself as [technical debt](http://blog.ircmaxell.com/2012/03/power-of-technical-debt.html) later on in the application's life-cycle. This usually results in moderate to severe maintenance difficulties, rendering certain bug fixes and most change requests almost impossible to accomplish (in bad cases).


So, if architecture flaws typically manifest themselves later on in the application's life-cycle, who cares? We're still saving money in the short-run, right? Yes. But only in the short run. According to the [60/60 Rule](http://programmer.97things.oreilly.com/wiki/index.php/The_60/60_Rule), at least 60% of all development costs will be incurred post-deployment. And 60% of those costs will be incurred due to changing requirements (post deployment). So the initial development is only (at best) 40% of the costs of a project. But changing requirements will cost at least 36% of the projects overall cost.


So saving money during initial development` at the expense of long term maintainability` is incredibly short-sighted. Now, I italicized that text for a reason. Not every method of saving money on initial development will have a negative effect on long term maintainability. And to the point of this post, the assumptions made by a framework may not be wrong for an application (and hence won't have a significant long term increase in cost).

## It's Easier To Find People


Another strong argument for using a framework is that it's easier to find people who can work with a popular framework than a custom solution. So if you need to build or expand your team, using a framework makes it easier to find people that can get right in and start working. It also lowers the barrier to entry when working with the application, meaning that new developers on the project need to learn less to understand how it works. Since there are more people available who know a specific framework, there are more options (and options are good).

## Again, The Flaw


The flaw here is revealed when we examine `why `using a framework makes it easier to find developers. There are two main reasons that I have come across. The first is that weaker developers are more likely to lean on a single framework. This biases them towards that framework, and weakens their ability to understand and solve general problems. So while there are more people who say that they have experience in a particular framework, a non-insignificant percentage of them are really just weak developers who are looking for a crutch.


The second flaw comes from examining why a new project is difficult to pick up. When we pick up a legacy project, the first thing we need to do is understand the application's architecture. This usually involves a lot of documentation reading (at best) and code browsing. Where when a framework is used, that part can be skipped. But remember that the framework's architecture may be sub-optimal for the problem. So if you just use a framework and skip the normal architecture step, you're just repeating the same mistake over again. You're making it potentially easier for some developers to come up to speed at the expense of the maintainability of the application. That doesn't sound like a good trade-off to me...

## But The Framework Developers Are Smarter Than You!


I've heard this as a justification for using frameworks for a long time. And every time that I hear it, I have the same reaction:` That's BS`. It's a classical [Appeal to Authority](http://en.wikipedia.org/wiki/Appeal_to_authority), basing a decision on the presumption that someone else is smarter than you. There are quite a few reasons why this is a bone-headed rationale for using a framework.


First of all, there's nothing that says someone who writes a framework is indeed smart. If we look at the popular software out there, a lot of it is based around crappy code. The reasons that it became popular are as varied as the projects, but it's often not because the code is good. Usually it's because they were in the right place at the right time (Ruby on Rails), or took a different angle on the problem as a whole (Wordpress). But that in itself doesn't make the person smarter than anyone else.


Second (and just as important) is that "smart" is relative. The art of development is so varied and complex that even the most seasoned and smart developer will come across problems they have never seen before. Problems that people a lot more junior (or a lot less smart) may have seen before. So while in aggregate a person may be smarter, for a particular problem that may not mean a whole lot. With the teams that I've worked with, I've learned something significant from each and every member of the team (from the most junior and inexperienced to the most senior and experienced). So just because someone is a thought leader, doesn't mean that for a particular problem set that they are going to come up with a better solution (statistically they will, but not necessarily on a single problem).


Finally (and perhaps the most important) is that using a tool because you believe the author is smarter than you is a cop-out. It's a way to pass on the responsibility for understanding the complex task of writing the application onto someone else. That's never good. Take responsibility for yourself, and use a tool because you think it fits the problem, not because you think the person who wrote it is smart. Even the smartest people out there has dumb and braindead ideas from time to time. It's up to the person using those ideas to determine if they are good for the situation or not...

## Are You Confused Yet?


Up to this point, I've given three strong reasons that you should use a framework for application development, and I've given you three strong reasons that you shouldn't use a framework for application development. Did I just contradict myself? Nope.


The question of whether or not you should use a framework for a particular project is a very complicated one. It significantly depends upon the nature and purpose of the application that's being built. So a general "yes" or "no" answer will **always** be wrong. Further complicating that is that each framework takes their own spin on the architectural problems they try to solve. So while one problem may be very suited to a framework like Zend, another may be very suited to a framework like Symfony.

## How I develop Applications


I have used frameworks in the past (and will again in the future) for problems that I felt the framework made sense to use. But the majority of the applications that I write now are (in my judgement) better suited to a formal architecture and design step. That's not to say that the architecture I come up with won't align with an existing framework (it does happen from time to time). And when it does align, I can just use the framework, but I know that the framework is suited to the application.


So, what about when I don't use a framework? Well, it's actually pretty simple. I use libraries to do all the heavy lifting for me, and just write the code that I don't have a library for. So I'm building the core of the application, and leveraging available libraries to fill in the gaps. Typically, this involves writing a custom front-controller, router and the bootstrap sequence. Sometimes I need to write the application layer from scratch and sometimes I can leverage an existing library to do it for me. But in my experience, it tends to result in a far more robust application over time putting the extra energy into the start.

## Framework Fixation Is A Problem


So, finally we can get to the heart of this post. I believe that the trend in the industry (at least from reading blogs and answers on Stack Overflow) is towards using a framework for all development. This is the same trend that we saw in the JavaScript community towards jQuery (incidentally, I believe that if it wasn't for node.js, javascript wouldn't be nearly as popular as it is now). People stop thinking about how to solve the problem generically, and start thinking about how to solve the problem with the framework. It's an [inner-platform effect](http://en.wikipedia.org/wiki/Inner-platform_effect) if there ever was one.


If you're an `"x"`<span style="background-color: white;"> framework</span>` `<span style="background-color: white;">developer, you're doing it wrong. Be a developer. The framework should be nothing more than an implementation detail. If you understand application architecture, switching between frameworks should be a trivial task. And if you devote the time to understand the architectural assumptions that each framework makes, you'll be able to make an informed choice when the time comes. So yes, if you specialize in a single framework, you're definitely doing it wrong (flamebait, I know).</span>
<span style="background-color: white;">
</span>

Then again, I truly feel that if you only develop for one language, you're also doing it wrong. You can't make a well-rounded decision if you don't understand other platforms. If the only tool you have is a hammer, every problem will look like a nail. And that's the problem with most frameworks. They encourage developers to look at all problems as nails. If they didn't, the phrase` "Just do it the Rails way"` wouldn't exist...

## The Root Of The Problem


The root of the problem with the way a lot of people use frameworks is that they treat them like magic boxes. They don't understand the framework's architecture decisions. They don't understand what's going on behind the scenes. They don't understand **why** a decision was made. So when they get backed into a corner where the framework doesn't appear to be doing what they want, they wind up having to rewrite a significant portion of the application. Where if they really understood what was going on, the change would likely be a lot simpler.


And that's the real issue. If you don't understand a tool, then don't use it (when I say understand, I mean understand to the point where you could write your own version of the tool). That's why I think that people writing their own framework is a very good thing. It's a very healthy learning process. Write your own so that you can understand what goes into writing one. Then use one that's out there. But don't just adopt a framework because it scaffolds for you. Don't just use it because it's easy. Use it because it does what you can do so that you don't have to do it.
[![](http://1.bp.blogspot.com/-iPmH2SsqRJ4/UA9NxX6rxAI/AAAAAAAABCc/cXopE7cuHPE/s1600/well_slide2.png)](http://xkcd.com/568/)
## The PHP Community Needs To Step It Up


The community right now is so focused on framework development, that it's quite hard to find quality libraries out there. PEAR sucks (the majority of it is **garbage**, and the few good libraries there usually have fubar conventions, especially around error handling). Composer is a decent step forward (in this respect), but finding and vetting libraries with it is no easy task either. With so much effort going into framework development, I wonder what will happen to the individual libraries that are so desperately needed.


Now, with that said, almost any framework can be used as a collection of libraries (those with sane dependency management at least, such as Zend and Symfony). So it's not a **huge** issue yet. But it's rapidly heading down that road. With the increasing focus on frameworks instead of core code, I really wonder what will happen to the ecosystem...

## A Note On Frameworks Vs Libraries


There's one point that I really want to make clear here. If you noticed based on my definition, a framework is only a framework if it imparts architectural decisions on your application. If you follow that line of reasoning, any framework where you can separate out the architectural decisions from the rest of the code base can be used as a collection of libraries. A great example of this is with Zend Framework. You can use it as a framework if you'd like, and reverse the normal role of application code to library code. Or you can use it as a collection of libraries and structure the application yourself.


A fair number of frameworks can be treated as just collection of libraries that has a little bit of "magic dust" sprinkled on top. And if you blow off that dust, you can use the libraries as libraries. Some frameworks make it very hard to separate the architecture from the underlying components (Cake and CodeIgniter come to mind). They are difficult to treat as a simple collection of libraries if you so choose. But in general, all frameworks are a special case of collections of libraries, and many frameworks can be treated as just a collection of libraries if you so need.

## Conclusion


In short, frameworks can be very good, but you shouldn't rely upon them. Understand your problems, understand the solutions. And most importantly, don't use a tool or framework that you don't fully understand. Don't just use a single framework for all of your problems. That's a recipe for hammer-nail syndrome. Instead, learn about application architecture and pick the right tool for the job.


Note that none of the arguments that I've made here (with the exception of the state of PHP libraries) is PHP specific. All of this applies equally well to each and every language out there. Whether it's Django in Python, Ruby on Rails in Ruby, ASP.NET MVC on the Microsoft stack, Express for Node.JS or Spring for Java, these same principles apply.

## Edit


It is becoming clear that may of the comments and follow-ups I've received are completely missing the point that I'm trying to make. Perhaps I didn't make it clear enough. Let me try to say it a different way:


I'm not saying frameworks are bad. I'm not even saying that you shouldn't use them. I'm also not saying that you should write the majority of things from scratch. What I am saying is that the architecture component that frameworks bring to the table may not be appropriate way to solve problems, and it's worth reflecting upon the application's architecture before kicking off development. The framework is defined by the architecture assumptions that it brings to the table. If it didn't (or you didn't use the architecture bit) it becomes nothing more than a collection of libraries.


When I write code without a framework, I'm not custom writing the majority of it. I'm pulling in third party libraries. I'm pulling in third party frameworks (such as Zend) and using them as library repositories. I'm gluing them together based on my needs, but I'm not writing the majority of the application from scratch. All I'm doing is changing the relationship between my code and the framework's code. Rather than writing my code to work with the framework, I'm wiring the framework/library code to work for me. Once I switch that relationship, it ceases to become a framework, and the architectural constraints associated with it disappear...


I'm not suggesting that you don't learn a framework and its architectural decisions. I am suggesting that you should not become a specialist with one framework. Learn multiple. Learn why each works the way they do, the pros and the cons. Understand the higher and lower level concepts. Write your own framework to understand the deeper architectural constraints better. But when you're writing a production application, solve the problem first in architecture, then pick the framework (if it matches) or libraries you'll need to solve it. Don't program in a language or framework, but into it.


If you focus on learning a single framework, the lessons that you learn are not going to be very portable. But if instead you focus on the concepts and how to apply them to one or more frameworks, then you've learned a far greater skill. And that's going to be far more valuable to the developer (and to the world) than just learning how to write code in a single framework... If you understand the concepts, the framework just becomes another tool. A tool that's not necessary, but can help when it is appropriate to use it...


Questions? Comments? Snide remarks? Comment away, follow up on twitter, or reply on your own blog.