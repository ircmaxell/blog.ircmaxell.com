---
layout: post
title: Object Scoping: A Triste Against Service Containers
permalink: object-scoping-triste-against-service
date: 2012-08-22
comments: true
categories:
- Architecture
tags:
- Anti-Pattern
- Architecture
- Best Practice
- Dependency Injection
- Framework
- Global Variables
- Object Oriented Programming
- PHP
- Rant
---

Yesterday, I got in an interesting conversation on twitter about object scopes and what constitutes a global scope. The discussion started around a [piece of code](https://github.com/fuelphp/core/blob/4fcfef0a20926bd99fca39d6bf6896d224e2bdfd/classes/Fuel/Core/DiC/DiCTrait.php) that I stumbled upon from Fuel 2.0. I am a firm believer that service containers are not a form of Dependency Injection, and are only slightly better than global variables. That led me to make a [few comments](https://twitter.com/ircmaxell/status/237957185974435840) that elicited a reply from two Fuel developers. That led to a rather interesting debate that just couldn't fit into 140 characters... So I'm going to go into topics that are tightly related: variable scoping and service locators.

<!--more-->

## What Are Global Variables?

Before we can get into the main discussion on service containers, we should talk for a minute about global variable scope. In traditional programming, there are two scopes: local and global. Local scoping is local to a function or routine, and global scoping is shared across every scope. In fact, this agrees with [Wikipedia's definition](http://en.wikipedia.org/wiki/Global_variable):> In computer programming, a global variable is a variable that is accessible in every scope. ... The global environment paradigm is contrasted with the local environment paradigm, where all variables are local with no shared memory (and therefore all interactions can be reconducted to message passing).


Instead of focusing on the definition, let's focus on the properties that global variables have over local variables: 

 * **Global Variables can potentially be modified everywhere.** - This means that code that has nothing to do with the variable directly can still modify that global state.
 * **Global Variables can be depended on from everywhere.** - This means that two units of code can be mutually dependent upon a single global variable, creating a dependency between the two units of code that otherwise would not be apparent.
 * **Global Variables can cause problems where two pieces of code use the same global identifier for different meanings.** - Basically, if two pieces of code use a global variable of the same name, but with different meaning that those two pieces of code cannot interact together safely.

It should be noted that this definition of global variables refers to "everywhere" as "everywhere in the process". But does it really need to? Where is the line? If we change "everywhere" to "potentially anywhere", does that make them suddenly not global (and suddenly not evil)? If we change "everywhere" to "a lot of places", does that draw the line? 

My position on this is simple. The everywhere clause is satisfied if the variable can be changed from an unknown (or non-deterministic) number of places. Do you need to grep the entire code-base to figure out who can change it? If so, it satisfies the "everywhere" clause in my book. So if that's satisfied, then we're left with the above three tests. Can it be modified from unknown places, can it be depended on by those unknown places and can those unknown places use the same identifier in a clashing way. If all three are yes, the variable is global. Even though it may not be in the traditional "global scope", it's still satisfies all the properties of a global.

## What Does That Mean?

So, if we take that as a definition, and look around PHP a bit, we can clearly see some things that are not technically globally scoped variables (using the `global` keyword or `$GLOBALS`) are indeed global variables. The easiest and most obvious is a static variable.

```php
abstract class Foo {
    public static $bar = 1;
}
```


That should be trivially easy to see as a global variable. But let's walk through the three tests. First, can the variable be modified everywhere? Check (`Foo::$bar = 2`). Second, can the variable be depended on from everywhere? Check (`$c = Foo::$bar`). Finally, can two pieces of code use that same identifier with the same name and different meaning? Check. The reason for the last one is a little bit more subtle than the others, so let's examine it further.

You could argue that the class name is a namespace, and hence that the variable has implicit meaning. Therefore, the chance that two independent pieces of code would use the same variable for two different meanings is zero. That would be a valid argument. But note that the requirement didn't say that two pieces of code will use them for different meanings. Just that they can use them for different meanings. Therefore, there's no difference between `Foo::$bar` and `$GLOBALS['foo_bar']` in this context. In fact, there's no different between them at all (they are functionally identical). 

By extension, any class that has static state is also global for the same reasons. Even if that static state is protected or private, and can only be accessed by validating methods, it's still global state because it can be accessed, modified and depended upon from anywhere in the application.

## Applying That To Objects

I'm going to make an assertion here first. I believe that objects only have those two scopes as well. However, I'm going to define them slightly differently. Local data is data which the class either generates itself, or is directly passed to the object as either a constructor parameter or a method parameter. Global data is anything else that the object uses, even if it was attained from an object that is a local member. You could even expand this to a three tier definition to: Local - data that the class generates, Dependency - data that's passed directly to the class and Global - everything else.

```php
class Foo {
    protected $Local;
    protected $Dependency;
    protected $Global;

    public function __construct(Bar $dep1) {
        $this->Local = 1;
        $this->Dependency = $dep1;
        $this->Global = $dep1->getBaz();
    }
}
```


That's a significant assertion. Let me try to back it up here. It should be trivial to see that what I classified as Local scope is indeed local to the object. If it generates that data, it's definitely local to the object.


Dependency scoped data is a little more tricky. The reason that I classify that under Local instead of Global is that it's easy to see where the data came from. I can find the method call that set the data, and trace it from there. I don't need to grep the entire codebase. Additionally, dependencies are more explicit. The only places in code that the dependency can be changed (or its state changed) are places that have access to both the dependency and the current class. Therefore [Spooky-Action-At-A-Distance](http://en.wikipedia.org/wiki/Action_at_a_distance_(computer_programming)) is not possible because the coupling between the objects is explicit.


The Globally scoped data requires a bit more thought to understand. Let's walk through our three global criteria. First, global variables can potentially be modified everywhere. In this case, everywhere that has access to either the dependency, or the dependency's child can modify the data's state. Furthermore, since the coupling is not explicit, if you want to look for all possible change points, you literally have to grep the code for everything that your dependency, and its child is passed to in order to see the potential modification points. Therefore, the first criteria is met.


The second criteria is that global variables can be depended on from everywhere. Remember that we modified the meaning of "everywhere" to be a non-deterministic number of places. We can easily tell which classes share a normal dependency by simply tracing the call point that injects that dependency. If it's a constructor dependency, we can simply see where-else that variable is passed (following it further up the chain if necessary). But the point is that there's a very limited and finite number of places where that dependency can be used. Contrast that with the global dependency where you not only need to track every set on your class, but also on your primary dependency's object. And anything that depends on that. And anything that depends on that. And so on. So the potential modification call graph goes from a small and predictable (at least from a debugger's point of view) set of possibilities to an unpredictable number of possibilities. Therefore, the second criteria is met.


The third criteria is actually easier to argue than it seems. Let's say that we have a method on our dependency called `getDatabaseConnection()`. We can inject that dependency into two different classes, but have those classes expect two different types of connections (one expecting a read connection and one expecting a read/write connection for example). So while the meanings may overlap today, the code that uses those second tier (global) dependencies actually are using the same variable for two different meanings. And in the long term, that may become a significant problem.


Therefore, anything that's not generated by an object, or passed directly to it is a global dependency. It's not necessarily a global variable (in the true sense of the word), but the dependency is global to the viewpoint of the class.## Service Locators


So how does this apply to service locators (aka service containers or dependency injection containers)? Well, all state that's managed by a service locator immediately becomes global state to the objects that use the locator. So why is it all the rage? It's simple. It seems simple on the surface. If your object needs another dependency, there's no need to adjust how it's constructed, just pull it from the locator. Sounds great, right? Well, not quite.

### Unit Tests

The easiest problem to see comes when unit testing your classes (you do unit test, right?). You just added a dependency to your class without changing how its constructed (or changing any of the code that constructs it). What happened to your unit tests? Are they still passing? If so, that's a huge problem... If your tests failed (because of the dependency problem), good job mocking your class!


If they are still passing, you changed behavior in your class, but without modifying your tests. Therefore, your tests aren't really testing the object's behavior, but the integration between your object and the service locator. If that's the case, you're definitely not mocking out the service locator properly, and letting the global state from the tests creep in.


The real problem here is that the "ease" of using a service locator leads to making it far to easy to create bad tests. Rather than testing your class in isolation, it's far too easy to inject the service locator into the class. And if you do that, the value of your tests is minimal at best.

### Clarity

Clarity suffers significantly with service locators. Your objects are advertising that they are dependent upon the locator only. To see what the true dependencies are, you need to look through each and every line of the class to see if it pulls an additional dependency from the locator. That means that automated API documentation will not have the dependency information unless you specify the dependencies in comments. And we all know that [comments lie](http://blog.ircmaxell.com/2012/06/to-comment-or-not-to-comment-tale-of.html). Therefore, to understand what dependencies are needed, you need to turn to the one and only authoritative source: the code itself. Contrast that to traditional dependencies which are indicated by the public API (signature) of the class's methods.

### Law of Demeter Violation

Service locators also violate the [Law of Demeter](http://en.wikipedia.org/wiki/Law_of_Demeter). They require classes that use them to understand the API of not only the locator, but of the locator's children as well. That second level of indirection winds up tightly coupling the class to the service locator as well as its children. If you wanted to refactor a different locator in, you'd have a lot of changing to do. Now, you could argue that this is the explicit purpose of a locator. But I would say that's an excuse for violating the LoD, not a reason for it.


Another problem is that you're passing the entire knowledge base that the locator has into each and every class that depends on the locator. You're giving each class not only the information it needs, but everything you know. While that's not directly problematic, it makes writing problematic code very easy. After all, you can implement the functionality anywhere since you have access to the state everywhere...


Additionally, if you wanted to split the `getDatabaseConnection()` method that we discussed earlier into being able to provide a read-only and a read/write connection, you'd have to grep through the codebase for all possible calls to that method first.

### Single Responsibility Principle Violation

Classes that depend on a service locator also violate the [Single Responsibility Principle](http://en.wikipedia.org/wiki/Single_responsibility_principle). The reason for that is simple: classes need to have the responsibility for fetching their dependencies from the locator in addition to the primary responsibility. Another way of phrasing the SRP is to say "No class should have more than one reason to change". Phrased that way, it should be clear to see why a locator would violate the SRP. If we wanted to change the locator (the interface), we'd have to change each and every class that uses it. Therefore, we've given our class an additional reason to change, and hence an additional responsibility.

### Hidden Coupling

As should be obvious from the prior discussion about globals, service locators wind up coupling each and every object that uses a particular locator instance together. This coupling is obvious but often overlooked. If one class makes a change to an object stored in the service locator, all other classes that use that same object will be affected. This can be desirable, but it also can lead to significant spooky action at a distance. Which is always seen as a bad thing.

### And More

There are a number of other issues with service locators. I've kept it to these few for the time being as the others are either really repetitious or difficult to express in a post like this. The ones that I've listed are the more significant ones.

## They Can't Be That Bad!

They are not that bad. Service locators are a significant step up from pure global dependencies or using static methods (Singletons, etc). They do solve some significant problems associated with OO development. And the new ones that they introduce are usually more minor than the ones they solve (it's a good tradeoff). So why am I harping about how bad they are? The answer is simple. Service Locators are better than nothing. However, there's an even better alternative: [Dependency Injection](http://en.wikipedia.org/wiki/Dependency_injection).


And no, what Fuel 2 has is not Dependency Injection. It's a service locator. They just mis-used (and bastardized) a term that's been in existence for a while in the greater programming community. Outside of the PHP world, a true Dependency Injection Container acts similar to a service locator, except that it creates your class for you, passing the contained dependencies to your class. The main difference is that your class doesn't depend on the container at all. Thereby eliminating all of the above problems with service locators.

It's worth noting that the difference between a Dependency Injection Container and a Service Locator is simply that in a true DIC, the created classes have no idea of the container's existence. It's a fine line, but a very significant one.


When it comes to Symfony 2, it's a bit more difficult of a situation. They do have a proper Dependency Injection Container. But they also use it as a service locator all over the place. Which then throws away the vast majority of the benefits of a proper DIC in exchange for even deeper coupling on the service locator. That further confuses the issue because they are using a DIC and treating it like a Service Locator, while still calling it a Dependency Injection Container...

If you want to see a real Dependency Injection Container, check out [Zend Framework 2](http://framework.zend.com/wiki/display/ZFDEV2/Zend+DI+QuickStart).

And that's why I wrote this post. Not because service locators are evil. But because there's a much better alternative. I find it amazing that the PHP community is shunning the better alternative in favor of something that's clearly worse.

I'd also like to call out to the developers and maintainers of Fuel 2 and all other frameworks and libraries using a Service Locator: Stop calling it dependency injection. It's not. Calling it a "Dependency Injection Container" just confuses the issue. Call it what it is, a Service Locator. Otherwise you devalue the term "Dependency Injection" to a mere buzz-word that has no meaning. And that **is** detrimental to the community...