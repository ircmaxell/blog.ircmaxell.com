---
layout: post
title: An Opinion On The Future Of PHP
permalink: an-opinion-on-future-of-php
date: 2014-03-10
comments: true
categories:
tags:
- HHVM
- Open Source
- PHP
- Programming
- Rant
---
There's been a lot of buzz in the community lately around PHP and its future. The vast majority of this buzz has been distinctly positive, which is awesome to hear. There's been a lot of talk about PHP6 and what that might look like. There's been a lot of questions around HHVM and its role in the future of the language and community. Well, let me share with you some of my thoughts in this space...
<!--more-->


## On Backwards Compatibility

In my opinion, backwards compatibility **must** be mostly maintained in a future major release (call it 6, 7, 99, "enthusiastic elephpant", whatever). Now, when I say "mostly", I do mean that some controlled breaks should happen. But those breaks should be well contained and well controlled. They also should ONLY target refining edge-case behavior and the like. That doesn't mean there can't be major internal refactoring. It doesn't mean things can't be cleaned up. It just means that they should broken in very controlled ways so as to not hurt user-land developers.

There's a really simple test to see if this is maintained:

> It **must** be easy to write a single codebase that executes on 5.X and 6.X (and any two consecutive major versions)

Why is that important? Well, look at PHP4 - PHP5 transition. It was pretty easy to write code that worked on both, and it still took nearly 10 years for adoption to switch (in fact, it took a movement called GOPHP5 to pull off). Imagine if it was hard to write code that worked on both?

Well, as it turns out, we don't have to imagine. Python did just that. Python 3 was first released nearly 5 years ago. And today, in 2014, it still sees trivial adoption rates. Not because it isn't good, but because it's not easy to maintain a single codebase that works on both versions. Which means that you either use 2, or you use a subset of 2 that works in 3 (gaining the full benefit of neither). And if the libraries or platforms you need to use don't exist for 3, you're left to port it yourself (basically you are SOL). And in practice, that's exactly what happened.

I don't want to say that it's a mistake to do that. There are a TON of benefits to the language to make those kinds of changes. But to the community and the average user, it's a show stopper IMHO.

## On An Engine Rewrite

There have been people talking about rewriting PHP's engine to clean a lot of things up. While I can definitely see the benefits in it (the engine is a pretty hairy codebase), I have to question why it is needed. After all, what about todays architecture is fundamentally flawed? There are definitely architectural flaws in there, but for the most part it works pretty well.

So, I would much rather see a component based refactor occur. Compartmentalize the engine into a series of subsystems. Today, that's actually partly done. But I'd rather see it refactored to be *practically* pluggable. Why is that important? Well, once the engine is compartmentalized, then specific refactors can occur to actually make significant changes to the engine.

For example, one of the messiest parts of PHP today is in the parser and compiler. Right now, they are so tightly coupled and messy that it causes a ton of issues with development. Instead, if they were compartmentalized, the parser could be swapped out, and the compiler could be swapped out. The common part in the middle would be an AST (Abstract Syntax Tree). Why an AST? Well, because it's a common representation that both sides can use. Don't get me wrong, this would be a very significant amount of work, but would have HUGE benefits. For everything from better, consistent and more predictable syntax to adding the ability to define new syntax via PHP code (imagine being able to define DSLs in PHP that are actually first-class parts of the language).

So no, a total rewrite isn't needed. A refactor is. A cleanup is.

## On Objectifying The Standard Library

Some people have suggested that the core standard library should be refactored to promote scalars into behaving like objects. So that you can do things like this:

```php
$string = "Foo";
var_dump($string->length); // 3
var_dump($string->toLower()); // string(3) "foo"
// etc

```
While I admit this sounds like a cool idea, I don't think it should happen.

The reason is simple, scalars are not objects, but more importantly they are not any type. PHP relies on a type-system that truly believes that strings **are** integers. A lot of the flexibility to the system is based that any scalar can be converted to any other scalar with ease. Now, this isn't necessarily a good thing, in fact a large number of bugs occur because of this. It's a leaky abstraction.

