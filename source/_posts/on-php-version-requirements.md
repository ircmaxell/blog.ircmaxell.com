---
layout: post
title: On PHP Version Requirements
permalink: on-php-version-requirements
date: 2014-12-19
comments: true
categories:
- Programming
tags:
- Best Practice
- Community
- Education
- Framework
- Open Source
- PHP
- PHP-Versions
- Programming
- Rant
- Security
- WordPress
---
I learned something rather disturbing yesterday. [CodeIgniter 3.0 will support PHP 5.2](https://github.com/bcit-ci/CodeIgniter/pull/3208#issuecomment-67517433). To put that in context, there hasn't been a supported or secure version of PHP 5.2 since January, 2011. That's nearly 4 years. To me, that's beyond irresponsible... It's negligent... So I tweeted about it (not mentioning the project to give them the chance to realize what the problem was):

{% twitter https://twitter.com/ircmaxell/status/545617254641967104 %}

I received a bunch of replies. Many people thought I was talking about WordPress. I wasn't, but the same thing does apply to the project. Most people agreed with me, saying that not targeting 5.4 or higher is bad. But some disagreed. Some disagreed strongly. So, I want to talk about that.

<!--more-->

## The Argument

There were a few replies that I want to point out:

{% twitter https://twitter.com/simonwheatley/status/545873041759408130 %}

{% twitter https://twitter.com/simonwheatley/status/545881837525270528 %}

And

> While there is some room for a coordinated effort by PHP framework developers to push the server vendors/operators to upgrade their PHP versions, most developers have to look at their potential user base to determine what version they use as their minimum supported version.

via [mwhitney on CodeIgniter's Forums](http://forum.codeigniter.com/thread-73-post-910.html#pid910).

Now, these are pretty interesting arguments. It boils down to making the logical argument that if hosts don't support 5.4+, then moving to require 5.4+ would leave the users who use those hosts abandoned. And some projects don't want to abandon users.

It's a warm and logical idea; Open your arms to everyone, and include them all. Don't leave anyone behind.

Really, it's a good argument. The problem is, is it based on a flawed premise...?

## Is It A Fallacy?

On the surface, it almost looks like it's an [Appeal To Emotion](https://yourlogicalfallacyis.com/appeal-to-emotion):

> Appeals to emotion include appeals to fear, envy, hatred, pity, pride, and more. It's important to note that sometimes a logically coherent argument may inspire emotion or have an emotional aspect, but the problem and fallacy occurs when emotion is used instead of a logical argument, or to obscure the fact that no compelling rational reason exists for one's position. Everyone, bar sociopaths, is affected by emotion, and so appeals to emotion are a very common and effective argument tactic, but they're ultimately flawed, dishonest, and tend to make one's opponents justifiably emotional.

It sounds like a "Think Of The Children" argument. "Think Of The Users", "We don't want to abandon anyone".

On one hand, this is a powerful message. It also seems perfectly logical since abandoning users would be bad.

On the other hand, it seems to be built to evoke an emotion of "taking a higher ground". It implies that to raise minimum version requirements would "abandon" users or do them harm.

## Is Raising Minimum Versions Abandoning Users?

Well, this is an interesting question to say the least.

On the surface, it seems logical. According to [WordPress.org's Own Statistics](https://wordpress.org/about/stats/), approximately 33.6% of users are still using PHP 5.2. Adding in 5.3 (which is also no longer maintained) brings that number up to 72.1%. Therefore, if you raised WordPress's minimum version to 5.4 or higher, then over 72.1% of users would be abandoned. But it also means that 72.1% of users are running unsupported software...

According to [w3techs.com](http://w3techs.com/technologies/details/pl-php/5/all), overall PHP 5.2 is at 20.4% of the market. Adding 5.3 brings the total to 66.5% of the market running unsupported versions of PHP.

If that was the only variable at play, it would be correct (raising the version would abandon users). But fortunately, it's not the only variable.

Another **very** significant variable are the hosts themselves. They are driven by demand and by market forces just like anything else.

If major projects like WordPress and CodeIgniter say that "5.2 will no longer be supported", the vast majority of hosts would almost immediately support newer versions.

Why? Because if they don't, they'll lose business.

But that still leaves the user out in the cold, doesn't it?

{% twitter https://twitter.com/simonwheatley/status/545872725043326976 %}

I would say that they don't need to know what "PHP or version means". They just need to know if the host is compatible with the project or not.

Considering how much business these tools bring to the hosts, they will move quickly.

I would also say that the key to benefiting users is not to give in to them, but to educate them.

If users don't know what "version" means, then teach them. That's how we all get better. That's how the community moves ahead.

## Remembering The Past

How do I know that they will move quickly? Because it's happened in the past. It happened 7 years ago.

When PHP 5 came out, there was initially trivial adoption. 5.0 was released in 2004. By 2007 adoption rates were trivial at best (low single digit percent).

Hosts had no reason to move to 5.0. Their users didn't need it, projects didn't require it. So nobody moved.

Projects couldn't move to 5.0, because hosts didn't support it. It would be a death toll for their user base. They would abandon their users. (Sound familiar?)

Then something amazing happened.

![GoPHP5](/images/go-php5.png)

A group of projects (3 initially, but over 100 within months) decided that if they banded together, then they would have enough leverage to force the hosts to adopt 5.2. So GoPHP5 was born. Projects pledged that by February 5, 2008 (approximately 6 months from the start) the next major release of every project would require 5.2 as a minimum version. That meant that within 6 months, 100 of the most popular PHP based projects would drop support for PHP 4.4 (which at the time was over 85% of the install base).

The surprising thing is that not only did over 100 projects join the pledge, but over 100 hosts did as well. They wanted to join the effort and move forward.

The amazing thing is that PHP 5.2 went from about 1% host adoption at the start of GoPHP5, to well over 50% adoption within 6 months.

Think about that for a second. Think of the shear number of servers that were upgraded. At the time, PHP represented approximately 60% of the Internet. That means that within 6 months, over 30% of the Internet upgraded versions. That's amazing.

But what about the remaining 50%? What about the hosts that were left behind?

Well, they mainly fall into two categories. The first is simply the one-off code bases that exist in the wild. Companies that are running legacy systems that aren't using open source CMS's or frameworks.

The second category requires understanding something about the GoPHP5 movement. There were two major projects that chose not to support GoPHP5. WordPress and CodeIgniter.

They both continued to support PHP4. In fact, WordPress continued to support PHP4 for another 3 years.

Ironically, CodeIgniter raised their minimum to 5.1 less than a month after PHP 5.2 went End-Of-Life. And WordPress raised their minimum version requirement to 5.2 **6 months after** 5.2 was End-Of-Life.

## What Does It Mean?

The project sets the requirements, and the hosts fulfill them. Many hosts are not incentivized to do more than that. Many hosts will do the bare minimum, simply because that's what's strongest for their bottom lines.

But they also will meet those minimums, because they want to make money. If their bread and butter projects ask for higher versions, the hosts will follow.

It means that the projects are in control. And this is not just a theory. GoPHP5 proved it. Yet some people still fail to understand that simple relationship.

I also don't want to imply it's an "us vs them" relationship with respect to all hosts. Many hosts are good, progressive and proactive. They drive the relationship rather than react to it. But unfortunately, the majority of hosts are the bottom-basement variety which choose to do the bare minimum.

The important thing to recognize, is who sets the minimum (hint: it's the projects).

## What's The Big Deal?

Why does this matter? Well, it matters because supporting old versions is actively harming users.

### Security

End-Of-Life versions do not get security fixes. Meaning that people running on PHP 5.2 are running on platforms that have known security vulnerabilities. So by allowing users to use them, you are basically saying that security doesn't matter for your project or your users.

The common argument against this is that "Well, the majority of 5.2 installs are from linux distributions, who back-port security fixes". So that means that some users of end-of-life versions get security fixes. But not all.

And do they really back-port security fixes? Last I checked, bcrypt wasn't supported in 5.2. And the fixes ($2y support namely) aren't back-ported into any version < 5.3.6 (including distribution maintained versions).

But let's look closer. Let's take a real example. Let's look at [CVE-2011-4885](http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2011-4885), better known as HASHDOS. This was one of the most significant (at least in terms of attention) security vulnerabilities to hit PHP in the past decade. It was fixed in 5.3.9 (and again in 5.3.10 due to an issue with the fix). But was that fix backported?

One of the Linux distributions that still ships 5.2 (or did at the time of that CVE) was Debian Lenny (5.0). Let's take a peak at [the source for PHP 5.2.6.dfsg.1-1+lenny16](http://archive.debian.net/lenny/devel/php5-dbg). Let's further inspect the code to see if the fix implemented as Hash-DOS protection in PHP was applied to Debian's version.

The fix was to introduce a new php.ini entry called [`max_input_vars`](http://php.net/manual/en/info.configuration.php#ini.max-input-vars). This is an engine-level directive to stop parsing arrays at that number of input variables.

If we search the source code for Debian's 5.2.6 version, we can find that there's no mention of max_input_vars.

The reason: the fix was never backported.

So the argument that "Linux distributions back-port security fixes" is patently false. They miss at least some of them. Especially for unsupported versions.

### Interoperability

The rest of the PHP community has moved past 5.2, and has required at least 5.3 for years. This means that most modern tooling requires at least 5.3, with many tools requiring 5.4.

By leaving the requirements at 5.2, it means that the majority of users cannot adopt the tools that the rest of the community has been using for years. This holds the project and its users back.

It also means that people will re-invent solutions rather than re-use them. It also means that it's harder for users to migrate off of the project to another project.

It pushes up walls.

### Education

Requiring out-dated versions tells users that it's OK to run unsupported software. It sets a bad example.

Projects like WordPress and CodeIgniter should be leading by example. Plenty of people look up to these projects, and will learn how to program from them. They will learn what to do, and what not to do based on what the project does. It is the responsibility of the project to lead.

This is very similar to a blog post I wrote a few months ago: [Educate, Don't Mediate](http://blog.ircmaxell.com/2014/10/educate-dont-mediate.html)...

### New Features

Since PHP 5.2, there have been a TON of important new features that have been introduced. Features that people cannot use if they have to support 5.2. Features such as:

 * Namespaces
 * Anonymous Functions (closures)
 * Late Static Binding (usage of `static::`)
 * Garbage collection
 * Traits
 * Short array syntax (`$a = []` instead of `$a = array()`)
 * Function array dereferencing (`foo()[1]`)
 * Generators
 * OpCache
 * Variadic Functions (~foo(...$var)~)
 * SSL/TLS improvements (actually making SSL/TLS connections from PHP secure)
 * And a TON more.

Namespaces alone have set fire to a revolution in the way PHP code is written. But by supporting 5.2, it means that many users will not get exposed (or be able to use) those features.

## Communities Are Pushing Forward

I don't know enough about the CodeIgniter community to comment, but I know that parts of the WordPress community are stepping up. They are giving talks at user groups and conferences, writing blog posts and spreading the word about moving to modern versions of PHP. They are working on pushing the community forward.

There are people writing plugins that require > 5.2. There are those who are trying to lead by example.

There are those in the community who are trying to push it in the right direction. There are plenty who try to do the right thing.

The problem is that it's not a fight that they should be wasting their effort on. It should be a given. They should be pushing their effort on things that matter.

## It Holds Everyone Else Back

You can be part of the solution, or part of the problem. Historically, projects such as WordPress and CodeIgniter have been reactionary, following the industry rather than leading it. But given their position, and given the users they target, they have the potential to lead.

So I put this to you, WordPress, CodeIgniter and every other CMS and Framework still supporting PHP 5.2 and 5.3 (and earlier versions):

> Step up and lead. Step up and be the change you want to see. Don't follow and react, lead and be proactive.

After all, if we can move forward together, we can all benefit. But if we walk separate paths, we build walls and we all lose...