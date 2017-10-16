---
layout: post
title: Thoughts On The Design Of APIs
permalink: thoughts-on-design-of-apis
date: 2015-03-24
comments: true
categories:
- Architecture
tags:
- API
- Architecture
- Best Practice
- Good Enough
- Library
- Object Oriented Programming
- PHP
- Programming
---
Developers as a whole suck at API design. We don't suck at making APIs. We don't suck at implementing them. We don't suck at using them (well, some more than others). But we do suck at designing them. In fact, we suck so much that we've made entire disciplines around trying to design better ones (BDD, DDD, TDD, etc). There are lots of reasons for this, but there are a few that I really want to focus on.

<!--more-->
## What Is An API?

For the purposes of this article, I'm taking the definition of API to mean literally every form of interface between programmers or portions of a program. So a function signature is an API, but its implementation is not. A class/interface is an API. A collection of classes/interfaces is an API. A REST endpoint is an API (actually, all HTTP endpoints are APIs).

Basically, anything that allows you to connect the code you're writing now with other code is an API.

But it's more than that. It's way more than that. An API is really any interface that's designed to be used or consumed by a user. That user can be an end-user, or a developer, or an architect, or a designer, etc. Really, anyone.

The key differentiator of what makes an API or not is who's intended to consume it. Implementations are targeted at compilers and runtimes, but the function itself is targeted at another developer. If it wasn't, we wouldn't bother naming functions (and arguments).

## But TDD Is About Architecture!

Yes, and it's my assertion that Architecture is nothing more than a high-level API. [Uncle Bob Martin](http://en.wikipedia.org/wiki/Robert_Cecil_Martin) talks about [Architecture as](http://youtu.be/WpkDN78P884?t=43m15s):

> Architecture is the art of drawing lines. With the interesting rule that once you have drawn the lines, all of the dependencies that cross that line go in the same direction.

Don't those lines create "groups" of dependencies? And don't those "groups" of dependencies form an API (more specifically, an API designed to solve a single problem).

We can do the same logic with BDD, but replacing architecture with user-interface (which is simply an API with a different target user).

## It's All About The Target User

The biggest factor in API design is who your target user is. Who are you writing the API for? Who will consume it?

In my experience, this is the thing we most often get wrong. We tend to assume that the users of our APIs will be like us. So we make APIs that we can use.

In reality however, we're not often the ones using our own APIs. Often, it's an entirely different class of user.

