---
layout: post
title: Open Standards - The Better Way
permalink: open-standards-better-way
date: 2012-05-23
comments: true
categories:
tags:
- Framework
- Open Standards
- PHP
- Rant
---

There has been a lot of traction lately on the topic of the [PSR](https://github.com/pmjones/fig-standards/tree/psr-1-style-guide) "PHP Framework Interoperability Group". They are introducing two new proposed standards: [PSR-1](https://github.com/pmjones/fig-standards/blob/psr-1-style-guide/proposed/PSR-1-basic.md)and [PSR-2](https://github.com/pmjones/fig-standards/blob/psr-1-style-guide/proposed/PSR-2-advanced.md), both dealing with code formatting standards. Actually, calling them proposed is a bit of a short-fall, since they both already have enough votes to be approved. I have read both, and actually agree and think they are quite good.

However, there's a deeper problem. Open Standards is something that the internet was built upon. From HTTP, E-Mail and HTML to ECMA Script (JavaScript), OAuth and JSON, open standards are everywhere. The problem with the entire PSR process is that it is not designed to produce open standards. <!--more-->


## What Is An Open Standard


For the purposes of this post, I consider any standard "Open" as long as it goes through an open process to become a standard. What is an open process? As it so happens, the IETF (Internet Engineering Task Force) has an RFC about that very topic: [RFC2026](http://tools.ietf.org/html/rfc2026#section-6) (Section 6 specifically). Basically, in order for a standard to be accepted, it must go through this basic process (trimmed down from the RFC to just the basic steps): 1. The content is proposed in a "draft" state. Anybody can submit a draft to be considered. Drafts are available for everyone to see.
 2. One member of the standards body must "recommend" or sponsor a draft to turn it into a proposal. If a draft goes 6 months without change and without being recommended, it is removed from the draft list.
 3. Once a draft is proposed, a minimum of 2 weeks is set aside for an open call to the community for comments. This should allow for open discussion with anyone in the community.
 4. After at least 2 weeks, a Last Call is announced for the proposal. That last call triggers a final 2 week period of discussion in the community.
 5. After that Last Call period, a vote is held by the standards body. If the vote passes, the proposal becomes an accepted standard.

It's important to note that an open standard isn't one that's voted on by everyone in the community. There still should be a "standards board" that has the final say on the standard. But the key difference is that there's not only community interaction, but it's explicitly required for the standard. 
## Why It's Important


As we've seen with the PSR-0 "standard", not doing an open process can allow for sub-standard standards. That's why I wrote [a blog post about it](http://blog.ircmaxell.com/2011/11/on-psr-0-being-included-in-phps-core.html). There are a number of issues with PSR-0 (both fundamental and implementation wise) that would have quickly been found if the standards body took an open process approach. By using a closed process, the best solution may not be found. But by having an open process, and actually paying attention to the community, the best solution that can be found will be found.
## My Call To The PSR Team


My call to the PSR team is simple: Adopt an Open Process for standards. Don't just create a standard and "force" it on the community. Look to the community for comments and interaction. Don't just post a blog post asking for feedback. Open a mailing list for the discussion, and publicize the lists. Have a central point of discussion, so that anyone can come in and read it and participate.

Make the process open and useful. Otherwise it's just a group of people that come across like "Do it this way because we know better than you..."


Note that I'm not asking to open the vote to anyone else. I'm not saying that standards should be approved by everyone in the community. There should still be a standards body that makes the final decision. But they should make that decision based on community input. They should actively look for and encourage open discussion prior to voting. 

By moving forward with an open process, a better solution can be had by all.

What are your thoughts?  Feel free to respond in the comments, on twitter, facebook, your blog or wherever you feel comfortable.