---
layout: post
title: Foundations Of OO Design
permalink: foundations-of-oo-design
date: 2014-10-29
comments: true
categories:
tags:
- Architecture
- Best Practice
- Framework
- Language Agnostic
- Object Oriented Programming
- PHP
- Programming
---
It's quite easy to mix up terminology and talk about making "easy" systems and "simple" ones. But in reality, they are completely different measures, and how we design and architect systems will depend strongly on our goals. By differentiating Simple from Easy, Complex from Hard, we can start to talk about the tradeoffs that designs can give us. And we can then start making better designs.

<!--more-->
## Simple Vs Easy

We, in general, have a really hard time separating simple from easy. So let's do a bit of a dive into that. I'm going to use some of [Rich Hickey's Examples](http://www.infoq.com/presentations/Simple-Made-Easy):

 * Simple
    
    Simple means the opposite of complex. It is an objective measure
    
    Simple means:
    
     * One role
     * One task
     * One concept
     * One dimension
    But not:
    
     * One instance
     * One operation
    Simple is about lack of interleaving, not cardinality.
    
    By that notion, 2 interfaces that are interdependent is always more complex than 2 interfaces that are separate.
    
    So, example:
    
    ```php
    interface A {
        public function doSomethingWithB(B $b);
    }
    
    interface B {
        public function doSomething();
    }
    
    interface C {
        public function doThingOne();
        public function doThingTwo();
    }
    
    interface D {
        public function doSomethingElse();
        public function doOtherThing();
        public function doOtherThing2();
    }
    
    ```
    By this definition of "simple", then `B+C` is simpler than `A+B`, because `B+C` has no interdependencies. And likewise `C+D` is simpler than `A+B`, even though `C+D` does "more", there is less interconnection and hence less interleaving.
    
    `B` is simpler than `C`, but you can't talk about `A` on its own, because it depends on `B`. So we wind up with this hierarchy of simplicity, from simplest to most complex:
    
    ```php
    B -> C -> B+C -> D -> B+D -> C+D -> A+B -> B+C+D -> A+B+C -> A+B+D -> A+B+C+D
    
    ```
    Note that `B+C` is simpler than `D`, even though they have the same number of methods. This is because the three methods on `D` are related in that they belong to the same interface. `B+C` has the same number of methods, but using unrelated interfaces are further decoupled, hence simpler.
 * Easy
    
    Easy talks about the amount of effort. Easy is a relative measure, it's a subjective one.
    
    The reason it's subjective is it requires background knowledge. What I find easy, you may not.
    
    Easy requires tacit knowledge. I do not know Dutch, so reading a book written in Dutch would be difficult. But because I know English well, reading a book in English is easy (even though it may be difficult due to complexity of the material).
    
    The same goes for OO design.
    
    If you understand a system deeply, it can seem trivially easy to modify.
These two concepts are related, but not replaceable. Difficulty (easy vs hard) is related to how much you understand of a concept, whereas simplicity (simple vs complex) is related to how connected things are.

In general, when viewing from the outside, a more complex solution will appear to be harder. But that doesn't mean it is. Sometimes that added complexity can make things easier when you get inside.

So when we talk about simplicity, we are **only** talking about connected-ness and measurable complexity. We are not talking about ease-of-use or ease of understanding.

## Essential vs Accidental Complexity:

 * Essential Complexity
    
    This is complexity that is fundamental to the problem being solved.
    
    If you are writing a function that adds two numbers, you cannot get simpler than:
    
    ```php
    function add($a, $b) { return $a + $b; }
    
    ```
    The essential complexity is the minimum required to solve the problem. It is essentially a measure of the complexity of the problem.
 * Accidental Complexity
    
    Accidental complexity (sometimes called incidental) is complexity that's added to the solution which is not strictly required by the problem.
    
    If you are writing a function that adds two numbers, you might want to do:
    
    ```php
    function add($a, $b) { 
        if (!is_int($a) || !is_int($b)) {
            throw new \InvalidArgumentException(
                "Both A and B must be integers"
            );
        }
        return $a + $b; 
    }
    
    ```
    The error checking, in this case, would be accidental complexity. It's not strictly required to solve the problem (it would work without it), but it adds a layer of defense.
    
    Accidental complexity has a negative tone, but it's not always a bad thing. In the case here, the additional check, while tangential to the addition problem, makes the overal application more robust.
## Design Principles:

These principles (or axioms, depending on how you want to think of them) are the basis for everything else to follow.

 1. All other things being equal, a simple solution always is better than a complex solution
    
    Note the "all other things being equal" part.
 2. All other things being equal, a solution should attempt to minimize Accidental Complexity.
    
    Again, note the "all other things being equal" part.
 3. All other things being equal, a solution should be as easy as possible *for the target developers*.
    
    Note that this doesn't mean it should be easy for everyone (as a target). If you have a dedicated team, target them. If you worry about expansion, then target someone with a baseline set of skills.
    
    For example: if you're worried about hiring, and are using Symfony Framework (for example), then do your custom work targeting maximizing the "easy" factor to developers experienced with Symfony.
These may seem obvious. But considering how *all other things being equal* never really happens, it's easy to forget.

## The Real World

Applying these principles to the real world, what you wind up with are a set of heuristics. A set of tradeoffs.

And what OO design and architecture are all about, it's about knowing these tradeoffs, and weighing them appropriately for the specific task at hand.

This is why it's so hard to talk about OO design in a non-abstract manner. Anyone who tells you one specific architecture is the right tool for the job (who doesn't understand your *specific* problem) has no idea what they are talking about, or is trying to sell you something (or both).

Instead, we need to understand these tradeoffs and apply them to our software design.

