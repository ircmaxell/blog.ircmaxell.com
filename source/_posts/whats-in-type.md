---
layout: post
title: What's In A Type
permalink: whats-in-type
date: 2014-10-24
comments: true
categories:
- PHP
tags:
- Change
- Inconsistencies
- Language Agnostic
- Object Oriented Programming
- PHP
- PHP-Internals
---
There has been a lot of talk about typing in PHP lately. There are a couple of popular proposals for how to clean up PHP's APIs to be simpler. Most of them involve changing PHP's type system at a very fundamental level. So I thought it would be a good idea to talk about that. What goes into a type?

<!--more-->
## Type Systems In General

Type systems tend to have 4 main properties. Or really, two axises they can be judged by: Strength and Explicitness.

Explicitness describes whether the types are resolvable at compile time. So an explicit type system either requires you to specify every type (commonly called "strict" typing) or it uses type inference to deduce the type. While different, both are explicitly typed. Without explicit typing, you have dynamic typing. This is where a compiler cannot know all type information at compile time. Some of the type information must come at runtime.

Strength describes what happens when you try to mutate a type. Can you change a variables type easily? In Strong typed languages, once a variable is defined to be a particular type (via explicit or runtime typing), it can never change types. In a Weak typed language, variables can change their type in the course of the program.

Looking at some popular languages:

<table><thead><tr><th>Language</th><th>Explicitness</th><th>Strength</th></tr></thead><tbody><tr><td>PHP</td><td>Static + Dynamic</td><td>Weak</td></tr><tr><td>Python</td><td>Dynamic</td><td>Strong</td></tr><tr><td>C</td><td>Static</td><td>Strong</td></tr><tr><td>Java</td><td>Static</td><td>Strong</td></tr><tr><td>JavaScript</td><td>Dynamic</td><td>Weak</td></tr><tr><td>Ruby</td><td>Dynamic</td><td>Weak</td></tr></tbody></table>

By definition, all Static languages are going to be Strongly typed. But there are even gradations within that. For example, in C, if you pass an integer to a function expecting a float, it'll happily cast it for you (as long as it's not a pointer). But in Java, that same functionality will be a compiler error.

Notice that both JavaScript and PHP are both Dynamic and Weak. But also note that PHP is also Static. Static and Weak? I just said that was not possible by definition. This is curious.

As it turns out, we get a few of the nice parts of Static typing, with none of the benefits. It's still quite hard to statically analyze PHP.

So, let's talk about the tradeoffs involved with a type system.

## The Tradeoffs

The tradeoffs are rather interesting. On one hand, if a language is both Statically typed and Strong typed, it's far easier to analyze without running the program. We call this type of analysis "static" analysis. Because it only looks at the code, not runtime information.

So a Static+Strong language is easier to analyze. What does that buy us? Well, it lets us have compilers that check for a certain class of errors automatically. You can detect areas where you wanted a string, but were given an array. Or where you expected an integer, but were passed a string. Etc. It means that all type conversions will be specified explicitly.

This doesn't mean that there are no bugs. It just means there are no *type* bugs. That's a very important distinction to make, for example:

```php
function foo(int length_in_feet) {...}
int length_in_meters = 10;
foo(length_in_meters);
```

From a type standpoint, that's 100% valid code. And no static analyzer will ever tell you it's wrong. But it's quite obviously wrong.

When we move from Static to Dynamic typing (while retaining Strong), an interesting thing happens. Once we know the type (via explicit cast, or other operation), we can rely on it. That means that compilation is a fair bit easier. Sure, we can't statically analyze as well, but it's easier on the programmer. And since you know that once the variable is created its type won't change, it's a bit easier to work with than weak languages.

But do you lose anything with it? Well, yes. You lose flexibility. And you lose the property of forgiveness.

With a statically typed language, if the types don't match, it's up to you to fix it. For small systems, this is easy to do. For large systems where the developer has intimate knowledge of the system, it's pretty easy to do. But for a junior developer, it can be difficult. For a new programmer, it can be down right confusing.

That's not that big of a deal though when writing custom code yourself. The type safety can be hugely beneficial.

But imagine you're running WordPress in a **purely** statically typed language. You install a plugin, and all of a sudden you get a compiler error on a type mismatch. That could be a problem! But how to fix it? To someone just starting out programming? That's unpossible...

Well, it depends on the types involved.

For some mismatches, it can be seen as an annoyance. "Expecting int, but found float". Yay. Sure, it's nice to be explicit, but that's annoying. Why not just do the sane thing when it seems sane?

And ultimately, that's the basis for PHP's type system. Try to do the sane thing, and error if you can't.

## PHP's Type System

PHP really has two semi-independent type systems. It has one for Objects, and one for everything else (yes, you can type hint on arrays and callables, but they are complex on their own).

