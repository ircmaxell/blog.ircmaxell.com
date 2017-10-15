---
layout: post
title: Are Traits The New Eval?
permalink: are-traits-new-eval
date: 2011-07-22
comments: true
categories:
- Programming
tags:
- Best Practice
- PHP
- Traits
---

The upcoming release of PHP 5.4.0 includes a plethora of new features, including Traits.  While I do believe this is a great feature with great possibilities, I also fear that it may fall into the category of often-abused-features such as `eval()`, `goto`, constants, the **`@`** operator, class inheritance and regular expressions.

<!--more-->

## What Are Traits?



There are two different things we can talk about here.  The true definition of a [Trait](http://scg.unibe.ch/research/traits/) is a compostable unit of behavior (meaning basically a collection of just methods).  This differs from the concept a [Mixin](http://en.wikipedia.org/wiki/Mixin) which adds state to the trait definition.  That means that all traits are mixins, but only mixins which don’t have a state can be traits.  Therefore, traits are nothing more than a subset of mixins.


Think of it like an integer type and a float type (in PHP).  All int values can be exactly represented as a float value.  But the vast majority of float values cannot be expressed exactly as an int value.


Now, I mention that because what is currently implemented in PHP 5.4 is actually a mixin.  It is called a trait, but the implementation supports state, so it is actually a mixin.  I bring this up because this is (in my opinion) a major consistency issue.  


For details on what’s currently implemented, I’d suggest starting by reading the [RFC](https://wiki.php.net/rfc/traits).  But there is still quite a bit in that document that was not implemented, and things implemented that were not in that document.  The following two posts may be of some use to better understand them:

 * [New to PHP 5.4 Traits](http://simas.posterous.com/new-to-php-54-traits)  
 * [Playing With Traits In PHP 5.4](http://cogo.wordpress.com/2011/07/01/playing-with-traits-in-php-5-4alpha1/)

## What Does Often-Abused Mean?



Some of the features I listed above will make most experienced developers cringe at the mere mention (eval and goto namely).  Others are used so often that some people may question why I included them on the list.  Most of the time they are used, they are used to solve problems that they shouldn’t try to solve (such as trying to parse HTML with regex).  They can introduce negative effects into code (such as security vulnerabilities or tight coupling).  They can significantly hamper readability (try reading this regex).  Some are so bad, the use of them is seen as nothing more than a [code-smell](http://phpmd.org/rules/design.html#evalexpression)...


Don’t get me wrong, each of those features that I listed in the opening paragraph are quite useful to solve certain problems. In fact, they can be the only way to solve some problems.  The difference between these features and other features that leads me to classify them as “often-abused” is that a significant amount of their uses can be seen as “bad”.

## My Concerns with Traits.



Like all of the other features, Traits have a lot of potential.  It should make it significantly easier to reuse code and implement common features.  I do look forward to having the tool available for when it’s needed.  However the potential for abuse is quite significant.  Let me go over my concerns one by one:

## Tight Coupling



Since traits are resolved at compile-time, the use is no different from extends in the sense that it tightly couples the trait implementation to the using class.  This can actually reduce the reusability and utility of the class itself.  These are problems that we normally use design patterns to solve (such as Decorator, Composite and Bridge).

## Testability



Unit testing traits is going to be an interesting challenge.  Sure, we can create a mock or a stub which uses the trait, and test that, but the interaction points between a class and a trait are fairly significant.  Do we then just test the implementation classes of the trait, and assume that if they are tested well that the trait will be too (similar to protected and private methods)?  I admit that this may not be a significant issue in the long run (as I’m sure the community will adopt a good methodology)…

## Single Responsibility Principle



There are definitely cases where traits can be used to implement common functionality where inheritance cannot (such as the reflection example in the RFC).  However there’s also potential (and temptation) to implement all sorts of code in a class because it makes it easier to cross the SRP line and have deceptive god classes.  I call them deceptive because their declaration looks like it complies to the SRP, but the available runtime object really does many things.

## Understandability



Right now, to understand what a class does (and how it does it), you need to traverse up the inheritance chain to determine how the class works.  By keeping inheritance depth to a reasonably small number (I usually choose 3 as a soft warning, and 6 as an error), it makes understanding the class easier.  But now we’re also adding breadth to that search.  Each class in the chain can have an arbitrary number of traits associated with it.  So even if the inheritance chain is only 3 deep, there may be 50 places the code is defined to assemble that class.  So now instead of an inheritance chain, there really is an inheritance tree, which can make understanding a code base significantly harder.  And when you take into account aliasing methods, this becomes an even more interesting challenge.

## With That Said



With that said, I’m definitely a proponent of adding traits.  They are a very useful construct and their ability to help an application architecturally is significant.  I just wonder if they will wind up being seen as eval and goto are today, dangerous tools that do more harm than good whose use is nothing more than a code-smell…


What do you think?  Are my apprehensions valid?  Or am I being overly cautious?  Do you share some of the same concerns?  Do you have any additional concerns?
