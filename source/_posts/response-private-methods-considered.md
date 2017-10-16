---
layout: post
title: "Response: Private Methods Considered Harmful"
permalink: response-private-methods-considered
date: 2012-12-11
comments: true
categories:
- Rant
tags:
- Anti-Pattern
- Architecture
- Best Practice
- Design Patterns
- PHP
- Programming
- Rant
- Response
---

Brandon Savage has recently posted two [blog posts](http://www.brandonsavage.net/private-methods-considered-harmful/) portraying [his opinion](http://www.brandonsavage.net/in-further-defense-of-avoiding-private-methods/) that using private visibility on class methods can be considered harmful in a lot of situations. While I understand the point he is trying to make, I can't say that I agree with it. I do like private visibility and think that it's actually under-used in a lot of software. But it's not because I think Brandon is wrong...
<!--more-->

## The Viewpoint

The key in understanding our two differing opinions stems from our approaches to object oriented design. From Brandon's blog posts (I haven't discussed it directly with him), I get the feeling that he is a fan of using inheritance to add or alter functionality. If you take this approach, his view points on protected vs private visibility are 100% on point.

Let me say that again. If you treat inheritance as a first go-to tool for behavior modification, Brandon is spot on the money with respect to what you lose when making methods private.

The problem here is that I don't share that viewpoint. I approach object oriented design from a different angle. I believe that inheritance is mostly an anti-pattern that leads to more problems then it solves...

## Inheritance? An Anti-Pattern?

Yup, that's what I said. If you look at code that I've written on [GitHub](https://github.com/ircmaxell), you'll see very little actual inheritance. I use interfaces a lot, but inheritance: not so much. The reason is the way that I write code. I write classes as atomic units of functionality. That means that when I design my applications, I am not writing them in terms of relationships to other classes (inheritance wise). I am writing them with stand-alone functionality. Then, I use inheritance as a tool to de-duplicate the code during refactoring (resulting in abstract parent classes).

You may be asking yourself "Why is he saying that it's an anti-pattern?"... The reason is simple, inheritance is a manifestation of my mortal enemy: static-coupling. Once you inherit from a class to add or alter functionality, you're statically coupling that behavior to the other class. You can't re-use it. Sure, traits partially solve that problem, but they introduce [all sorts of new ones](http://blog.ircmaxell.com/2011/07/are-traits-new-eval.html). And deeper still, as soon as you inherit to add (or alter) functionality, you eliminate the possibility of combining changes.

Let me explain with an example:

```php
class Printer {
     
    private $_string;
     
    public function __construct($string = null) {
        if($string) {
            $this->setNewString($string);
        }
    }
     
    public function printString() {
        print $this->_string;
    }
     
    public function setNewString($string) {
        $this->_setString($string);
    }
     
    private function _setString($string) {
        $this->_string = $string;
    }
     
}
```

Now this code is pretty straight forward (if not meaningless, and copied from Brandon's second post). Let's now say that we want to add "<pre>" tags around the output. So we can extend the original class:

```php
 
class PrePrinter extends Printer {

    public function printString() {
        print '<pre>' . $this->_string . '</pre>';
    }

}
```

Simple and straight forward. What could the problem there be? Well, what happens if we now want a printer that strips HTML tags out of the output? We could define a new printer:

```php
class NoTagPrinter extends Printer {

    public function printString() {
        print striptags($this->_string);
    }

}
```

Do you see the problem here? What happens if we want to strip HTML tags from the output, **AND** wrap it in `<pre>` tags...? We've got to make a third custom one... Where instead, if we used composition to build the functionality into the object, we could do it a different way. Here's a simple example of using a decorator:

```php
interface Printer {
    public function printString();
}
class StringPrinter implements Printer {
     
    private $_string;
     
    public function __construct($string = null) {
        if($string) {
            $this->setNewString($string);
        }
    }
     
    public function printString() {
        print $this->_string;
    }
     
    public function setNewString($string) {
        $this->_setString($string);
    }
     
    private function _setString($string) {
        $this->_string = $string;
    }
     
}
class PrePrinter implements Printer {
    private $printer;
    public function __construct(Printer $printer) {
        $this->printer = $printer;
    }
    public function printString() {
        print '<pre>';
        $this->printer->printString();
        print '</pre>';
    }
}
class StripTagsPrinter implements Printer {
    private $printer;
    public function __construct(Printer $printer) {
        $this->printer = $printer;
    }
    public function printString() {
        ob_start();
        $this->printer->printString();
        $string = ob_get_clean();
        print striptags($string);
    }
}
```

Simple, straight forward, and flexible. All the elements of good OOP code... I can construct any combination of printers that I want:

```php
$printer = new StringPrinter('<br>foo');
$printer->printString(); // "<br>foo"

$pre = new PrePrinter($printer);
$pre->printString(); // "<pre><br>foo</pre>"

$strip = new StripTagsPrinter($printer);
$strip->printString(); // "foo"

$preStrip = new PrePrinter(new StripTagsPrinter($printer));
$preStrip->printString(); // "<pre>foo</pre>"
```

The beauty here is that the behavior composition is left to the consumer of the objects, not to the writer of the classes.

## The Stance

The cool part here, is that if you treat inheritance as last resort, then it doesn't matter if you make methods protected or private, since you're not really inheriting from the class anyway. So all of Brandon's criticisms go away once you take that viewpoint on object construction.

But using protected in a public library brings along its own challenges. Those protected methods instantly become public contracts. The reason for that is that code that uses the library is free to extend from its classes. Therefore, anytime you want to make a change to a class, you have to keep in mind that you're not only maintaining the public API, but the protected one as well.

Another problem with protected methods is that it exposes the implementation details of the class. While this may not seem like much, it's a form of tight coupling that is actually listed as the last point of the [SOLID](http://nikic.github.com/2011/12/27/Dont-be-STUPID-GRASP-SOLID.html) principles: Dependency Inversion Principle. You should never depend on details, but always depend on abstractions. Inheriting from a parent class doesn't give you an excuse to break this guideline...

## The End Result

In the end, I feel that my approach has more benefits. But that doesn't mean that Brandon's approach is wrong. We simply have different values. I tend to value composition over inheritance, and as such using `private` methods gives me more than it costs me. Brandon, on the other hand, tends to use inheritance a lot more, which pushes that balance to the side that private methods cost him more than it gives him.

Software development is not a science. It's very much an art. Different people have different experience and approach problems differently. That doesn't mean that one way is better than the other. It just means that we're different people. And different approaches require different tools. 

And that's my point here. Don't be afraid of -or avoid- a tool because someone wrote a blog post or a book saying to. Avoid it because you feel it doesn't fit your values and doesn't give you enough of a trade-off. Think critically about how you write software, and then fit that tool to your development style. After all, if we all thought the same way, this would be a pretty boring industry...

### Responses:

 * Larry Garfield: [The Danger Of Privates](http://www.garfieldtech.com/blog/private-composition-inheritance)
