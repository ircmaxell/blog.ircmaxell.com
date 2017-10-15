---
layout: post
title: Thoughts On PECL Frameworks
permalink: thoughts-on-pecl-frameworks
date: 2012-08-27
comments: true
categories:
tags:
- Framework
- Large Scale Applications
- Library
- Micro Framework
- PHP
- Rant
---

In recent months, a number of new frameworks have cropped up for PHP as PECL extensions (Including [YAF](http://code.google.com/p/yafphp/) and [PhalconPHP](http://phalconphp.com/)). They promise to provide huge performance gains and lower resource usage for PHP applications. On the surface, they appear to be incredible tools for improving development. But they aren't all they are cracked up to be. In fact, I would argue that they are actually not necessary at all.<!--more-->


## But It's High Performance!


If we look at the [benchmarks for PhalconPHP](http://docs.phalconphp.com/en/latest/reference/benchmark.html), it looks to be blindingly fast! In fact, it's three times faster than the fastest PHP based framework used in the tests (CodeIgniter). And when we add in the fact that memory usage is cut by 25% over the next leanest framework (Fuel), it's hard to argue that it's incredibly more efficient!

No, I was wrong, it's easy! These tests are for a [Hello World](http://en.wikipedia.org/wiki/Hello_world_program) application. I can make a faster hello world than any of them:

```php
<?="Hello World"?>
```


In all seriousness, this benchmark proves nothing. It's very tempting to say "well, the framework itself has less overhead, so that must be good, right?"... But that's also a very dangerous assertion. The fact of the matter is that the framework's overhead will likely be far outweighed by your application's overhead. And that will likely be far outweighed by your application's external dependencies (database, filesystem, 3pd REST calls, etc).
## What You Give Up


The importance of a framework or library is not the amount of overhead that it has, but what it gives you for that overhead. There is no free lunch in this world. Everything is a tradeoff. The additional efficiency that a C based framework give us comes a a very significant cost:
### Readability


One of the most significant things that you lose when you switch to a C based framework is the ability to easily read and understand the code behind that framework. How can you hope to use something that you don't understand? The fact of the matter is that while a number of developers will use a framework without trying to comprehend it, the successful ones do not. They take the time to learn the framework, learn the how and why behind its design and implementation.


I do know C. But knowing C and PHP's PECL extension mechanism, I'd rather read PHP. That's not to say that I couldn't read the C code to figure out what's going on. Indeed I could (and have). But when I'm writing PHP code, I'd rather not have to switch my mental model back and forth from PHP to C to figure out what's going on.
### Debug-ability


Thanks to tools like gdb, it's pretty easy to debug C code. The problem is that we're not debugging C code, we're debugging PHP code written on top of C. While this does present its own challenges, having the framework portion in C means that XDebug is all but useless for figuring out what's going on. Now, you're stuck having to debug PHP code with both XDebug and gdb. And having done exactly that before, all I can tell you is: `have fun`...

### Portability


With a traditional PHP framework, any application that you write is going to be largely portable to almost any server configuration. But with a PECL based framework, you're stuck with only being able to move to supported environments (for that PECL extension) where you have root access to install PECL extensions. While in many cases this may not be a huge issue, it's something to think about.
### Maintainability


If your (or your team's) core competence is not C, using a PECL based framework can be suicide for a long term project. The reason is that you're pitching the success and support of your application on a tool that you cannot fix if you wanted to. So when bugs crop up, you're stuck asking the community for help. While that may not seem like a huge issue, imagine explaining to the CEO of your company that your site has been broken for two weeks because you couldn't find anyone to fix the bug.

With a PHP based framework, if all else fails you can go in and fix the issue. In fact, this is a lot more common than you may think. Not to mention that this is usually how bugs get fixed in a large project anyway (someone fixes the bug, and submits a patch to core). At least with a PHP based framework this option is open to you.
## What You Gain


So with all of those losses, surely there must be a significant gain, right? Not really. I hinted before that the performance gains really aren't as significant as they first appear. The reason for that is that the slowest parts of the code that you're going to be executing are going to be in your application specific code dealing with external systems. By using a PECL based framework, you're making the fastest part of an application faster, and not doing a thing about the slower parts... This is nothing short of a [premature optimization](http://blog.ircmaxell.com/2011/08/on-optimization-in-php.html)...
## But I Have A High Traffic Site!


Even if you do, this type of a gain is going to give you minimal results. Look at those benchmarks again a little bit closer. You can see that the slowest framework (Symfony 2) serves each page view in 40ms while the PECL based framework serves each view in about 2ms. Our gut instinct points out that it's a HUGE difference. And it is. But that's 38ms per request. Let's even say that your application resolves in 50ms on top of the framework (let's say it's a bloody fast app). So we're talking 90ms vs 52ms. Still a big difference, right?

Not really. With numbers that small, you'd need traffic levels on the scale of thousands of requests per second to see any kind of meaningful cost savings. 1k requests per second equates to 86 million requests per day. If we make the numbers more realistic, say 200ms for the application layer, the result is even more stark. 38ms out of a 240ms response is 16%. That's large, right?

Saving 16% off your front-end server costs will wind up saving you almost nothing. Think about it for a minute. Let's say a server costs you $200 per month. To see a gain from 16% savings, you need at least 7 servers. And with 7 servers, you just saved a whopping $2400 per year! Good for you (especially considering the cost of the added developers that you might encounter due to the lower level code)!
## Conclusion


My argument here would be that if you have a site where you can measure meaningful money savings by putting the framework into C (with taking the additional maintenance costs into account), you likely shouldn't be using a framework anyway. If you have Facebook level traffic, a 1% savings per page view will add up to hundreds (or thousands) of servers worth of savings. It makes sense for them to micro-optimize, because it's not micro for them. But even if you're running 20 front-end servers (which can usually handle a TON of traffic), it doesn't make sense to spend money and time trying to save even one or two servers worth of performance... The cost of the developers will likely be more expensive than the cost savings you'll gain...


Note that I'm only saying this about using full blown frameworks written in C. Not one-off libraries. Not PECL extensions in general. Just full blown frameworks (which you already [know my opinion on](http://blog.ircmaxell.com/2012/07/framework-fixation-anti-pattern.html))...