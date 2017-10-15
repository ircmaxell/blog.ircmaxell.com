---
layout: post
title: A Followup To An Open Letter To PHP-FIG
permalink: a-followup-to-open-letter-to-php-fig
date: 2014-10-17
comments: true
categories:
tags:
- Architecture
- Composition
- Design Patterns
- Good Enough
- Object Oriented Programming
- PHP
- PHP-FIG
- Rant
---
A few days ago, I wrote [An Open Letter to PHP-FIG](http://blog.ircmaxell.com/2014/10/an-open-letter-to-php-fig.html). Largely the feedback on it was positive, but not all. So I feel like I do have a few more things to say.

What follows is a collection of followups to specific points of contention raised about my post. I'm going to ignore the politics and any non-technical discussion here.

<!--more-->
## I Don't Understand The Cache Proposal!!!

One point I want to make before we dive into the tech:

My post wasn't about the cache proposal. I used it as a literary device. I used it as an example. My point was about the FIG group itself, and the standards they are creating.

The points I were making could be applied to any of the recent proposals and discussions they have been having. And they could be applied to any framework or library creator as well.

But let's talk about the cache proposal anyway. Let's show why I think the complexity is not necessary.

And while this may seem like it's a "strong item vs weak item" debate, it's not (whether get($key) should return the raw item, or an object which can return the item). It's more about using composition instead of inheritance. It's more about creating simple interfaces that we can compose together to make functionality.

## The Simple Cache System Can't Work

Let's talk about that. Let's get technical.

Let's assume the following simple interface:

```php
interface CacheAdapter {

    /**
     * Gets a cache entry
     * returning null if not in cache
     * @return null|mixed
     */
    public function get($key);

    /**
     * Sets a cache entry
     */
    public function set($key, $value);

    /**
     * Deletes a cache entry
     */
    public function delete($key);

}

```
That's it. No `hasKey()` method. No `isHit()` method. No `setTTL()` method. Nothing. Just `get()`, `set()` and `delete()`.

There are a few pieces of criticism around that. Let's look at them one by one:

## It doesn't protect against race conditions.

A race condition in this context can occur when you check to see if an item is in cache, and then fetch it at a later time. The race condition is when an item is expired between the call that checks to see if it exists, and the call to fetch it.

But wait, there's no `exists()` or `hasKey()` method. There's just a `get()` method. Meaning that a race condition is impossible. You either get the key, or you don't. It's either there, or its not. It's a single atomic operation.

Now, an astute reader will likely see a problem. In my interface, to check to see if an item is in cache, you need to load it into memory. This could waste memory! So you want an `exists()` method, to save memory overhead (to only load it when you know you need it, aka have all the cached items you need).

But with an atomic exists/get situation like in the proposed PSR, you *need* to cache it in memory anyway. That's how the item interface is designed to work. That's even how the interface says it needs to work.

So having an atomic exists saves you literally no memory. It saves you no complexity (since you need to do two operations instead of one). And it buys you nothing on implementation side.

Which is precisely why I don't have it in my version of the interface.

The use-cases for a non-atomic `exists()` method, I feel, are even rarer. And hence doesn't fit the 50% use-case definition of the design of the interface.

## Inability to distinguish between failure and a `null` response.

Yes. That is intentional. I would argue if you want to distinguish a `null` cached value from a failed lookup, either you're doing something **highly** specialized, or you're doing something **highly** wrong.

Either way, it doesn't fit the 50% use-case that I was talking about.

To the 50% case (even the 99% case), `null` is simply an uninteresting value. And if you're trying to signify "lack of a value", then you're better off using a domain-specific sentinel value anyway. Otherwise you're coupling yourself too significantly to the cache system.

## No way to handle stampede protection

Sure there is. There are plenty of ways of doing it. However, all of the ways are implementation details.

And those implementation details are specified by neither of the proposals (my simple interface, nor the existing PSR cache proposal).

To demonstrate what I mean, let's imagine that we're creating a library. Let's say that library needs to do a lot of work. Let's imagine that it's a DI container which can pre-compile its dependencies.

Using the existing proposal, we might expect something like this:

```php
class Container {
    public function __construct($name, CacheItemPoolInterface $cache) {
        $key = __CLASS__ . $name;
        $item = $cache->getItem($key);
        if ($item->isHit()) {
            $this->data = $item->get();
        } else {
            $this->data = $this->compile();
            $item->set($this->data);
        }
    }
}

```
Using my proposal, we might expect something like this:

```php
class Container {
    public function __construct($name, CacheAdapter $cache) {
        $key = __CLASS__ . $name;
        $this->data = $cache->get($key);
        if (!$this->data) {
            $this->data = $this->compile();
            $cache->set($key, $this->data);
        }
    }
}

```
Basically the same (some minor differences, but not much to talk about).

Both follow the interfaces exactly.

And neither provide stampede protection.

To add stampede protection, you'd need a dedicated interface to describe how you do it. So if you issue a lock, then issue a lock. If you use pre-computation or something else like that, then you'd need an interface to communicate that to you.

Neither interface does that for you.

So to say "the simple way doesn't handle stampede protection" is completely disingenuous.

But what if we wanted to add it. How could we do it?

Well, using composition, we could create a new interface:

```php
interface CachePregenerator {
    public function needsRegeneration($key);
    public function regenerationComplete($key);
}

```
So now, you can build a [bridge implementation](http://sourcemaking.com/design_patterns/bridge) with a pregenerator.

```php
class CachePregeneratorBridge implements CacheAdaptor, CachePregenerator {
    protected $cache;
    protected $generator;
    public function __construct(CacheAdaptor $cache, CachePregenerator $generator) {
        $this->cache = $cache;
        $this->generator = $generator;
    }
    /** proxy methods for get, etc **/
    public function set($key, $value) {
        $this->cache->set($key, $value);
        $this->generator->regenerationComplete($key);
    }
}

```
The key here is that using object composition, we are able to produce very simple interfaces. The implementation behind the interfaces can hide the complexity from the consumer.

Which is precisely what OOP is about.

Now, some of you may be thinking that creating the `CachePregenerator` interface defeats the point of a PSR cache interface. Because it's non-standard.

The point of a standard is to allow common implementations to work together. So a Symfony DI container can use a Zend cache adapter.

But if Symfony's DI container doesn't add stampede protection inside of itself (which isn't directly added by the current PSR proposal mind you), then you can't really add it from the outside.

So instead, we'd need to create a standard way of doing that.

By following a simple interface approach, you can allow the industry to determine what the next simple interface is. The `CachePregenerator` interface could be developed and used as a non-standard. Then, after enough experience, it could be ratified as a PSR standard. But it would be ratified because it has been demonstrated to be useful, not because we think it solves abstract problems...

But hang on, is there a better way? Is there a simpler way?

That method requires everything that uses cache to have some stampede protection... To know about it, and to check the appropriate interfaces...

What if we did something easier. What if we provided a new, simple interface:

```php
interface CallbackCache {
    public function get($key, callable $cb);
}

```
A single method.

Our container would be reduced to:

```php
class Container {
    public function __construct($name, CallbackCache $cache) {
        $key = __CLASS__ . $name;
        $this->data = $cache->get($key, function() {
            return $this->compile();
        });
    }
}

```
Woah!

Simple.

You call a get method, and pass it in a way to re-generate the cache item.

Our simple adapter could be trivial:

```php
class SimpleCallbackCache implements CallbackCache {
    protected $cache;
    public function __construct(CacheAdapter $cache) {
        $this->cache = $cache;
    }
    public function get($key, callable $cb) {
        $item = $this->cache->get($key);
        if ($item) {
            return $item;
        }
        $item = $cb();
        $this->cache->set($key, $item);
        return $item;
    }
}

```
Simple.

But what if we wanted stampede protection?

```php
 class StampedeCallbackCache implements CallbackCache {
    protected $cache;
    public function __construct(CacheAdapter $cache) {
        $this->cache = $cache;
    }
    public function get($key, callable $cb) {
        $item = $this->cache->get($key);
        if ($item && !$this->needsPregeneration($key)) {
            return $item;
        }
        $this->lock($key)
        $item = $cb();
        $this->cache->set($key, $item);
        $this->unlock($key);
        return $item;
    }
}

```
So we just transparently added stampede protection, from the **implementation** level. The API is identical. The consumed standard remains simple.

But notice we now have two interfaces. A `CacheAdapter`, and a `CallbackCache`.

They are completely unrelated. Yet you can use them together if you need.

And that's the point of a standard. It defines the protocol, not the implementation.

So both can live together, side by side. Different approaches, for different needs.

Awesome.

## Very Hacky Attempts To Add In Group Invalidation Methods

Again, this is a misdirection. The core proposal doesn't support this in the first place.

The current justification for it is:

> Pool/Item module is a lot more expandable. Without it, for instance, tags would require a duplication of all the set/clear functions (set, setWithTags)- with it you just add a setTags function to the Item.

Let's talk about how you could add support for group invalidation methods. Note that these methods work for both proposals. There's no difference at all between them for these techniques.

For these examples, let's assume that we're working with the DI container that we discussed earlier, but in reality, they can be substituted with many different implementations.

 * **Namespaces:**
    
    Namespaces are the simplest possible thing to implement on this sort of a system. A simple decorator can handle it for you.:
    
    ```php
    class NamespaceCache implements CacheAdapter {
        protected $cache;
        protected $nsName;
        public function __construct(CacheAdapter $cache, $nsName) {
            $this->cache = $cache;
            $this->nsName = $nsName;
        }
        public function get($key) {
            return $this->cache->get($this->nsName .  $key);
        }
        public function set($key, $value) {
            $this->cache->set($this->nsName .  $key, $value);
        }
        public function delete($key) {
            $this->cache->delete($this->nsName .  $key);
        }
    
    }
    
    new Container("name", new NamespaceCache($cache, "ns"));
    
    ```
    Simple. Perhaps too simple. Well, what happens if you're using a cache backend that supports first class namespaces? Well, your decorator turns into an adapter. It proxies to a different backend which supports methods:
    
    ```php
    class NamespaceBackendCache implements CacheAdapter {
        protected $cache;
        protected $nsName;
        public function __construct(Backend $cache, $nsName) {
            $this->cache = $cache;
            $this->nsName = $nsName;
        }
        public function get($key) {
            return $this->cache->getNS($this->nsName, $key);
        }
        public function set($key, $value) {
            $this->cache->setNS($this->nsName, $key, $value);
        }
        public function delete($key) {
            $this->cache->deleteNS($this->nsName, $key);
        }
    
    }
    
    ```
    Note  that the same public API is preserved. Meaning that, transparent to the consumer of the interface, we can implement namespacing.
    
    This is OOP. This is why we abstract things. Yay!
    
    But namespaces are easy. What about a hard method. What about Tags?
 * **Tagged Cache Invalidation**
    
    So this seems much harder. It seems you need new write methods to `setWithTags($key, $value, $tags)`.
    
    This has the same problem as with stampede protection, in that you can't add that functionality without changing the interface (or adding to it). So both solutions can't do this.
    
    Right?
    
    Well, what if we got a little bit creative? What if we actually inspected the cached `$value` when we set it?
    
    Remember, the `$value` is any type that can be serialized.
    
    So what if we create a decorator, that'll check to see if `$value` is an array, and if it is check for a `tags` member element. And if that exists, set those tags. Something like:
    
    ```php
    class TaggedCache implements CacheAdapter {
        protected $cache;
        protected $nsName;
        public function __construct(CacheAdapter $cache) {
            $this->cache = $cache;
        }
        public function get($key) {
            return $this->cache->get($key);
        }
        public function set($key, $value) {
            $this->cache->set($key, $value);
            if (is_array($value) && isset($value['tags']) && is_array($value['tags'])) {
                $this->setTagsForKey($key, $value['tags']);
            }
        }
        public function delete($key) {
            $this->cache->delete($key);
        }
    
    }
    
    ```
    Simple and transparent. If your consuming code provides tags, it doesn't matter if you're using tagged invalidation or not. Your cache backend can ignore it.
    
    Or you can install the decorator, and progressively upgrade your code to use tags.
    
    And if you wanted to get more fancy, you could create a new interface for cache items which are tagged:
    
    ```php
    interface TaggedItem {
        public function getTags();
    }
    
    ```
    Then, your `set()` method becomes:
    
    ```php
    public function set($key, $value) {
        $this->cache->set($key, $value);
        if ($value instanceof TaggedItem) {
            $this->setTagsForKey($key, $value->getTags());
        }
    }
    
    ```
    And that's where OO composition wins. Our backend has no idea about tags. Our front-end doesn't require it to (it just passes along tags, and if they are used, great. If not, who cares). But we can choose the functionality by how we compose our objects together.
## Focusing On Composition

## Wrapping Up

I could go deeper. I could go further. But I think that would be counter productive. The reason I wanted to go this far is to demonstrate that simple solutions aren't as handicapped as they may seem.

By getting creative with OO solutions, you can build incredibly powerful, strong and (most importantly) simple abstractions. The best way to build complexity is by composing simplicity. If you start with complex, you can never get simple.

But if you start simple, you can always stop there if you don't have to go further.

