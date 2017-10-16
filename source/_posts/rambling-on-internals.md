---
layout: post
title: Rambling On Internals
permalink: rambling-on-internals
date: 2013-09-06
comments: true
categories:
- PHP
tags:
- Open Source
- PHP
- PHP-Internals
- Rant
- WTF
---

This is a post that I didn't want to write. Actually, it's a post that I still don't want to write. But I find myself in a situation where I feel that I have to say `something`. So I'm going to just open up here. I'm going to put it all out on the table, and see what happens from there.
<!--more-->

## The Backstory


If you haven't followed the `#drama` of the past week, then you may have missed me rage-quitting the php-internals project on Monday.

> That's it. I quit. Tomorrow I'm going to retract all of my RFCs, and wish PHP a good life. I can't deal with this any more... [#cya](https://twitter.com/search?q=%23cya&src=hash)

— Anthony Ferrara (@ircmaxell) [September 2, 2013](https://twitter.com/ircmaxell/statuses/374658734057717760)

Really, this has been a long time in the making, and has been something I've strongly been considering for nearly a year. It wasn't a snap decision (well, the pushing of the button was, but not the decision to do it).


Let me step right up and say this one point of clarification first: **I left internals, not the greater PHP community**. So I'm still around (for the time being at least).

## The Real Reason


There are actually several reasons why I chose to walk away. So let's go through them:

### Internals Is A Toxic Kindergarden


There's an ongoing joke between many people who follow PHP internals development (or used to follow) that it is a `toxic kindergarden`. The mailing list is a nearly-impossible to navigate minefield of misinformation, misdirection and FUD. This is a problem. But the deeper problem is that the misinformation, misdirection and FUD are completely inconsistent.


I'll give you an example. In the [Function Autoloading RFC Discussion](http://marc.info/?t=137782586100002&r=1&w=2), there were 7 basic things discussed in the 70+ replies (for some reason, marcmail isn't able to find all of the replies):

 * `"This will make function calls slower!"` - Which is pure FUD, since this was disproved early by several people and in the RFC directly, yet people kept bringing it up.
 * `"Will you put every function in its own file?"` - Again, this was repeated over and over in the thread, even though several people pointed out that there are other ways of doing it.
 * `"Just use static methods instead!"` - Yet more misdirection and off-topic pushing
 * `"Just write OOP code instead!"` - Yes, because that's constructive.
 * `"Why don't we pull PSR-0/4 into core?"` - Yes, because that's on-topic.
 * `"People don't use namespaced functions!"` - Yes, because namespaced functions are hard to use in 5.5. Shocker.
 * `"Which function is autoloaded?"` - This discussion point came up later on, and is the only one that is actually valid.