But those types of edge-cases could be cleaned up. For example, you could raise a notice or warning or other catchable error/exception on a "lossy" cast from one type to another (so if you try to cast `"123abc"` into a int, you'd get told there was data loss).

More importantly though, due to this loose type system, you can't 100% of the time know what type a variable will be. You can tell how you want to treat it, but you can't tell what it is under the hood. Even with casting or scalar type hinting it isn't a perfect situation since there are cases where types can still change.

So that means that all scalar operations would need to be bound to all scalar types. Which leads to an object model where scalars have all of the math methods, as well as all of the string methods. What a nightmare...

## The Rise of HHVM

Right now, today, as I write this, I don't recommend moving production systems to HHVM. There are a few reasons for it. And none of them is a fundamental reason. All of them are known. Time will tell if they get resolved, but I have high hopes.

 1. HHVM is controlled by a single company. Don't get me wrong, it's not that Facebook is spending a lot of money on development that's the problem. It's that the project is controlled by a company who's business has no bearing or impact by your use of HHVM. It would be one thing if they sold support contracts and made it into a legitimate product, but as it stands it's neither an open source project, nor a commercial one. It's a weird conglomerate. And I would be VERY wary to bind a production stack to that sort of a situation.
 2. HHVM has no public spec. That means that your code is basically the same as code written to run on the Zend engine. It's a trial and error case. And that's "ok" for a single implementation, but murder to try to support 2 or more implementations. As a library maintainer I have personally felt this pain, and will continue to. However, if HHVM and PHP were to agree on a common specification, then things would get a TON easier...
 3. HHVM is not run as an open source project. It does accept contributed code. That's awesome. But a pull-request/patch queue doesn't make an open source project. Where's the clarity of process? Where's the clarity of vision? Where's the open tooling? Where's the leadership?
I know I'm not alone in these beliefs. HHVM **will** be a strong contender in the future. But IMHO, until the above issues are sorted out, it's not ready for prime-time in a commercial production setting.

## Can Both PHP And HHVM Live Side-By-Side?

Absolutely. Despite what some benchmarks woud like you to believe, JIT compilers aren't magic. They come with real world tradeoffs. Many benchmarks show this specifically. In fact, if you look closely at the vast majority of the benchmarks, you'll notice that they aren't running real world code. Oh, you're comparing the performance of HelloWorld or a Fibonacci generator??? Good for you. Now please quiet down and throw away your meaningless results.

Let me say that again, benchmarks that don't test real world systems are meaningless. They are just noise. They are worse than useless, they are downright dangerous.

In practice, there are going to be use cases where HHVM will give a signifiant boost of speed. But there are also going to be cases where PHP *will* be faster. The only way for you to know is to test **your application**...

### But HHVM Runs My Code As Native! How Could PHP Be Faster

Remember how I said JIT isn't magic? Well, that's true. You can't compile PHP natively directly, because it's a dynamic language. Which means that you can't know enough about what code is going to do to compile it to native code until right before you execute it. So a JIT does just that. It analyzes the code being executed, and when it learns enough about it, it generates native code. There's overhead to this process, which is why HHVM is slow on the command line.

But more importantly, it doesn't generate universal code. It generates code that's specific to the conditions that existed when it was created. So if your function adds 2 integers, it may compile to a simple add instruction. But it will also add guard instructions to confirm that the parameters were integers. If you then pass a non-integer (which is perfectly valid PHP), one of the guards will fail.

When the guard fails, something called a bailout happens. This basically means that the engine will "undo" everything that was done for the current method (effectively running it in reverse), and switch to the interpreted mode. That's far more expensive than just running the interpreted mode in the first place.

And that's just one way JIT compilers aren't "magic".

I don't want this to sound like I'm against JIT style compilers. Indeed, for the majority of code they will result in huge efficiencies. But they aren't perfect.

And if you look at other communities, you'll see VM implementations right along side JIT compiler implementations. CPython and PyPy are two great examples. (It's also worth noting that python has a language spec, so you can easily move between competing implementations).

### But HACK Is Awesome!

Hack is a new language that Facebook developed and included in HHVM. It is basically a statically typed version of PHP, with some AWESOME features built in...

And Hack is incredible! I am really looking forward to my prior reservations about HHVM to be resolved so I can invest in it!

And that leads to an interesting idea. Right now, there are several meta languages spinning up around PHP. Hack and Zephir being the two main ones. But there's a problem. Both are specific to a runtime (Hack only works on HHVM, and Zephir only works on PHP). How to solve that issue?

Well, I would solve it by throwing away Zephir, and building a Hack->PECL compiler for Hack. Since Hack is statically typed, it should be possible to cross-compile between Hack and PECL. And considering that Hack already supports C++ bindings for binding to system libraries, the compiler could theoretically handle that as well. So then there'd be no reason to write a PECL extension again. You'd build your extension in Hack, where you have static code analyzers and debuggers, get it to run, and then generate a 100% compatible PECL extension from it. It's not a trivial thing to build, but I'd love to see it! (Again, another reason for a language spec).

## On A Language Specification

So you may have noticed that I've mentioned a few times already in this post about the need for a language specification...

As a minor hint, I think that's the single most important thing that could happen to improve the future of PHP as a language, platform, ecosystem and community.

## Wrapping Up

It's a very exciting time for PHP. There's a ton of awesome things happening, and a ton of cool progress being made. If we want to keep it going, I think we just need to be smart about the choices we make...

