---
layout: post
title: A Tale Of Open Source
permalink: 2012/07/tale-of-open-source.html
date: 2012-07-04
comments: true
categories:
- Open Source
tags:
- Open Source
- PHP
- Programming
---

As recently as 5 years ago, I barely understood the meaning of Open Source. I had been working with computers for my entire life (I was using a Commodore 64 before I could walk). I had been programming them nearly as long (I wrote my first program before I started grade school). I was an early adopter of Linux (I still have a Red Hat 1 disk somewhere). But I never guessed the impact that open source would have on my life. I never appreciated the impact that open source would have on the world. The past 5 years have changed me forever. This is my story.<!--more-->

## The Early Years


I have been using and programming computers for as long as I can remember. Before the days of the internet as we know it, I was involved in Usenet and the dial-up BBS groups in the area. To say that I was into computers would have been an understatement. By the time high school came around, I could program in nearly a dozen languages. I was even dabbling in areas of questionable legality relating to system security (I'll leave it at that).

Early in high school I came to a realization: I really didn't like computers anymore. I was good at using and programming them, but -to be frank- they pissed me off. I would rather spend my days fishing or camping than working with them anymore. So I did. Then I was introduced to the concept of flying (I lived down the street from a small airport growing up). That dominated the next few years of my life. I worked at the airport for nearly 4 years (off and on). I got my pilots license before I got my driver's license. By the time I turned 18, I was burning myself out of it. I could have made flying my career. But my father was insistent that I shouldn't. He was insistent that I was capable of more (this bothered me at the time, but in retrospect he was absolutely right).

I still wasn't ready to go back to computers. I spent the next 5 plus years going back and forth with new adventures. I spent a few years as an EMT for an ambulance transport company. I spent a few years on a volunteer fire department. I worked night security for a hospital. I tried studying mechanical engineering in college (that didn't work out). I bounced back and forth looking for something that fit. Looking for something that was challenging in the way that I didn't realize I needed.

Then one day, a friend of mine came to me with an idea for a website. He knew I was good at computers, so he asked for my help. The two of us built the site using Mambo (an open-source CMS). It felt good to get back into computers, but I was still unsure. I was working at the hospital at that point. Which left me a good deal of time free (even on shift there was a lot of down time).

## The Turning Point


