---
layout: post
title: Slides From "Cross Site Scripting and PHP Security" at NYPHP on 6-30-2011
permalink: 2011/07/slides-from-cross-site-scripting-and.html
date: 2011-07-01
comments: true
categories:
- Slides
tags:
- PHP
- Presentation
- Security
- Slides
- XSS
---

As promised, I'm going to post the slides from last night's talk on XSS prevention with PHP here.  There was a fair turnout, with a few following the live stream of the talk.  I must thank those who came, as there was definitely some good interaction and questions.

<!--more-->


The itself talk went fairly well, barring a few times that Chrome actually thwarted an otherwise valid attack.  It's kind of ironic since some of the attacks are supposed to be transparent to the user, yet the browser actually was able to identify what was happening at certain stages and blocked some of the attacks.  It could be better, but it was pretty good at it.


The live stream wasn't as good as I would have hoped, due to a washed out projector in the video.  I think I might try Camtasia in the future to stream the screen along with a small segment captured from the camera.  I'm just wondering if I want to bite the $200 price tag to try it...


You can [download the slides here](http://www.ircmaxell.com/downloads/NYCPHP_XSS_6_30_2011.pdf).


You can checkout the Bad Web Application that I built [over on GitHub](https://github.com/ircmaxell/XssBadWebApp).

**_WARNING!  DO NOT USE THE BAD WEB APPLICATION ON A PUBLIC FACING SERVER!  DO NOT INSTALL IT ANYWHERE YOU CARE ABOUT!_**

I'll try to do a post over the weekend as a walk through of the Bad Web Application.  For now, you can just take a look at the code and play around with it on your own.


The next talk will be announced in a few weeks, but it will be on [Authentication And Session Management](https://www.owasp.org/index.php/Top_10_2010-A3) (#3 on the [OWASP top 10](https://www.owasp.org/index.php/Category:OWASP_Top_Ten_Project)).
