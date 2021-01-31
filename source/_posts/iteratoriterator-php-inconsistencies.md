---
layout: post
title: IteratorIterator - PHP Inconsistencies And WTFs
permalink: 2011/10/iteratoriterator-php-inconsistencies.html
date: 2011-10-31
comments: true
categories:
- PHP
tags:
- Inconsistencies
- PHP
- Weird Behavior
- WTF
---

Last night I was discussing the [SPL Iterators](http://us2.php.net/manual/en/spl.iterators.php) with [@go_oh](http://twitter.com/#!/go_oh) in the [PHP StackOverflow chat room](http://chat.stackoverflow.com/rooms/11/php) when I came across something very interesting.  We were talking about why some of the SPL Iterators accept only an Iterator as the constructor argument (Such as [LimitIterator](http://us2.php.net/manual/en/class.limititerator.php)), and others accept either an Iterator or an IteratorAggregate as the argument (Such as [IteratorIterator](http://us2.php.net/manual/en/class.iteratoriterator.php)).  Feeling that this would be a useful feature to add (having all of them accept an IteratorAggregate), I opened up the PHP source and started looking at how hard of a change this would be.  What I found was... Interesting...

<!--more-->
## The C Code.



So I started by opening up ext/spl/spl_iterators.c.  I started off by looking at the constructor for IteratorIterator as that's what I would model the rest off of.  You can see the source of it [here](http://lxr.php.net/xref/PHP_5_3/ext/spl/spl_iterators.c#2908).  We can clearly see (even if you don't know C well) that it's calling another function with a few parameters.  So, to figure out what it does, let's look at that function (With lxr.php.net, all you need to do is click on a function name to be taken to its definition).


If we look at [spl_dual_it_construct](http://lxr.php.net/xref/PHP_5_3/ext/spl/spl_iterators.c#spl_dual_it_construct), we can see that it's basically a centralized constructor body for most of the SPL Iterators.  The majority of it is normal code for PHP and was expected.  What wasn't expected was inside of the body for the switch statement for the [case DIT_IteratorIterator](http://lxr.php.net/xref/PHP_5_3/ext/spl/spl_iterators.c#1418).  At first, it seems fairly straight forward, until we hit this block:

```php
if (!instanceof_function(ce, zend_ce_iterator TSRMLS_CC)) {
    if (ZEND_NUM_ARGS() > 1) {
        if (zend_lookup_class(class_name, class_name_len, &pce_cast TSRMLS_CC) == FAILURE 
     || !instanceof_function(ce, *pce_cast TSRMLS_CC)
            || !(*pce_cast)->get_iterator
        ) {
            zend_throw_exception(spl_ce_LogicException, "Class to downcast to not found or not base class or does not implement Traversable", 0 TSRMLS_CC);
            zend_restore_error_handling(&error_handling TSRMLS_CC);
            return NULL;
        }
        ce = *pce_cast;
    }

```


Let's walk through that code to see why it's such a WTF.  To preface this, let's talk about the variables and functions that are defined here.  ``ce`` is a variable holding the object that was passed to the constructor as the first parameter.  `ZEND_NUM_ARGS()` is basically the C equivalent of `func_num_args()` in PHP.  `Zend_lookup_class` takes a string and returns the class structure for that string (Vaguely similar to ReflectionClass).  And `instanceof_function()` is basically the internal way of calling `$foo instanceof bar.  `The rest of it should either be easy to understand, or isn't really that important anyway.


So, the first if statement basically checks if the object that was passed in implements Iterator or not.  Remember that since IteratorIterator accepts a Traversable object, it could be either a Iterator or an IteratorAggregate.  So the entire branch is conditional upon the object being an IteratorAggregate.  The second if statement checks to see if we have a second argument (which hereto is undocumented).  So far so good.


Here's where it starts to get interesting.  The next if statement has three parts.  The first one determines if the string passed as the second argument is a valid class (and looks up the definition to store it in `pce_cast`).  If it can't find the class specified, it throws an exception.  The second part of the if statement is making sure that the object that was passed as the first parameter is an instance of the class provided as a second parameter (that the class name passed as the second parameter is in the class hierarchy for the object).  The final part simply ensures that the found class implements Traversable as well (can function as an iterator).


If all three of parts pass, something very interesting happens.  The original object is cast down to the specified class.  Now I know what you're thinking: Cast down?  PHP has no concept of casting...?  Well, in this case, it appears it does.

## What it means

So basically, the second parameter to IteratorIterator controls which method is used to get the iterator.  To best understand it, let's use it in an example...  First, let's define a few classes.
```php
class Foo implements IteratorAggregate {
    public function getIterator() {
        return new ArrayIterator(array(1, 2, 3));
    }
}

class Bar extends Foo {
    public function getIterator() {
        return new ArrayIterator(array(4, 5, 6));
    }
}

class Baz extends Bar {
    public function getIterator() {
        return new ArrayIterator(array(7, 8, 9));
    }
}

```


Now that we have them defined, let's go ahead and try iterating over them a few times to see what our behavior is.
```php
var_export(iterator_to_array(new Foo, true));
// array(1, 2, 3)

var_export(iterator_to_array(new Bar, true));
// array(4, 5, 6)

var_export(iterator_to_array(new Baz, true));
// array(7, 8, 9)

```


That's exactly what we would expect.  But now let's look at iterating over them again, this time using IteratorIterator instead.
```php
var_export(iterator_to_array(new IteratorIterator(new Foo), true));
// array(1, 2, 3)

var_export(iterator_to_array(new IteratorIterator(new Bar), true));
// array(4, 5, 6)

var_export(iterator_to_array(new IteratorIterator(new Baz), true));
// array(7, 8, 9)

```


So far, so good.  But now, let's pass the hereto unknown and undocumented second parameter.  Since we want to downcast, it wouldn't make sense to pass Foo for the new Foo one.  So let's pass "Foo" to the bar one...
```php
var_export(iterator_to_array(new IteratorIterator(new Bar, "Foo"), true));
// array(1, 2, 3)

```


Did you see what happened there?  It used the method defined in Foo instead to iterate over.  So we just told it to use a method from a child class instead of the parent!  Let's look at another example: 
```php
var_export(iterator_to_array(new IteratorIterator(new Baz, "Bar"), true));
// array(4, 5, 6)

```


And let's look at a failure:


```php
new IteratorIterator(new Baz, "StdClass");
// LogicException("Class to downcast to not found or not base class or does not implement Traversable")

```

It's quite interesting that we can downcast like this.  I did some quick searches in core, and this appears to be the only place that does this.

## Finally

Personally, I can't see any use-case for this.  Doing anything with it requires explicit knowledge of the class tree when creating an IteratorIterator object.  So I'm not even sure what in practice it would be useful for.  So I don't know whether it being there classifies as a bug, or if it is just another "weird quirk" of PHP.  



When I saw it, all I could say was "WTF"...
