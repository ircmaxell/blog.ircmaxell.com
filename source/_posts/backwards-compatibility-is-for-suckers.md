---
layout: post
title: Backwards Compatibility Is For Suckers
permalink: 2013/06/backwards-compatibility-is-for-suckers.html
date: 2013-06-25
comments: true
categories:
- Programming
tags:
- Anti-Pattern
- Best Practice
- Change
- Forward Compatibility
- Good Enough
- Open Source
- PHP
- Programming
- Rant
---

Yes, you read that right. If your project aims to provide backwards compatibility as a primary goal, you're a sucker. Tons of popular software projects from PHP to Microsoft Windows have stated goals of providing Backwards Compatibility between releases. And yes, I am here to say that they are doing it wrong.
<!--more-->

## The Realist Perspective


Now, I'm not trying to say that maintaining Backwards Compatibility is really that bad of a goal. In a lot of cases it makes everyone's lives easier. Well, perhaps not in a lot of cases. In the short term Backwards Compatibility has nothing but wins for everyone involved. The maintainer's lives are easier, because they have a yard-stick to measure changes by. The user's lives are easier because updates are far less painful.
## The Flaw In The Reasoning


The problem with trying to maintain Backwards Compatibility between releases is that every release adds more cruft for you to maintain. Over time this creates a halting effect on the code base involved that makes it nearly impossible to clean up and "make things better". This tends to create an anchor that keeps a project stuck in the stone age. 

It's a matter of accruing technical debt. Think about it this way. If you make a mistake in an API design in version 1.0 of a project, that mistake will live with you for MANY versions. You can't easily repay that debt. And this isn't even a theoretical problem. Look at PHP's string and array functions. Why are the parameter orders the way they are? Because it would be a BC break to change them!
## Forward Thinking


The fundamental problem with BC is that it relies on the concept that code will be correct when it's written. If the code is solid and perfect from the get-go, there's no reason for it to change, and hence maintaining compatibility is easy. In theory. But in practice, theory and practice differ. And like all things, we never get it right on the first try.

That's why I want to introduce a concept here. Instead of worrying about BC as a primary rule, why don't we worry about Forward Compatibility? 
## Forward Compatibility


The basic premise here is simple:> Try to anticipate future needs with the code we write today, and write it in an adaptable enough way that you won't need Backwards Compatibility breaks going forward.


Now that's a lofty goal... Unreasonable?

Well, not really. We don't need for it to be perfect to work. All we need is the thought to be there. If we honestly think and influence our designs by future needs, even when we get it wrong we'll be in a better place than if we assumed we were right from the beginning.
## In Action


I put this theory into action about a year ago. When I designed the [password_hash](https://wiki.php.net/rfc/password_hash) API, I designed it using a Forward Compatible approach. That's why there's an `$options` array, instead of explicit `$cost` and `$salt` parameters. I tried to anticipate future changes, and adapted the API to take that into account. Did I do a good enough job? Only the future can tell. But I think I did a FAR better job with it than if I had approached it in a purely BC only view (in which case I could do whatever I wanted).
```php
function password_hash($password, $algo, array $options = array())

```
## TL/DR


So next time you want to propose a change, rather than thinking how it can break BC, try thinking how you can make the change compatible with future use-cases and changes. The best way to prevent BC breaks, is to plan for them from the beginning. I'm not saying to strictly ignore BC concerns, but instead focus on the Future, and let the past fall into place as a secondary concern.

The future is what we can still influence. The past mistakes that we have made are already made. Let's not try to live with them forever...