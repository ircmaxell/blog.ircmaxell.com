---
layout: post
title: OOP vs Procedural Code
permalink: oop-vs-procedural-code
date: 2012-07-11
comments: true
categories:
- Programming
tags:
- Architecture
- Best Practice
- Design Patterns
- Object Oriented Programming
- PHP
- Procedural Programming
- Programming
- Rant
---

This morning I was asked a question that took me by surprise: "Your examples for PasswordLib are in OOP style, how do I write it in procedural style"... This took me by surprise, because the examples actually are in a procedural style. So I felt that I should write a post about the real differences between OOP and Procedural coding styles. Hint: whether you use classes and objects or not has very little to do with the answer...<!--more-->

## Procedural Programming

Wikipedia defines [procedural programming](http://en.wikipedia.org/wiki/Procedural_programming) as:

> **Procedural programming** can sometimes be used as a synonym for [imperative programming](http://en.wikipedia.org/wiki/Imperative_programming) (specifying the steps the program must take to reach the desired state), but can also refer (as in this article) to a [programming paradigm](http://en.wikipedia.org/wiki/Programming_paradigm), derived [structured programming](http://en.wikipedia.org/wiki/Structured_programming), based upon the concept of the `procedure call`.

That's a decent definition, but let's see if we can improve upon it. I'm going to assert here that procedural programming is really just the act of specifying a set of ordered steps needed to implement the requested functionality. How those steps are implemented is a detail that's not related to the paradigm. The important thing is that it's imperative in how it works. Let's look at a few examples:

Obviously procedural:

```php
$m = mysqli_connect(...);
$res = mysqli_query($m, $query);
$results = array();
while ($row = mysqli_fetch_assoc($res)) {
    $results[] = $row;
}

```


This is also procedural, even though it uses an object:

```php
$m = new MySQLi(...);
$res = $m->query($query);
$results = array();
while ($row = $m->fetch_assoc($res)) {
    $results[] = $row;
}

```


This is still procedural, even though it uses a class:

```php
class GetResults {
    public function getResults() {
        $m = new MySQLi(...);
        $res = $m->query($query);
        $results = array();
        while ($row = $m->fetch_assoc($res)) {
            $results[] = $row;
        }
        return $results;
    }
}

```

Note that all three of those examples use the exact same code structure. The only difference between them is the way the routines are resolved. But each is procedural. Each has discrete steps that must be taken. Let's look at what OOP is and why this is different...

## Object Oriented Programming


Wikipedia defines object oriented programming as:

> **Object-oriented programming** (**OOP**) is a [programming paradigm](http://en.wikipedia.org/wiki/Programming_paradigm) using "[objects](http://en.wikipedia.org/wiki/Object_(computer_science))" – [data structures](http://en.wikipedia.org/wiki/Data_structure) consisting of [data fields](http://en.wikipedia.org/wiki/Field_(computer_science)) and [methods](http://en.wikipedia.org/wiki/Method_(computer_science)) together with their interactions – to design applications and computer programs. Programming techniques may include features such as [data abstraction](http://en.wikipedia.org/wiki/Data_abstraction), [encapsulation](http://en.wikipedia.org/wiki/Encapsulation_(object-oriented_programming)), [messaging](http://en.wikipedia.org/wiki/Message_passing), [modularity](http://en.wikipedia.org/wiki/Module_(programming)), [polymorphism](http://en.wikipedia.org/wiki/Polymorphism_in_object-oriented_programming), and [inheritance](http://en.wikipedia.org/wiki/Inheritance_(computer_science)). 


Again, that's a decent definition. But I only agree with the second part. The first sentence says that you must use object data structures to write OOP. That's blatantly wrong. You can completely implement data abstraction, encapsulation, messaging, modularity, polymorphism and (to a limited extent) inheritance without using an object structure. What I'd argue makes code OOP is a few things. First, it must abstract the data concepts into modular units. Second, it must have some way to polymorphically execute code. Finally, it must at least partially encapsulate that code and functionality. Let's look at a few examples before continuing further:


A classic OOP pattern:

```php
class Mediator {
    protected $events = array();
    public function attach($eventName, $callback) {
        if (!isset($this->events[$eventName])) {
            $this->events[$eventName] = array();
        }
        $this->events[$eventName][] = $callback;
    }
    public function trigger($eventName, $data = null) {
        foreach ($this->events[$eventName] as $callback) {
            $callback($eventName, $data);
        }
    }
}
$mediator = new Mediator;
$mediator->attach('load', function() { echo "Loading"; });
$mediator->attach('stop', function() { echo "Stopping"; });
$mediator->attach('stop', function() { echo "Stopped"; });
$mediator->trigger('load'); // prints "Loading"
$mediator->trigger('stop'); // prints "StoppingStopped"

```


The same pattern, using functions.

```php
$hooks = array();
function hook_register($eventName, $callback) {
    if (!isset($GLOBALS['hooks'][$eventName])) {
        $GLOBALS['hooks'][$eventName] = array();
    }
    $GLOBALS['hooks'][$eventName][] = $callback;
}
function hook_trigger($eventName, $data = null) {
    foreach ($GLOBALS['hooks'][$eventName] as $callback) {
        $callback($eventName, $data);
    }
}

```


As you can see, both follow the [Mediator Pattern](http://sourcemaking.com/design_patterns/mediator). Both are object oriented, because they both are designed to de-couple caller from sender. Both provide state, and are modular. The difference here, is that one is implemented using a traditional object (and is hence reusable, a very good advantage) and the other is not reusable since it depends on a global variable. I used the term "hook" here for a very important reason. It's the name of the event system that [Drupal](http://drupal.org/) uses.

Drupal in a lot of ways is very object oriented. Their module system, their hook system, their form system, etc are all object oriented. But none of them use objects for that. They use functions and dynamic dispatch. This leads to some really awkward tradeoffs, so I'm not suggesting that it's a good thing, just that it's a proof that you don't need classes to write OOP.

## Why does it matter?

It matters for a very simple reason. A lot of developers think that just because they use classes, they are writing OOP. And others think that because they use functions, they are using procedural programming. And that's not true. Procedural vs OOP is an approach to writing code, not how you write it. Are you focusing on "Steps" and an ordered way of writing a program? You're likely writing procedural code. But if you're focusing on state transformations and encapsulated abstractions, you're writing OOP.

Classes are just a tool that make writing real OOP easier. They aren't a requirement or a indicator that you're writing OOP.

Just My $0.02...

## Update: OOP Database Access



So, some of you are asking what database access would look like in OOP code. The reason that I didn't include an example is that it's all abstracted away. In reality, the way that I would do that query could be:

```php
$mapper = new PersonDataMapper(new MySQLi(...));
$people = $mapper->getAll();
```

Where `$people` is an array of person objects. Note that it's a responsibility that's abstracted away. So in your business objects you'd never access the database directly. You'd use a mapper to translate back and forth from your business objects to the data store. Internally, a specific mapper will build a query, execute it, and fetch results, but that's all abstracted away. We can change the implementation detail of the database layer by simply swapping out a mapper.


The responsibility of data persistence becomes an encapsulated abstraction. And that's why it's not procedural but object oriented...