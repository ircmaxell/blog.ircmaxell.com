---
layout: post
title: Handling Plugins In PHP
permalink: handling-plugins-in-php
date: 2012-03-09
comments: true
categories:
tags:
- Design Patterns
- Events
- Library
- PHP
- Programming
---

A common problem that developers face when building applications is how to allow the application to be "plug-able" at runtime.  Meaning, to allow non-core code to modify the way an application is processed at runtime.  There are a lot of different ways that this can be done, and lots of examples of it in real life.  Over a year ago, I wrote a [StackOverflow Answer](http://stackoverflow.com/a/4471363/338665) on this topic.  However, I think it deserves another look.  So let's look at some patterns and common implementations.
<!--more-->
## Communication Handlers


These patterns are designed to handle communication between disjoint objects.

### Observer Pattern

<span style="text-align: justify;">One of the most frequently cited patterns for events is the </span>[Observer Pattern](http://sourcemaking.com/design_patterns/observer)<span style="text-align: justify;">.  The odd thing, is that it's also one of the least frequently used patterns.  The main use-case for the observer is when you want to add the ability for multiple objects to be notified of changes to a single object.  This seems quite useful, until you realize that this means that every object which you want to trigger an event must be bound to separately.  Let's take a look at an analogy:</span>

> Let's say that you're building an alarm system for a home.  That alarm system would likely have several different types of sensors to determine if something bad happened (motion sensors, door switches, window switches, etc).  The alarm system doesn't care what happened, it just wants to know if something changes.  So it listens to each sensor for a change.  If it gets notified of the change, it will go into alarm mode.




So a quick simple example would be:```php
class Subject implements SplSubject{
    protected $observers = array();
    public function attach(SplObserver $observer) {
        $this->observers[] = $observer;
    }
    public function detach(SplObserver $observer) {
        $key = array_search($observer, $this->observers) {
        if ($key) {
            unset($this->observers[$key]);
        }
    }
    public function notify() {
        foreach ($this->observers as $observer) {
            $observer->update($this);
        }
    }
}

class MyObserver implements SplObserver {
    public function update(SplSubject $subject) {
        echo "I was updated by " . get_class($subject);
    }
}

$subject = new Subject;
$subject->attach(new MyObserver);
$subject->notify(); // prints "I was updated by Subject"

```

Now, one key point to note here, is that every listener would need to bind to the object `instance `that it wants to track.  Another key point is that the Subject does not pass along any information about the cause of the update.


This makes the Observer Pattern extremely useful for situations where you want to bind the state of one part of the application to the state of another.  A key example of this is in a stateful MVC pattern, you can bind a view instance to observe a model instance.  That way, when a controller makes changes to that model instance, it will notify all the views that are listening that it changed and they need to re-render themselves.


However, it should also be noted that the Observer Pattern creates a moderate coupling between the two classes involved (the subject and the observer) as they need to directly call methods on each other.

### Mediator Pattern


The other communication pattern is the [Mediator Pattern](http://sourcemaking.com/design_patterns/mediator).  This one is far easier to understand, and far more useful in real world applications.  Basically, it allows for a central object instance to control the flow of messages in an application.  Let's take a look at an analogy:
> Continuing our alarm example, let's say that we now want our alarm system to send a message to either the police or fire department when an alarm is triggered.  We could have each alarm directly call the police, but then we'd need to configure (and re-configure) each alarm whenever a detail changed.  Instead, we would have the alarm call us (the mediator), and tell us the problem.  Then, we can dispatch the problem to the correct resource based on our configuration.


A quick example:
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

There are two important traits that make it a mediator.  The first important one is that the mediator is a separate object from either the source of the event, or the notification object.  It stands in the middle of them, controlling the information flow.  For that reason, Javascript events are not using the Mediator Pattern.  The second important trait is that the mediator is not just a relay (telling everyone about everything), but it makes decisions about who to route events to.


In the example, the event name was used as the decision on who gets the request.  But it could be different.  For example, you could build a mediator that inspects the data passed to the trigger to determine which events should be called.  So you could have a mediator in an inventory system send notifications to a receiver only when the data matches certain conditions (quantity is less than 10, for example).  So then the mediator would be told about all quantity changes, and only update our "low inventory alarm" if the quantity is too low.


The point is that the complexity of the message routing is both centralized and decoupled from the business objects.  That allows for the business objects to know almost nothing about each other.

## Functional Handlers


These patterns are designed to alter functionality of one object at run-time.

### Strategy Pattern


The [Strategy Pattern](http://sourcemaking.com/design_patterns/strategy) is used to provide different implementations that depend on a common interface.  This is really simply normal polymorphism disguised by a pattern.  Let's look at an analogy:
> Let's say that I want to support multiple types of connections to our mediator for our alarm system.  I could hard-code in a bunch of choices, or I could just provide a phone jack on the alarm.  Then, you could plug in a phone-line, a cell phone or a VOIP phone, and let the installation determine how it should function.


If you use Dependency Injection, then a strategy pattern would flow right from that, in that to switch the strategy for an object, you just pass in a different dependency:
```php
interface CallHomeStrategy {
    public function sendMessage($message);
}
class AlarmSystem {
    public function __construct(CallHomeStrategy $strategy) {
    }
}
class PhoneCall implements CallHomeStrategy {
    public function sendMessage($message) {
        $this->dialPhone();
        $this->readMessageAloud();
        $this->hangup();
    }
}
class InternetCall implements CallHomeStrategy {
    public function sendMessage($message) {
        $this->openConnection();
        $this->sendPackets($message);
        $this->closeConnection();
    }
}
$strategy = 'InternetCall';
$alarm = new AlarmSystem(new $strategy);

```

That's all there really is to it.  By separating the implementation from the dependency, we can control how the dependency is handled and inject our own functionality instead.

### Decorator Pattern


The [Decorator Pattern](http://sourcemaking.com/design_patterns) is used to add (or change) functionality on an existing object without needing to change its class (as Strategy would).  The decorator really just "wraps" the original object to add its functionality.  Let's look at an analogy:
> Now, we want to add a set of instructions to the front of our alarm panel.  So instead of re-making the entire panel, or having a different manufactured panel per language we want to provide instructions for, we can "decorate" the panel by placing a sticker on it.  This allows us to keep the same underlying structure, but add the things we need onto it later.


An example:
```php
class BlogPost {
    public function getTitle() {}
    public function getBody() {}
    public function displayAsHtml() {}
}
class RSSDecorator {
    protected $post;
    public function __construct(BlogPost $post) {
        $this->post = $post;
    }
    public function __call($method, $args) {
        return call_user_func_array(array($this->post, $method), $args);
    }
    public function displayAsRSS() {}
}
$post = new BlogPost;
$post->displayAsRss(); // Fatal Error, method doesn't exist
$post = new RssDecorator($post);
$post->displayAsRss(); // renderd post in RSS

```

There's one big caviat to decorators (in PHP especially).  The decorator by default does not inherit the interface or class from its wrapped object.  So if you want to decorate an object, which will then be used in a type-hinted method call, the decorator needs to manually implement those interfaces.  That yields this kind of code:

```php
interface Post {
    public function getTitle();
    public function getBody();
}
class BlogPost implements Post {
    public function getTitle() {}
    public function getBody() {}
    public function displayAsHtml() {}
}
class RSSDecorator implements Post{
    protected $post;
    public function __construct(BlogPost $post) {
        $this->post = $post;
    }
    public function __call($method, $args) {
        return call_user_func_array(array($this->post, $method), $args);
    }
    public function getTitle() {
        return $this->post->getTitle();
    }
    public function getBody() {
        return $this->post->getBody();
    }
    public function displayAsRSS() {}
}

```

As you can see, this can get quite dirty quite quickly if you have a lot of interface methods.  This can lead to a lot of duplication across multiple decorators.  But it also allows us to dynamically add functionality to all sorts of classes with a single decorator (imagine if we changed the hint in `RSSDecorator::__construct` to `Post`)...

### Chain of Responsibility


The [Chain of Responsibility](http://sourcemaking.com/design_patterns/chain_of_responsibility) pattern is used to provide a "list" of possible handlers to a method, and then calling them one-by-one to see if it can handle the functionality.  Let's talk about an analogy:
> Now, let's say that we want to have our alarm go off in multiple steps.  The first step would be to sound a "warning" chirp for 10 seconds.  If the alarm wasn't disarmed, then sound a fast "warning" chirp for another 10 seconds.  If the alarm still wasn't disarmed, then trigger the main alarm and call the mediator.  This can be handled by having a list of steps that happen one after another.  Then, it's up to each step to either cancel the processing (the alarm was disarmed), pass it off to the next handler (sound the next warning after 10 seconds) or handle it itself (the main alarm).


The example is pretty easy:
```php
class Chain {
    protected $chain = array();
    protected $key = 0;
    public function append($callback) {
        $this->chain[] = $callback;
    }
    public function prepend($callback) {
        array_unshift($this->chain, $callback);
    }
    public function reset() {
        $this->key = 0;
        return $this;
    }
    public function handle($params) {
        if (isset($this->chain[$this->key])) {
            $callback = $this->chain[$this->key];
            return $callback($this, $params);
        }
        throw new OutOfBoundsException("Cannot handle chain request, falled off");
    }
    public function next() {
        $this->key++;
        return $this;
    }
}
$chain = new Chain;
$chain->append(function($chain, $params) {
    if ($params == 1) { 
        return "1!";
    } else {
        return $chain->next()->handle($params);
    }
});
$chain->append(function($chain, $params) {
    if ($params == 2) { 
        return "2!";
    } else {
        return $chain->next()->handle($params);
    }
});
$chain->append(function($chain, $params) {
    if ($params == 3) { 
        return "3!";
    } else {
        return $chain->next()->handle($params);
    }
});
$chain->append(function($chain, $params) {
    if ($params == 4) { 
        return $chain->reset()->handle(1);
    } else {
        return $chain->next()->handle($params);
    }
});
echo $chain->handle(1); // "1"
echo $chain->handle(3); // "3"
echo $chain->handle(4); // "1"
echo $chain->handle(5); // OutOfBoundsException

```

The key here is that the chain is dynamically built, and handles the functionality dynamically.  The clearest use for this is in HTTP request routing.  The router can maintain a list of "handlers".  When it comes time to route the request, the router starts the chain, passing the request to the first element.  Then, handlers can pass the request along (if it doesn't know how to handle it), handle the request or even rewrite the request and restart the chain.


It's important to realize that the chain can fall off the end, and that must be handled.  In the router example, the easiest way to prevent this, is to add a default route to the end that throws a 404 error.  That way, the chain will never fall off the end.

## Real World Implementations


So patterns are good and all, but real world implementations are better.  Let's take a peak at some real-world implementations of these patterns.

### Observer Pattern


Honestly, I've looked around for real-life implementations of this pattern.  While I found a few have Observer classes (Such as [Joomla](https://github.com/joomla/joomla-platform/blob/staging/libraries/joomla/base/observable.php)), I couldn't find any that actually used them in the application...  I did even find a package that claimed to be an Observer, but was really a Mediator: [Symfony](https://github.com/symfony/EventDispatcher).

### Mediator Pattern


On the other hand, the Mediator Pattern is very ubiquitous.  It's the most used pattern that I could find.  Here's a very small list of examples:

 * [Joomla Plugins](https://github.com/joomla/joomla-platform/blob/staging/libraries/joomla/event/dispatcher.php)
 * [Symfony2's EventDispatcher](https://github.com/symfony/EventDispatcher)
 * [Zend Plugins](http://framework.zend.com/manual/en/zend.controller.plugins.html)
 * [Drupal Hooks](http://api.drupal.org/api/drupal/includes%21module.inc/group/hooks/7) (Yes, that uses functions.  Which goes to show that an OOP pattern does not need classes to be used - although the project as a whole has been moving more towards OOP).

### Strategy Pattern


This is used quite often as well. Here's another small list. * [Doctrine2's Database Drivers](https://github.com/doctrine/dbal/blob/master/lib/Doctrine/DBAL/Driver.php)
 * [CryptLib's Random Mixer Classes](https://github.com/ircmaxell/PHP-CryptLib/tree/master/lib/CryptLib/Random)
 * [PHP's SessionHandlerInterface](http://www.php.net/manual/en/class.sessionhandlerinterface.php) 

### Decorator Pattern


This one is a little harder to find in production code, due to the large amount of boilerplate code required.  Here's one very good example that I found * [Zend_Form Decorators](https://github.com/zendframework/zf2/tree/master/library/Zend/Form/Decorator)

### Chain of Responsibility Pattern


This one is also a little harder to find. * [Lithium's Filter's Class](https://github.com/UnionOfRAD/lithium/blob/master/util/collection/Filters.php) - Used to power almost all of the core.
 * [Symfony2's Authentication Provider](https://github.com/symfony/symfony/tree/master/src/Symfony/Component/Security/Core/Authentication/Provider)

## But That's Not The Whole Story


These patterns are not the only way to handle event handling.  They are just a series of basic tools that can be used to provide a really flexible and plugable system.  The key is to understand the basic patters - and their limitations - so that you can make the appropriate choice when you need to.