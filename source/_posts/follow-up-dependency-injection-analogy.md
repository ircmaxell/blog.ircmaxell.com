---
layout: post
title: Follow-Up: Dependency Injection: An Analogy
permalink: follow-up-dependency-injection-analogy
date: 2011-03-22
comments: true
categories:
tags:
- Best Practice
- Dependency Injection
- PHP
- Programming
---

I recently read a post entitled [`Dependency Injection: An Analogy`](http://weierophinney.net/matthew/archives/260-Dependency-Injection-An-analogy.html), and I think it does a pretty good job explaining two of the types of Dependency Injection.  I really like the theme, and feel it really brings down the topic of DI to easy to understand language.  The only problem with it that I can see is that there are actually 4 flavors of DI available to us.  The other two flavors aren't even touched in that post.  So let me expand on that theme a bit here (Borrowing the same core analogy base from that post):

<!--more-->


## Regular Dependency Injection

> `Telling your waiter what you want without looking at the menu, and then giving up if you don't get it.`



Regular Dependency Injection is quite simple.  When you construct a new instance of an object, you simply pass in the dependencies needed manually.  In code, this is really simple:

```php
class A {}

class B {
    public function __construct(A $a) {
    }
}

$b = new B(new A);

```


That's all there is to it!  If you do that, you've got Dependency Injection up and running!  Was that so hard?  Well, actually it is much more complicated than that.  What happens when you need to create a new object somewhere down the road?  Do you then need to keep track of all possible dependencies you might need so that you can create all of your child objects?  Well, yes.  That makes this powerful, but ultimately can lead to some dirty code in larger projects (albeit no where near as dirty as hard-coded dependencies).  So what can we do?

## Enter Dependency Injection Frameworks

> `You call in your order before you show up to the restaurant, but don't care who actually gives you the meal as long as it's correct.`

Dependency Injection Frameworks haven't really been a big hit yet in PHP (the only significant one that I know of is in [Symfony2](http://components.symfony-project.org/dependency-injection/documentation) and is rather new).  However, other languages have sprouted several popular DI Frameworks in recent times (such as Spring in both Java and .NET, and StructureMap in .NET).  The principle is quite simple.  You define the dependencies that you need in some manner (usually XML or YAML).  Then, you can instantiate the new object with a call to the framework instead of using `new`. 

```php
$sc = new sfServiceContainerBuilder();
 
$loader = new sfServiceContainerLoaderFileXml($sc);
$loader->load('path/to/xmlfile.xml');

$b = $sc->b;

```


One benefit to the manager is that it lazy loads the dependencies for you.  Another is that `it just works` without you needing to do much manually.  But I personally see that as a problem.  I don't like magic.  I find it hard to debug, hard to understand quickly and hard to trace manually.  It's somewhat better than injecting your dependencies manually, but still suffers from a few issues.

## Enter Service Containers

> `The waiter hands you a menu.  You then need to try to pick something off of the menu, even if it's not exactly what you need.`

Service Containers are also known as Registry objects.  Basically, it's just a simple object that manages instances of dependencies.  At first glance, this might seem very similar to Dependency Injection Frameworks.  However, they are quite different.  Dependency Injection Frameworks build the object for you.  With Service Containers, you build the object, and pass the container as the parameter.  The object then pulls whatever it needs from the container.

```php
$sc = new StdClass;
$sc->a = new A;

class B {
    protected $a;
    public function __construct($container) {
        $this->a = $container->a;
    }
}

```

`Note: In reality, you wouldn't use StdClass here, you'd use a better suited class which actually does some type checking.  I just used it for simplicity.`


One benefit here is that there's nothing magic going on.  You can track the history of the container everywhere it goes.  And since the same container is passed to all objects that need it, there's no worrying about if it's available or if you need it.  However, there's still a problem: You need to pass this registry around.  And even worse, is you lose the type-hinting that PHP can do for you with regular dependency injection.  And even worse still is that your public API is muddied since there's no mention of the actual dependencies that the class actually needs.  Worse still is the fact that if you want to change the dependency used for a particular object, you need to change it in the registry, create the object, and then change it back. And worse of all, you still need to actually do the enforcement of your dependencies manually yourself.

## Finally, Lazy Dependency Injection

> `You make your custom order ahead of time.  And if it's not ready when you want to eat, you make it yourself.`

In short, this is basically just manual DI where you make the dependencies optional.  If they are not passed in, create them yourself.  This is actually a nice balance between testability, loose coupling and ease of use.  You still build the object yourself.  But you can choose if you want to pass in your own version of the dependency or if you want to let the object handle it yourself.

```php
class B {
    protected $a;
    public function __construct(A $a = null) {
        if (is_null($a)) {
            $a = new A;
        }
        $this->a = $a;
    }
}
$b = new B(); // Default Dependency Used
$b = new B(new A); // Our own Dependency Used

```


It's really that simple.  I think that this is basically the best of all worlds.  You still can create objects yourself and not lose any of the benefits of the DI method.  You can inject the dependencies as you want.  If you don't care, don't bother injecting them and let the class build the dependency itself.  You get all of testing benefits that DI can provide.  And yet it's still just as easy as calling `new Foo;` to create a new instance.

## Conclusion

I hope that explains some of the finer details of DI and how it applies to every day coding.  Each of the methods has their pros and cons, as well as valid uses.  But as of late I find myself programming more and more using the lazy DI style.  I find it to be far easier to write, use and test than any of the other alternatives.  That's just my preference though.  Find your own preferred style.  Try them all.  But most importantly, don't just use a method, understand it.
