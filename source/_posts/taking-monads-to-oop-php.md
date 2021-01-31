---
layout: post
title: Taking Monads to OOP PHP
permalink: 2013/07/taking-monads-to-oop-php.html
date: 2013-07-12
comments: true
categories:
- Programming
tags:
- Design Patterns
- Functional Programming
- Learning
- Monads
- Object Oriented Programming
- PHP
- Programming
---

Lately I've been playing around with some functional languages and concepts. I have found that some of these concepts are directly applicable in the OOP code that I've been writing. One of those concepts that I think is worth talking about is the Monad. This is something that every functional developer tries to write a tutorial on, because it's such a cool but hard to grasp concept. This post is not really going to be a Monad tutorial per se, but more of a post about bringing the general concept to OOP, and what that looks like.
<!--more-->

## What Is A Monad

For now, let's not worry too much about *what* a Monad is. That should become relatively apparent as we play around with a few. Instead - for our purposes - just think of a Monad as a state container, where different Monads do different things to that state.

## GitHub Repo

I've got a GitHub repository that I'm going to be playing around with here. I'd suggest that you check it out and play around with it. It's not really designed to be a production library, but instead a way to play with a few concepts and learn. So checkout [MonadPHP](https://github.com/ircmaxell/monad-php).

## Getting Started

To get started, we're going to look at the simplest Monad we can, the `Identity` Monad. If you notice, there are four public functions on the Monad (Defined on the [base Monad class](https://github.com/ircmaxell/monad-php/blob/master/lib/MonadPHP/Monad.php))

```php
namespace MonadPHP;
class Identity {
    public function __construct($value) {/*...*/}
    public function bind($function)     {/*...*/}
    public function extract()           {/*...*/}
    public static function unit($value) {/*...*/}
}
```

The constructor, a function bind, a function extract and a static function unit. Traditionally, you only really need two functions for a Monad (a constructor and a bind function), but the other two will make our lives much easier.

The constructor creates a new Monad (obviously). In reality, all this does is take a value to be wrapped, and set it on a protected property. There's not much logic there.

The extract function does the exact opposite. It takes the value from the protected property and returns it back out. This is a non-standard Monad function, and I added it because PHP isn't really functional in the first place, so this helper method is simply a convenient function.

The static function unit is simply a factory method. It checks to see if the value is already an instance of the current requested Monad, and returns a new instance if not. Really quite simple.

The bulk of the value here is provided by the final method: bind. The bind function takes a callable value and calls it using the wrapped value. So the provided callback never realizes that a Monad is even involved. But whatever the function returns will be wrapped again by the Monad. And this is where the power lies.

So let's try it:

```php
use MonadPHP\Identity;
$monad = Identity::unit(10);
$newMonad = $monad->bind(function($value) {
    var_dump($value);
    return $value / 2;
}); // prints int(10)
$b = $newMonad->extract();
var_dump($b); // prints int(5)
```

Really quite simple. And really quite pointless.

## Where's The Value?

So why is this such a powerful concept? Well, we can add logic into the bind function (or into other functions). This allows us to do useful transformations with the Monad.

We can use the Maybe Monad to abstract away null values. In this case, the bind function will only call the callback if the wrapped value is non-null. This basically abstracts nested conditional logic out of your business logic! So let's try refactoring the following conditional code:

```php
function getGrandParentName(Item $item) {
    return $item->getParent()->getParent()->getName();
}
```

This looks good, but what happens if an item didn't have a parent? You'd fatal error on a null-object call (call to a member function on a non-object). We could fix it like this:

```php
function getGrandParentName(Item $item) {
    if ($item->hasParent()) {
        $parent = $item->getParent();
        if ($parent->hasParent()) {
            return $parent->getParent()->getName();
        }
    }
}
```

That can become this:

```php
function getGrandParentName($item) {
    $monad = new Maybe($item);
    $getParent = function($item) {
        // Can be null, and that's ok!
        return $item->getParent();
    };
    $getName = function($item) {
        return $item->getName();
    };
    return $monad
        ->bind($getParent)
        ->bind($getParent)
        ->bind($getName)
        ->extract();
}
```

Looks pretty straight forward...? It is a little bit of overhead, but look at what changed. Rather than being a procedural step-by-step build-up of functionality, instead it now describes a state transformation. We start with the item, we get the parent, then we get the parent, then we get the name. So the Monad implementation is actually closer to describing the algorithm at the heart of the task, but abstracts away the safety we need.

## Another Practical Example

Let's say that we want to get the GrandParentName from an array of Items? We could iterate over it and call `getGrandParentName()` on each iteration, but we can also abstract that part away as well.

Using the [ListMonad](https://github.com/ircmaxell/monad-php/blob/master/lib/MonadPHP/ListMonad.php), we can treat a list of values exactly like a single one. So we could refactor our last method to take a Monad:

```php
function getGrandParentName(Monad $item) {
    $getParent = function($item) {
        return $item->hasParent() ? $item->getParent() : null;
    };
    $getName = function($item) {
        return $item->getName();
    };
    return $item
       ->bind($getParent)
       ->bind($getParent)
       ->bind($getName);
}
```

Quite simple. Now, we can pass in a `Maybe` Monad, and it will work like before. Or we can pass in a `ListMonad` with an array of items, and it'll still work exactly the same. Let's try that:

```php
$name = getGrandParentName(new Maybe($item))->extract();
//or
$monad = new ListMonad(array($item1, $item2, $item3));
// Make each array element an instance of the Maybe Monad
$maybeList = $monad->bind(Maybe::unit);
$names = getGrandParentName($maybeList);
// array('name1', 'name2', null)
```

Notice that the business logic stayed the same! The difference came from the outside.

## The Core Concept

The core here is that a Monad abstracts away the non-business logic and allows you to simplify your logic as state-transforms. So rather than building up complex logic in a procedural way, you can build it up as a series of simple transformations. And by decorating your values with different Monads, you can handle the common boilerplate logic without needing to duplicate anything. Notice that with the ListMonad, we didn't even need to create a `getGrandParentNames(array $items)` function.

It's not a silver bullet. It's not going to simplify most code. But it's a really interesting concept that has a lot of usages and can really impact the OOP code that we're writing... The only way to really get it is to play around with it. So checkout the repo, and play with the different Monads. Try to create new Monads. Play around with it. Experiment and learn!
