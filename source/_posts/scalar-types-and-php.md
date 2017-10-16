---
layout: post
title: Scalar Types and PHP
permalink: scalar-types-and-php
date: 2015-02-11
comments: true
categories:
- PHP
tags:
- Language-Design
- PHP
- PHP-Internals
- Scalar
- Types
---
There's currently a proposal that's under vote to add [Scalar Typing to PHP](https://wiki.php.net/rfc/scalar_type_hints) (it has since been withdrawn). It's been a fairly controversial RFC, but at this point in time it's currently passing with 67.8% of votes. If you want a simplified breakdown of the proposal, check out [Pascal Martin's **excellent** post about it](http://blog.pascal-martin.fr/post/in-favor-of-rfc-scalar-type-hints.html). What I want to talk about is more of an opinion. Why I believe this is the correct approach to the problem.

[I have now forked the original proposal and will be bringing it to a vote shortly.](https://wiki.php.net/rfc/scalar_type_hints_v5)<!--more-->

## Strict All The Way

So, a portion of the community wants strict-only types. So that if you declare `function foo(int $abc)` and pass in a non-integer, it will raise an error.

There are a ton of advantages to this approach. You get type safety. Which means that you can finally statically analyze code! You can detect bugs where you accidentally take a string from one function and pass it as an integer to another.

That may not seem like a big deal to you at first. The reason is that while it may be appropriate in some cases, in many it isn't. So computers can't reason about that code ahead of time (statically) and therefore can't be sure that the operation will work.

Type checkers (static) aren't the end-all be-all of testing. They can't tell you if your code is semantically correct (does what you think it does). But what it will tell you is if your code will do what it says it does. For example:

```php
function foo(string $abc): int {
    return $abc + 1;
}
```

There's a type error in here. You're taking a string (text) and using it in a numeric context. That may work for some inputs (like `"12"`), but will be weird for some (like `"10 apples"`) or down right wrong for others (like `"bird"`).

So that code's behavior will change depending on the input. And it will change in subtle and hard to follow ways.

With static analysis, you can be told that

> Hey, it looks like you're using a string where you're expecting a number. This might not do what you expect, we suggest either changing the type from a string, or doing some validation first.

## The Weak Argument

On the other hand, if you used weak (casting) types, you'd still be able to do the same analysis inside of a function! You know that in function `foo`, that `$abc` is a string, and you'd be able to find the bug as well. Therefore there's no benefit to erroring on invalid input, so just cast it to make it work. Because that's easier on the programmer with all the benefits of strict typing.

So wait a minute, does that means that we can statically analyze both strict and weak types?

And does weak typing provide all of the benefits of strict typing?

In short, no.

## The Conceptual Difference

The problem comes down to if you believe that a changing type is OK or not. If an implicit type-change signals the presence of a bug or if it's normal.

And the sane answer to that is "it depends".

It depends on what you're writing. It depends on what you're doing. It depends on the problem that you're solving.

In some cases, having a casting-based weak approach is perfectly acceptable. Beyond acceptable, it's one of the reasons that PHP and dynamic languages in general exist. The reason is that it's sane to pass `int(123)` into a function that expects a string if you want to use the string representation of the number. It's incredibly powerful to just be able to pass a variable to a function and have it work.

In other cases, a weak-based approach is going to lead to subtle problems. An example would be using `password_hash`:

```php
function password_hash(string $password, int $algorithm, array $options)
```

Which you can call like `password_hash($password, true)` to get a bcrypt hash.

In this case, everything looks fine, right?

And indeed everything operates fine in weak typing. It isn't until you turn on strict typing to see that `bool` is not an `int`. Wait a minute, that `true` should be a constant!

So by using coercion, we hid the intent of the parameter behind an accidentally-worked situation. The code is incorrect *today* (and may not work in the far future) but pretends everything's OK...

But let's take a far better and more dangerous example:

```php
curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, true);
```

With weak type hints, you'd read that line and think "Cool, we're verifying hostnames". But no...

That option takes an integer parameter:

 1. only verify the cert has a name
 2. verify the name matches the domain you're using
Notice what happened? You think that `true` causes curl to verify the host. But in reality it doesn't. Another subtle (yet **potentially catastrophic**) bug caused by weak typing.

## History

History has showed us that these subtle bugs are incredibly difficult to find, and plague developers for a long time.

Take a look at PHP 5.4, which added a notice when you tried to convert an array to a string. Prior it would just use the word `"Array"`. But starting in 5.4, it would add a notice as well. The [flood of questions](https://www.google.com/search?q=notice+array+to+string+conversion) showed that people were relying on meaningless casts **without even knowing about it**.

Drupal's [own test suite relied](https://bugs.php.net/bug.php?id=60198) on this behavior for years without knowing it. Their tests passed on code that didn't work **silently**.

## The Problem That Needs Solving

The problem with strict types is that they are a pain in the neck to use in conjunction with a dynamic language. Seeing as PHP treats `12` and `"12"` as the same value in most contexts, that would mean that calling strict typed code would require a cast. So you'd call `sha((int) $algo, ...)` instead of passing the algorithm directly.

This would be safe, but it also would completely defeat the point of strict types as the cast would hide the very errors the strict typing is supposed to catch.

So plain strict types won't work...

But weak types hide all sorts of classes of subtle bugs that strict types will catch. So plain weak types don't get us any further in terms of code correctness or validation.

So neither solution works by itself.

## Enter Mixed-Typing

This is where the current proposal comes in. Many call it a compromise. Many call it a "worst-of-both-worlds". I call it the only way to do strict typing in PHP that won't utterly suck.

The genius of this proposal is that your code controls how you *call* other functions. So if you want your code to be strict, any function you call will be treated strictly. But if you don't want to be strict, then the functions you call will accept weakly.

So what the heck does that mean?

Let's take a rather simple example:

```php
<?php //index.php

include "functions.php";

switch ($_GET['action']):
    case 'add':
        echo add($_GET['x'], $_GET['y']);
        break;
    case 'div':
        echo div($_GET['x'], $_GET['y']);
        break;
    case 'quadratic':
        $value = quadraticFormula($_GET['a'], $_GET['b'], $_GET['c']);
        echo $value[0] . ', ' . $value[1];
        break;
}
```

Then

```php
<?php //functions.php
declare(strict_types=1);

function div(int $x, int $y): float {
    return $x / $y;
}

function add(int $x, int $y): int {
    return $x + $y;
}

function quadraticFormula(float $a, float $b, float $c): array {
    return [
        div(-1*$b + sqrt($b**2 - 4*$a*$c), 2*$a),
        div(-1*$b - sqrt($b**2 - 4*$a*$c), 2*$a),
    ];
}
```

Without strict typing in functions.php, you'd be hard-pressed to find the bug. But it's there.

The problem is that `div` is integer division. But `2\*$a` is a float (since `$a` is a float). So therefore there's a cast going on. In fact, it would truncate to the nearest integer. Which would be fine for large numbers (>10000 perhaps), but for small numbers would cause massive error.

Which means that `quadraticFormula` would produce weird results (especially for small values of `$a, $b, $c`). And there's nothing that would tell you that. If you didn't sit down and write a unit test with hand-calculated results, you'd never realize it. Yet the usage of it would be wrong. And that error would propagate through your application.

But since we declared strict types, we were notified of the error right away. So we can see that we need to fix it. We could add an int cast in front of `2\*$a`, but the proper fix would be to add a new `floatdiv` function (or promote the `div` function to accept a hypothetical `numeric` instead):

```php
function floatdiv(float $x, float $y): float {
    return $x / $y;
}
```

OR:

```php
function div(numeric $x, numeric $y): numeric {
    return $x / $y;
}
```

So our strict type system prevented us from making a pretty significant error without realizing it.

However, since `index.php` is in weak mode, we can still call into the math functions without having to cast. And without having the overhead of worrying about the types involved. Ideally you would want to validate the input (please do), but even if you don't, things won't blow up.

So it's even better than the best of both worlds. It allows for the fully dynamic side of PHP to interact safely and sanely with a fully strict side. And it makes it easy to do so while still generating meaningful errors when necessary.

This, in my opinion, is the only way to handle strict typing in PHP.

## The Way Forward

Moving on, if this RFC passes, it will open a LOT of doors. Better static analyzers. More efficient opcode generation.

And my favorite: native compilation. If this vote passes, I plan on building a native compiler as a PECL extension to compile fully-strict-and-typed functions down to native code. Not as a JIT (doing it when the function's called), but at compile time when opcodes are generated.

So I hope this passes. Not as a compromise, but as the right way to do it.

