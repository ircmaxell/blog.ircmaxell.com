---
layout: post
title: Ponderings on Odoriferous Syntactical Constructifications
permalink: 2017/07/ponderings-on-odoriferous-syntactical.html
date: 2017-07-31
comments: true
categories:
- Programming
tags:
- Anti-Pattern
- Architecture
- Design
- Functional Programming
- Object Oriented Programming
- PHP
- Programming
- Rant
---

(AKA: "Thoughts on code smells" and how *"high brow"* they have become)

We have a habit of talking about "code smells" to indicate patterns and practices that our experience has shown can be problematic. Many of these "smells" are backed by a lot of data and really are legitimate problems to avoid. These are constructs and tools that often have few legitimate uses. But many so called "smells" really aren't significantly bad. Let's dive into some of the nuance here and talk a bit about why our word choice matters.
<!--more-->

## What is a smell?

Before we get into code smells, let's talk for a brief second about the etymology  behind the term. In the real world, smells provide our brains with important data points about our environment. Our brain interprets smells into a few main categories (10 actually). Each of these categories gives us an important piece of information about our surroundings. When we smell a particular food source, we can get an idea if it's safe to eat or not.

The really important thing to note is that the way our brain interprets scent is heuristical. Meaning that the vast majority of the time you smell something sharp or pungent it's something that you need to avoid because it likely is bad (or contains bad bacteria). I say it's heuristical because it's not always bad for you. It could be simply Limburger cheese.

The smell alone isn't enough to firmly know if it's bad or not the vast majority of the time, you need other information from other senses to know for sure. But those smells are useful to us because the vast majority of the time we encounter a bad one it's because the object is bad.

### Reliable Smells

Some of the items we identify as "code smells" are legitimate  sources of problems. That's not to say they are *always* problematic, but the *vast* majority of the time they would be. `goto` is an awesome example, but let's go with a few more explicit ones:

- **Using `eval()`**
    
    While `eval()` does have some valid uses, the vast majority of them are actually huge issues. The reason for this is simply that `eval()` is **really** hard to use without becoming a huge security vulnerability. And that doesn't mention that there are usually better, easier, or more robust tools that can use the job.

    Some things are literally impossible without some form of dynamic evaluation. Meta-programming for one is quite difficult without some ability to dynamically execute code. In fact, some languages blur that line so much that language becomes code (which is quite similar to `eval()`, but beyond the scope of these thoughts).

- **Duplicated Code**

    Writing the same thing over and over again is quite often seen as a bad practice. The reasoning behind this is that when a bug is discovered in one copy (or a new feature is added), the chances are quite significant that other copies won't be updated.  

    One of the downsides of refactoring out duplicated code is that by doing so you create artificial  coupling between different pieces of code. The vast majority of times this coupling is less of a burden than the original duplication was. But every once in a while you wind up in a situation where the coupling makes life so difficult that copy/pasting is not just easier, it's cleaner.

- **Global Variables In Modularized Code**
    
    Specifically inside of modular code, global variables tend to be sources of bugs and difficult to understand complexity. The problem isn't the global variable itself, but that the nature of modular code is that you don't control the life-cycle or access patterns of the code. The code is being used by another system and will be called in all sorts of weird ways. By having global state it makes it far harder for interacting code to know when a chance will clash in other areas of the system.

    For example, imagine a logging class that used a global variable for "prefix". One part of the code sets the prefix to A, and another to B later in the execution. Because it's a true global variable, those clashes will cause weird side-effects.

These (and way more) are legitimate "smells". They tell our fight-or-flight response to be ready to jump pending confirmation from another sense. The key thing to realize here is that the false-positive rate is exceedingly low (less than 100:1), meaning that valid uses are few and far between.

### Smells That Are On The Border

Some "smells" are hinting at legitimate issues, but the false positive rate is significantly higher at reasonable values for the definition. Perhaps a valid:invalid ration of 5:1 or 10:1.

- **Too Many Method/Function Parameters**

    This one has more preference baked in, but you'll usually find few people advocating for hundreds of parameters to a single function. 

    The nuance here is where the line is. Some designs and systems having more than one or two parameters results in a more complicated system to the point where it's problematic. For some other systems and usages that number is higher.

    There is a limit where too many parameters becomes an obvious smell that something's wrong. The point though is that limit (and hence the value of the heuristic) only provides a strong signal that there's a problem at quite high values...

