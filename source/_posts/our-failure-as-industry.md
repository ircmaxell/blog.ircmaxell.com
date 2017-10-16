---
layout: post
title: Our Failure As An Industry
permalink: our-failure-as-industry
date: 2013-05-06
comments: true
categories:
- Security
tags:
- Community
- Open Source
- Open Standards
- Philosophy
- PHP
- Programming
- Rant
- Security
---


In the April issue of the [PHPArch magazine](http://www.phparch.com/) (also published on [her blog](http://www.alittleofboth.com/2013/05/security-driven-development/)), Elizabeth Tucker Long wrote a really interesting editorial piece coining a concept she called Security-Driven-Development. She (quite correctly) identified a problem in the current development community where security has become an after-thought (if it's thought of at all). This isn't a new concept, in fact it's a concept that I and many others have been preaching for quite a while now. However I've been coming to realize that I've had it wrong the whole time. And I think the entire industry is getting it wrong today.
<!--more-->
## The Current State

It's 2013. The Internet as we know it is officially 20 years old. We have seen the rise and fall and re-rise of the Dot-Com bubbles. We have seen technology go from the limiting factor to the enabling power. Today's browsers are faster than ever. We have more powerful APIs. We have new interfaces coming out all the time to allow us to tap into more powerful aspects of the computer. The available bandwidth between clients and servers has never been increasing faster. The richness and capabilities of media handling has never been stronger. On the surface, it looks like we're full steam ahead.

It's 2013. Unit testing and Test-Driven-Development are just starting to gain mainstream traction in the web development sector. A lot of developers and maintstream development shops still haven't bought into the fact that tests are necessary. A lot of open source projects still don't ship with a test environment for their platform. Professional developers still will argue that they get paid to write code, not tests.

It's 2013. Our foundational technologies suck so much that we use abstraction layers and libraries for almost everything that we do. Think about that for a second. CSS is such a pain in the neck to work with, that we have invented pre-processors and entire workflows to work around the pain. JavaScript DOM manipulation is such a nightmare that we resort to all sorts of libraries to abstract the pain. Our back-end systems are so hard to work with, that we need to use frameworks to abstract all of that away.

It's 2013. A major website has been in the news nearly every single day because of a security incident. Company X was hacked and the attackers stole 10 million usernames and passwords. Company Y was breached and the attackers inserted malware that's infecting every visitor. Company Z's twitter account was breached and the attackers were able to crash the Stock Market (yes, that really happened). We constantly see reports of vulnerabilities and fixes released by very reputible and responsible companies and projects. Yet there's always another vulnerability. It's 2013 and SQL Injection is still a problem.

## The Bottom Line

Up until now, we (as an industry and community) have always treated those three problems as separate problems. Testing? Oh, we have an entire Quality Assurance team for that! It's 2013 and if you don't have people looking after the quality of your products you're being irresponsbile! Specifications suck? We have specification teams working on the next one to make it better! It's 2013, and you have to care about speficications! We have security vulnerabilties? Get the security team on that. It's 2013, and if you don't have a security team locking down your IT infrastructure you're being irresponsible!

It's that kind of thinking that got us in this situation in the first place. It's the attitude that *"It's not my problem, it's that person over there's problem!"* It's the lack of self-accountability that is destroying this industry from the bottom up.

Testing isn't something that you can reasonably bolt on after you build a product. It's something that you have to build in at the most fundamental levels. Security isn't something that you bolt on after you build a product. It's something that you have to build in at the most fundimental levels.

Everyone needs to be responsbile for the product. Everyone needs to be responsible for writing secure and well tested code. If someone doesn't want to write tests, they don't belong earning a paycheck. If someone doesn't want to think about the security impacts of their code, they don't belong writing code (professionally or not). And if someone doesn't want to fix their code (for *any* reason), they don't deserve to be in their position.

## The Way Out

One of the core values for the company that I work for is that empolyees should *"Act like owners, not renters."* That philosophy is at the heart of our road to recovery. If something is broken, we shouldn't try to work around it. We should try to fix it. We shouldn't just deal with it. We should put the time and energy into actually making a difference. We shouldn't let the "Broken Window Theory" fool us into thinking that because others don't care, it's ok for us to not care.

A necessary part of the process of recovery is for people and open source projects to lead by example. A lot of people will learn how to develop and write code by looking at and emulating open source code. Contributors and maintainers owe the industry and community the responsibility of leading by example. We (as a community and industry) should not sit behind the wall of complacency and close a blind eye to projects that may be popular, but set a bad example.

Groups that are in a position of leadership should realize that and take the responsibility seriously. Far too often they shirk that responsibility (*"It's not what we wanted"* or *"We never said that you had to"*). That does everybody a dis-service. Instead, there needs to be an air of accountability and responsibility. Remember, responsibility cannot be taken, it can only be asked for or given.

I'm not suggesting that companies shouldn't have a security team or a quality control team. What I am suggesting is that security/testing shouldn't be that team's responsibility. Those teams' responsibilities should be for verifying that security and testing have been adequately implemented.

I know that I would rather live in a society where we all take responsibility for ourselves rather than having to rely on "somone else" to do it for me...