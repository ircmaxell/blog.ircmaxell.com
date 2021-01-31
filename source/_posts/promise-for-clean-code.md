---
layout: post
title: Promise for Clean Code
permalink: 2013/01/promise-for-clean-code.html
date: 2013-01-18
comments: true
categories:
- Programming
tags:
- Dependency Injection
- Design Patterns
- Events
- Javascript
- PHP
- Programming
- Promise
---

I first came across the concept of a [Promise](http://en.wikipedia.org/wiki/Futures_and_promises) about 3 years ago. At the time I was working with jQuery and was rather put off by the concept. It wasn't that it wasn't useful, I just didn't understand it. Then, about a year ago the concept finally "clicked"... I refactored some existing applications and the reduction in code and simplicity of it all was breathtaking. But I never really appreciated the true power until I used them in PHP...
<!--more-->

## What Is A Promise?


A promise is basically a way to handle callbacks (similar to continuation passing) that can resolve in the future. So if your function returns a promise, it'll resolve the promise when it can. But that doesn't really explain why using a promise is so nice. From here out, I'm going to use the [jQuery promise object](http://api.jquery.com/category/deferred-object/) (and its parent, the deferred object). So to understand what a promise really gives us, let's look at an example using jQuery's `getScript()` function (this function is used for asynchronously loading JS dependencies). So let's say we want to load a dependency, and only use it after the dom is loaded (since the dependency can resolve before domready). Using continuation passing syntax, we could do:

```javascript
jQuery.getScript("/js/foo.js", function() {
    jQuery(document).ready(function() {
        foo.run(something);
    });
});

```

That isn't so bad. It's pretty clear what's happening. But what happens if we want to load TWO dependencies and execute on ready?

```javascript
jQuery.getScript("/js/foo.js", function() {
    jQuery.getScript("/js/bar.js", function() {
        jQuery(document).ready(function() {
            foo.run(bar.run());
        });
    });
});

```

As you can see, it gets out of hand pretty quickly. But there's another problem with this new code. It will load `foo.js` asynchronously, but it will wait until it is loaded before loading `bar.js`! While this may be what you want, it's not ideal... But `getScript()` also returns a promise. So let's see how we can refactor the continuation passing into using promises...

```javascript
jQuery.getScript("/js/foo.js").then(function() {
    return jQuery.getScript("/js/bar.js")
}).then(function() {
    jQuery(document).ready(function() {
        foo.run(bar.run());
    });
});

```

That's a bit better in terms of readability and scalability. But we can do one better. There's a jQuery function `when()` that takes multiple promises and returns a new one that will resolve when all of its arguments are resolved. So that lets us simplify the code above to:

```javascript
jQuery.when(
    jQuery.getScript("/js/foo.js"),
    jQuery.getScript("/js/bar.js"),
    jQuery.ready.promise()
).then(function() {
    foo.run(bar.run());
});

```

Now that's what I'm talking about! Really simple code. Both `getScript()` calls are executed in parallel, and there's no dirty stacking of callbacks.
## So, How Does A Promise Work?


Well, promises come in two main parts. A Deferred object, and a Promise object. The promise object needs to have a single function: `then()`:

```javascript
promise.then = function(success, failure, notify) {}

```

That single function also needs to return a `new` promise. That promise is resolved with the return value from the called function. This lets you chain promises together.
The Deferred object is what lets you resolve a promise. When you create a new Deferred object, you have a few methods:

```javascript
Deferred = function() {
    this.resolve = function() {};
    this.reject = function() {};
    this.notify = function() {};
    this.promise = function() {};
    return this;
}

```

Commonly, there are more methods (typically those that let you treat the Deferred object directly as a Promise), but those aren't really needed. The `resolve()` method triggers the Promise's `success` handlers. The `reject()` method triggers the Promise's `failure` handlers. And the `notify` method triggers the Promise's `notify` handlers. Finally, the `promise()` method returns a Promise object that is resolved by the current Deferred instance. Pretty straight forward so far.

The interesting thing comes in that once you resolve or reject a deferred object, it will always be resolved or rejected (and can never change). Therefore, any resulting calls to the promise's `then()` method will immediately execute the appropriate callback. This leads to some very interesting usages...

For one, a Promise object is a promise to be resolved. It's not a promise to `when` it will be resolved. That means that if your code can be resolved synchronously, it will be called immediately. But if not, it will be called as soon as the promise is resolved. That means that there's no need to write synchronizing code, locking code or anything complex. Just combine Promises to dictate when your code will fire!

## But PHP Is Synchronous!


When I was building [RequirePHP](https://github.com/ircmaxell/RequirePHP), I attempted to build it so that it could support asynchronous dependency resolving. My motivation was that if you used something like [ReactPHP](https://github.com/reactphp/react), you could use the dependency loader to actually respond to asynchronous dependencies (such as loading a remote URL resource). So I pulled in and started using their [Promise library](https://github.com/reactphp/promise) (after ditching my own implementation).

When I went to add in circular dependency checking and resolving, I realized that I didn't need to. Deferred objects took care of it for me already! By setting my export to the promise to return the dependency, if I ever got back to the root without it being resolved (with synchronous loaders), I know there must be a circular dependency somewhere in the graph! The cool part, is that this not only detects direct circular dependencies (A requires A), but also complex graph circular dependencies (A -> B -> C -> E -> A). And it knows how to resolve non-circular complex dependencies automatically (such as A requiring B and C, but B also requiring C).

That means that using a Promise in a synchronous environment let my dependency resolver be built in about [50 lines of code](https://github.com/ircmaxell/RequirePHP/blob/master/lib/RequirePHP/AMD.php#L101)! To put that in perspective, Composer's dependency resolver is about [2900 lines of code](https://github.com/composer/composer)... And the only thing it does that mine doesn't do is check and determine which version(s) to load... Ok, so that's not really a fair comparison, but it illustrates the point that dependency resolving can be a nightmare to detect errors and do without risk of infinite loops or endless recursion. But by using Promises, I accidentally built a robust and simple resolver!

What cool (and possibly unexpected) things have you used Promises for?