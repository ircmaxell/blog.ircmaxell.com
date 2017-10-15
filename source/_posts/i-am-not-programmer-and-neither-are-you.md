---
layout: post
title: I am not a programmer. And neither are you!
permalink: i-am-not-programmer-and-neither-are-you
date: 2012-11-09
comments: true
categories:
tags:
- Good Enough
- Learning
- Philosophy
- PHP
- Programming
- Rant
---

Last weekend I was at the [True North PHP conference](http://truenorthphp.ca/) in Toronto, Canada. Aside from being an incredible experience (really, it was an incredible conference, huge props to Chris Hartjes ([@grmpyprogrammer](https://twitter.com/grmpyprogrammer)) and Peter Meth ([@mrpmeth](https://twitter.com/mrpmeth))), it was an inspiration. I was particularly inspired by both of the keynote speakers. They both really took really unique spins on programming and how the culture of open source inspires, enables and empowers programmers to do cool and important things. The problem with all of this is that I hate the term programmer. I think it unfairly paints a picture of what we do. Let me elaborate.<!--more-->
## An Analogy


Before I get too deep into my angst against the term programmer, let me start off by taking an example from outside of technology. Let's say that we want to have a book written in English. We can either hire an Author to write a new book to convey our message, we can hire a translator to translate an existing book in a different language (let's say Russian) into English, or we can use a tool like Google Translate to do it for us. Let's examine what each would do starting with Google Translate.


The Google Translator would basically be doing context-free grammar based translation on the foreign content. What that means is that it looks at a sentence by itself and translates each word according to gramar rules. So what comes out on the other side is usually valid English, and you can usually infer the meaning of the sentence from the translated content. But something is missing. When reading the translated content, you can only get a cursory understanding of what was written. Something's missing and feels out of place. Sometimes adjacent sentences seem to be completely unrelated. Sometimes entire paragraphs look like they were produced by a random sentence generator.


The reason that these "grammar based" translators don't really feel natural is that they lack the ability to translate the context behind the sentences. Even deeper than that though, is that they lack the ability to translate the cultural contexts that are embedded into the original work. They lack the ability to read between the lines to what is meant, rather than what is written. That's the benefit that you get when you hire a professional human translator. They don't just rewrite what was written in a mindless fashion. They understand the original piece, and rewrite the contextual meaning of the work into the new language.


This is a very important distinction. The human translator's output will likely have fairly significant differences in terms of how the message is conveyed from the original. The further apart the cultures are, the more significant the differences in the works will be (which is why I chose Russian and English). The interesting point here is that human translation is not a transcription based on rules like Google Translate was. It is a more intimate and creative process. Indeed, the human translator imparts their own experience and culture on the finished document. It's a much more involved process.


However, even though the human translator is more creative, it still lacks the abstract creativity that the author possess. The author can take abstract and high level concepts and convert them into complete works. The translator only ever works with the low level and defined concepts and translates them from one language to another. So the author's job is a far more broad and encompassing one than the translator's is. I don't want to say that the author's job requires more skill, because that's relative to what and how each works. There are going to be cases where the translator's job requires significantly more skill (such as translating from dead cultures, where the translator also needs to be an expert researcher and historian). But the point remains that both are very different jobs.## Back To Programming


If we draw that analogy back to programming, we get a rather interesting insight into our every day jobs. The Google Translate of the programming world is the compiler. It takes code written in one language, and transcribes it according to gramar rules into a different one (usually machine code). It can't tell anything about the "meaning" of the code, and is rather deeply tied to the gramar rules of each language. Any inconsistencies or oddities result in bugs in the output. It doesn't translate meaning, only the gramatical and syntactical rules of each language. So far, not so interesting. We've equated the computer's task in translating to the computer's task in programming. Big whoop.


The interesting part comes when we look at what happens to the human roles. I consider the human translator to be the equivalent to a programmer. In this context, a programmer is someone who takes low level information in a human parseable language (requirements, design specifications, architecture) and translates them into the language that the computer understands.


Now it's worth noting that, like the human translator, the programmers role is not a simple one. It requires a great deal of skill to be able translate a specification into working software. It also requires a great deal of skill to even parse a specification and understand what's going on. But the point that I'm making here is that it's less of a creative skill and more of a comprehension skill. To be a good programmer requires being able to understand the culture of the computer as well as of the person writing the specifications. It's a hard job, and someone has to do it.


