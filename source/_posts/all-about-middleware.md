---
layout: post
title: All About Middleware
permalink: all-about-middleware
date: 2016-05-20
comments: true
categories:
- Architecture
tags:
- Design Patterns
- Middleware
- Object Oriented Programming
- Open Standards
- PHP
- PHP-FIG
- Rant
---
Last week, [a proposal](https://github.com/php-fig/fig-standards/pull/755) to standardize middleware for [PSR-7](http://www.php-fig.org/psr/psr-7/) was introduced to the PHP-FIG. The general concept of middleware is not a new one, and has been in use in the PHP world for many years. Several people have raised significant concerns with the proposal, which have gone completely unheeded by the author. Let me go through the most major of these concerns, as well as show what a better proposal might look like.

\*Note: All code that will be used in this post is real-world code found in the wild (and linked to) with one exception (`X-Powered-By`).

<!--more-->
## The Current Proposal

The current proposal includes a single interface (the return-type was added by me for clarity):

```php
interface MiddlewareInterface {
    public function __invoke(
        RequestInterface $request,
        ResponseInterface $response,
        callable $next
    ): ResponseInterface;
}

```
This is not really a new idea. The [Slim Framework](http://www.slimframework.com/docs/concepts/middleware.html) uses this exact signature. And a number of frameworks/libraries use similar interfaces: [mindplay/middleman](https://github.com/mindplay-dk/middleman/blob/1.0.0/src/MiddlewareInterface.php#L24), [relay/relay](https://github.com/relayphp/Relay.Relay/blob/1.0.0/src/MiddlewareInterface.php#L24), [zendframework/zend-stratigility](https://github.com/zendframework/zend-stratigility/blob/1.0.0/src/MiddlewarePipe.php#L69-L79) among others.

It's important to note that [StackPHP](http://stackphp.com/) and [Laravel](https://laravel.com/docs/master/middleware) use a different approach. It does not pass the response in as a parameter to the middleware. In fact, many middleware implementations in the ecosystem use this approach (Including the original: Rack with Ruby on Rails). I will go more into why and what makes this approach both technically and non-technically superior towards the end of this post.

First, let's take an example of real world code that uses this approach. Let's look at the [AccessLog Middleware](https://github.com/oscarotero/psr7-middlewares/blob/master/src/Middleware/AccessLog.php). This is really straight forward and demonstrates the concept well.

```php
public function __invoke(
    ServerRequestInterface $request, 
    ResponseInterface $response, 
    callable $next
) {
    if (!self::hasAttribute($request, ClientIp::KEY)) {
        throw new RuntimeException(
            'AccessLog middleware needs ClientIp executed before'
        );
    }
    $response = $next($request, $response);
    $message = 
        $this->combined ? 
          self::combinedFormat($request, $response) 
        : self::commonFormat($request, $response);
    if (
           $response->getStatusCode() >= 400 
        && $response->getStatusCode() < 600
    ) {
        $this->logger->error($message);
    } else {
        $this->logger->info($message);
    }
    return $response;
}

```
Note here that there are really two things that this middleware is doing. First, it validates that the request is valid, meaning that it has the additional ClientIP address added by a prior middleware. The second step is that it generates a log message and then decides how to execute the log based on the status code of the response.

Note here how the `$next()` handler is called in the middle of the method. Behavior that needs to change based on the request should happen before the call. Behavior that changes based on the response needs to happen after this call. Overall, it should be simple.

Let's take another simple example to really demonstrate this concept. Let's build a middleware that adds an `X-Powered-By` header to the response:

```php
public function __invoke(
    ServerRequestInterface $request, 
    ResponseInterface $response, 
    callable $next
) {
    $response = $response->withHeader('X-Powered-By', 'This Blog');
    return $next($request, $response);
}

```
That's one approach (known forth as "Pre-Modifying"). Another approach (known forth as "Post-Modifying"):

```php
public function __invoke(
    ServerRequestInterface $request, 
    ResponseInterface $response, 
    callable $next
) {
    $response = $next($request, $response);
    return $response->withHeader('X-Powered-By', 'This Blog');
}

```
Note that there's an important distinction between them. The first modifies the response, and then passes the response to further middleware. The second executes the inner middleware and then modifies the returned response.

## The Fundamental Problem

The fundamental problem with this interface is that it passes a response in to the middleware, rather than letting the inner middleware define the response. On the surface this may not seem like a big deal, because through discipline you can avoid the pitfalls associated with such an approach. However, it really is a fundamental problem that is better solved with a different interface.

The root of the problem is this:

> What does `$response` mean inside of the middleware?

The proponents of this style interface have said many times that it is an "instance that middleware should modify should they need to generate a response".

The problem is that the actual meaning of the instance passed in **depends on what outer middleware (middleware that was called before it) decided the meaning should be**. This means that no middleware can actually trust what `$response` means.

Let me give an example of why this is an actual problem. And let me show you actual code. Here is a cut-down version of the [Cache Middleware](https://github.com/oscarotero/psr7-middlewares/blob/master/src/Middleware/Cache.php) which basically adds cache control headers:

```php
public function __invoke(
    RequestInterface $request, 
    ResponseInterface $response, 
    callable $next
) {
    $key = $this->getCacheKey($request);
    $item = $this->cache->getItem($key);
    //If it's cached
    if ($item->isHit()) {
        $headers = $item->get();
        foreach ($headers as $name => $header) {
            $response = $response->withHeader($name, $header);
        }
        if ($this->cacheUtil->isNotModified($request, $response)) {
            return $response->withStatus(304);
        }
        $this->cache->deleteItem($key);
    }

    $response = $next($request, $response);

    //Add cache-control header
    if (
        $this->cacheControl 
        && !$response->hasHeader('Cache-Control')
    ) {
        $response = $this->cacheUtil->withCacheControl(
            $response, 
            $this->cacheControl
        );
    }

    //Add Last-Modified header
    if (!$response->hasHeader('Last-Modified')) {
        $response = $this->cacheUtil->withLastModified(
            $response, 
            time()
        );
    }

    //Save in the cache
    if ($this->cacheUtil->isCacheable($response)) {
        $item->set($response->getHeaders());
        $item->expiresAfter(
            $this->cacheUtil->getLifetime($response)
        );
        $this->cache->save($item);
    }
    return $response;
}

```
Now, let's walk through what this function is doing. First, it looks up the item in cache. If it finds the item in the cache, it gets the headers and sets all of the cached headers on the response. Then it looks to see if the cache is still valid (the item isn't modified). If and only if the item isn't modified is the 304 response returned to the client.

But if the item was modified, things change. The next middleware is called. **NOTE:** the cached headers still exist on `$response`. This includes the old `Cache-Control` and `Last-Modified` headers. Which means that if an inner middleware returns an error, the `$response` is no longer a prototype, but instead has cache headers attached to it. **Which means this will cause any HTTP errors generated to have cache-control headers attached**. Which is normally not a good thing...

The solution here would be to not re-use the `$response` when adding the headers, and hence avoid the problem all together.

But that's not really the cause of the error. There are plenty of middleware that write to the `$response` **before** calling the inner middleware. Some set headers. Some set bodies. Some modify status codes.

**What this means is that by definition you cannot trust the meaning of `$response`.**

Now, you could make the argument that this is just bad code, and that it's not a fundamental flaw of the proposal. And indeed, good code will not have these issues. The reason good code won't have these issues, is because good code won't modify `$response` before it's returned from an inner middleware. An outer middleware cannot possibly know anything about the response prior to it being handled. So why would it modify the response before looking at it?

If best practice is to only modify the `$response` *after* calling `$next()`, then why bother passing it in at all?

### Dependency Inversion

An argument that's being made to pass in the `$response` as a parameter is that it acts as a form of [Dependency Inversion](https://en.wikipedia.org/wiki/Dependency_inversion_principle). On the surface, this is legitimate. It allows middleware that wants to return a response directly (rather than modifying one created further down the pipe) to not have to depend on a concrete implementation of PSR-7.

This prevents a potential explosion of PSR-7 implementations inside of an application, where 5 middleware each bring in a different PSR-7 implementation.

This is a false tradeoff.

There are several reasons this is a false tradeoff. First, passing the `$response` as a parameter is not the only (or easiest) way of solving this dependency inversion problem. The easiest, would be to not solve it and let individual middleware authors use normal DI techniques to solve it (using a constructor parameter for the prototype, using a `use()` clause in a closure, etc).

Another solution would be to pass a factory to create responses into the middleware.

The reasons both of these solutions are **far** preferable to passing a `$response` parameter is that both of the other solutions impart context onto the injected instance. The context being that it is an empty prototype, not a pre-filled partially-completed response.

### Adaptability

One of the arguments that's being used to justify the `$response` being included as a parameter is that it's easy to adapt from the parameter to another style. For example:

```php
class Adapter implements MiddlewareInterface {
    private $otherMiddleware
    public function __construct($other) {
        $this->otherMiddleware = $other;
    }
    public function __invoke(
        ServerRequestInterface $request, 
        ResponseInterface $response, 
        callable $next
    ) {
        return $this->other->handle(
            $request, 
            function($request) use ($next, $response) {
                return $next($request, $response);
            }
        );
    }

```
This seems simple and straight forward. And the flexibility this buys is huge, right? It allows for both "formats" to be solved.

Except it's not.

By definition, any modification to `$response` (and actually the default response itself) will be thrown away. The reason is that the other middleware will create its own separate response and return it since it doesn't have access to the outer `$response`.

So this breaks the contract that has been provided by passing the response as a parameter in the first place. Which is going to be an interoperability nightmare.

### The Extent Of The Problem

Can you use the `$response` parameter method effectively? Absolutely. Hands down. Can you use it wrongly? Absolutely, 100%. The design actively encourages poor usage by providing a response to modify. Many tutorials show that you should end the middleware with a call to `return $next($request, $response);`. Further complicating the problem when the author wants to modify the response. It becomes incredibly confusing. What happens if an inner middleware resets the response to a new instance (or clears it)???

It's like comparing a straight razor with a safety razor. When used perfectly, both give almost identical results. But when you make a tiny mistake with a safety razor, you don't end up in the hospital (or worse).

Don't take my word for it. Redditer [/u/renang](https://www.reddit.com/user/renang) complied [a list of middleware](https://www.reddit.com/r/PHP/comments/4jsk4m/phpfig_starts_entrance_vote_for_http_middleware/d3bgsr3) that modifies `$response` prior to calling `$next()`.  The interesting point, is that the majority of these actually have significant bugs and inconcistencies due to this effect:

 * [ResourceHandler](https://github.com/bearsunday/BEAR.Middleware/blob/51a93093a0164e1f0c326b12fdc8b69b59e2a251/src/Handler/ResourceHandler.php#L58) - Calls `$next` **after** building the full response, meaning that a later middleware (further in) can completely overwrite the response.
 * [RateLimit](https://github.com/Lansoweb/LosRateLimit/blob/a8308ae1133be5615d3413d9d60040394366ad9f/src/RateLimit.php#L145) - Calls `$next` **after** adding all of the metering headers, meaning that a later middleware can remove all of the headers rendering the middleware completely ineffective.
 * [AuraRouter](https://github.com/oscarotero/psr7-middlewares/blob/f9822abd19674b0ff9d5b4e99a68ecdfac389b8a/src/Middleware/AuraRouter.php#L82) - Again, calls `$next` **after** building the full response from the application.
 * [Cache](https://github.com/oscarotero/psr7-middlewares/blob/f9822abd19674b0ff9d5b4e99a68ecdfac389b8a/src/Middleware/Cache.php#L89) - Calls `$next` when a cache item is modified after modifying the response with all cached headers. This means that cache control headers will erroneously propagate to all responses that re-use the passed in response.
 * [FormatNegotiator](https://github.com/oscarotero/psr7-middlewares/blob/ae6f8efbe2bf6528f2b7daaec86963f8bc32eecb/src/Middleware/FormatNegotiator.php#L142) - Calls `$next` after adding the `Content-Type` header to the response. Meaning that error conditions or other responses may have an erroneous content type added.
 * [HTTPS](https://github.com/oscarotero/psr7-middlewares/blob/65e059ab88ea23c881846d78f847aa533cb05bfa/src/Middleware/Https.php#L91) - Calls `$next` after setting HSTS headers, meaning that if later middleware write over the response or reset it, the header will be lost.
 * [LanguageNegotiator](https://github.com/oscarotero/psr7-middlewares/blob/f9822abd19674b0ff9d5b4e99a68ecdfac389b8a/src/Middleware/LanguageNegotiator.php#L117) - Again, calls `$next` after setting headers, allowing later middlewre to overwrite or reset the response. And may write the header in a response that is actually incorrect.
 * [LeagueRoute](https://github.com/oscarotero/psr7-middlewares/blob/3175934bffecc4edc747b79a19519c3e60500204/src/Middleware/LeagueRoute.php#L37) - Same thing, sets a full response, and then calls later middleware which may alter or remove large parts of the response.
 * [ReadResponse](https://github.com/oscarotero/psr7-middlewares/blob/f2ff9003fbe29b35a12e288b2310c70c606b0985/src/Middleware/ReadResponse.php#L77) - This is the worst, because it sets not only the body but content encoding headers as well. If an error is set by a later middleware, you could wind up with a completely incorrect response.
Now, this was only a sample of available middleware. But it's telling that all but one of the middleware listed actually contains a bug or design flaw that makes it not robust. It's also important to note that if `$response` wasn't passed in to the middleware, none of these issues would exist.

It's not that this middleware proposal can't work. It's that it's **REALLY** easy to screw up. And that makes it a bad design from the ground up.

## Other Issues With The Proposal

There are several other issues with the proposal that really boil down to more "academic" or "style" points, but are worth mentioning:

### The Usage Of __invoke

The usage of `__invoke` rather than a named method presents an interesting problem. It was chosen because it allows for compatibility with anonymous functions, and hence backwards compatibility with a lot of pre-existing middleware. However, this also prevents any implementing middleware from using `__invoke` for other means.

But further, it also prevents distinguishing between client and server middleware. Since both use the same root interface, it forces the distinction to happen at runtime inside of the implementation. This is mentioned explicitly in the proposal by saying the middleware should throw an `InvalidArgumentException` if the wrong type is passed.

Using a named method would allow this distinction to occur at an interface level. We could define two interfaces, one for `Client` and one for `Server`, and push that error checking up a level.

### The Restriction On Typing

The current proposal defines the following:

> Middleware consumers (e.g. frameworks and middleware stacks) MUST type-hint any method accepting middleware components as arguments formally as `callable`, and informally as `Psr\Http\Middleware\MiddlewareInterface`, e.g. using php-doc tags:

```php
/**
 * @param MiddlewareInterface $middleware
 */
public function push(callable $middleware)
{
   // ...
}

```
This means that by definition no application that implements the proposed middleware is allowed to use the middleware as type information. Which means that static analysis will not work, autocompletion will not work, and you will not get any help from the engine (or your IDE) with type checking.

### Next Being Callable

The fact that `$next` parameter is simply a callable also suffers from the same problem as above. It means that there's no longer any enforcement or ability to auto-complete or check types.

Instead, `$next` should be a formal interface which would allow for type validation.

## A Better Proposal

All of the above issues can be rectified extremely simply by using a few simple patterns. The first, is to rename the method. `handle()` sounds good, so let's start there:

```php
interface Middleware {
    public function handle(
        RequestInterface $request,
        ResponseInterface $response,
        callable $next
    ): ResponseInterface;
}

```
Next, let's remove the response as a parameter which will solve the fundamental problem with the proposal that I detailed above:

```php
interface Middleware {
    public function handle(
        RequestInterface $request,
        callable $next
    ): ResponseInterface;
}

```
Next, let's change the `$next` from callable to be a formal interface:

```php
interface Middleware {
    public function handle(
        RequestInterface $request,
        Frame $frame
    ): ResponseInterface;
}
interface Frame {
    public function next(
        RequestInterface $request
    ): ResponseInterface;
}

```
This is all we need to do. It's really simple. Let's take our `X-Powered-By` example from above, and see how it looks here:

```php
public function handle(
    RequestInterface $request,
    Frame $frame
): ResponseInterface {
    $response = $frame->next($request);
    return $response->withHeader('X-Powered-By', 'This Blog');
}

```
Basically the same as before, but without the ability to screw up the response.

### But What About Dependency Inversion???

Let's say we wanted to return a 404 from a middleware? What would we do in this case? We have three options:

 1. Take it as a constructor parameter:
    
    ```php
    class MyMiddleware implements Middleware {
        private $response;
        public function __construct(ResponseInterface $response) {
            $this->response = $response;
        }
        public function handle(
            RequestInterface $request,
            Frame $frame
        ): ResponseInterface {
            return $this->response->withStatusCode(404);
        }
    }
    
    ```
 2. Bind to a specific instance of PSR-7
    
    ```php
    class MyMiddleware implements Middleware {
        private $response;
        public function __construct(ResponseInterface $response) {
            $this->response = $response;
        }
        public function handle(
            RequestInterface $request,
            Frame $frame
        ): ResponseInterface {
            return new Guzzle\Psr7\Response(404);
        }
    }
    
    ```
 3. Modify our original `$frame` to include a factory.
    
    ```php
    class MyMiddleware implements Middleware {
        private $response;
        public function __construct(ResponseInterface $response) {
            $this->response = $response;
        }
        public function handle(
            RequestInterface $request,
            Frame $frame
        ): ResponseInterface {
            return $frame->factory()->createResponse(404);
        }
    }
    
    ```
All three solve the "DI" problem. The first is the most flexible for authors. The second is the most flexible for framework authors. The third is a good mix between the two.

So our final interfaces become:

```php
interface Middleware {
    public function handle(
        RequestInterface $request,
        Frame $frame
    ): ResponseInterface;
}
interface Frame {
    public function next(
        RequestInterface $request
    ): ResponseInterface;
    public function factory(): Factory;
}
interface Factory {
    public function createRequest(
        /* snip */
    ): RequestInterface;

    public function createServerRequest(
        /* snip */
    ): ServerRequestInterface;

    public function createResponse(
        /* snip */
    ): ResponseInterface;

    public function createStream(
        /* snip */
    ): StreamInterface;

    public function createUri(
        /* snip */
    ): UriInterface;

    public function createUploadedFile(
        /* snip */
    ): UploadedFileInterface;
}

```
Easy And Simple

### But What About Closures???

One of the arguments used for the proposed syntax is that it's simple to add new middleware with closures rather than requiring objects for everything.

In reality, this could be trivially solved by creating an adapter:

```php
class CallableServerMiddleware implements ServerMiddlewareInterface 

{
    private $callback;

    public function __construct(callable $callback) {
        $this->callback = $callback;
    }

    public function handle(
        ServerRequestInterface $request, 
        ServerFrameInterface $frame
    ): ResponseInterface {
        return ($this->callback)($request, $frame);
    }
}

```
Now, it's worth noting that frameworks can optionally allow callables to be registered directly by using this adapter:

```php
public function append($middleware) {
    if (!$middleware instanceof ServerMiddlewareInterface) {
        $middleware = new CallableServerMiddleware($middleware);
    }
    //append here
}

```
Really simple. And since it's unrelated to dispatching, it's out of context for the proposal.

### But What About Backwards Compatibility?

Another frequently cited justification for the proposed interface is that it's backwards compatibility with a set of middleware that already exists for `PSR-7`.

My assertion here is that the correctness gains that we can have by formalizing the interface *far* outweigh any compatibility issues. This is especially true when you consider that the current interface has such serious flaws.

Should we standardize something broken because it's used, or should we standardize something robust? Especially when many of the existing usages are broken and incorrect already.

## Try It Out For Yourself

I have released a proof-of-concept package called [Tari](https://github.com/ircmaxell/Tari-PHP) on these APIs so that you can try them yourself. The names are a little bit different (`ServerMiddlewareInterface`, `ServerFrameInterface` and `FactoryInterface`), but the concept is identical.

This is a far more robust middleware interface set that solves a lot of very significant problems with existing middleware. Note that this isn't new either, it's basically identical to [StackPHP](http://stackphp.com/), [Laravel Middleware](https://laravel.com/docs/master/middleware), [Ruby-On-Rails' Rack](http://guides.rubyonrails.org/rails_on_rack.html) and many others.

I strongly encourage PHP-FIG to recognize the problems with the existing proposal and move to a more robust interface design. One that encourages and can support arbitrary interoperability, not just "works if you get lucky".




