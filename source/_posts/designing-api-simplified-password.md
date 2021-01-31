---
layout: post
title: "Designing An API: Simplified Password Hashing"
permalink: 2012/11/designing-api-simplified-password.html
date: 2012-11-16
comments: true
categories:
- Architecture
tags:
- Answers
- Architecture
- Object Oriented Programming
- Password-Hashing
- PasswordLib
- PHP
- PHP-Internals
- Rant
- Security
---
The other day, [PHP 5.5 Alpha 1](http://www.php.net/archive/2012.php#id2012-11-15-1) was released to the public for the first round of testing the new features that are coming out. One of those new features is the [Simplified Password Hashing API](https://wiki.php.net/rfc/password_hash) that I proposed (and was accepted). I have received a lot of feedback and criticism of the new API in the months since it's been committed. I figured now that Alpha 1 is out and people can play with it, I should respond to some of those items, and give a little bit more insight into why it was built the way it was...<!--more-->
## The Backstory


When I was working on trying to come up with the API, I had a few goals in mind. Those goals (in no particular order) were:
 * **Easy to use** - Meaning that an average junior developer would understand how to use it.
 * **Support the 99% use-case** - It shouldn't try to be all things to everyone, just solve the baseline common need.
 * **Forward compatible** - The API shouldn't have to change if requirements and algorithms change in the future.
 * **Secure** - Obvious

These were the primary design goals that I had when working on this. There are others that were secondary, but I felt that these 4 summed up the goals of the project. 

With this in mind, let's look at some of the criticisms of the design, one by one.## Why Aren't The Functions Namespaced?!?!?!?!?


This has to be the most common question that I've been asked. PHP has namespaces, so why weren't these new functions and constants namespaced... There are actually a few reasons why they aren't namespaced. Let's start with the most obvious. They weren't namespaced, because nothing in core is namespaced. There is not a single core function or class or extension that uses namespaces. So for consistency sake, it makes little sense for this tiny part of the standard library to all of a sudden break convention.

Don't underestimate that point. Yes, there will have to be a first namespaced function/class/extension in core. But this is not a new extension, or a new set of classes. It's a new function inside of a standard library full of other functions. It would be odd (to say the least) to have 4 random functions namespaced  while the rest of standard lib around it is not.

The second reason is that there's really no benefit to namespacing functions. You can't alias them. You can't import them (via a use statement). You always have to type out the full namespace of the function, unless you're in the same namespace as the function. And considering that the namespace for this would start with `\php`, you should NEVER be in that situation anyway. So namespacing these functions would be LITERALLY the same as prefixing them with a constant string (like "`password_`")... So namespacing buys us nothing, except for the sake of namespacing...

The final, and perhaps most important point, is that namespacing the function detracts from its ease of use. It detracts from one of the primary goals of the effort. Sure, you could make the argument that many PHP developers understand namespaces. But many don't, and don't need to. In fact, the audience that would benefit the most from this new API is the audience that is least likely to understand namespaces... But more on that later...## Why Isn't This A Class?!?!?!?!?


I've been asked this question a lot of times as well. The simple answer is that it's not a class because it doesn't need to be. But in reality, there are a number of reasons that this is not a class. The first and easiest to dig into is the fact that there's not much of a gain associated with making it a class. There are two primary reasons to make something a class: to encapsulate state or to enable polymorphism. In the case of this API, there's really no state (aside from the options array, which is used by only 1/2 the functions), and there's no reason for polymorphism. So why make it a class in the first place?

Sure, you can come up with valid reasons for making it a class, such as being able to mock out the implementation for unit testing, etc. You could say that it organizes it better. But in reality, does it? In most applications, you're only going to be using this in at most one class. So the benefit to mocking is rather limited...

So now we can move on to the second big reason for it not being a class: that it raises the barrier to entry. There are a large number of developers out there who have no idea what objects or classes are. These are the kinds of people who will copy and paste code from examples. Who will ask for help and try to make the helpers write the answer for them. The kind of people who don't really understand the nuanced fundamentals of programming. But that doesn't mean that they don't program. That doesn't mean that they can't get things done and produce popular software.

These are the kinds of people that would benefit the most from a simple API. Senior developers who know about unit testing and mocking objects will likely know that they need to hash their passwords, and can usually figure out that they should use a library. This API can help them, but it's not going to do too much for them, other than give them a library in core. The real demographic where this will help is those that don't understand that they need to use a library, and think `md5($password)` is fine.

I wanted it to be as easy to use as possible while still remaining completely usable for the vast majority of use-cases.## Why Isn't This An OOP API?!?!?!?!?


Don't be fooled, this is indeed a different question from the prior one. Wrapping a few functions in a class is very different from creating an OOP API. I have been asked that, since I was the creator of [PasswordLib](https://github.com/ircmaxell/PHP-PasswordLib), which uses an OOP design, why couldn't I come up with a clean OOP design for this. The short answer to this is the same as the "class" question above. But I put it as a separate point here, because I think it deserves a little more explanation...

Initially, when I was discussing this idea with other developers, I had intended to make it an OOP API. I went back and forth between a number of different options. I tried a strategy system (like PasswordLib uses), where you'd instantiate a "dispatcher" class, and it would figure out how to route the password based on the configuration. I tried a system like spl_autoload where you'd register implementations (conforming to an interface), and then use functions to access them. I tried a number of other techniques.

But each one of them had severe problems. Well, not severe, but severe enough that I wouldn't want it in core. To understand what I mean, let's say that we define a interface `PasswordAlgo` to allow user-land algorithms to be defined and registered with `password_register_algo(PasswordAlgo $algo);`. It might look something like this:```php
interface PasswordAlgo {
    public function detect($hash);
    public function hash($password, array $options = array());
    public function verify($password, $hash);
}

```

Pretty straight forward. But now what happens if you install a third-party library that registers this algorithm:```php
class NullAlgo implements PasswordAlgo {
    public function detect($hash) { 
        return true; 
    }
    public function hash($password, array $options = array()) { 
        return $password; 
    }
    public function verify($password, $hash) {
        return true;
    }
}

```

All of a sudden, without looking at every line of code, all of your passwords are now plain-text!

Obviously there are ways around that. And there are other object oriented patters that avoid this behavior, but none are foolproof enough for core. In other words, I felt that every OOP API that I could come up with was simply too risky for not enough gain for a core implementation...

Additionally, the use-cases that this would enable are often "you can, but you shouldn't" use-cases. And even if they are valid, they are usually remote edge-cases that core shouldn't worry about supporting directly.

And that brings me to the final reason I didn't make it OOP. There is always going to be room for OOP libraries that do this. This isn't trying to be the one stop shop for password hashing. It's trying to be a secure and trivially easy to use library. There will always be room for libraries like PHPASS or PasswordLib to do the more remote edge cases. There will always be room for frameworks to provide wrappers around this functionality to handle their specific use-cases...## Why Isn't PBKDF2 Supported?


The answer to this one is pretty straight forward. I didn't add support for PBKDF2 for two reasons. First, it's weaker than bcrypt. But more importantly, there are no `crypt(3)` bindings for PBKDF2 that are standardized. And I'm not willing to be the person who invents a standard binding without feedback or support from the greater cryptographic community. And PHP core is definitely NOT the place to invent  such a standard. If a binding is made for PBKDF2, I'll gladly make the patch to include it in PHP. But I won't be the one who makes that binding...## Why Isn't Crypt-SHA-512 Supported?


The simple answer is that it's weaker than bcrypt. That doesn't mean it's bad necessarily. But there's really little reason to introduce the API where weaker algorithms are supported. As time goes on and we add stronger algorithms, the older ones won't be removed, but there's no reason to start with weak ones...## Why Isn't This A PECL Extension?


There was some discussion about that. My position is that there's really not much to be gained by it. The benefit to the community from this API is that it's in PHP's core, and you don't need to worry about libraries or extensions. From my experience, most extensions go unused in all but specialty situations. Even APC which is used all over the place is all but useless on the majority of shared hosts. The utility here is in having it everywhere, so it can be leveraged...

As far as enabling people who aren't on 5.5 yet, I have provided a PHP compatibility script called [password_compat](https://github.com/ircmaxell/password_compat). It requires PHP >= 5.3.7, so if you're on recent 5.3, or 5.4 you can use that instead on all hosts (not worrying about extensions). ## Why Isn't It Written In Python?


Because it's written for PHP's core, which uses C...## Does It Make Me Hacker-Proof?


No, no tool can. It will help make it more difficult for an attacker to get passwords, but it's still possible. You still need to defend your application properly against other forms of attack (like SQLInjection, Session Hijacking, Remote URL Includes, etc)...## Why Doesn't It Use Unicorns?


Wait, what?## I Like Unicorns.


That wasn't even a question...## Can You Fix My Website?


Ok, I'm done. Thanks for reading...