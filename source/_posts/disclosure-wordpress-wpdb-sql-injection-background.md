---
layout: post
title: "Disclosure: WordPress WPDB SQL Injection - Background"
permalink: disclosure-wordpress-wpdb-sql-injection-background
date: 2017-10-27
comments: true
categories:
- Security
tags:
- Disclosure
- Open Source
- PHP
- Security
- SQL Injection
---

Today, a significant SQL-Injection vulnerability was fixed in WordPress 4.8.3. Before reading further, if you haven't updated yet stop right now and update.

The foundations of this vulnerability was reported via Hacker-One on September 20th, 2017.

This post will detail the background on the vulnerability as well as why I publicly threatened to Fully Disclose. There is another post which deals with the [technical vulnerability](disclosure-wordpress-wpdb-sql-injection-technical.html). 
<!--more-->



## The Short Story

In short, the WordPress team released a "fix" in 4.8.2 that broke a LOT of sites. It was shown that the fix didn't actually fix the root issue (but just a narrow subset of the potential exploits).

I reported a new vulnerability the day after the 4.8.2 was released. It was ignored for several weeks. Finally when I got the attention of the team, they wanted to fix a subset of the issue I reported.

It became clear to me that releasing a partial fix was worse than no fix (for many reasons). So I decided the only way to make the team realize the full extent was to Full Disclosure the issue. I started the process of going public by asking for Hosts and Plugin Developers to reach out to me so that we could coordinate the release.

During the planning steps of the FD, the WP team started constructive discussions again. 

The 4.8.3 patch mitigates the extent of the issues I could find, and I believe is the second best way to fix the issue (with the first being a much more complex and time consuming change that still needs to happen).

## Summary / Time-line

 * *September 19th* - WordPress releases 4.8.2 with a "fix"

    This fix doesn't actually fix the vulnerability, but breaks a metric ton of third-party code and sites in the progress (an estimated **1.2 million** lines of code affected)

 * *September 20th* - I file a security vulnerability report and notify them the fix isn't a fix and suggest they should revert and fix properly (with included details on how to fix)
 * *September 21st* - WP closes my report saying "non documented functionality is non documented" (forgetting the 1.2 million LOC that uses said undocumented functionality). I replied a few times saying it was improper to close.
 * *September 25th* - I request public disclosure since ticket remains closed with no apparent resolution

     1 hour later I get a response saying "Sorry for the delay and confusion, we're still looking into this"

