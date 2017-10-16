---
layout: post
title: PHP Sucks! But I Like It!
permalink: php-sucks-but-i-like-it
date: 2012-04-10
comments: true
categories:
- PHP
tags:
- Inconsistencies
- PHP
- Programming
- Rant
---

I read a rather interesting post yesterday called [PHP: a fractal of bad design](http://me.veekun.com/blog/2012/04/09/php-a-fractal-of-bad-design/). It's been getting a lot of traffic among the PHP community lately because it's rather inflammatory. But to be honest, it does make a lot of really good points. It also makes a lot of mistakes and misses a bigger picture.<!--more-->

## A Few Mistakes

The post makes quite a few mistakes and odd apples to oranges comparisons. Let me point out the major ones that I saw. * No Debugger - PHP has xdebug which works quite well as an interactive debugger.
 * Lack Of Threading - This is true, but he lists it as a difficulty, and I list it as a positive, since the application lifecycle is per request (I'll expand more on this shortly).
 * `==` Is Useless - Actually, it's quite useful, if used appropriately. I do admit that I use it less and less as time goes on, but when you need it, it's quite useful...
 * Scoping Issues with Globals - He lists this as an oddity. Honestly, it's one of the things that I think PHP got right over almost every other language. Without seeing a `global $var` declaration in a block, you **know** the variable is local. So by looking at a function declaration, you can immediately know what external state is needed without having to examine or trace every variable (or have your IDE do it for you).
 * Constants Are Defined By A Function Call - This is true, but it completely ignores the `const FOO = "bar";` syntax, which is also perfectly valid and not a function call.
 * Static Variables Inside Instance Methods are Global - This is true, because that's exactly what a static variable is supposed to be. It's just like using a variable in Python using `obj.__class__.varname`...
 * PHP Is Naturally Tied to Apache - This is blatantly false, since there are plenty of applications not running Apache. It's just that Apache comes pre-configured on most platforms with mod_php. But setting up FastCGI with NginX is actually easier IMHO than setting up mod_php with Apache...
 * There Is No Easy Way To Insulate A PHP App - This is not true, since with suphp and FastCGI, it's actually `easy` to have multiple PHP instances running on different versions. Sure, with mod_php you need to have a separate Apache instance, but there are better SAPI's than mod_php, so it's not really fair to discount PHP for a limitation in Apache...
 * The Entire Missing Features Section - This is where I got lost. Up until here, he has been talking about language issues (most of which I agree with). But at this point, he starts to talk about libraries and frameworks. Sure, PHP doesn't have a template system. But neither does Python or Ruby. Django and Ruby On Rails do, as do Zend and Symfony. PHP doesn't have an XSS filter, but Python and Ruby don't either (the frameworks do). PHP doesn't have routing, but neither do Python and Ruby. It does have a [dev server](http://us2.php.net/manual/en/features.commandline.webserver.php). And it does have interactive debugging (xdebug). The security section is pretty much more of the same...

Now, out of such a long post, that's a really short list of gripes. I think there's a lot of good content in there, and once you get past the ranty tone, it's worth the read.

## My Stance


I actually agree with the majority of what he said in his post. PHP **is** inconsistent. It **is** verbose. It does have a lot of weird behavior. It does have a lot of problems. It can be ugly. It can be really awkward to work around. It can leave a lot to be desired.

But it's also incredibly powerful. It's really easy to write working applications. It's **really** easy to create a large scale project. It's really easy to extend. It's **really** easy to get help (in reality it's one of the largest and most active programming communities on the Internet).

However, there's one thing that it can do that almost no other popular language can: Be useful to non-developers. All you need to do is look at the open source web application space to see that PHP really wins. I mean in the CMS market alone, PHP dominates by a long shot (Wordpress, Joomla!, Drupal, vBulletin, MODx, TYPO, etc). Pick a web market, and PHP will likely dominate it (if not just have a strong presence). The fact of the matter is simply that PHP is ridiculously easy to deploy. So easy that even a non-developer can do it. 

As Brandon Savage points out: [It's About The Customer](http://www.brandonsavage.net/its-about-the-customer-stupid/). And that's the big missing piece to the original post. Sure, from a developer's standpoint PHP is lacking in quite a few areas. But since when do developers determine what's successful? If developers did, software like Wordpress, jQuery and Jenkins/Hudson would have never made it big (since their codebases have traditionally been of *questionable* quality). But they did, because they solved a problem, and they solved it well.

The fact of the matter is that PHP has a lot of advantages over most other languages. Here's a simple list from the top of my head: * HTTP is a first-class citizen. No other popular language provides this. Not Python, not Ruby, not C, not JavaScript. PHP has HTTP interaction baked right in. You may argue that it's sub-optimal, but it's first class. You don't need a library or a framework to talk HTTP. 

 * SAPI is a first-class citizen (Server API, mod_php vs CGI vs FastCGI, etc). That means that PHP is designed from the ground up to have a server infront of it. That means that transitioning code from CLI to a server API is trivial (it's just changing how it gets the request variables). There's no need for a library or framework to interact with a server. WSGI in Python gets you part of the way there, but you still need to import a library to talk to the server. This makes PHP just plain easier to get off the ground for web applications.
 * Application lifecycle is per-request. This is actually one of the negatives identified by the original post. Every request boots up PHP anew (well, not PHP, but your PHP application). This is a good thing, because (quoting [Rasmus Lerdorf](http://en.wikipedia.org/wiki/Rasmus_Lerdorf), creator of PHP, [in an interview](http://techpatterns.com/forums/about567.html)) *"The shared-nothing architecture of PHP ... leads to infinite horizontal scalability in the language itself."* That means that transitioning from a single server to multiple **after** the application is deployed is trivial. The only constraints are ones that the programmer put in artificially. Languages that use shared state natively (like Python, Ruby, JavaScript - NodeJS, etc - and Java) must be written to not use that shared state that's provided for this to work.
 * Absolutely gigantic user base. Sure, other languages have large followings, but few are as large as PHP. And I personally think that this is one of the best parts of it. There is a boat load of knowledge out there about how to scale PHP, and how to solve almost any problem. If you know what you're doing, finding the answers is actually really easy.

Those 4 reasons are enough for me to keep PHP as my primary language. I do know and actively use Python and server-side JS (Node.JS specifically), as well as a number of other languages. But I stick with PHP for my main projects because, while it's not perfect, it works...

Thoughts?