In retrospect, there is one decision that set the rest in motion. I had stumbled upon a site called [Woot!](http://www.woot.com/). I became obsessed with the site and its highly addictive Woot-Offs. At that point in time, there were only a handful of [Woot-Off Checkers](http://woot.wikia.com/wiki/Woot-Off_Checkers) out there, and they all were unreliable at best. So I decided to build my own. Little did I know what I was getting myself in to. 

I soon realized why there were no reliable checkers out there. They get **a lot** of traffic. On the order of 200 to 500 requests per second, during peak times. That led me to try to learn as much as I could about performance tuning. Before long, I was running my own dedicated server, serving traffic with 100% uptime during Woot-Offs. I decided to build out a site for it, and based it on the CMS that I knew. Now, this was shortly after the fork of Joomla! from Mambo. So I picked Joomla!, and built the site. 

And immediately took down my server. There was so much to Joomla! at that time that it just couldn't sustain that level of traffic on that little hardware. Since I wasn't making much money on the site, I just decided to try to performance tune it myself. After months of tweaking and testing, I had a Joomla! site that could handle the needed traffic on a single box. The patch to core was so extensive that it actually was larger than the stock core itself. 

I didn't return that patch to core. But I did take some of those lessons and make a component that used some of those lessons and made them available to the community as a whole. Before long I had been noticed by the Joomla! team. I was contacted by one of the core team members on the side. We worked together for a little while and he helped me build and maintain another site that I had built, [JoomlaPerformance](http://www.joomlaperformance.com/).

## My Joomla! Days

Shortly there after, in mid 2007, Joomla! held a PBF (Pizza, Bugs and Fun) event in New York City. I was told that I should attend by a few people, so I went. It was such a successful event, that I was given commit access during the event (Not many other community members attended). It was there that I met some of the closest friends that I would have for the next several years. For the first time in my life, I was on a development team.

I quickly realized that I was wasting my time at the hospital and went and found a development job. I got a job as a junior developer for a small market-research company. I was now a professional developer.

But the opportunities at Joomla! quickly blossomed. I went from a lowly developer to a team lead in a few short months. I was one of the few with the privilege to lead the team that squashed the remaining bugs in 1.5 (then in RC for nearly a year). In January 2008, our team (The Bug Squad) played a huge role in releasing 1.5.0, and maintaining it through point releases. I was then asked to be on the core team of the project as a development coordinator. I took that role and proceeded to form a dedicated security team and start forging inter-project collaboration with other CMS projects. In 6 short months I had gone from never contributing anything to any open source project, to the top of one of the largest (in the CMS scene at least).

The year that followed was a blur. I was invited to talk at and keynote conferences all over the world (both Joomla! related, an non). I was learning so much from my fellow developers (and non-developers). I was enjoying every minute of it, but it was starting to wear on me. I was growing distant from some of the other core team members. I was starting to disagree more and more about how things were run, and how decisions were made. I was starting to realize that I didn't agree. It was more than not agreeing though. It was a feeling like everything I was working for was being thrown under a bus.


But it was deeper than that. It had become apparent that I wasn't doing it because I wanted to do it anymore. I was doing it because I had fallen into it. I disagreed with the direction that the project was taking. I felt that I was holding it back. I felt that it was holding me back.


At the same time, I was working on a new business with a few friends from the Netherlands (who were also connected to the Joomla! project). It was time to leave the Joomla! project. So, with a bit of drama, I left the project in 2009.

## The Dark Years

That side business fizzled out as well, because I was just too burnt out to continue. I had spent approximately 80 hours per week since I joined Joomla! between my day job and the other activities. I was done. I wanted some time to myself. I kept working, but I stayed away from the computer during my free time. I had told myself that I'd never be involved in another open source project again. I was that bitter and burned out.

So I took up golf. I spent time playing with my niece and nephew. I was enjoying life in the real world, not just the digital life. But I still was working as a developer. I was still connected, but I cut almost all ties with the community that had been my home for the past 2 years. I was trying to enjoy life. But something felt missing. I started messing around with security again. I found new vulnerabilities, and reported them to a number of projects. But it wasn't enough. Then, in late 2010, I started hanging out in the [Stack Overflow PHP chat room](http://chat.stackoverflow.com/rooms/11/php). I had a community again.

## The Shake-Up

My job was going well, until we got a new managing director. Let's just say we didn't see eye to eye on just about anything. He let go the entire development team with the exception of myself. When I asked to be shown something to prove that the company was loyal to me, he told me "I think 4 years is enough with one company in this day in age, if you came to me tomorrow and resigned, I wouldn't be upset"... And so I did. 

Oddly enough, I owe my current job to a competing CMS: Drupal. I had gotten an interview at a startup in NYC on one Wednesday last spring. I saw that the NYC Drupal community was having a "Happy Hour" that night. So after the interview (which went very well), I headed up to drink with a few people I hadn't seen in years. It was there that I met my current boss. We talked for a while, about everything programming related. I was about to head home, and he asked if I had a resume (of course I did). I interviewed there a few days later and started shortly after. 

## The Past Year

Once I started working in a healthy environment for a change, I started blogging more. My blogs were starting to get some interesting traffic levels. Apparently someone was interested in what I had to say (although I do like to stir the pot). I also started following [php-internals](http://news.php.net/php.internals). I was getting interested in what was happening in the core. I was also starting to reference the C source code for PHP to figure out why it behaved in a certain way. Before long, I had an understanding of how PHP worked internally. 

And before long, I started building my own patches to PHP to get the behavior I wanted. I put up a few RFCs, and started lots of discussions on internals. I pissed some people off. I made some new friends. Eventually, I was given commit access to PHP. For the second time in 5 years, I am involved in an Open Source project again. I don't want it to go where it went last time. I want to stay on the fringes. I want to contribute.

## Why

Why am I writing this? I don't know. It felt like something that I needed to say. Nobody really knew the full story of what happened. I'm a huge supporter of open source projects. They have been a huge part of my life. There have been ups and downs, but in the end it was all worth it. So I want to say thank you to everyone who's been a part of that experience. From the bottom of my heart, thank you.

Anthony

> So, what's your story? If you don't have one, there's no better time than now to start...