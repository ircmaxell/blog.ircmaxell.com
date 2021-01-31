---
layout: post
title: N-Tier Architecture - An Introduction
permalink: 2012/08/n-tier-architecture-introduction.html
date: 2012-08-01
comments: true
categories:
- Architecture
tags:
- Architecture
- Email Response
- Large Scale Applications
- Learning
- PHP
- Programming
---

If you've been following me for a while, you've likely heard me use the term *"N-Tier Architecture"* before. Today's question comes from [Arno](https://twitter.com/me_arno). He basically asked *"What is this N-Tier Architecture thing you keep talking about?"*... So, to answer his question, a N-Tier Architecture is one that uses more than one tier. Of course there's more to it than that...

<!--more-->


## What Is A Tier?


The first thing that we must talk about, is what makes up a tier. The fact of the matter is that the answer depends on who you're talking to, and what context you're talking in. Some people consider a tier to be a process boundary. If your application talks to another process to work, it would then be multi-tier. Others (including myself) consider tier to be separated by more of a conceptual boundary. Being split into separate processes is not enough (after all, you can do that by forking).

So if there's a conceptual boundary, what goes into the separation of tiers? The answer is that there are a number of ways to separate them. I typically consider tiers to be parts of an application that are separated by a protocol based API. Note that I didn't say network based. You can have tiers that use FIFO files to communicate. But they are communicating through other means than just shared memory or signals.

## Common Setups


Almost all web based applications use at least two tiers. One for the "application server" (which in this case could be PHP) and one for the database server (MySQL). If we were to diagram the application, it might look something like this:

