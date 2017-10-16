---
layout: post
title: Parameter Type Casting in PHP
permalink: parameter-type-casting-in-php
date: 2012-03-05
comments: true
categories:
- PHP
tags:
- PHP
- PHP-Internals
- Programming
---

As any of you who follow the [PHP internals list](http://news.php.net/php.internals) know, scalar type hinting has been a hot topic as of late.  You'll also know that I've submitted two new RFC (Request For Comment) proposals for inclusion of two new major features in the PHP language.  I figured it was worth going into both RFCs and patches a little deeper, explain my rationale and (hopefully) garner some more visibility of the proposals.
<!--more-->
## RFC1: Parameter Type Casting Hints

The RFC can be found [here](https://wiki.php.net/rfc/parameter_type_casting_hints).  Basically, this patch and RFC adds support for type-hinting scalar variables in functions and methods.  But to keep PHP's dynamic typing paradigm, the hints are designed to cast whatever is supplied to the requested type.  For example, with the RFC and patch, this becomes valid:

```php
function foo((int) $int)
```

It's worth noting that this is fundamentally different behavior from prior attempts to add scalar hinting to PHP on two fronts.  First off, it is intentionally casting the parameters to the destination type without throwing errors (so it's not strict type hinting).  Secondly, it uses the exact same casting rules that the engine uses for variable casting.  The RFC takes a leap from the prior RFCs on scalar type hinting by trying to not only work with PHP's dynamic typing behavior, but to fully embrace it.

Example:

```php
function test1((int) $foo) {
    var_dump($foo);
}
function test2((float) $foo = null) {
    var_dump($foo);
}
test1(1); // int(1)
test1("2"); // int(2)
test1(array()); // int(0)
test1(1.5); // int(1)

test2(); // null
test2(null); // null
test2(1); // float(1)
test2(1.5); // float(1.5)
test2("2.5"); // float(2.5)
```

## RFC2: Object Scalar Casting Magic Methods

The RFC can be found [here](https://wiki.php.net/rfc/object_cast_to_types).  In short, the RFC adds a number of new magic methods to classes to allow for finer control over how objects are casted to primitive types.  These magic methods are: 

```php
public function __toInt();
public function __toFloat();
public function __toArray();
public function __toScalar();
```


With the new magic methods, explicit casts (using `(int) $obj` syntax) will now be fully controlled by the class.  The one odd method out is the `__toScalar()` method.  This is called when the object is used in a scalar context, but without an explicit cast.  So it allows for `1 + $obj` to be meaningful...  The return type is up to the class, so it can return the type that best describes how the object should be represented in that context.

Additionally, the RFC adds support to internal PHP functions to support casting to the destination type.  So that means that an object implementing `__toInt()` can be passed to an internal function that expects an integer parameter directly.  

It's worth noting that references are not supported and will cause an error if attempted to be passed into an internal function.  So that means an object implementing `__toArray()` cannot be directly passed to `sort()`.  This is to prevent really odd side-effects where passing an object to a function changes the type of the variable holding the object.  However, the object can still be manually cast using `(array)` prior to calling the function...


Example:

```php
class Test1 {
    public function __toInt() {
        return 2;
    }
    public function __toFloat() {
        return 3.5;
    }
    public function __toArray() {
        return array(1, 2);
    }
    public function __toScalar() {
        return 5;
    }
}
$t1 = new Test1;
var_dump((int) $t1); // int(2)
var_dump((float) $t1); // float(3.5)
var_dump(array_keys($t1)); // array(0, 1)
var_dump(1 + $t1); // int(6)
var_dump(round($i)); // float(3)
```

## Two Sides of the Same Coin

It should be pretty easy to see the connection between the two RFCs.  They are both very complimentary and are intended to work together.  If both are implemented, it will greatly reduce a lot of boilerplate code that's currently included for defensive programming.  And further, the scalar casting code will reduce coupling between classes that include methods such as `toInt()` today (which is a lot, based on a quick search).

## The Future

Both of these patches only add the functionality they provide, and the necessary hooks to use it.  They do not change the nature of casting in PHP, nor do they really impact the future changes to said casting behavior.  The parameter type casting hints patch actually leaves the door open for more strict type hinting later on.  

## The Missing Piece

There is already sentiment that PHP needs to tighten up the casting mechanisms to identify data-loss due to a cast.  From what I've heard, a few developers are actually planning on submitting a RFC to emit an error (which is up for debate) if data-loss occurs from an implicit cast (for example, implicitly casting `float(2.5)` to `int(2)` through a parameter type hint -or passing to an internal function expecting an int- may emit an `E_NOTICE`, because of the round).  These two RFCs, coupled with the third (but unwritten) RFC would present an incredibly powerful set to help advance the PHP language while embracing its dynamic typing roots...

I'm all for improving PHP as a language.  I'm all for implementing new features, and porting features from other languages.  But I think we need to be careful to not try to just re-create another `{insert-language-here}`.  If you want all the features from that language, just use it.  But if those features really do improve PHP, then why not include them...

## What Can You Do

Do you like the concept?  If so, show your support!  Post to the [internals list](http://php.net/mailing-lists.php), post to your blog, post to twitter.  Show the support, so that the community knows this is a wanted feature.

Do you like the concept, but have issue with how it's implemented?  If so, share your concerns!  Post to the [internals list](http://php.net/mailing-lists.php), post to your blog, post to twitter.  Share the concerns so that the best overall outcome can be had by all.

Do you not like the concept?  Then keep it to yourself!  

Just Kidding!!!  Please, if you don't like the concept, share your concerns!  Post to the [internals list](http://php.net/mailing-lists.php), post to your blog, post to twitter (that's getting old, isn't it).  Share your concerns.  Let's just keep the conversation constructive...

So, with that said, what are your thoughts?

## Further Reading

### Patches

 * [Parameter Type Cast Hinting](https://gist.github.com/1963999)
 * [Scalar Cast Magic Methods](https://gist.github.com/1966809)

### RFCs:

 * [Parameter Type Cast Hinting](https://wiki.php.net/rfc/parameter_type_casting_hints)
 * [Scalar Cast Magic Methods](https://wiki.php.net/rfc/object_cast_to_types)
 
### Followup / Reply Posts

 * [Scalar Type Hinting Is Harder Than You Think](http://nikic.github.com/2012/03/06/Scalar-type-hinting-is-harder-than-you-think.html) - @Nikic
 * [Reddit Thread for This Post](http://www.reddit.com/r/PHP/comments/qiniv/parameter_type_casting_in_php/)
