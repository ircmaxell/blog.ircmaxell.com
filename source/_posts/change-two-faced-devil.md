---
layout: post
title: "Change: A Two Faced Devil"
permalink: change-two-faced-devil
date: 2012-11-14
comments: true
categories:
- Meta
tags:
- Best Practice
- Change
- Community
- Open Source
- PHP
- Rant
---

There's nothing as universally controversial in this world as change. Change can be (in aggregate) for the better or for the worse, yet people will always be split down the middle. Some will believe that the change is a good thing, and others will see it as a bad thing. Often your view points will be dictated by your perspective and how the change will directly effect you. When it comes to software projects and change, what's the right thing to do?
<!--more-->

## Types of Change

There are two basic types of change that I think are worth talking about. Basically:

 * **Constructive Change** - Change which adds functionality or features without much backward compatibility concern.
 * **Destructive Change** - Change which refactors existing functionality and breaks existing code.

It's worth noting that open source projects thrive on change. In fact, it's their lifeblood. Without embracing change, there's no advantage to a project being open source. Where open source gains its real advantage is when outside change is not only accepted, but encouraged. The type of change that they usually live off of is constructive change. But that's not very interesting. The really interesting part comes when a project needs to handle destructive change.

The reasons for the destructive change can vary from horrible legacy practices to the need to refactor to better support a use-case. The important point to note is that every major project that I've seen that's survived for more than a few years has gone through at least one period of destructive change. It's really unavoidable for anything but a REALLY simple project (which doesn't have enough functionality to require a destructive change), a really unpopular project (2 users can cope without it) or really low-level APIs (which doesn't need to change often enough to justify it).

The lesson here is that eventually all reasonably popular and non-trivial projects will need to go through periods of destructive change from time to time. If they don't, they tend to die (after enough time). The speed at which technology is changing demands rapid updates which get harder and harder to do without destructive change...

## How You Handle Change

You could do an entire series of case-studies on how projects handle destructive changes. Projects like Symfony and Zend have basically forked themselves and launched a new version that basically only shared the name between them (comparing versions 1 and 2). Other projects like Joomla! with the 1.0 -> 1.5 transition have provided "legacy modes" which allow a great deal of backwards compatibility while still destructively changing the core.

Another set including PHP itself have tried over the years to make destructive changes either gradually or in such a backwards compatible manner that it's more of an evolution than a revolution. There are definitely exceptions to that rule, but in general it's worked fairly well up to now.

The interesting thing to note is how each of those methods affects the user-base of the software. The rewrite-and-screw-everyone style (that Symfony and Zend used) are really effective at getting beyond the past and doing really cool things. But the problem with it is that it alienated the existing community. People who were experts on Symfony 1 all of a sudden became junior with Symfony 2 (an over-generalization, but not by much).

The Joomla! method tries to provide the best of both worlds: new and clean coupled with backwards compatibility and a migration path. The problem is that this type of functionality rarely works. Legacy modes are nice in theory, but they rarely work at scale with significant functionality. And when they do work, they are often riddled with bugs and wind up being the part of a code base that everybody knows about, but nobody wants to go near...

The PHP method is interesting because it values its users more than its developers. By trying to maintain such strict backwards compatibility, it tries to make it as easy as possible for end-users to upgrade and take advantage of newer features without having to rewrite all of their applications. In theory. But it also places a burdon on the developers of the language in that they can't really clean up the language itself. So over time the bc-free mode of evolution that PHP sees will slow down and eventually collapse under its own weight, simply due to the impossibility of doing what's needed without major BC breaks...

## A Balance


If you notice, all three of these examples attempt to balance a tradeoff between being nice to its existing users, advancing (to become more powerful) and maintainability. The really intriguing thing here is that the larger a project gets, the more precarious the situation is. It's one thing to alienate your users for a total rewrite if you have 1000 developers maintaining 10k sites. It's another when you have 2 million people maintaining literally tens of millions of sites. And it's a completely different story when you have not only developers to report to for the project, but also support contracts and corporate partners to consider.

## Drupal 8


With the next version, the Drupal project is undergoing destructive change (or at least it plans to as of now). But this change is different from any that we talked about so far. Not only are they basically rewriting the entire codebase, but they are also rewriting it in a completely different way then before. So now, not only are they making their existing experts into junior devs again, but they are also taking them back a step further and making them new developers again (at least a large percentage of them at least).

This has to do with how they are rewriting it. In the past, Drupal was written in a unique way. It was procedural code with object patterns sprinkled in. The result was a code base that can't really be called procedural anymore, but also bears almost no resemblance to OOP code either. To their credit, the code was fairly easy to understand and modify with almost no programming knowledge. But that also is going to cause the biggest pain when 8 comes around.

Many professional Drupal developers don't have a solid grasp on programming fundamentals. They know how to write Drupal code. And while we could argue all day long about the pros and cons of it, the end result is that they are able to do some REALLY incredible things, in a really small amount of time. To a business who doesn't care about the academics of code quality, they are extremely effective at getting a job done, and getting it done well.

But when 8 comes out, all of that is going to change. Not only will everyone (except the developers who are building 8) be working in a completely new system, they will be working in a completely new system that's written in a way they have never worked with before. 

Sure, you could say that "who cares, it's up to them to learn", but that misses the point. A wildly successful project is about to take the community that got them to that point and throw them back to the Stone Age. If it works, it'll be great (getting Drupal onto a modern platform with modern practices). But if it doesn't work, I'd expect to see at least a few community forks come out. And that's the best case scenario...

## PHP's ext/mysql

A similar situation is shaping up in PHP's core. There's been a lot of talk about deprecating ext/mysql (the `mysql_\*` functions) in 5.5, and removing it from the release after that. On the surface this seems like a great idea. The mysql extension is a legacy nightmare of horrible coding practices and is basically unsupported already. But there's a problem that I think can't be underestimated...

The mysql extension is still being actively used by major open source projects (such as Wordpress). There are literally tens if not hundreds of millions of websites out there right now that depend on this functionality. And considering the time it takes for new versions to penetrate the market, it'll be years (or longer) before the majority of sites stop using the extension.

Why is that core's problem? Core should just do what's right, and force others to follow, right? Absolutely not. We hit that problem with the switch from 4 to 5. There wasn't much backwards-compatibility break from 4.4 to 5.2 (most code would still work). But it still took nearly a decade for PHP5 to be adopted to the point where projects could realistically target it. It was such a mess that the GoPHP5 initiative was needed to will projects and hosts to upgrade to 5.2...

Part of what feeds the PHP core is the community. If the community takes 10 years to adopt a new version, there really isn't much point to advancing the language. But, on the other hand if adoption is much faster (as 5.4 was), it enables some really powerful changes to happen. It enables a healthy community.

## A Better Way

There has to be a better way of handling destructive change... I won't pretend to have **the** answer, as each project and circumstance is different (not to mention: who am I to say my method is actually the best). But I do have an idea on how to do it better...

Instead of taking these style destructive changes and throwing them at the community full force, why not roll them out over time. So rather than simply rewriting the application from scratch in a new paradigm, rewrite a small subcomponent and release. Then another subcomponent and release. Then another. Before long, you wind up with a completely changed application (or at least the important parts), and you let people learn as they went. You didn't kill productivity with a single version. Instead, you gave people the chance to grow with the application.

This is very much inline with the traditional Agile methodology of release early and often. Anyone who's familiar with the tenants of Agile will understand what I'm suggesting here. And because it borrows from Agile so much, you get another key benefit: rapid feedback. If a change is really bad for the application, the feedback-cycle is so much shorter that you'll find out before devoting years of development into it. So you wind up growing your developers and the application together. Sounds pretty good to me...

Now it may seem that the ext/mysql debate is slightly tangential to this process. But in reality, it's not. According to the accepted [release process RFC](https://wiki.php.net/rfc/releaseprocess), there should be a new version of PHP each and every year. With such a short feedback cycle, it doesn't make sense to rush out and run instead of walking. But there's a bigger problem. With a short feedback cycle and rapid releases (1 year for a language is pretty rapid) comes a cost: the biggest problem will be the rate of adoption. For example, 5.4 has been out for nearly 9 months now, but still the vast majority of hosts are still stuck on 5.3 or 5.2. When 5.5 comes out, it's likely that adoption to 5.4 won't still be overly significant. 

Instead of putting up barriers to upgrading (such as quickly pulling a widly used extension), the core needs to be actively tearing down as many barriers as possible. The time will come when bc breaks are needed. But let's not make it harder than it has to be on hosts and adopters. Let's try to ease the pain of upgrading by not only providing a clear plan, but also giving them a reasonable amount of time to do it in. 5.6 is due out in about a year and a half. While that sounds like a lot of time (and in some contexts it is), it's not really a lot to most of the projects involved. It's not just Wordpress that needs to switch away from ext/mysql, but also all of the plugins (if they use ext/mysql directly, which there's nothing stopping them from) and all of the installations (a fair number of which include custom code).

By taking small, controlled and planned steps, we can hopefully make the lives easier on the adopters, projects and hosts. And by making their lives easier, we can make everyone's lives better by getting new and improved features into the hands of the developers that actually need them. ## Wrapping Up


There's a very applicable quote that applies here:> Be careful not to throw the baby out with the bathwater...


Perhaps I'm blowing things way out of proportion here. Perhaps everything will work out nicely and I'll be labeled a wolf-crier. But I think that it's a topic that's worth discussing. And I think it's a topic that most people overlook to a fault. Sure, you can reason away a lot of it. You can take elitist positions and preach about how "no self-respecting developer would do that anyway". But at the end of the day, successful projects aren't built by the core members. Projects are built by the communities. And to alienate or disenfranchise a community can be a complete disaster. 

It's a serious gamble. I am a betting man, but there are some bets that I just won't take...

