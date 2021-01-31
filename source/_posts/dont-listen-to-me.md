---
layout: post
title: Don't Listen To Me!
permalink: 2012/08/dont-listen-to-me.html
date: 2012-08-10
comments: true
categories:
- Meta
tags:
- Best Practice
- Language Agnostic
- Learning
- PHP
- Rant
---

Or anyone else for that matter. Lately, I've been getting a lot of feedback about my posts that I'm suggesting things that are going to get less experienced developers into a lot of trouble. Or that people are going to use my posts as justification for bad practices. Or that people are going to cause major issues by putting experimental concepts into production. My initial response is "That's their problem."<!--more-->


## Never Believe What You Read


Most of my posts are not tutorials. I'm usually posting about abstract concepts and methodologies. And most of those are controversial (to say the least). I don't want you to believe what I write. I don't want you to believe what anyone writes. "But person X said so" should never **ever** be a valid justification for anything short of a boss dictating process. You should be building your own mental model of how things should be done. Take input from others (especially industry opinion leaders) to help form those models, but make sure that you're thinking for yourself.

There's a quote which I really like about opinions:> `If a man isn't willing to take some risk for his opinions, either his opinions are no good or he's no good` - Ezra Pound


One of the reasons that I like this quote so much is that it encourages us to think for ourselves. It encourages us to form our own opinions even if they go against what others believe. It encourages us to analyze opinions and not reject risky ones, but to attempt to understand why they are formulated. If everyone holds the same opinion, either it's really a good option, or it's just fad/cult mentality where people don't want to think for themselves.
## My Process


When I read a new post or book, I always assume that the author is wrong. And not wrong like is missing a few details, wrong as in fundamentally wrong. Then, as I read, I try to prove to myself that my assumption is incorrect, and they are in fact correct. By taking this approach, I find that I'm able to extract more useful and meaningful concepts from the article than if I approached it from the angle that the author is correct from the start. 

If I still disagree at the end (am not convinced that my original assumption is incorrect), I look back and try to think about why it's not correct. I try to understand what the author was trying to say from their context. And usually, I can find at least one or two good components to even the worst article written. I then can use that to further evolve and shape my own mental model. 

That also impacts how I write posts. I tend to want to post about things that I don't think are covered well, or take controversial opinions. Not because I necessarily think that my opinions are correct, but more that I think that for the topic in question the general opinion is biased towards one side. In my post about the [Space Shuttle's Code Process](http://blog.ircmaxell.com/2012/08/thoughts-on-space-shuttle-code-process.html), I presented an almost heretical viewpoint that sometimes it's not worth while to find and fix all bugs. A lot of people disagreed with my point. But I think what a lot of people missed is that real life is not black and white. 
## The Real World


If we were all stuck in an academic setting, we could argue about perfection all day long. But the reality is that most of us live in the real world. In a world where no two projects are the same. In a world where no two clients are the same. In a world where a tiny deviation in requirements can have a catastrophic impact on the delivered application.  We are in a world where procedures are actually a damaging concept. Where we need more flexibility in what we do.

To explain where I'm going, let me tell a story. Many years ago I was a volunteer fire fighter. At the time I started, the consensus was that every department had a set of Standard Operating Procedures (SOPs). There were hundreds of procedures for many of the different types of circumstances that we'd encounter in the field. If we encountered a problem, we'd look up the procedure for that problem and execute the procedure. Sounds simple, right?

Well, the problem came that we weren't being efficient. There were many situations we came across that dictated a different solution, but we were stuck with our "standards". There were also many situations that didn't quite line up with the standards that were provided. So a better solution was needed. The community had started to move away from SOPs to SOGs. The G stands for "Guidelines". 

So now we have a series of guidelines to follow. Same problem, right? Nope. The guidelines are just that, things that we agree we should do if possible or appropriate. You can break a guideline, you can't break a procedure. By setting up the guidelines, we were able to become much more adaptable to different problems. But that started showing a different problem.

With procedures, any idiot who can understand how to execute a step can complete them. But with guidelines, it requires someone who understands the concepts in much more detail to be able to decide what's best for a particular situation. And that knowledge requires understanding of a number of ways of how to do something. After all, how can you understand why one way is better if you've never learned any other way? If you never push your limits, how will you know where they are when your life (or other lives) depends on it.

Now, we're not risking lives in software development (I surely hope you're not using PHP if you are), but I think the same approach can apply here. That's why I tend to post controversial topics. Not that I think they are right, but I think we need to understand them to become better. The typical mantra of "just let a framework do it for you" helps nothing except creating brainless code monkeys. That doesn't mean a smart developer can't do brilliant things with a framework, it just means that the approach should be different.

So don't just develop a procedure and stick to it. Don't just install framework X for every project, and go through the same recipe. Think about what it takes, and if it makes sense to do that, by all means go for it. But understand everything that's at play. Understand the tradeoffs. Understand what you're doing. And most importantly, make a decision. Don't just let one be made for you.
## What Production Means


I've said a number of times in prior posts not to do something in a production application. Usually it's in the context of an experimental concept or something that you should do for educational value. But the important thing is that you shouldn't do it in production. Well, that's not entirely true. Here's a flow chart that I would use to determine whether to try an unproven concept or not:[![](http://3.bp.blogspot.com/-qyMGndKVC2s/UCQHSpORLEI/AAAAAAAABEQ/MquhyTiLmrU/s640/Experimental_Concepts.png)](http://3.bp.blogspot.com/-qyMGndKVC2s/UCQHSpORLEI/AAAAAAAABEQ/MquhyTiLmrU/s1600/Experimental_Concepts.png)

As you can see, the circumstances where it's acceptable to use an experimental concept is very narrow. And almost all production code for a client will fit solidly in the "Hell No!" category. The only projects that you would professionally use an experimental concept would fit into the category of long timelines, high risk tolerance, unique project requirements, you have team buy-in for the change and it's a short-term project (meaning that there's nothing to maintain long-term). If those don't hold, you shouldn't be trying something new in the production concept.

Note that I'm not saying that you shouldn't be trying new things. Try them on your own. Try them on side-projects. Experiment all you want. But when you're doing work for a client, do it right. If you feel that your concept is developed enough to not be classified as experimental, but is new, then run it through this flow chart at least once successfully (implementing it) before using it on more important projects.
## Closing Up


I really think that the cult mentality that surrounds many open source projects is worse than bad. I think it's a huge step backwards. I'm not talking about using frameworks or believing in popular opinion. I'm talking about believing something because the group believes it. I've talked to a number of people who say that Symfony's Dependency Injection is good because `[Fabien Potencier](http://fabien.potencier.org/)` said it was good (note, not a personal attack against him, just that I've heard his name used specifically on multiple occasions). They couldn't justify why it was good except that Symfony used it, and they wouldn't if it wasn't good. While having thought leaders is good, blind following is far worse. 

I want you to think for yourself, and judge the concepts for yourself. I want you to take some risks with your opinions. I want you to question everything. Not because everything is wrong, but because if you don't question it, how can you hope to understand it? Even if you completely disagree with what I have posted (here and in the past), if it made you think for even a second, then I've done my job. 