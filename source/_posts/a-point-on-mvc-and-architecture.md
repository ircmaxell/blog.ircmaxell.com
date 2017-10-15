---
layout: post
title: A Point On MVC And Architecture
permalink: a-point-on-mvc-and-architecture
date: 2014-12-02
comments: true
categories:
- Architecture
tags:
- Anti-Pattern
- Architecture
- Best Practice
- Good Enough
- MVC
- Object Oriented Programming
- PHP
- Rant
---
Last week I published a post called [Alternatives To MVC](http://blog.ircmaxell.com/2014/11/alternatives-to-mvc.html). In it, I described some alternatives to MVC and why they all suck as application architectures (or more specifically, are not application architectures). I left a pretty big teaser at the end towards a next post. Well, I'm still working on it. It's a lot bigger job than I realized. But I did want to make a comment on [a comment that was left on the last post](https://plus.google.com/107061180923764515046/posts/aNJv1buZvhh).
<!--more-->


## The Comment:

## The Problem

I take issue with a few points that are made there. And the issue is not that I disagree. The issue is that I do agree.

> For the canonical "personal blog" example, the Rails-style pseudo-MVC does actually work fairly well.

Which is precisely correct. For a CRUD-based application, "MVC" (conceptual) does work quite well. And that's the problem. It demos extremely well, is easy to understand with simple examples and is simple to make into a framework.

> If all you're doing is CRUD on blogs and an index page, then you're fine.

Yup. Except that if all you're doing is CRUD on blogs with an index page, **WHY THE HELL ARE YOU WRITING IT IN THE FIRST PLACE**?

CRUD is a well solved problem. We have tools like [WordPress](https://wordpress.com/) and [Drupal](https://www.drupal.org/) and [Joomla](http://www.joomla.org/) and [Alfresco](http://www.alfresco.com/products/web-publishing) and [ExpressionEngine](https://ellislab.com/expressionengine) and [tons and tons of others](http://en.wikipedia.org/wiki/List_of_content_management_systems).

There are three reasons not to use them:

 1. **They don't fit your use-case**
    
    Then either you're not just doing CRUD, or you're lying to yourself about it not fitting your use-case.
 2. **You want to learn**
    
    That's fine, as long as it's not done in a professional context.
 3. **You're an elitist**
    
    You think you're too good to use an existing tool.
## The Need For Customizations

So MVC works fairly well for CRUD applications. What happens if you need to add some custom rules?

Well, every one of those CMS's has an extension mechanism. Why aren't you using that?

If your application is 98% CRUD, use a CMS.

If it's 80% CRUD, use a cms.

If it's 40% CRUD, then start looking at architecture options. You'll still relegate the CRUD to something like [CMF](http://cmf.symfony.com/) or some other skeleton builder so that it's a *tiny* part of your application code, but you'll have better integration options.

## The Real Problem

The real problem is that we really have 3 classes of developers:

 * 75% Use CMS's
    
    Even if what they are doing is more suited to custom development.
 * 24% Use Custom Code (based on a framework or not)
    
    Even if they should use a CMS.
 * 1% Use Both
    
    They pick the right tool for the job.
My hope is that people realize this and stop reinventing the wheel. If you're getting paid to develop, and you're first stop is to code, you're doing something wrong. Often the best solution is one that requires no code. The trick is finding it.

Larry's closing is spot on.

> Really, the answer to "what architecture should I use / is best?" is always, **always** "it depends". Architecture can vary widely, as long as it's deliberate.

Software design is not about solving problems. It's about understanding problems. The prime reason that *"it depends"* is that *every* problem has different requirements. And a problem isn't something you can explain to someone in a chat room in five minutes (or if it is, you should be using a CMS in the first place).

Finally, I'll let Larry close it out:

> The architectural monoculture that has gripped the web dev world since Ruby on Rails came on the scene is quite harmful.

I'd go with stronger than "quite harmful", but there you go...




