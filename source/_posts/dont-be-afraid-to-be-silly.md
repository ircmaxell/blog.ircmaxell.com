---
layout: post
title: Don't Be Afraid To Be Silly
permalink: dont-be-afraid-to-be-silly
date: 2013-01-07
comments: true
categories:
tags:
- Architecture
- Best Practice
- Learning
- PHP
- Silly
---

When was the last time you were silly? Well, more specifically, when was the last time that you wrote code that was downright silly? I'm not talking about writing code that's dirty, or hacking something together. I'm talking about writing code that you `know` before writing won't work, or is wrong or is just plain silly... I'm talking about the kind of code that you think that if you show other developers, they'll just sit back and go `"Why the #@$% would you do that in the first place?"`... Well, I do it quite often, and let me tell you why you should do it more as well!
<!--more-->

## For The Fun Of It


I don't know about you, but I got into programming because I enjoyed it. More than just that, I got into it because I loved it. I loved the power that I had discovered. I could type some gibberish into a text editor, compile, and I had a program that did what I told it to. It didn't matter that the program was as useless as a car with no gas. Or that it was inefficient as driving a tank to the grocery store. Or that it was as poorly coded as WordPress.

What mattered was that it was fun getting a computer to do something that you told it to. It was awe inspiring, entertaining and powerful. But somewhere along the line, I stopped writing code for the fun of it, and started trying to get better at it. I tried to write useful code. I tried to write efficient code. I tried to write clean code. In the process, I learned a hell of a lot, but I also lost something. I lost some of that spark that came from trying things. 

So that's one reason I write silly code. Because it's just fun to pick an idea that's so far in left field that that the question of "if I can do it" transforms into "why the heck should I do it". And keeping things fun is a huge key to keeping proactive and not sitting back and resting on your laurels.
## Experience Is A Lousy Teacher


In the grand scheme of things, Experience is a pretty lousy teacher. It gives you the test first, and the lesson later. But even worse is that experience tends to teach complacency. In a former hobby of mine (firefighting), we had a saying: `"Complacency Kills"`. The reason is that if you do something 99 times, and nothing bad ever happens, you develop a complacent attitude that something bad will never happen. And by developing that attitude, you stop paying attention and taking events seriously. And that's exactly when bad things do happen.

But there's an even darker side to experience. Experience only teaches good lesson when things work. It doesn't teach a good lesson when it doesn't. Have you ever heard someone say "In my experience, that won't work". The next time that you hear that, alarm bells should be going off. The reason is that there are a lot of reasons for something to fail. If you try a code technique, or a new framework or an architecture, and it fails, there are a ton of reasons that it may not have worked. But very few of those reasons are the technique itself. Most of them are caused by the things you glossed over and forgot about.

So don't be complacent. Don't trust your experience on bad ways to do something. Be silly and purposely try something that previously failed you. I'm not saying to bet the bank on it, but at least take a little time and investigate it properly before completely dismissing it. Be silly and put your negative instincts on hold for a a minute. I'm not saying to dismiss them in their entirety, but to at least give it a fair shot. Trust your experience when it says that something will work, but be cautious when it says it won't...
## Being Silly Usually Isn't As Silly As It Seems


Quite often when we're discussing a problem at work, I'll propose a silly sounding solution. Not because I think we should do it, but because the discussion usually leads somewhere interesting. Every once in a while, the idea that sounded silly in the beginning winds up actually being pretty useful. Even if nobody sees it in the beginning (not even yourself), the train of thought and discussions that the silly idea stimulates are invaluable.

Furthermore, just because an idea is silly, doesn't mean it isn't useful to someone. When I started the development of [PHPPHP](https://github.com/ircmaxell/PHPPHP), it was a silly idea. Hell, it still is a silly idea. I mean, a PHP interpreter written in PHP? What the heck? But even now, just a little over a week since the first commit, it's already showing some usefulness. And the amount that I've learned about the Zend runtime engine is extremely valuable. All from such a silly and dumb sounding idea...
## Putting It All Together


Don't be afraid to be silly. Don't be afraid to propose a silly idea. Don't be afraid to try something silly. One of the easiest ways to combat complacency is to temporarily throw out everything that you think you know, and try to do something that you "`know`" you shouldn't. Now I'm not saying to go replace your production database with a flat file, but don't rule out the concept in a development test environment until you \*know\* it won't work...

Here's a silly idea for you to try (that I've always wanted to try, just haven't had the time): create a NOSQL database based on GIT (using GIT as the back-end "commit" storage mechanism). And then try to get it to use git remotes to enable replication. Sure it's a silly idea, but who knows what cool things may come from it...

What silly idea have you tried recently?