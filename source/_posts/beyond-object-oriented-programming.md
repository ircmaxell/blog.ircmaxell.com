---
layout: post
title: Beyond Object Oriented Programming
permalink: 2013/11/beyond-object-oriented-programming.html
date: 2013-11-11
comments: true
categories:
- Programming
tags:
- Beyond
- Functional Programming
- Language Agnostic
- Object Oriented Programming
- PHP
- Programming
---

In the last post [Beyond Inheritance](http://blog.ircmaxell.com/2013/11/beyond-inheritance.html), we talked about looking past "types" and reasoning about objects differently. The conclusion was that inheritance wasn't necessary for OOP, and often results in more problems than it solves. Well, let's go beyond that and explore more of what will come from treating objects as containers of behavior. Let's look at what this means for various kinds of classes:<!--more-->
 * `Representers` - Classes which "Represent" a concept - These are things like domain models. This roughly represents the "Type" model we talked about before. We can say that the class's behavior is to "Represent A {CONCEPT}". A more real-world example would be a user class. The class "Represents a user" to our application.
    
    These classes tend to be value objects more than anything else. Since they "represent" something, they tend to be little more than state containers.```php
    class User {
        public function isLoggedIn() {}
        public function getName() {}
        public function isAdmin() {}
    }
    
    ```
 * `Doers` - Classes which "Do" a task - These are things that are typically exposed as Services in an application. We can say that the class's behavior is to "Do A {CONCEPT}". An example would be a class which sends emails:
    
    These classes tend to be stateless services in most situations.```php
    class EmailSystem {
        public function send(Message $message) {}
    }
    
    ```
 * `Plumbers` - Classes which "Route" tasks - These are things like Controllers. They don't actually implement any functionality, nor do they really represent any functionality. Instead, they just translate and dispatch tasks (either dynamically or statically).
    
    These classes tend to be stateless as well in most situations.```php
    class FrontController {
        public function handle(Request $request) {}
    }
    
    ```
 * `Translators` - Classes which "Translate" or "Transform" one "Representer" into another form - This can mean a serializer (which turns a "Representer" into a string), or an adapter set which adapts one interface into another. It's worth noting that a "View" in web-MVC will typically be a translator of some form.
    
    These classes tend to be stateless as well in most situations.```php
    class UserView {
        public function render(User $user) {}
    }
    
    ```
 * `Makers` - Classes which "Make" other classes - This can be a factory, a builder, a container of builders, etc.
    
    These classes tend to be stateless, but depending on the circumstance may have application-specific state.```php
    class UserFactory {
        public function getUser() {}
    }
    
    ```

There definitely are other behaviors and other reasons for classes to exist, but I think this covers most classes well. I chose those names very specifically, as they aren't already loaded by other usages and mis-usages (for example, I could call "Representers" by their other term "Domain Models", but depending on your understanding of the word "Model", that may confuse the concept further). So don't get hung up on the naming, but instead focus on the effect.
## 
A Note On Statelessness


If you notice, all of the behaviors that I talked about above are stateless, with the exception of one. The only behavior that I identified as stateful is the Representer behavior (Makers `can` be stateful, but you're not going to store external state there). This is very much intentional. This is a page out of functional programming, and it's a natural step in the direction of behaviors. We'll come back to this in a bit...
## 
SOLID, Applied To Behaviors


So, we have this new model of OOP. It's really the same model as before, but it's given us a different perspective on it. Rather than looking at classes as "Types" and rather than rationalizing why a class exists, we can look at classes as "Units of Behavior" and rationalize about what behavior a class imparts on our application.

So, let's see what [SOLID](http://en.wikipedia.org/wiki/SOLID_(object-oriented_design)) really means when we talk about it from this angle:
 * **Single Responsibility Principle** - This really stays about the same as long as you translate "Responsibility" to mean "Behavior". A class should do `one` thing. A class should only impart `one` behavior on an application.
 * **Open/Closed Principle** - This principle stays basically the same. You shouldn't modify functionality, you should "extend" it.
    
    One important thing I would like to point out here, is that `extension` doesn't mean classical inheritance. It means any form of extension. So it could be classical inheritance, or it could be composition. Or it could be polymorphism. Or it could be event-based extension. Don't get caught up that "extension" and the keyword for inheritance being "extends" are similar. The concept is similar, but it's very significantly different.
 * **Liskov Substitution Principle** - This one changes quite a bit. The original principle talks about "subtypes". It really makes significant sense in the context of classical inheritance. But without inheritance, it can be difficult to understand what the intent is.
    
    Remember way back we discussed the role of interfaces providing pure specification? Well, applied to Behaviors, the interface is a "contract" or specification of a Behavior. Therefore, we can apply the LSP to interfaces and classes which implement them. And rather than talking about having "subtypes" (or children) being replaceable, any implementer of a contract should follow the same concept.
    
    Really, it opens the LSP up to apply to any class which implements a behavior (via explicit interface or not) rather than just subtypes.
 * **Interface Segregation Principle** - Since we can define "Interfaces" as contracts or specifications of a Behavior, the ISP starts to make significant sense. A contract (Interface) should specify a `single` behavior. And that single behavior should be as narrow as possible. This is basically the Single Responsibility Principle, but applied to the specification rather than the implementation.
 * **Dependency Inversion Principle** - This one stays exactly the same. We don't want our implementations (or specifications) to depend on other implementations. Instead, we always want to depend upon other specifications. That way we can swap out implementations as needed, and still maintain usable and testable code. 
    
    Really, it's the same. The perspective shifts a bit, but all in all, it's the same content.

So, what changes with this view?
## 
Going Further


When you start to think about behaviors, and start to think about your implementations (classes) as imparting behavior on your application, some very interesting things start to appear.

One of the first things that you'll notice is that behavior is composable. That means that just about any "big" behavior is reducible into a combination (or series) of smaller behaviors. This is basically just applying [Decomposition](http://en.wikipedia.org/wiki/Decomposition_method) to the abstraction instead of the problem. This shouldn't feel new. It shouldn't even be revolutionary. It's just an interesting effect.

But there is something oddly familiar about it. It feels a lot like [Function Composition](http://en.wikipedia.org/wiki/Function_composition_(computer_science)). As it turns out, Function Composition **is** Object Composition, as long as your objects represent behavior. Think about it for a second. In function composition, you can turn two generic purpose functions into a new specific purpose function. That's exactly what Behavior composition does.

I am not trying to implying that you can reason about OOP code in the same way that you can reason about Funcitonal code. I am saying it outright (at least about the subset of OOP code that we've been discussing so far).
## 
Functional OOP


What is Funcitonal programming? Well, we could go with the definition that [Haskell uses](http://www.haskell.org/haskellwiki/Functional_programming):
> Functional programming is a style of programming which models computations as the evaluation of expressions.


What does that really mean though? Well, the key is that "expressions" translate state from one form to another. They don't modify state. Therefore, "functions" are purely deterministic and idempotent (the output purely depends on the input, if you pass the same input twice, you will `always` get the same output).

We can therefore draw a line between procedural code and functional code in how we treat state. If there is global state (or state is modified), it's procedural. If there is no global state (state is not modified, but transformed), then it's functional.

Notice that in my definition of "functional" I never actually needed to talk about functions. That's because you don't need **functions** to write functional code. All you need is a composable "unit of functionality".

Wait a minute. We just talked about how classes are "composable units of behavior". What is the difference between "behavior" and "functionality"? In reality? Nothing.

Let's look at an example. Let's take some procedural code (let's assume here that the function `array_sum()` didn't exist):
```php
function sum_array_procedural(array $array) {
    $sum = 0;
    foreach ($array as $value) {
        $sum += $value;
    }
    return $sum;
}

```

In OOP, we would use polymorphism, and ask the array to sum itself (leaving the implementation details to the object):
```php
$sum = $array->sum();

```

We can write that in a more functional form as a series of "transformations". One such way may be:
```php
function sum_array_functional1(array $array) {
    if (isset($array[0])) {
        return $array[0] + sum_array_functional1(array_slice($array, 1));
    }
    return 0;
}

```

So what is it doing? Well, it's decomposing the steps of summing an array down into summing the first element, with the sum of the remaining elements. In a sense, we're composing the function with itself (recursion) to solve the problem. Also note that we're never "modifying" state. We are just "building" the solution from components.

But let me ask this: What's the difference between `sum_array_functional1` and:
```php
class SumArray {
    public function sum(array $array) {
        if (isset($array[0])) {
         return $array[0] + $this->sum(array_slice($array, 1));
        }
        return 0;
    }
}

```

It should be quite obvious that they are identical. In fact, there's nothing special going on. We've just wrapped our "functional" function in a class. What's the big deal?

Well, for a trivial example like this, there isn't much to gain. But let's take a more significant example. Let's talk about generating a HTTP response.

In procedural code, you might have code like this:
```php
function render404() {
    header('Status: 404 Not Found');
    echo "Error: 404 Not Found";
}

```

In a "traditional" object-oriented context, you might have something like this:
```php
function render404(Response $response) {
 $response->setStatus(404);
 $response->setBody('Error: 404 Not Found');
}

```

And in a functional context, you might have something like this:
```php
function render404() {
 return [404, [], "Error: 404 Not Found"];
}

```

It may not be obvious what that last did differently. First, it returned a structure where the first array element was a status code, the second was response headers, and the third is the response body. Any code calling `render404` would expect it to return the "response structure".

Fundamentally this isn't too different from the OOP solution. There are two big differences though. The first one, is that the response structure is completely controlled by the functional `render404()`. That means that **every** time we call `render404()`, we are 100% sure that the same thing will happen. With the OOP one, we can't say that, because `$response` is created elsewhere (and as such may have "hidden" state).

For example, what if before hand, we called `$response->addHeader('Content-Type: application/jpg')`? Now, our response is weird (its body is text, but its headers indicate `application/jpg`).

The second big difference is the OOP solution is "contract structured", which means that you **know** the response object is structured because of the `Response` interface type hint. The `render404()` functional implementation just returns a plain array which you can't really reason about easily (this is mainly a limitation of PHP, with weak return type hinting potential).

So, we can solve both of these problems with one tiny tweak:
## 
Make `Response` a Value-Object


The term value-object may be new to you. Basically, the entire premise is that a Value-Object is an object which is immutable after it's been instantiated. So, we can't edit the values. The only thing we can do is read. If we want to modify, we create a new instance with the change.
```php
class Response {
    private $status;
    private $body;
    private $headers = [];
    public function __construct($status, array $headers, $body) {
     $this->status = (int) $status;
     $this->headers = $headers;
     $this->body = $body;
    }
    public function getStatus() {
     return $this->status;
    }
    public function getBody() {
     return $this->body;
    }
    public function getHeaders() {
     return $this->headers;
    }
}

```

Now, if we want to change something, we'd need to create a new response object. So let's say we wanted to append a "X-Powered-By" header to the response. We could do so like this:
```php
function addPoweredBy(Response $response) {
    return new Response(
        $response->getStatus(),
        array_merge(["X-Powered-By" => "Us"], $response->getHeaders()),
        $response->getBody()
    );
}

```

Our `render404()` code would become:
```php
function render404() {
    return new Response(404, [], "Error: 404 Not Found");
}

```

Pretty cool, right?

The one significant thing to note is that nowhere in the system is the "current response" stored. It's passed where it's needed from the return of one function/method to the input of another (or even to the constructor of another value object). Once you store it, it becomes global state again, and you lose the benefits you've already gained...
## 
OOP With Value Objects IS Functional


If you only use `Value-Objects` where you have application state, then we can show that all functional code is **identical** to OOP code. The reason is pretty simple. Functional code does have state. The difference is that it never modifies state (it only creates new state, transforming the old one). 

And if you use value objects **exclusively**, the same exact thing applies to OOP.

But there's an important thing to note. What I'm talking about isn't just wrapping our functional code in classes. It's deeper than that.

As anyone who's done a fair bit of true functional code will tell you, your entire application can't be functional. Global state is a reality of life of any non-trivial program. Things like I/O alone introduce a statefulness to the application. It's for this reason that Haskell introduced [Monads](http://en.wikipedia.org/wiki/Monad_(functional_programming)). It's important to realize that Monads don't make I/O functional. They provide a way to intermix functional code with the non-functional I/O code safely.

And that's the key here. I'm not suggesting that `all` state be value objects. It would become quite tedious to write non-trivial objects if that was the case. Instead, realize that there are two main types of state in an application. There's data state (input/output, etc) and there's application state (configuration, etc). In this model, it's completely OK to use regular stateful objects for application configuration state (event subscriptions, etc). But it's not OK to use regular stateful objects to represent data. Data **must** be immutable.
## 
An Entirely New Approach


What winds up falling out here is a new approach to writing code. When you combine the abstraction and encapsulation properties of OOP, with the flexibility, test-ability and explicitness of Functional Programming, you get an extremely powerful method.

There's so much more we could explore with this approach. And I may go deeper in the future. But for now, the only remaining thing to go over at this point, is what to call this approach (to distinguish it from OOP and Functional)...? Value-Oriented-Programming?