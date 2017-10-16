---
layout: post
title: What Is Security - Web Application Security - Post 1
permalink: what-is-security-web-application
date: 2011-03-25
comments: true
categories:
- Security
tags:
- PHP
- Security
- Web Application Security Series
---

This is the first post in a multiple part series on Web Application Security.  Throughout this series, we will take a look at some of the different aspects of security as it relates to web applications and some techniques on how to mitigate them.  Before we can dive into the finer details of Security, we must define what it is and what it is not.  After that, we'll talk about some foundational pieces that will drive and support the rest of the series.

<!--more-->

## What Is Security?

For the purposes of this article, let me assert this definition:
> **Security**: *The Art of Preventing People From Doing Things You Don't Want Them to Do*

Now, that definition is very vague.  It is that vague for a very specific reason.  Security is not just about preventing defacements.  It's not just about protecting information.  It's not just about protecting your interests.  It's conceptually much more than that.  My hope is that by the end of this series you will understand why I made such a broad and encompassing definition.

## The Three Laws

Another important thing that we need to talk about before we can continue are three fundamental laws of Security.  My suggestion is that you understand these well, since they will form the foundation of everything we're going to talk about.

## - Law 1: If It Exists, It Can Be Compromised.

This is perhaps the single most important thing to keep in mind throughout all of our discussions.  If someone wants to bad enough, without doubt they will be able to find a way to compromise your application (No Exceptions).  Why do I make this bold claim?  It's simple, there will always be a way to compromise any system as long as it is implemented.  The only difference between a "secure" system and an insecure one is how difficult it is to compromise.  Even if it's secure to the point where you need to physically kidnap an authorized user to gain access, it still can be done.  Your job is to determine where the acceptable level of risk is, and make sure that your systems are secured to that risk level.

## - Law 2: Trust Nothing.

Anything that you trust can be turned against you by a potential attacker.  It almost goes without saying that you can't trust the user of your web application.  But you also should not trust your database server.  And if your needs dictate aggressive security, you shouldn't trust your network.  Basically, as a rule, the less you implicitly or explicitly trust, the harder it will be for your application to be compromised.  Conversely, the more systems and people you trust, the more possible attack vectors there will be. 

## - Law 3: Security Through Obscurity Is Not Security.

Don't be fooled into a false sense of security by thinking that because an attacker doesn't have your source code, they can't compromise your application.  You are still just as vulnerable even if you obscure your code.  An attacker just needs to find one vulnerability to exploit and all the obscurity is worthless.  While obscurity will not actually fix or eliminate any vulnerabilities, it can be effectively used as a defensive measure intended to slow down or confuse an attacker.  But it should only be seen as a defensive layer that can be easily worked around.

## Filter In, Escape Out

That simple phrase will be applied throughout our discussions on security.  So let's look at it a little bit further before we go on.  So to dig deeper, let's split it apart into its two parts, and discuss them individually:

## - Filter In

To look at this phrase, let's break it in two parts as well.  So, what does *"Filter"* mean here?  Well, it can mean two different things depending upon your needs.  It can mean to obstruct and prevent improper values from getting it (Let's call this an Obstructing Filter).  It can also mean to make the passed in values safe for use (Let's call this a Sanitizing Filter).  To better understand this, let's think about a simple example.  Let's say that your application needs an integer for some reason.  Obstructing filters would stop any non-integer values cold and prevent the application from continuing (perhaps by displaying a friendly error message asking for a integer).  On the other hand, a sanitizing filter would attempt to parse out an integer value from the passed in value.  Intrinsically, obstructing filters will produce code with less vulnerabilities than sanitizing filters.  However, obstructive filters also can make the application harder to write, and are generally seen as less usable from the end users' perspective than a sanitizing filter might be.


Ok, now that we know what *"Filter"* means, what is meant by that innocent looking word *"In"*?  Well, if we consider *"In"* to be user input, the first part of the phrase means that you should filter all input that comes from a user.  However, does *"In"* mean input in the classical sense?  I would argue that no, it does not.  I consider "In" to be anything that your application takes from outside of its own walls.  This could mean input from the user (traditional Input).  But it also could mean data read from the file-system.  It can mean data read from a database server, and data pulled from a web service.  It can even mean environmental variables and generally any data that's supplied from code that is not under your direct control.

## - Escape Out

Again, let's break this into two parts.  What does *"Escape"* mean?  Well, it means to make sure that data behaves exactly as we intend it to.  One important thing to keep in mind, is that escaping is context sensitive.  That means that how and what we escape will completely depend on what we are doing.  If you're writing HTML, you will need to escape using one set of techniques.  If you're writing a SQL query, you're going to use a completely different set of techniques.  If you're executing a command on the command line, you're going to use an even different set of techniques.  But the important thing to understand is that how you should escape is completely dependent upon both what you're escaping and what you're producing.


I won't spend too much time on *"Out"*, since by now you should have a pretty good idea on what it constitutes without even saying anything,  But for the sake of completeness, I consider it to be anything that leaves the boundary of your application.  That means output that's sent to the user.  But it also means data sent to your database and written to files.  It also means data that's used in a command line program.  It also means data that's passed to third party libraries.


So to wrap up the entire "Filter In, Escape Out" paradigm, we can now say that it means you should filter any data that comes into your application from any source, and escape any data that leaves your application.  How you go about doing that will depend on the context of what you're doing.  We'll get to some specific examples and topics in later posts.

## Conclusion

Now we have the foundation laid for the rest of our discussions.  We will be building upon these concepts as the series continues, so make sure that you're not only familiar with them, but that you actually understand them.  If there's anything that's still not clear, drop a note in the comments section.  Remember, knowing without understanding is useless.