Even though a point is made and disproved, it's still beaten to death. You'd think that [the section in the RFC dealing with performance](https://wiki.php.net/rfc/function_autoloading#performance) would be enough. But nope.


Now, some people have told me "just ignore the banter." Or "Just ignore the trolls." Or "Just put it to vote, you have plenty of support." Which all sounds fine and dandy. Except that the entire point of an RFC process, is that it's a `Request For Comments`. It's not a "here, vote on this and we'll put it in." I didn't create these RFCs because I thought the concept was perfect. I created them because I wanted to get them to a place where they are good. 


To illustrate why this is an issue, I posted [this reply](http://news.php.net/php.internals/68799) explicitly asking for feedback on two items. How many replies did I get? One. A single reply. Oh, there were more replies to the thread afterwards. But they were too busy arguing over the other off-topic or non-constructive things in the above list to actually discuss the open issues with the proposal.


So "ignoring the banter/trolls" is not a valid option, since they are stopping the very discussion that needs to happen. And even if I ignore them, it still kills the very point of having an RFC process.

### Internals Pushes People Away


New contributors can be actively pushed away because some long-time contributors don't agree with a proposal. Now, this isn't saying that every proposal has to be agreed with, but the attitude with which the disagreement is made is `really` condescending and negative.


For example, some people have a very condescending attitude towards the proposals of others, suggesting that they do not stem from a real need, but are created only "because we can." These people do not accept "because many people are asking for it" as a valid justification for a proposal.


That would be bad, but not horrible, if it wasn't for the fact that these same people themselves use ["because many people are asking for it"](http://news.php.net/php.internals/68868) as a justification. And when [someone calls him out on it](http://news.php.net/php.internals/68870), it's ignored by the rest of the community.


If it's bad for a new contributor, it must be bad for an old one. And if it's ok for an old one, it must be ok for a new one. Any different is just toxic.

### Internals Lacks Vision


I've talked about this before, so I won't spend too much time on this. But the PHP internals project lacks vision. Everybody has their own idea of what PHP should be, and that's explicitly the way some people want it (they think that's fine). This means that discussions have entirely different baselines of what PHP should be, which contributes to the toxic kindergarden above.

### Internals Lacks Leadership


It's no secret that there's a total lack of leadership in the PHP project. There are a few people that could play that role (they have enough respect and position), but they choose not to. Or at least they choose not to consistently (an inconsistent leader is worse than no leader).


Now, I'm not saying that PHP needs a benevolent dictator. But I do think that there needs to be leadership. There needs to be a person or group of people who can actually set a vision, and enforce it. Perhaps this means an elected body. Perhaps this means something else. I'm not sure. But I do know that some sort of leadership is needed.

### Internals Lacks Regulation


Ideally, a community should be self-regulated. Where individual members call each other out for crossing lines or acting in a detrimental way. 


To be fair, there are a few people on internals who have tried to do such. But self-regulation is not something that can fall on a few people. It is something that takes a community to do. And as far as I can tell, the community as a whole is not interested in that.

### Contributors Don't Think There's A Problem


There have been several times that I've been told to "just ignore the trolls" by long-time contributors. They have said "you have silent support" and "just put it to vote, and be done with it".


When people on-list raised a concern [one of their replies](http://news.php.net/php.internals/68893) included:> I am also relatively happy with the situation compared to other projects (try to do it on the kernel mailing list f.e.)

I can't even begin to express how disappointing that stance is.

## Is The Project Doomed?


Absolutely not. It has survived for years, and it will continue to survive. That doesn't mean thrive, but it does mean survive. 


I think the project \*could\* thrive. I think if the problems above (and others) were rectified, that the project could really thrive and keep moving forward. But as it stands now, the burnout rate is extremely high. And while there will always be new contributors, there's something to be said for consistent progress rather than spurts of progress...


How could it be improved? Well, for starters, I think that everybody that's even remotely involved in internals needs to stop and go watch [How Open Source Projects Survive Poisonous People](http://www.youtube.com/watch?v=ZSFDm3UYkeE). I'll even embed the video here (it's that important):

<iframe allowfullscreen="" frameborder="0" height="394" src="//www.youtube.com/embed/ZSFDm3UYkeE?rel=0" width="525"></iframe>

## Wrapping Up

I won't put an absolute "I'll never go back to PHP internals again" statement out there. But what I will say is that if things don't change, I don't see any reason for me to go back. But if things do change, then that door will open wider.

But as it stands right now, I don't think it's fair to myself to have to put up with it. And I don't feel that it's fair to the greater community either. But unless people realize and talk about the problems, they can never be solved.

### The Support


This week I have also gotten a lot of support, and I think it's really important for me to recognize that here. In fact, these people are the very reason that I am writing this post. These people... Well, there aren't a lot of words I can say. Let me share a very small sampling of what I have received:

> [@ircmaxell](https://twitter.com/ircmaxell) I hope you can reconsider. I've really valued your contributions to the community.

— Jeremy Cook (@JCook21) [September 2, 2013](https://twitter.com/JCook21/statuses/374660746644176896)

> [@ircmaxell](https://twitter.com/ircmaxell) This will be a major loss to the community. Hopefully things can be worked out.

— Cory Fowler (@SyntaxC4) [September 2, 2013](https://twitter.com/SyntaxC4/statuses/374662996087173120)

> [@Mark_Baker](https://twitter.com/Mark_Baker) [@ircmaxell](https://twitter.com/ircmaxell) I'm going to second Mark's comments. I too appreciate your hard work - as do many, many, more I'm sure.

— Anthony Sterling (@AnthonySterling) [September 3, 2013](https://twitter.com/AnthonySterling/statuses/374759363195715584)

> . [@ircmaxell](https://twitter.com/ircmaxell) is doing a great job with his PHP RFCs. I will be sad if he turns away from PHP internals. He will always be one of my heroes.

— C. Hochstrasser (@hochchristoph) [September 5, 2013](https://twitter.com/hochchristoph/statuses/375578009601703937)

Not to mention a blog post by Luis Cordova [I Don't Understand PHP Bureaucracy, But I Do Understand Anthony Ferrara](http://www.craftitonline.com/2013/09/i-dont-understand-php-beaurocracy-but-i-do-understand-anthony-ferrara/).


Not to mention several extremely positive and encouraging emails.


To put it simply, I am touched. I don't know what to say. I really don't. Except **`_thank you_`**.