For objects, it follows a Strict+Weak model. Which is really weird, because the type checks only happen at function boundaries or with `instanceof`. For example:

```php
function foo(Bar $bar) {
    $bar = 10;
}
```

We strictly hinted on `Bar`, but then the variable changed types. That means when we analyze PHP, we need to keep in mind that the types can change on a line by line basis. So talking about the type of a variable is more talking about how the type propagates over time through a program.

For everything else except objects, we have a fully weak system. Excluding the weird `resource` type, PHP will always *try* to do a sane conversion for you. Meaning:

```php
function foo($a) {
    return $a + 1;
}
```

When we call that function, we don't know what the result will be. But we can say for sure that it will be a numeric type (float or integer). Now, the interesting thing is what happens when we pass in something that's non-numeric. What if `$a` was a string? What if it was an array? What about a boolean?

Well, PHP will use the context that you're using the type in to determine what type it should be (re-read that line, this is important, and we're going to come back to this again).

So when we pass in a string, it'll say "Hey, this is a numeric operation, so let's try to convert to a numeric". Then it'll look at the string, and say "does this look like a number?". If it does, then it converts it silently to that number, and proceeds. If not, it'll raise a notice, and return the nearest sensible value (`0`).

We call this type juggling. And PHP's type system is rooted in it.

In a lot of cases, it's incredibly valuable. It makes an application more flexible, but really it makes it more forgiving. "You expected a float, but tried to pass an integer, no problem, we'll make it work".

The devil is in the edge cases. And PHP is famous for them. But overall, as long as you stay in the sweet spot, it works really well.

## Context Is Everything

PHP's entire scalar type system is built around context. When you pass a variable to `strlen()`, it doesn't matter what the type is, you're saying you want a string length.

PHP's entire type system is built around that fact. You need the context to determine what the type should be.

## Polymorphism

Polymorphism is basically inverting the relationship of context. Rather than the calling code providing the context, it lets the type itself provide the context. So when you call `$foo->bar()`, you're saying "I don't care what `$foo` is, just do the `bar` concept on it".

With polymorphism, the functionality can change simply by changing the type. So the same method can do two different things on two different objects (`$duck->quack()` can either echo `"quack"` or do something far more nefarious, but to the calling code, it's just a quack).

This is incredibly powerful, because it inverts the normal context relationship. Rather than the call providing the context, it lets the called thing determine the context.

So what happens when Polymorphism meets PHP's weak type system?

## Chaos

Imagine for a second that we had methods on scalar types. What would the following code do:

```php
$foo->length()
```

Does that take the string length? Does it take the array length? Does it give you something else entirely?

On the surface, that seems like a moot point. That's the point of polymorphism, after all.

But what happens if you intended to get the string length. Then what happens if it's an object that implements `__toString`? Do you expect the method call to fail? Or do you expect `__toString` to be called first?

Ok, so that's not a big deal. If you want a string length, you just make sure you have a string!

```php
$str = (string) $foo;
$str->length();
```

Or even better, if we had strict scalar type declarations:

```php
function my_strlen(string $str) {
    return $str->length();
}
```

Boom! We have predictability. We have sanity! We know our code works on strings, so we know the length method works! Awesome!

But how would you call that code? If you wanted safety, you'd almost *have* to just use a cast:

```php
my_strlen((string) $foo)
```

But now we're back to the beginning. We have lost all the benefits of strong typing. It's the same type juggling all over again, but this time we're pushing the juggling requirement onto the caller of our code. Weird.

The cast is the least safe alternative that we could do. At least the implicit context-based cast will raise errors (or notices really) if the cast doesn't make sense (like passing `"apple"` to a function expecting an integer). The explicit cast means that you can be hiding far worse bugs...

## Enter Safe Casts

There's currently a [proposal to add Safe Casts](https://wiki.php.net/rfc/safe_cast) to PHP. This would basically be a series of functions which will convert if sane, or error. So it provides the same context that PHP needs under the hood, yet allows the programmer to determine that context at call time.

```php
my_strlen(to_string($foo));
```

That's a lot better, since an unsafe value results in an error...

If strict scalar type declarations (hints) are going to happen, a safe-cast mechanism would make it much safer.

## My Assertion

I don't think you can reasonably do scalar methods without scalar type declarations (type hinting). The context point is lost without it.

I don't think you can do scalar type declarations without a safe cast mechanism. Otherwise you're just changing where the error is hidden.

And you definitely can't remove the context-dependent APIs (the existing procedural APIs) without fundamentally changing the entire type system. At which point it's not PHP anymore.

So the choice (for a scalar method API) boils down to: don't do it, or provide two of every API (one procedural, one via methods).

And that sounds pretty scary to me...