Security APIs are some of the worst offenders of this. Take [`scrypt()`](https://en.wikipedia.org/wiki/Scrypt). The function signature is (at a high level):

```c
string scrypt(
    string password, 
    string salt, 
    int N, 
    int r, 
    int p, 
    int resultLength
)
```

To someone who has read [the academic paper about scrypt](http://www.tarsnap.com/scrypt/scrypt.pdf), that makes sense. To everyone else, "*what???*". Heck, I've read the paper (a few times) and still would have trouble reciting from memory the precise relationships between the parameters.

But that's not really fair. `scrypt()` as a function wasn't really designed for the every day developer. It was designed as a cryptographic primitive to be implemented by security experts. And in that sense, it works pretty well (though we could talk about the naming of `N`, `r` and `p`).

What's missing here though is an API for normal developers to implement. There are definitely some companies that can afford to have security experts implementing their crypto (and making decisions for them), but the majority of code is written without that luxury. So normal users are forced to make a bad tradeoff between implementing something they don't understand and implementing a worse alternative.

Let's say that again, because it's important.

> Normal users are forced to make a bad tradeoff between implementing something they don't understand and implementing a worse alternative.

## Limiting Tradeoffs Developers Need To Make

One way to overcome this problem is to provide APIs to users that allow them to not have to make these tradeoffs. Present a simpler API that includes some assumptions. Yes, that won't work for every possible use-case, but if it works for the majority case then you've done some good.

This is what I tried to do with [`password_hash()`](http://php.net/password_hash):

```php
string password_hash(string password, int algorithm, array options)
```

I made some assumptions (you wanted to use bcrypt with `$2y`, you wanted a generated salt, etc). Then I implemented a simple API that matched those assumptions. If those assumptions failed, you have other alternatives (you can use `crypt()` directly, or another API). But for the average developer, they don't need to make the tradeoffs because they were already made.

This technique is definitely not perfect. It's quite hard to get the tradeoff line right. For example, I think I made a big mistake with `password_hash()` allowing the user to specify a salt manually. In all (literally *all*) the cases I've seen users specifying a salt manually, it's either of a lower quality than would be generated automatically, or it's worse than that.

Give users what they need, but no more. The way to determine that line is to understand your user. And remembering that different users require different APIs.

## Principle of Least Knowledge

We often interpret the [Law of Demeter](https://en.wikipedia.org/wiki/Law_of_Demeter) as saying that *"a given object should assume as little as possible about the structure or properties of anything else"*. Otherwise known as "Don't talk to strangers". This manifests itself as the ["one-dot rule"](http://williamdurand.fr/2013/06/03/object-calisthenics/#5-one-dot-per-line) or [Coupling And Cohesion](http://c2.com/cgi/wiki?CouplingAndCohesion).

In a sense, we anthropomorphize our code, and the reason about it as if the code had feelings and understanding. We talk about how an object "talks to strangers". As if the object itself has any knowledge of what its friends are... We talk about the coupling that exists between two objects. As if that coupling is some innate truth that exists in the code itself.

Let me pose a slightly different way of looking at the same rule. To understand this view, let me reformulate the definition of the Law of Demeter to something slightly more clear (and less tied to objects):

> A user of an API should have to know as little as possible about other APIs to effectively use it.

That's a completely different perspective on the same problem. Rather than trying to relate objects together we instead relate an API to a user. The net effect is the same. Code that was well decoupled and conformed to the Law of Demeter before will still conform to this new interpretation. The difference is that the reformulation is a lot more targeted and easier to validate.

To see why, let's imagine that we're looking at an interface. Not an implementation, just the API of a class. We can see the dependencies and parameters for every method, but that's it. Let's take an example:

```php
interface ShoppingTransaction {
    public function __construct(ServiceLocator $locator);
    public function pay(string $creditcard);
}
```

In this case, we can see that creating a new `ShoppingTransaction` requires passing in a `ServiceLocator` instance. This is a Law of Demeter violation. In the classic sense, it means that `ShoppingTransaction` must know internal details about `ServiceLocator` and how it can get a `PaymentGateway` instance to process the credit card transaction.

In our new way of looking at it though, it tells an entirely different story. We look at the interface, and we have no idea how it works. We know that it works, but we don't know why. If we were familiar with the architecture of the application, we *might* say something like *"Well, I know that there's a PaymentGateway somewhere in the application, the ShoppingTransaction is probably fetching that from the ServiceLocator and using that to process the payment"*. But even that's a guess. You really don't know what's going on because you need intimate knowledge of the application and the implementation to understand it.

But let's refactor a tiny bit:

```php
interface ShoppingTransaction {
    public function __construct(PaymentGateway $gateway);
    public function pay(string $creditcard);
}
```

Now this is far easier to understand from a high level. We can fairly safely assume that *"ShoppingTransaction uses a PaymentGateway to process the payment"*. You know what the API does with as little knowledge of the rest of the system as possible. Yes, we reduced the code's coupling. Yes, we've followed LoD. But really, we've made it easier for the *user* to understand and use the API. And that's the key thing people miss about LoD. It's not about some magical constraint of the code. It's about the person using the code.

## Wrapping up

So far, we have two very simple rules of thumb:

 * Design your APIs specifically for your target user
 * Design your APIs to require the least amount of target-user knowledge as possible
 
It's really easy to go overboard on both accounts. It's easy to design 20 different versions of the same API to target slightly different users. It's also easy to try to build APIs that have 50 parameters to avoid having another class to know about.

The key here is moderation. Try to keep your *target* user in mind when designing APIs (even functions/methods).

And above all, don't ever think of yourself as your target user. You will be targeting *today's* copy of you. Tomorrow's copy will be different. And I bet in 3 months you'll forget things that you've assumed today. Always target someone else. It will make for better self-documenting APIs.

Always try to make self-documenting APIs (in the context of your target user), but that doesn't mean you shouldn't document your code either. APIs are a part of documentation, but not all of it.




