---
layout: post
title: Is Autoloading A Good Solution?
permalink: is-autoloading-good-solution
date: 2012-07-20
comments: true
categories:
- Programming
tags:
- Autoloading
- Design Patterns
- Library
- Object Oriented Programming
- Optimization
- PHP
---

One of the most powerful changes that PHP5 brought to the table was the ability to [autoload](http://us.php.net/autoload) classes. It's such a useful tool that it was the [first standard](https://github.com/php-fig/fig-standards/blob/master/accepted/PSR-0.md) the FIG group put forth. Almost every single major PHP framework and library uses an autoloader to include its classes. It always felt somewhat wrong to me to autoload in production at runtime. So I decided to give it a bit more exporation...<!--more-->
## The True Problem


The real problem that autoloaders solve is to load dependencies. During development, it makes life really easy because you just drop your class in a folder (assuming correct naming conventions) and it just works. But does this problem exist in production? What's the difference between run-time autoloading and pre-generating a list of dependencies (either at the top of a file, at the top of a package, or in a single bootstrap file).

The normal logic that's used to justify autoloading over manual dependency loading in production is that `it only loads the classes you need`. Therefore you save the parsing costs of classes that you don't need. But surely that additional run-time loading has costs. So I decided to setup a test to see how expensive that additional run-time loading costs us, and to prove whether or not autoloading is worth it in production.


## The Setup

So, to test this properly, I'd need a lot of classes. Rather than using a production framework, where dependency ordering could prove interesting, I decided to generate a number of classes. One thousand to be exact. And they are all empty classes. Just:

```php
<?php class test{$n} {}

```

Now, how to test it. I created two scripts to test this. The first uses an autoloader, and the second requires all of the classes that are defined. Here's the autoload test script:

```php
$classes = $argv[1];

spl_autoload_register(function($class) {
        require __DIR__ . '/files/' . $class . '.php';
});

$start = microtime(true);
for ($i = 0; $i < $classes; $i++) {
        $class = 'test' . $i;
        new $class;
}
$end = microtime(true);

echo "Completed in " . ($end - $start) . " seconds\n";

```

And here's the hard-coded test script:

```php
$classes = $argv[1];
$start = microtime(true);

require 'files/test0.php';
// ... snip ...
require 'files/test999.php';

for ($i = 0; $i < $classes; $i++) {
        $class = 'test' . $i;
        new $class;
}

$end = microtime(true);

echo "Completed in " . ($end - $start) . " seconds\n";
```

As you can see, the same thing is timed in both. The only difference between the two is the method of loading the dependencies.


All of these tests are run via a fresh compile of master (trunk, what will be 5.5.0).

## Loading All The Classes

The first and simplest test loads all 1000 classes. Not surprisingly, the autoload solution is significantly slower than the hard-coded version. Shockingly over 42% slower. The hard coded test ran in -on average- 0.0210 seconds. The autoloaded solution ran in -on average- 0.0300 seconds. So it's clear that if you're loading all of your classes, hard-coding is clearly a better solution.

## Loading Most Of The Classes

But what happens when we drop the number of classes that we're loading? What happens when we drop it to 75% of the classes (750 of them)? Not surprisingly, the hard-coded didn't change appreciably (dropping from 0.0210 to 0.0208). But shockingly, the autoload solution dropped to within a margin of error of the hard-coded solution at 0.0215 seconds. 

## Loading Half Of The Classes

Not surprisingly, when we reduce the number of classes loaded to 500, the autoloading solution starts to pull way ahead. At 0.0150 seconds, it's already 25% faster than the hard-coded solution.

I'm not going to go any further, it's obvious the direction we're heading...

## The Verdict

The verdict seems clear. Autoloading is more efficient. But hold on, we can't leave it at that. While we're here, let's look at some controversial implementation details about the autoloader.

## File Exists

What happens when we add a file exists check to the autoloader? Surely it'll make a huge impact because of the additional `stat()` call, right?

```php
spl_autoload_register(function($class) {
        $file = __DIR__ . '/files/' . $class . '.php';
        if (file_exists($file)) {
                require $file;
        }
});

```

Well, as it turns out, for 1000 classes, it raises the execution time from 0.0300 seconds to 0.0340 seconds. That's an additional 13%. But more importantly, it's an additional 0.000004 seconds per include. Which is such a trivial difference that it's still dirt cheap. Given the other benefits that it has (preventing fatal errors, and making the autoloader play nice with others), it's easy to see why we'd want to do that.

## Require Once

Now, let's swap out `require `for `require_once`. This should prevent edge-case situations where two different classes would map to the same file by one autoloader (but perhaps be handled by separate autoloaders).
```php
spl_autoload_register(function($class) {
        $file = __DIR__ . '/files/' . $class . '.php';
        if (file_exists($file)) {
                require_once $file;
        }
});

```

For 1000 classes, it raises our execution time from 0.0340 seconds to 0.0350 seconds (well within the margin of error for the test). That's only a 3% difference, and only a 0.000001 second difference per class file. Definitely worth it for the compatibility gains that it brings...
## Conclusion


When I started to write this post, I was set on proving why autoloading in production could be bad for high performance or complex applications. I still feel that applies to some extent. But at a 75% class usage tradeoff point, it doesn't really make sense **not** to autoload, especially given all of the other benefits. So in the end, it looks like autoloading is indeed a good solution...


Note that these numbers all constitute micro-optimizations. Making decisions based on them is not advised. Your application structure and specific parameters may have other results, so be sure to test it on your system prior to implementing it...