---
layout: post
title: Being A Responsible Developer
permalink: 2014/12/being-responsible-developer.html
date: 2014-12-29
comments: true
categories:
- Programming
tags:
- Best Practice
- Open Source
- PHP
- PHP-Versions
- Rant
- Security
---

Last night, I was listening to the combined [DevHell and PHPTownHall Mashup](https://web.archive.org/web/20170920120822/https://www.youtube.com/watch?v=FfVZ_Erl0DU) podcast recording, listening to them discuss a topic I talked about in my [last blog post](https://web.archive.org/web/20170920120822/http://blog.ircmaxell.com/2014/12/on-php-version-requirements.html). While they definitely understood my points, they for the most part disagreed with me (there was some contention in the discussion though). I don't mind that they disagreed, but I was rather taken aback by their justification. Let me explain...

<!--more-->

## The Rationale

The general consensus was that as an ideology, only supporting latest versions is correct. From a practical standpoint though they said that it's unrealistic. That there are tons of legacy systems out there that are running just fine and can't justify the cost of upgrading. So they shouldn't have to upgrade "for ideological reasons".

From one point of view, this certainly makes sense. It can be expensive to maintain software, especially old and outdated software. If it's running, why not just let it run? After all, if you don't have problems with it, why bother touching it (if it ain't broke, don't fix it).

This point of view disturbs me deeply. And it further disturbs me that it came from the same person who preaches for testing.

## The Connection

Why do we unit test our code? Is it to find bugs? No. In fact, there are far far more effective ways of finding bugs. In [Code Complete 2](https://web.archive.org/web/20170920120822/http://www.amazon.com/Code-Complete-Practical-Handbook-Construction/dp/0735619670), Steve McConnell presents a collection of study evidence on the effecitveness on defect detection. Here's a breakdown of the average effectiveness for each type of detection:

| Type 	| % Effectiveness |
|-------|-----------------|
|Informal Design Reviews | 35% |
|Formal Design Reviews | 55% |
|Informal Code Reviews | 25% |
|Modeling or Prototyping | 65% |
|Formal Code Reviews | 60% |
|Unit Testing | 30% |
|System Testing | 40% |

Automated testing is only about 30-40% effective at finding defects. Formal code review alone is far more effective than automated tests at detecting defects (at least according to studies).

So why do we write automated tests?

There are two main reasons:

1. To drive the design of our applications (TDD).

2. To prevent regressions.

So if we practice TDD, we write the tests to help us design components and ensure that they work as intended (defects aside). Then we keep those tests to ensure that regressions don't enter the system down the line.

Preventing regressions, as it turns out, is the key.

By automating testing, you can have confidence that changes in the future won't break existing functionality. Chris Hartjes says this perfectly on his site [grumpy-learning.com](https://web.archive.org/web/20170920120822/http://grumpy-learning.com/):

> You don't have to be scared to push code live.

## It's All About Maintainability

Testing is one way to make code maintainable. The better the tests are (note, the test quality, not the coverage), the more confidence you'll have that your change won't break things and the faster and easier it will be to maintain the codebase.

If it's so important to be able to maintain software, why are we afraid to do it?

> If it's running, why not just let it run? After all, if you don't have problems with it, why bother touching it (if it ain't broke, don't fix it).

Just because you don't see problems with it, doesn't mean those problems aren't there.

## Security Is A Maintainability Concern

No non-trivial application that is ever built is 100% secure. Tradeoffs are made, mistakes are made and new research uncovers new vulnerabilities every day.

Think about that for a second. That means that every single piece of non-trivial software that was ever written will have a security vulnerability it in today. It may not be known, but it exists.

The question comes, what do you do when those vulnerabilities become known? Do you update? Or do you ignore it? Do you pretend it's not broken, because your specific website hasn't been hacked (yet, that you know of)?

## If It Ain't Broke Don't Fix It

The problem is that it is broken. All software is. The fallacy isn't that upgrading is "fixing something that works fine today", the fallacy is that it's working fine in the first place.

You can choose to ignore the break, or you can make an "informed" decision that the break isn't worth fixing, but don't pretend it's working fine.

And that brings us to the point:

> Sometimes, upgrading [legacy code] is a major pain, and you might never get the proper return on the investment for the resources it will take.

This assumes that the return is a positive value that will "offset" the cost of implementation. That upgrading will increase revenue.

When it comes to security, the inverse is the point that you need to consider. What's the potential cost of a security breach? What's the potential cost if an attacker holds your company's data hostage?

What's the potential cost to the rest of the internet when your server becomes part of a botnet?

What's the potential cost to random users when your server starts serving malware?

What's the potential cost? Way more than the resources it will take.

You think it'll cost more to upgrade than is worth it? Then shut the site down. Yes, it's a harsh line, but it's a responsible one.

## Ideology Vs Reality

Some people say that I'm just being an idealist and am disconnected from the realities of the world with this discussion. That in the "real" world there are tradeoffs that need to be made. That in the "real" world it's not a black-and-white discussion.

Well, let's look at this "real" world:

 * Sony - Seemingly all data on network leaked. Including social security numbers of 47,000 employees.
 * Ebay - 145 million records leaked.
 * Target - 40 million credit card numbers leaked. 70 million contact details.
 * Home Depot - 56 million credit card numbers leaked. 53 million email addresses.
 * Goodwill Industries - 868,000 credit card numbers
 * JP Morgan - 7 million contact details
 * Neiman Marcus - 350,000 credit card numbers
 * Michaels - 2.6 million credit card numbers.

And that's just [the big ones for 2014](https://web.archive.org/web/20170920120822/http://www.informationisbeautiful.net/visualizations/worlds-biggest-data-breaches-hacks/) so far.

It's been reported that there were [761 major breaches](https://web.archive.org/web/20170920120822/http://www.idtheftcenter.org/images/breach/DataBreachReports_2014.pdf) in 2014 alone. Exposing well over 83 million records (only counting confirmed records, not including unconfirmed numbers like Ebay). And those are just the major ones.

That doesn't touch the [100,000+ WordPress sites breached in November](https://web.archive.org/web/20170920120822/http://wptavern.com/100000-wordpress-sites-compromised-using-the-slider-revolution-security-vulnerability). Or the millions of sites hit by [the Drupal SQL vulnerability](https://web.archive.org/web/20170920120822/http://www.bbc.com/news/technology-29846539).

The reality is quite grim. Perhaps if others were a bit more "idealist", this world would be a lot safer.

## Being Responsible

The responsible approach is to understand that when it comes to the software that you expose to the internet (the OS, webserver, programming languages, etc), you must run supported versions. And you must run a version with all known security issues fixed.

Running unsupported versions puts everyone at risk. So don't do it.

## Applying This To OSS Version Requirements

There was a [Reddit Comment](https://web.archive.org/web/20170920120822/https://www.reddit.com/r/Wordpress/comments/2pvbfx/on_php_version_requirements_x_post_from_rphp/cn0kbje) about my PHP version requirements post on r/WordPress:

> It's not the application's job to force the PHP version onto the hosts, if you ask me, no matter how large the application is in market share.

People who understand the tradeoffs at play will know that they shouldn't be running old versions, and aren't. So the question comes, does the application take the responsible line and make the decision for those incapable of making it for themselves (due to lack of skill, knowledge or time)? Or does it pretend that it's OK?

> Some projects can't just shoot themselves in the foot and cut off developers by forcing a higher dependency than their users want.

And that's precisely the point that I made in my last post. Those users will upgrade their stacks. Hosts will follow. If users want old, unsupported versions to work they either don't understand what's at stake or don't care. And considering that the impact of their decision is not limited to themselves, it's irresponsible to support that decision.

You can pretend to care about your users and help them run old versions of software or you can actually care about them and give them incentive to upgrade.

Do the responsible thing, run supported software and encourage your users to as well.