---
layout: post
title: A Failure Of Process (Tools Are Not To Blame)
permalink: failure-of-process-tools-are-not-to
date: 2011-08-24
comments: true
categories:
tags:
- Best Practice
- PHP
- Programming
- Rant
---

A tool is only as good as how it's used.  It seems like such a simple concept, yet it's amazing to see how many people get caught into the trap of thinking that because a tool is there, they are safe.  We see it all the time in almost any industry.  Company X pays untold millions of dollars for a product, just to find out later that it didn't do what they needed.  It's such common sense that it's hard to think of someone logically arguing against it.  Yet the same mistake is made over and over and over and over again.  And on August 18th, we saw a really blatant example of this with PHP's 5.3.7 release.

<!--more-->
## The Backstory



PHP version 5.3.7 was released gold on August 18th.  But a critical level [bug](https://bugs.php.net/bug.php?id=55439) was filed on the 17th.  The bug was seen as so important, that 5.3.8 was released just 5 days later to fix it.  It was a bug in the `crypt()` function which hashes passwords.  So all sites that use MD5 `crypt()` would not be able to verify their users' passwords.  And worse yet, any new passwords hashed with MD5 `crypt()` would be stored in a unverifiable state.  So it's actually a fairly significant bug.

## Shouldn't Tests Have Caught This?



Yes, a test `should` have caught this bug.  That's why we write tests, isn't it?  To catch big issues like this?  Well, as it so happens, there was [a test](http://svn.php.net/viewvc/php/php-src/branches/PHP_5_3/ext/standard/tests/strings/crypt.phpt?revision=242949&view=markup) that was able to catch this bug.  As a matter of fact, the test did catch the bug as well (as seen from a comment by stas on the bug report).  So why was 5.3.7 released if this test failed?

## The Tools Are Working Fine



Right now, PHP 5.3 has [200 failing tests](http://gcov.php.net/viewer.php?func=tests&version=PHP_5_3).  5.4 has even more at [218 failing tests](http://gcov.php.net/viewer.php?version=PHP_5_4).  The tools to improve quality and prevent regressions are there.  It's not like no tests exist.  If we look at the [graphs](http://gcov.php.net/viewer.php?version=PHP_5_3&func=graph&mode=Year), we can see a rather disturbing trend: over the past year, about 100 failing tests have existed in the core (5 releases in that time), and in the past 2 months, that number has doubled.  That's actually a very good sign.  It means that the tools are doing their job.  They are pointing out things that are broken, and that need to be fixed. 


Let me say this again.  A failing test is a good thing.  It shows you that something broke and must be fixed.  But that last part is the key.  It **MUST** be fixed (even if the test needs to change, it still needs to be fixed).

## The Process Is At Fault



So the problem is not that there weren't tests (there were).  The problem is not that the tests weren't run (they are run nightly).  The problem is that releasing PHP with failing tests has become not only acceptable, but actually the norm...  If nobody wants to fix the bugs, then edit the tests to test for the failing issue (hence turning the failing result into a passing one), and mark the issue a "Known Issue" in the bug tracker to be fixed in a future minor/major version. 


The reason is that looking at the number of failing tests tells you nothing.  How do you know one test wasn't accidentally fixed and another failed?  What if the reason for a specific test failing changed?  The only sane solution is to not ship unless there are literally 0 failing tests.  And it seems that[ Rasmus seems to get that](http://news.php.net/php.internals/54828).


The simple fact of the matter is that PHP has gotten complacent.  They have been releasing with failing tests for so long and maintained reasonable stability that there's no apparent incentive or benefit to do so.  There was a saying when I was on the Fire Department: "`Complacency Kills`"...  It's one of the worst possible things that can happen to someone with responsibility (especially responsibility that people depend upon, either for their job or for their life)...


Another way of saying it is that an expected failure is a dumb idea.  Failure is failure.  An expected failure would be like you saying "Officer, yes I am drunk, but I expected to be, so I am fine to drive home"...

## Tools Need Human Intervention



A tool is only as good as how it's used.  You will get absolutely no benefit from using a tool unless you adjust your process to utilize that tool effectively.  Just having and using a tool won't help you one tiny bit.  This latest PHP fiasco is proof positive of that much at least...


It's kind of odd posting this, since this seems like such common sense to me that I feel like everyone reading it will simply say "duh, that's common knowledge".  But apparently it's not, since the mistakes are still happening (and PHP is only an example, these kinds of mistakes happen every single day)...  So please don't take this as bashing on the PHP developers.  I just wanted to use this incident as a basis for pointing out that the process is more important than a tool...