In this span, I posted 4 times adding information and requesting this be escalated, as well as addressing the root issue of the vulnerability.

 * *October 16th* - I announce my intention to go public on the 19th, barring any additional contact.

     Same day I receive a reply "I'll get you an update tomorrow"

 * *October 17th* - WP replies with a full history of the vulnerability, but still no indication of anything that I said, nor any indication that they would fix anything. In fact, their exact reply for next steps was:

     > Publishing the details of the issue will be the next step. Once that's done, #41925 can be reopened and work can be done to add in support for numbered placeholders if there are people that want to do so and if it can be done without re-creating any vulnerabilities.

     Note that this doesn't actually admit to any of the issues found so far.

 * *October 18th* - I reply talking about the fact that the vulnerability still wasn't fixed, and demonstrating a black-and-white proof-of-concept as to the break.

     WP replies stating that they are "triaging" the bug (a month into this ordeal) and will fix the `meta.php` issue...

     So far, they haven't admitted root issue (that their prepare system is poorly designed and must be fixed conceptually), but only the surface level repercussions of it (and even then only a few of them).

     Also receive a patch to remove the "double prepare" from `meta.php`

 * *October 20th* - Receive a reply saying "we're working on it" and discussing some details of the fix. Specifically that they are going to try to implement something I had suggested earlier (using a "comment marker" to indicate if a string has been through `WPDB::prepare()` before).

    It's worth noting that the reply indicated some hesitance to fix this because:

    > Regarding broken plugins – I'm sure there are plugins that double prepare things as well. Going this route we're likely to break plugins as well, it will probably just be a different set of plugins.

    I also announced my intention to disclose on October 25th (1 month since I originally requested disclosure).

 * *October 22nd* - Receive a patch to review that adds implements the "mitigation" fix noted above. WP team says they aren't comfortable with the 25th as it's too soon given external factors.

 * *October 23rd* - I reply with a few issues with the patch (most minor, one major). 

    I also ask for an intended date of release so that I can adjust the disclosure time-line accordingly (I mentioned that given the history of this interaction I don't feel comfortable making it open-ended).

    I receive a reply stating that "Several people are traveling and they won't be able to get a date to me by Wednesday the 25th". This also includes a new "mitigation patch" that addresses none of the concerns I raised before hand.

 * *October 24th* - I reply with two significant comments about the proposed patch. I also recommend a different approach (erroring if detecting a double-prepare/etc). 

    I also attempt to recognize team constraints and offer to wait until Friday October 27th to negotiate a release date:

    > I get that there's timing. Get back to me as soon as you can with a projected date. But I won't wait around arbitrarily. I'll push back the deadline for a date until Friday. But by doing that I'm stating I'm not willing to push disclosure past next Wednesday (which will be 6 weeks from the breaking release and the initial report).

 * *October 26th* - Receive a reply from the WP security team. The following quote was included:

    > One of our struggles here, as it often is in security, is how to secure things while also breaking as little as possible.

    There was also significant push-back to solving the `_real_escape` side of the issue. The proposed patch at this point in time only mitigated double-prepare, but purposely didn't address when `esc_sql()` was passed into the query side of prepare (which happens a fair bit thanks to things like `get_meta_sql()` and the `posts_where` hook).

    This appeared to me to be the worst-case scenario. A partial fix which left the main portion of the vulnerability there, but also gave instructions on how to execute it. Seeing as it appeared to hit an impasse, I felt the only alternative I had was to push for FD.

    I replied, announcing my intentions to FD on the 27th if the discussion didn't meaningfully change (if they didn't acknowledge the extent of the vulnerability).

    Publicly, I announced my intention to FD "soon" and asked hosts and plugin authors to contact me to start working out a responsible FD roll-out giving people enough of a head start to cleanly rectify issues.

 * *October 27th* - I receive a reply from the WP security team. A security team member who hadn't yet participated in the thread went back to the beginning of the thread and re-read every post. He (correctly I may add) summarized the entirety of the issues, as well as asked a few clarifying questions. He also asked for a little more time but gave me a target of Tuesday, October 31st so it wasn't wide open.

    This was the response I was looking for the entire time. We were on the same page finally. The discussion immediately turned constructive from all sides and we worked together on a better solution. Turn around time was good (sometimes 2-3 replies per day, not always). But more importantly I think we both got confidence of the release.

    I replied with some comments on the patch/clarifications. We had about 5 replies back and forth that day, all moving solidly in a good direction.

 * *October 28th* - The first version of the patch that I felt good about was created. There was still some work to be done, but here is when it seemed like the problem would be properly (IMO) fixed.

    I also announced that I was scrapping plans for FD as I felt the current patch and time-line were appropriate (barring anything major changing before the 31st).

 * *October 29th-30th* - A bit of refinement and back and forth on the issue. 

 * *October 31st* - Release, and these posts were published.

## On The Security Team's Response

The early experience was troubling. I wrote a few years ago about [one issue](https://blog.ircmaxell.com/2013/07/disclosure-wordpress-wpdb-sql-injection.html), and honestly while it was easier for me to send things to them (via HackerOne), the overall experience hadn't improved (if anything got worse in some aspects).

It took literally 5 weeks to even get someone to consider the actual vulnerability. From there, it took me publicly threatening Full Disclosure to get the team to acknowledge the full scope of the issue (though they did start to engage deeper prior to the FD threat). 

Once the issue was understood, we got to a really good place. If the entire interaction was like Oct 27 - Oct 31, I would have been ecstatic. Even if on a different time-line (the good part wasn't the speed of the replies, but the content of the conversation).

Security reports should be treated "promptly", but that doesn't mean every second counts (usually). I get that there are competing priorities. But show attention. Show that you've read what's written. And if someone tells you it seems like you don't understand something, stop and get clarification.

And ask for help.

Overall, I hope the WP security team moves forward from this. I do honestly see hope.

## These Are Volunteers

I get that. I really do. And I don't blame them for this.

The miss IMHO isn't that a team of volunteers isn't living up to my expectations, but that a platform that powers 25%+ of the Internet (or at least CMS-powered-Internet) isn't staffed with full time security personnel. Volunteers are amazing and can only do so much. At some point it comes down to the companies making money off of it and not staffing it that are ultimately the biggest problems...

## Wrapping Up

The core issue is mitigated. My perspective of the interaction was frustrating at first, but got far better towards the end.

I was disappointed for a good part of the past 6 weeks. I'm now cautiously hopeful.