- **Excessively Long Methods**

    This is another one where you need to know more about what's going on to really judge whether there's a problem or not. In some cases, having a 10 line method is exceedingly long and results in a huge amount of complexity. In other cases, a 50 line method may really do one thing and may not be worth refactoring (depending on what's being done at least).

    Again, the smell is only significantly valuable outside of reasonable limits. And even then it only hits our "few false positive" test at relatively extreme limits (more than many developers would consider sane for most cases).

There are plenty more, but I want to get into the third class of "smells":

### Smells That Require Huge Amounts Of Context

The majority of "smells" you will see people talk about seem perfectly reasonable on the surface, but only really make sense inside of a context. To get what I mean, let's take a few examples of some "smells":

- **Using Conditionals**

    Yes, some programming camps suggest that having an `if` statement inside of your code is an anti-pattern and a "smell". From their perspective, it's hard-coding a decision that should be inverted (a reflection on the [Tell-Don't-Ask principle](https://pragprog.com/articles/tell-dont-ask). Let's look at an example:

    ```php
    if ($user->canBuyAlcohol()) {
        $shoppingCart->checkout();
    }
    ```

    That could be rewritten as:

    ```php  
    $user->purchaseAlcohol($shoppingCart);
    ```

    The key benefit there is that complex logic can be encapsulated way more than a simple boolean can. For example, in some European countries the age depends upon location or percent of the alcohol. By removing the conditional you can leverage polymorphism to truly encapsulate the change and make for a more flexible design.

    If you buy into this way of designing this should seem obvious. If you don't buy into it, this likely seems contrived and overly dogmatic. 

- **Depending On A Service Locator**

    I've personally [written about this one](http://blog.ircmaxell.com/2012/08/object-scoping-triste-against-service.html) before, and I do not like service locators for OO code. The reason is they create hidden dependencies and act akin to global variables.

    But that really depends on what you're building. If you're building a large application or reusable modules, those hidden dependencies cause significant complexity and problems. But for some corners of the codebase, and for many applications, the trade-offs don't fall as hard (to the point where in some cases the alternatives are worse).

    To know if a Service Locator is the right choice or not really depends on what you're building and the trade-offs you need to account for...


### Unreliable Smells

These smells are those that are good to know about, but don't give you a whole lot of signal to noise. Meaning that they are signs of good code as often as bad code.

- **Avoid Static Function/Methods**

    This is another one of those "it depends" cases. A static function/method is one that's not polymorphic, meaning that it's referenced by class name or global variable. In PHP, that's `ClassName::method()` ([most of the time](https://stackoverflow.com/a/17027307/338665)). In Ruby, it's `ClassName.method()` (which is really just a method call on a global variable). In Java `ClassName.method()`. And so on.

    The problem with static calls are the same as with calling `new` and creating a hard-coded object class. It's not polymorphic (meaning it isn't dynamic based on other objects) and hence it's not OO. Take the following code:

    ```php
    class User {
        public static function getCurrentUser() {...}
    }
    ```

    What's the difference between that and `get_current_user()` as a function? The answer is: nothing. 

    If you're writing imperative, functional or really any other code than OO, this is a non-issue at all. But when looking at composition, hard coding the call does reduce flexibility (no matter what paradigm you're using).

    So to know if this is really a problem or not you need to not only know a lot about the style of the application you're looking at, but also know the trade-offs involved and specific points that may change...

- **Any smell that says "always" or "never"**

    Any so-called "smell" that declares an absolution like "always do X" or "never do Y" is likely an unreliable smell. Look for the context, and look at the trade-offs.

## What Use Are Smells?

I urge you to be cautious about how you talk about code smells, and how you talk about "good vs bad" ways to write code. Realize that programming is an insanely complicated endeavour with a huge amount of nuance. 

Be wary of anyone who uses the terms "always" or "never" when it comes to writing code, unless they specifically qualify the statement with the context needed to justify it.

Most of all, think critically about your code and other's code. Don't just look at it in isolation, but understand the context around which it was developed.

After all, that context is the most important part of programming that we talk the least about...