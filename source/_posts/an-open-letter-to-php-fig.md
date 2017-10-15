---
layout: post
title: An Open Letter To PHP-FIG
permalink: an-open-letter-to-php-fig
date: 2014-10-15
comments: true
categories:
tags:
- Best Practice
- Community
- Forward Compatibility
- Good Enough
- Philosophy
- PHP
- PHP-FIG
- Rant
---
Dear PHP-FIG,

Please stop trying to solve generic problems. Solve the 50% problem, not the 99% problem.

Signed,

Anthony

PS:

...
<!--more-->


Ok, so I wasn't going to leave it at that. What am I talking about, and why does it matter...???

## Solving The 100% Problem

You can never build a generic solution that can scale to everyone's needs.

Never.

It ain't going to happen.

You can try to bend any solution to fit all problems, but it's not going to work well at *everything*.

Sure, you can build solutions that work reasonably well for a very large portion of problems. But you can't build one that's completely generic. And trying to is a waste of time.

## Solving the 99% Problem

Thankfully, most people realize this. And so we don't talk about general solutions, but instead 99% solutions (those that solve 99% of the problems, leaving out the weird edge cases).

The problem comes, that building a 99% solution is hard. For simple problems, it's not terribly complicated. Take a look at the [PSR-3 Logger Interface](https://github.com/php-fig/fig-standards/blob/master/accepted/PSR-3-logger-interface.md). It does a pretty good job of solving most peoples use cases.

But there are two things to realize:

 * If you have a simpler use-case, where you only really `need` a single `log($message)` function, PSR-3 is overkill. It brings more functionality than you need. But it's not unreasonably overkill. Sure, it has more methods than you need, but it's still simple to work with.
 * Logging is a pretty well defined task, and it's quite easy to enumerate the possibilities.
The two of these facts combine to make PSR-3 a good standard. It's simple enough where the "overkill" aspect isn't bad for simple use cases. But it's also flexible enough to support most usages.

## The Problem With 99% Solutions

The problem is that most cases, the task isn't well defined, and it's not easy to enumerate the possibilities.

Trying to solve the 99% case will often lead to over-complication. The trick with any good design is balancing the over-complication with simplicity of use.

And that's where trying to solve the 99% use-case is problematic.

That balance is incredibly hard to achieve. There are very few systems out there that do it well.

Instead, most systems that try to solve the 99% case, don't solve any case *well*.

> It becomes a jack of all trades, but a master of none.

## PSR Caching

The current [Cache proposal](https://github.com/php-fig/fig-standards/blob/master/proposed/cache.md) is a great example of this.

They are trying to create a reasonably generic solution (99% solution). So they need to handle a HUGE range of needs and requirements.

So they wind up with all sorts of things. Things like cache pools, items, transactions, deferred saves, etc... An incredibly complicated interface.

If all I want to do is put something in cache, I now have to interact with a huge system.

Sure, if I want to build a really complex cache system where I save multiple items in transaction blocks, I still need to write a bunch of my own glue code to do it.

Wait, what did I just say?

It's over-complicated for the simple use, and it doesn't solve the complex use. It enables the complex use, but it doesn't solve it.

On one hand, this is fine. Because you can still use it for both usages (simple and complex).

But on the other hand, it's a huge problem. Because none of this is free. Creating cache items can have a performance impact. Interacting with a complex API will tend to have a ripple effect of increasing the complexity of user-land code.

It's not that I think the PSR Cache proposal is *bad*. It's that I think it's targeting a problem that doesn't exist.

In trying to build a generic solution, it's really not solving any of the problems well.

## Solve the 50%

Instead of trying to build a solution that scales, why not build a targeted solution? One that targets the simple case, but doesn't preclude the complex case?

If I was designing a cache interface like that, I'd do something like:

```php
namespace Psr\Cache;

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
That's it. Simple, quick, and dirty.

Now, I know what some of you are thinking. Well, you're probably thinking a bunch of things. Let me list some of those things:

 1. *But how can I set a TTL?!?!?!*
    
    Well, an implementation could set the ttl (time-to-live) on the cache adapter prior to injecting it.
    
    The complexity is pushed from the thing that uses the cache, to the thing controlling the cache. An interesting concept.
 2. *But how can I determine if an item is in the cache if it can return null?!?!?*
    
    You simply make null not a valid cache entry. Is that such a bad idea?
 3. *But I need to support transactions!!!*
    
    Then build your implementation to support them.
    
    Heck, you could do something like:
    
    ```php
    interface Transaction extends CacheAdapter {
    
        public function commit();
    
    }
    
    ```
    Then, your client code (that's doing the work) would simply set and delete cache items as it wanted to. Blissfully unaware that it's in a transaction. Then the calling code can commit it all in a single block.
 4. *But I want to invalidate cache based on tags!!!*
    
    Then build a decorator which determines tags from the cached item! Or build another interface for interacting with tagged items.
 5. *But I have more features I need to expose!!!*
    
    Then expose them! The point of an interface is that it's extensible.
    
    If you need the simple case, then just require the interface for the simple case.
    
    And you can trivially build an adapter to make it all work together.
## What's the point?

The beauty of OOP is that you can always build an adapter from a complex system to a simple interface. So standardizing on the simple system will allow for incredibly complex use cases to interact with each other, via simple and easy to understand interfaces.

The need for this lesson is even more seen with the current [HTTP Message API](https://github.com/php-fig/fig-standards/blob/master/proposed/http-message-meta.md).

It is my opinion, and my suggestion, that FIG should stop trying to solve generic solutions. They should instead try to solve very simple solutions, and make those solutions extendable.

Then, as people use them, identify the common extensions, and ratify them.

Build the standards as you go, based on implementations. Not on an academic "I think this would solve most peoples use case". All that will result in is a design-by-committee behemoth.

Instead, stick to the 50%. Solve the basic 50%, and then extend later. Anyone can create a complex solution, but it takes a real genius to create a simple one.

You should't "standardize" implementation details. You should standardize the API. Everything else is an implementation detail and can be handled downstream by the user via appropriate OOP mechanisms.

Standards should be about interfaces, not implementations. And interfaces should be simple and to the point. Really, they should follow a simple philosophy:

> As simple as possible, as complex as necessary.

