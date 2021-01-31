---
layout: post
title: Preparing Tech Presentations
permalink: 2013/08/preparing-tech-presentations.html
date: 2013-08-15
comments: true
categories:
- Meta
tags:
- Community
- Conference
- Meta
- Open Source
- PHP
- Presentation
- Rant
---

Yesterday I was asked a rather interesting question about presenting technical presentations. While I don't think my method will work for everyone, I feel it's a good thing to talk about. So here's my method, and some advice that I would give first time presenters:

<!--more-->

> [@ircmaxell](https://twitter.com/ircmaxell) any tips for a first-time tech presenter? How do you prepare your material? Any software you use?— Danny Kopping (@dannykopping) [August 14, 2013](https://twitter.com/dannykopping/statuses/367770730211315712)

## My Process


Let me first start off by saying that my process is very lose and not well defined. So it's less of a "checklist" or "pattern", and more of a general "guide".

### The Idea


My process starts before I ever even write a single thing down. The first thing that I do is start to think about a message that I want to get across. I think about the primary "take home" point, or what I want the audience to leave with after the talk. I start every single talk this way, and try to form every single talk around this one concept.

Typically this is the easiest part of designing a talk. Often times, it takes less than an hour to distill the talk idea.

### The Flow


Once I'm happy with the take-home point, I work on thinking about a flow to the talk. I know the point I want to make, so I start building the conversation in my head around how to make it. This step is `really` informal, and is just a general sketch of an outline in my head. For example, in my `[Don't Be STUPID, Grasp SOLID](http://blog.ircmaxell.com/2012/05/dont-be-stupid-grasp-solid-slides.html)` talk, the flow might look something like this:

> What Is An Object? ->
    
    What Is Polymorphism? ->
    
    What Is An API? ->
    
    What Is A Good API? ->
    
    What Is A Bad API? ->
    
    Supporting Code ->
    
    Good Is Good Enough.



A good talk should tell a story. And like many stories, I find that talks work better in chapters.

Again, I want to stress that this step is not formal. I don't write an "outline". I don't even write it down (formally at least, I may jot some notes down). I just think about it to the point where I can visualize the story flow.

This is also by far the longest part in my talk preperation. I have some proposals in my head that I've put literally hundreds of hours into thinking about the flow and am still not happy with enough to move on.

### The Proposal


Once I have the idea and the story flow in my head, I sit down and write the title and proposal. This is the first time that I formalize the talk in any shape or form.

### The Slide Deck


Once a proposed talk is accepted, I start working on the slide deck. I start off at the start of the talk, and basically put the slides in to tell the story I already have in my head.

I typically do this in three passes. The first pass is just a brain dump of what I think needs to be shown. The second pass I restructure things to make the story smoother. The third pass I add pictures or transitions to help break up the story into digestable "chapters".

Once I feel the deck is complete, I will go over it a few times by myself while talking out loud like I was giving the talk to a crowd. This usually results in a good bit of refactoring of the deck.

Also, I don't write "speaker notes". I try to focus on the slides as the story, and I let the story lead me. I personally find notes distracting.

I've written slide decks in as little as 4 hours, and as long as 40 to 60 hours.

### The Practice


Typically, I try to run through every new talk idea at a user group or smaller venue first prior to giving it at a full scale conference. It really depends on how comfortable with the story and the idea that I am. The more uncomfortable that I am with the story, the more I want to practice it.

### The Conference


If I am giving a talk for the first time at conference scale, I typically will spend the 30 minutes prior to the talk with my headphones in wandering around looking at the sides. I do this to clear my mind and re-focus on the story. Once I've given a talk a few times, I'm typically ok with just walking up on stage and going.

As I'm giving a talk, I try to constantly watch the crowd for what looks like it works, and what doesn't. I'll sometimes take notes about what I felt could use improvement.

### After The Conference


Afterwards, I take those notes and refactor the talk. Sometimes this means tweaking the slide deck. Sometimes it means rethinking everything back to the flow.

As an example, my `Don't Be STUPID, Grasp SOLID` talk is one that I'm very comfortable with, but it's also one that I'm on my 3rd complete rewrite of (going back and rethinking the flow). I am comfortable with the subject, but still am not happy with the talk. This latest rewrite (which I will be presenting this weekend at [NorthEastPHP](http://www.northeastphp.org/)) I think comes closest to what I want the talk to be. But I'll see on Saturday if that's right...

## Suggestions For New Presenters


So that was my "process". For new presenters, here are some tips and suggestions that I have for preparing for your first conference-level presentation:

### Know Your Message


Know the point that you want to make. This seems obvious, but I used to give talks because I liked the subject. I wanted to "talk about it". But I quickly realized that the best presentations have one or two takeaway points that are constantly revisited over the course of the talk. So know the point you want to make, and know it well.

### Find A Cadence


I like to give my talks a predictable cadence. What that means is that I try to look at the "depth" of technical information I am discussing. I like to transition back and forth between high-level (easy to understand) and deeply technical (more specific) content. Ideally I like to hit "high-level" summary information every 5 minutes or so during the talk.

If you charted the talk, technical depth over time, it should look somewhat like a cosine wave. It starts High, then goes Low (detail) then comes back high, and goes low and high and low and ends at a high level.

The reason that I try to do it this way is that I feel it keeps a broader audience better engaged. Less technical people in the talk (or more junior developers) will be able to follow the higher level discussions. The more technical people who have some knowledge of the topic will also be able to get something out of the more detailed parts of the discussion.

It doesn't always work the way I'd like it to, but when it does, the results are amazing...

### Be Passionate


The best talks I've ever been in haven't necessarally been from the best speakers. The best talks I've seen came from people who are passionate about what they are talking about. The passion and energy will come through during the talk.

### Talk Slowly


This is something that I struggle with to this day. Partly it's nerves, partly it's that I know what I want to say. But the net effect is the same. I tend to want to rush through the talk. I wind up talking really fast, and breazing through points and slides. I've done hour long talks in 25 minutes because of this.

So I constantly need to remind myself to slow down. It makes for a better talk experience and helps to keep things flowing nicely.

### Pick A Friend (or 2) In The Crowd


One trick that I use whenever I give a new talk (or a talk in a situation I'm not 100% comfortable in) is that I find a person or two in the crowd that I can feed off of. Typically, this is a friend, but it can also be someone that just is engaged with your talk.

Look around the room, but focus on them from time to time. They will be your anchors. Whenever you get to a point where you may feel like things are starting to go wrong, look at them. They will give you the confidence to move past it. Whenever you notice someone look like they are starting to fall asleep, look to your anchors for support.

Basically, they help keep your mind in the game. They help give you the support that you need to deliver a great talk.

### Don't Read From Your Slides


Your slides should serve as an outline for your talk, they shouldn't be a script. Use them to puctuate ideas, but don't get in the habit of putting all of your content onto a slide.

One rule of thumb is that if you need transitions for most of your slides to show content as you talk about it, you have too much on the slide. There are times when having information appear is good (telling a story), but most of the time it's a distraction.

### Just Do It


A lot of people think that you have to be an expert to speak. A lot of people who are plenty smart and plenty capible of speaking avoid it because they feel they are not "enough of an expert" to do it. Pardon the saying, but that's bullshit.

The majority of "experts" are experts because they speak. They don't speak because they are experts. Often enough the only difference between an "expert" and a "non-expert" is that the expert has the confidence to speak about the subject with authority. They may not (and often don't) know more than others. But they can communicate it better.

So don't worry if you're "good enough" to talk. If you have something to say, get up and say it. Your own head is the only thing standing in your way...

## Wrapping Up


What do you think? What's your process? What tips and suggestions do you have for new presenters?