[![](http://1.bp.blogspot.com/-RIAum2bO1do/UBcx29gEEDI/AAAAAAAABDc/525TeDe0aq4/s320/2_tier.png)](http://1.bp.blogspot.com/-RIAum2bO1do/UBcx29gEEDI/AAAAAAAABDc/525TeDe0aq4/s1600/2_tier.png)

You've likely realized that we're missing a piece here: the web server. In the common LAMP setup, using mod_php to run PHP, it is a two tier application (since you can't easily separate the Apache server from the PHP server). But if you use FPM or FastCGI, you can further separate it out into another tier:

[![](http://2.bp.blogspot.com/-DJZ98jQdLoE/UBcyetqbr_I/AAAAAAAABDk/ms0iq3RzhUY/s320/3_tier.png)](http://2.bp.blogspot.com/-DJZ98jQdLoE/UBcyetqbr_I/AAAAAAAABDk/ms0iq3RzhUY/s1600/3_tier.png)

This is the level that was very common until the past few years (it is still very common, but there are other architectures that are starting to pick up steam). One of the more popular is to separate out a presentation layer from the business logic layer. The business logic then becomes nothing more than a set of Restful APIs. There are several advantages to this form of architecture, in that you can have multiple front-ends that share the same business logic. For example:

[![](http://1.bp.blogspot.com/-qmSXPaZ3kuY/UBc0dbj4FkI/AAAAAAAABDs/oXnEwLnFRfw/s320/4_tier.png)](http://1.bp.blogspot.com/-qmSXPaZ3kuY/UBc0dbj4FkI/AAAAAAAABDs/oXnEwLnFRfw/s1600/4_tier.png)

## Why Use Tiers?


Using tiers is an incredibly powerful way to architect an application. It allows for several things to be done that are more difficult if you don't tier the application. The one benefit that I already covered was that it enables fluid code re-use across disparate environments. So you can share the same business logic with an enterprise Java application that you use to serve mobile devices. As long as the APIs are designed correctly, it really opens up the possibilities towards infinite extend-ability.

Furthermore, creating tiers allows you to scale an application easier because you can move each tier to a separate server (or server cluster) depending on the amount of resources they require. This can make horizontal scaling much easier, as the application is split up by functional purpose.

Additionally, as long as the tiers are communicating over HTTP, you can leverage reverse proxies at each tier to cache the results the tier generates. Thereby creating an application that can scale much easier than a traditional application without having to wire cache into the application itself (or making it easier to cache the results). This lets you scale the front-end easier, because it's not really doing any data processing. So it basically becomes a dumb front-end, dispatching data tasks further back. So therefore, it is usually much easier to scale out, because you have less inter-tier communication and data sharing requirements.

Finally, it allows for far greater security to be applied. Since each tier can be put behind a separate network firewall, you can distinctly separate the core data store from the rest of the application. That means that if a user compromises the front-end, it doesn't buy them much. They would need to compromise each tier separately (which is much harder). It's worth noting that any SQL injection vulnerability in the API tier would be exposed to the front-end, so it's not perfect. But it can help significantly.

## A Real Example

Here's a real example of a live application that I've built. It's fairly complicated, so I'll explain it afterwards, but let's look at the diagram first:

[![](http://3.bp.blogspot.com/-_BKuO95QLFo/UBc50P8rLYI/AAAAAAAABD8/X9gqxIQU4S0/s320/live_architecture.png)](http://3.bp.blogspot.com/-_BKuO95QLFo/UBc50P8rLYI/AAAAAAAABD8/X9gqxIQU4S0/s1600/live_architecture.png)

So, there's a lot going on there. In reality, it's not nearly as complicated as it seems. So let's start with the two right-most ends. The JavaScript end should be fairly straight-forward. In the browser, there's a JavaScript client that talks back to the central API server through a cache (the cache is operating on fetch records, and is intelligently purged as write requests are passed back). The top PHP client should also be pretty straight forward, in that it calls the API server and renders static HTML (which then include the JavaScript application for subsequent requests).

The central API server (the singe PHP node in the center) sits behind a reverse-proxy HTTP cache. It aggregates several generic backend API servers into a single front-end, application specific API. Most of the application's business logic sits in this tier.

Behind that API server exists three API servers. One is a content server (which manages editorially controlled static content), one is a user data store (which manages user-submitted dynamic content) and the final one is an authentication server (similar to an OAUTH provider, but managing user records instead of just authentication). The front-end API server then aggregates the content from these three back-ends (through their own cache layer) into a single application API.

In reality, there are far more systems in play in this diagram (Redis, Memcached, Gearman, more MySQL instances, reporting servers, etc), but this presents the main architecture behind how the application serves content.## The Real Benefit


The really cool benefit here is that each tier is really just a stand-alone application. They can be worked on by different teams, with different release cycles. The only thing that matters is that the contracts exposed by the APIs are honored (that the behavior of the API doesn't change). Each sub-system can be written using a technique and architecture that makes sense for the problem it's trying to solve. Furthermore, each system in the design becomes relatively simple and easy to understand. The overall application is only around 40k lines of code, but each sub-system has on average about 6,000 lines of code (in reality, there's one with 20k, one with 14k, and the others are around 1500 lines of code each). 
## The Downsides


You never get something for nothing in this world. So what good would a post that discusses only the advantages be? In practice, there are a number of downsides to using a N-Tier architecture. The biggest is network latency. Since every high level request is serviced by multiple API requests over HTTP, network latency becomes a huge problem. Think about it, if each request takes 50ms to resolve, making 10 API requests will raise the page load time to over half of a second.


Additionally, there's another significant downside in that it's a lot more systems to manage. And don't underestimate the costs associated with that. It can mean upgrading 5 systems instead of one every time you want to upgrade PHP. It also means monitoring many more systems for security breaches...## Conclusion


While every application won't benefit from the complications that an N-Tier application will bring, those that can will benefit significantly. Of course there's a lot more to the picture than I've gone over here, but you could write a doctoral thesis on the generic problem. But if you need an application that's highly scalable, easily extendable, needs to integrate with several existing systems or requires communication between different technologies, consider an API based N-Tier Architecture.

Do you have a question that you want me to try to answer? Something about how PHP works internally? Something about OO Design? Something related to PHP? Shoot me an email at *ircmaxell **[at]** php **[dot]** net*, and I'll see if I can answer it!