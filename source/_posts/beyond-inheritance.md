---
layout: post
title: Beyond Inheritance
permalink: 2013/11/beyond-inheritance.html
date: 2013-11-04
comments: true
categories:
- Programming
tags:
- Beyond
- Language Agnostic
- Object Oriented Programming
- PHP
- Programming
---

In my [last post](http://blog.ircmaxell.com/2013/09/beyond-design-patterns.html), I talked about revisiting the concept of Design Patterns and questioned how useful it is to "learn" them. The conclusion that I came to was that you are better served by focusing on how objects communicate rather than traditional patterns. Well, that's not the only "traditional concept" that I think we should move beyond. So, let's talk about inheritance...<!--more-->

## What Is Inheritance?

So, let's get on the same page here. When I say inheritance here, I am talking about direct class inheritance. I am not talking about traits or interfaces. I am talking about abstract classes though. So any time you write `class {NAME} extends {PARENTNAME}`, we can say that `{NAME}` "inherits from" `{PARENTNAME}`.

So:

```php
class Foo {
}

class Bar extends Foo {
} 

class Baz implements Iterator {
}

class Buz {
    use SomeTrait;
}
```

Only `Bar` is considered using inheritance for our purposes here. To understand why this distinction is important, let's examine what actually happens in each of the three cases (`extends`, `implements` and `use`, or `Inheritance`, `Interface` and `Trait`).

## Implementation Versus Specification

All three methods impact Implementation and Specification differently. Basically, Implementation is physical code that does "something", while Specification is a promise to do "something". A Specification defines `what`, while an implementation defines `how`.

Imagine that you're a chef and you want to make an apple pie. You can go out and find a specification (a recipe). But that won't help you make it without ingredients (implementation).

At first, this may seem like a bad example, as ingredients aren't a process. But think about it for a few minutes. If you had ingredients, but no recipe, you could likely make `something` that was edible. And if you had some skills, you could likely make something amazing without a recipe. But without ingredients, the best recipe would be completely worthless.

Interfaces provide pure specification. They don't `actually` solve a problem. Instead, they define the contract that another system (or more than one) will implement.

Traits provide pure implementation. They don't offer any contract, they just define an implementation. 

Classes provide specification along with implementation. They distill the recipe and ingredients into a pre-measured "kit", providing both a contract and the implementation.

All that's pretty straight forward (I hope).

## Flexibility

Separating Specification from Implementation gives us HUGE benefits. We can vary either without dependence on the other. The only thing that matters at the end of the day is that the Specification is implemented. How is not our concern.

So, what does that mean for us? 

Well, if we use Traits and Interfaces, we can build one-off Classes where we are just mixing the ingredients together to do what we want. We can call this static composition (static because the class is hard-coded for this mix). So now we have these off-the-shelf re-usable components which we can piece together in the right order to implement whatever we want.

If we use classical inheritance (class inheritance), we wind up losing some of this flexibility. That's because any class that extends another is also bound by all of the contracts **and implementations** of its parent. All of a sudden, we lose a significant amount of flexibility, because our child class is no longer flexible.

## Use-Cases For Classical Inheritance

So why would we want to use classical inheritance? Wouldn't there be a reason that "makes up for" the loss of flexibility? Well, as it turns out, there are two separate use-cases for classical class inheritance:
 * `Code Reuse` - Inheritance is a method for vertical code reuse (vertical, because the code is bound to the same contracts as the parent). So we can avoid certain duplications of code by using inheritance.
 * `Contract Reuse` - Inheritance is a method for extending contracts to other classes. So by using inheritance, we can make child classes satisfy all contracts that the parent satisfied (if you type-hint against the parent class, a child will satisfy that hint).

This shouldn't be much of a surprise. Since we're inheriting from another class, we're inheriting both the contract and the implementation.

The problem here is that either use-case is automatically the other use-case. If you're just using classical inheritance to provide code-reuse, you are also getting the contracts of the parent. If you're using it to get the contracts of the parent, you're also getting the implementation.

## What Is A Contract

All of this boils down to a simple question: `What is a contract?`. How you answer that question will tell you whether contract reuse (and hence classical inheritance) is a good thing or not.

Many people, when they first teach OOP, tend to teach that a class is a "Type", and that objects are instances of that type. Indeed, this makes sense! If we think of it that way, we can now draw parallels to the real world.

As humans we understand classifications and types quite well. In fact, we subconsciously do it all of the time. This is one reason that the "Type System" model is so prevalent in programming. We understand types. To demonstrate what I mean, let's take an example that we often see in "intro to OOP" text:
```php
    interface Animal {
        // ....
    }
    class Cat implements Animal {
        // ....
    }
    $cat = new Cat("Some Name");
    $cat->meow();

```

We use examples like this because it allows us to draw real-world connections and analogies. We can imagine that `$cat` is actually an object which represents a physical cat in the real world (a specific one). From there, we can imagine that our methods are interacting with that physical object. It is really easy to understand, which is one of the reasons that it is so widely used.

But it raises a very significant problem. I've never seen non-trivial real-world code that behaves like that. How do you visualize a Session object as a real-world object? How do you visualize a View as a real-world object? How do you visualize an event listener as a real-world object?

There may be some code that does fit this model. User classes are one that come to mind. In fact, domain classes in general \*may\* fit this mold. But the vast majority of the code that we write is not the domain model. It's code that will interact with the domain model (or do other services). Therefore, it's useful to visualize and discuss that code in a different context...

## Enter Behaviors

This is another approach to what a "specification" (class or interface) is conceptually. A specification doesn't represent a real-world "thing" so much as it represents a "behavior". So instead of describing what an object **is**, a class or interface would describe what an object **does**. This may seem like a minor tweak, but its effect is very significant. 

Let's talk about a `real` application concept to see why this is significant. Let's imagine we're talking about interacting with a cellphone. Our application will do a few things, such as send an SMS, etc. So, let's imagine what our interface might look like in a traditional model:

```php
interface CellPhone {
}
```

Well, every phone has a number, so let's add that:

```php
interface CellPhone {
    public function getNumber();
}
```

Every phone also has a model:

```php
interface CellPhone {
    public function getNumber();
    public function getModel();
}
```

We can send phones SMS messages:

```php
interface CellPhone {
    public function getNumber();
    public function getModel();
    public function sendSMS($message);
}
```

But hang on. Why can the cellphone send an SMS to itself? That doesn't make sense. Something else needs to send it the SMS. So we can give it a target number.

```php
interface CellPhone {
    public function getNumber();
    public function getModel();
    public function sendSMS($number, $message);

}
```

Ah, that makes more sense. Instead of sending an SMS `to` the instance of the phone, we're having `it` send an SMS. Makes sense, right? Well, no. And I should hope that you recognize that it doesn't belong. Or at least it should feel weird or somewhat out of place, even if it's not obvious why (yet).

Let's look at the behaviors associated here. The first two methods (`getNumber()` and `getMode()`) have a very defined behavior that we can sum up as `Representing A Specific CellPhone`. It's not actually linked to that phone. It just stands in the place and represents the specific information about it.

The third method (`sendSMS()`) is different. Its behavior is to `Send a Message`. That is, it's behavior is to `Do` a specific task. It felt out of place, because it's fundamentally a different responsibility than the rest of the methods on the object. It's a fundamentally different behavior.

## Behaviors Are Key

One common question that I've heard when talking about OOP is "How do I know if a method belongs on a particular object or not?". Well, the answer is related to the behavior of that object. Every object should have one "fundamental" behavior. Each method should implement one or more "facets" or parts of it. Yet each method is also a behavior. So the object (or specification, interface) should be a collection of related behaviors that combine to produce a complete behavior.

The beauty of this model is that it applies at all levels of your application. Methods implement a single behavior. Classes implement a collection of related methods to implement a single complete behavior. Packages combine a collection of classes to implement a set of related behaviors. Libraries combine a collection of packages to implement a more broad behavior.

All the way up to the application. It's a fractal!

And that is the key! Object Oriented Programming is all about abstraction. Each layer is an abstraction of code below it. Using "types" makes this difficult, because often we don't have real-world analogs to represent each layer. After all, an abstraction is specifically `not` a type. It's the concept behind it. With behaviors, this comes naturally.

## Back to Inheritance

So, why would we use traditional inheritance?

Well, as we talked about before, there are fundamentally two reasons: Code Reuse and Specification. If a class represents a "type", then inheritance bringing along specification makes sense. When you inherit from a class, you "inherit" its type (or create a subtype). But if a class represents a "behavior", creating a new class is defining a new behavior. If a new class needs to use behavior from an existing one, it's usually better to compose that behavior together using composition, rather than inheritance.

Composition allows for more-flexible re-use than extension does. Inheritance is static, composition is not. Inheritance is one-way, composition is not. In short, inheritance is hard-coupling, composition is loose-coupling. In traditional type-based OOP, this is completely true as well. The difference is that now, with behaviors, we have less reason to use inheritance.

Try it. Go out and play. Focus on how you can compose objects in different ways. Focus on how these different compositions communicate. See how with a proper abstraction, you can vastly adjust behavior without altering code (other than which objects are composed, and how).

This shift is a LOT more subtle than the last one (design patterns). Think about it. Play with it. Use it on your next project. Really try to see past "type" and into "behavior".

BTW, I think we can go further, but more on that in a later post... :-D