But there's another role that I really want to talk about. For the time being I'm going to call this roll a Developer, but it can be called many different things in practice (Software Architect, Software Designer, Software Engineer, Business Analist, etc). The important thing to note here is that the developer's role is not to translate specifications into software. The developer's role is to translate abstract business requirements into solutions. Sometimes that involves writing code to solve the business problem. Sometimes it involves writing specifications to give to programmers to implement. But sometimes it involves recommending using a pre-built tool. And sometimes it involves recommending a change in the business process that led to the requirement in the first place.

## Enter the Problem Solver


When you look deeper at the relationships involved here, the developer's role appears to be less about writing software and more about solving problems. Usually those solutions will require writing software, but while the programmer is limited to writing software to solve the problem, the developer has no such limitation. The developer is free to suggest what they feel is not only the best solution for a particular problem, but the right one. It's a more liberating role, with a lot more responsibility.


To a programmer, the only requirement that they put on the business is that the specifications that they receive must be internally consistent (one part of the spec can't say the result must be true, and another part say it must be false for the same inputs). But a developer has a different interaction with the business. A developer is not just a tool, they are a partner. A good developer will give business feedback and work together with the business rather than for the business.


This sounds simple and intuitive, and it really is. But it's also counter to the traditional culture of the business-worker relationship. The typical American culture of "go to work, do what you're told and go home" really works against this whole philosophy. Now, I'm not implying that you should say no when asked to do something, but I'm saying that you should make it a conversation. If you think that what you're being asked to do is wrong (for whatever reason), it's your responsibility to say something.


In practice, there will be times where you just need to Get Shit Done(TM), and you'll have to accept "just do it" as an answer. An example would be when up against a tight deadline, sometimes going down what seems the wrong path as a team can be far more productive (for the business) than trying to constantly correct it. I say "seems" there, because there are examples where you can refute this. But for the most part, times like this (tight deadlines, dealing with an outage, etc) "get it done" can be more important than "get it done right". It's the classic debate between Good and Good Enough.

## Your Value


The important thing that I'm trying to get across here is that your value to your company is not in writing software (unless you're dealing with a 500 person development team). Your value is in your ability to solve complex and abstract problems. Your value is in your ability to not just "do what you're told", but to give feedback and to step up and say something if you think there's a problem.


It's a huge cultural shift for most people in the USA. But it's a very important cultural shift. Once you stop viewing yourself as "doing what you're told", but instead view yourself as a collaborator and partner, it really opens the doors to doing something amazing. It also opens the door to personal growth. If you're junior, by asking "why" and understanding the business reason for doing something, you can better understand why the more senior developers made their decisions. If you're senior, you can learn a lot from the most junior members of your teams by the questions they ask and the suggestions they make.


That's something that I can't stress enough. I am considered to be one of the most senior developers of our team. But every single day I learn something from what others would consider to be the most junior members of our team. We're all different and have had different experiences. This is one of the reasons that I partially dislike the traditional mentorship relationship of master-apprentice, as it tends to imply a one-way knowledge transfer. To me, the value in a mentorship is in both directions.


It is a significant cultural shift. It's one that will take time for many companies. Many startups (and big companies) have already jumped on board, but there are a lot that still treat us like code monkeys. The only way that the culture will change is for us to be the change we want to see in the world.

## My Point


I try to make it clear to my teams that I want them to be experts. I want them to step up and say something if they think that there's a better course of action. I want them to understand what they are doing beyond a specification understanding. I want them to understand the business reason. And more importantly, I want them to buy into the concepts. I want them to feel like partners in the development process. It doesn't always work, but when it does, it's an extremely powerful way to get incredible things done.


I don't want to hire programmers. I want to hire developers. And I don't want to work for a business who views me as a code monkey. I want to work for a company that views me as a partner. So why would I refer to myself as a mere translator when what I really want to be seen as is an author. That's why I am not a programmer. Sure, I could do the job of one if needed, but that wouldn't be the best thing for the business or for me. At the end of the day, I view myself as a developer. What do you view yourself as?