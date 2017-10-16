---
layout: post
title: Musings On PHP.JS (And Similar Libraries)
permalink: musings-on-phpjs-and-similar-libraries
date: 2011-04-05
comments: true
categories:
- Rant
tags:
- Best Practice
- Language Agnostic
- Library
- PHP
---

I have always been intrigued by projects such as [PHP.JS](http://phpjs.org/). To be completely honest, it's not because I though they were *"neat"* or *"innovative"*, but because they have always made me ask myself *"Why would someone seriously want to do something like that?!?!?"*...  Let me try to explain my standpoint.

<!--more-->

## PHP's API Is Not That Great

Seriously, who's going to argue that PHP's APIs are well _designed_?  Sure, the functionality is just about excellent.  There is a function for just about everything you might want to do (with basic types that is).  The documentation is just about the best I've ever seen (for a library so big at least).  However I will still assert that there is much to be desired...

First off, one gripe that I have is the fact that there is a function for everything.  I mean really, do we **need** functions such as [`nl2br()`](http://www.php.net/manual/en/function.nl2br.php), [`strpbrk()`](http://www.php.net/manual/en/function.strpbrk.php) and [`strspn()`](http://www.php.net/manual/en/function.strspn.php)?  I would argue that while they may be useful in some circumstances, they belong in a well maintained external library rather than inside the core.  Secondly, there is absolutely no consistency in the API provided by those functions.  I mean why does [`strpos()`](http://www.php.net/manual/en/function.strpos.php) have the $haystack parameter first, while [`str_replace()`](http://www.php.net/manual/en/function.str-replace.php) has it as the third parameter (In reality the array functions are a lot worse than the string functions at this)?  Third, some of the functions completely violate the Single Responsibility Principle.  Take [`strtok()`](http://www.php.net/manual/en/function.strtok.php) for example, it does something different depending upon how many parameters you pass in.  While I'm not saying it's *horrible* to do that, it's certainly not the absolute best design possible.


Therefore, why should we mimic a poorly designed API in another language?  Why not design a good API layer and mimic that in multiple languages?  Sure, you can argue (and many do) that many people know the PHP API, so implementing it in other languages will make it easier for developers to transition to the other languages.  Again, I would argue that this is the wrong approach.

## Program Into Your Language, Not In It

The best developers do not program in any language, they program into it (As discussed in [Code Complete 2](http://www.amazon.com/Code-Complete-Practical-Handbook-Construction/dp/0735619670) in chapter 34 and in [this excellent post](http://nayyeri.net/program-into-your-language-not-in-it)).  What does that mean?  Well, in short, it means that you should not be limited by the way your language works but instead make your language work for you.  So if your language does not support a feature that you need, instead of trying to alter your design around what's available you should implement the feature (or find a working version).  I highly suggest reading the book and the article since they dive into the subject far deeper than I can here.


So wouldn't that mean that implementing PHP's API in JS is actually programming into JS?  I would argue that no, it is not.  My view on the matter is that all PHP.JS is doing is allowing people to program in the PHP programming language while in JS.  So now we're at 2 layers of something that we shouldn't be doing instead of just one!  JS is not PHP.  PHP.JS is neither PHP nor JS.  By implementing the API in that manner all that you're doing is giving people the look and feel of a hybrid child with none of the benefits.

## Please Think Of The CPU!

Go take a look at any one of your code bases.  I'm going to go out on a limb and take a guess that the single most often used operation that you do in that code base is either a string operation, or an array operation.  Now, for a single operation, worrying about the performance would normally be seen as either a micro-optimization or a premature optimization.  But we're looking at the entire application, in which a few percent improvement in a single routine will make a significant different to the overall runtime.


Why does this matter?  Because string and array operations are extremely inexpensive in both PHP and JS.  Both implement the functions is a lower level and usually compiled language.  They usually use direct memory operations to implement the functionality.  Most of the time, the core implementation is multiple orders of magnitude faster than you could possibly implement in the language itself.  So by building the language wrapper, you're trading off significant CPU time for a better interface.  Now, if it makes development easier, this might be an acceptable trade-off.  But I ask how much easier is it to write:

```javascript
var foo = str_replace("from", "to", "replace this string");
```


Than it is to write:

```javascript
var foo = "replace this string".replace("from", "to");
```

## Coding Is Easy, Developing Is Hard

In general, writing code is the easiest thing a good developer will do during his average day.  In fact, the specific act of writing code is so easy, we let Junior Developers with little to no experience do the majority of it for us.  But writing good software is far more than just writing good code.  It requires discipline, patience, common sense and -most of all- thought. In fact, I'd argue that if you're a good developer, the language you're coding in is nothing more than semantics.  Therefore any libraries or tools that are worth while using should help you architect and design your code more than implement it.   After all, the design and architecture stages are the most important and hardest stages of development. 


The actual code writing part is the easiest thing that you'll do.  That doesn't mean that a tool is worthless if it makes writing code easier.  But the biggest and most important gains are to be had by making and vetting code from a higher level than that.  After all, a language is nothing more than a way to express your thoughts and designs into a medium that a computer can understand.  If you buy that argument, then the language is nothing more than an abstraction that shouldn't really been given much thought beyond choosing the correct one for the problem.  Once you pick the language, it should (in an ideal world) be completely transparent to the problem.  Which is why I argue that implement one language's API in another language is solving the wrong problem at the wrong level.

## Conclusion

I know how this sounds.  I know it seems like I'm bashing the developers who have devoted a lot of time and effort to their passion.  That's really not my intention.  I know it seems like I think that I am a better developer than I think that they are.  That's really not my intention either.  Instead, I'm just trying to share my reaction and thoughts that come to me whenever I see projects such as PHP.JS.  I know there are people with other views.  I know that the other views are quite valid.  I just don't understand them.


So, here's my call out to you.  Please prove me wrong.  Show or explain to me the benefit of re-implementing one programming language's API in another language.  Explain to me why it's a good idea (for other than academic reasons) to use a library such as this instead of either building a unified API (such as [Dom](http://en.wikipedia.org/wiki/Document_Object_Model)) or using the language provided API?  Did I get something wrong that I posted here?  Let me know your thoughts (Feel free to either comment below, or make a follow-up blog post and link back here)...
