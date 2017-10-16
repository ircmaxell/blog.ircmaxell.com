---
layout: post
title: What Generators Can Do For You
permalink: what-generators-can-do-for-you
date: 2012-07-23
comments: true
categories:
- Programming
tags:
- Design Patterns
- Generators
- Object Oriented Programming
- PHP
- PHP-Internals
- Procedural Programming
---

The concept of generators was [recently proposed](https://wiki.php.net/rfc/generators) for addition in PHP's core (Possibly for 5.5.0). While I believe that this is a great tool, it appears that many PHP developers aren't familiar with the concept of generators. So I thought I would take a little time and explain some of how it works, and how it can be used to greatly simplify code.<!--more-->

## The Theory

Let's get one thing clear here first. Generators do not add any capability to the language at all. Everything that you can do with a generator, you can already do with an iterator. So with that in mind, let's take a look at an example first. Let's say we're going to iterate over the lines in a file (this is also the example used by the RFC, and I chose it for that specific reason). So, in procedural code, that might look like:

```php
$f = fopen($file, 'r');
while ($line = fgets($f)) {
    doSomethingWithLine($line);
}
```

This is quite fine for normal usages. But what if we wanted to abstract the call. For example, what if we wanted to generate those lines from an abstract source. Sure, today it may be a file. But tomorrow, we may want to fetch the lines as records from a database. Or perhaps as packets from a service call. Or some other method.


Up to now, we've had two choices on how to generalize that. We could either return an array from the method call, or return an iterator. The problem with returning an array every time is two fold: first, we might not be able to fit all the data in memory (what if the file is 30gb?); Second, we may not be able to implement it as an array at all (for example, what if we wanted to return an infinite series, and let the caller determine how much to consume).


So that leaves us with an iterator. For this example, it's pretty simple to convert to an iterator. In fact, for this use case, PHP already has a built-in iterator to do that for us: [SPLFileObject](http://us3.php.net/manual/en/class.splfileobject.php). But for demonstration reasons, let's try writing one ourselves:

```php
class FileIterator implements Iterator {
    protected $f;
    public function __construct($file) {
        $this->f = fopen($file, 'r');
        if (!$this->f) throw new Exception();
    }
    public function current() {
        return fgets($this->f);
    }
    public function key() {
        return ftell($this->f);
    }
    public function next() {
    }
    public function rewind() {
        fseek($this->f, 0);
    }
    public function valid() {
        return !feof($this->f);
    }
}
```

Simple, right? Well, not quite. If you look closely, you'll see that we've violated the contract of the iterator. Next and Rewind are supposed to be the only mutating methods of the iterator. Calling `current()` twice should give the same data. But it doesn't here. I made that mistake for a reason. To show how converting procedural code directly into an iterator isn't trivial. In fact, it's pretty difficult to do properly. So let's look at a correct implementation:

```php
class FileIterator implements Iterator {
    protected $f;
    protected $data;
    protected $key;
    public function __construct($file) {
        $this->f = fopen($file, 'r');
        if (!$this->f) throw new Exception();
    }
    public function __destruct() {
        fclose($this->f);
    }
    public function current() {
        return $this->data;
    }
    public function key() {
        return $this->key;
    }
    public function next() {
        $this->data = fgets($this->f);
        $this->key++;
    }
    public function rewind() {
        fseek($this->f, 0);
        $this->data = fgets($this->f);
        $this->key = 0;
    }
    public function valid() {
        return false !== $this->data;
    }
}
```

Wow, that's a lot of code and state to manipulate for the simple task of iterating a file (and most of the heavy work is handled for us inside of the file functions). Now, imagine if you had more state to maintain, or had a more complex algorithm to implement. Storing the state across method calls is possible, but the different combination of method calls may prove to be, well, difficult. So let's introduce a generator to this problem:

```php
function getLines($file) {
    $f = fopen($file, 'r');
    if (!$f) throw new Exception();
    while ($line = fgets($f)) {
        yield $line;
    }
    fclose($f);
}
```

So much simpler. In fact, it uses the exact same syntax as the procedural version, with the exception of the new `yield `keyword.

## So, How Does It Work?


The important thing to note here is that the return value of the function is changed. It's not the `null` that we'd expect it to be. The presence of the `yield `keyword makes the engine return an instance of the special `Generator` class. This class implements `Iterator`, so it can be used directly in an iteration context:

```php
foreach (getLines("someFile") as $line) {
    doSomethingWithLine($line);
}
```

The cool thing here, is that we can structure our code however we want, and just "yield" the iteration step values as we need them. So how does it work? Well, when you call the `getLines()` function, PHP will run the code until it hits the first yield, at which point it'll remember that value and then return the generator instance. Then, as `next()` is called on the generator (either internally by the iteration context, or manually), PHP will run the code again, resuming from the last yield statement, until it encounters the next one (or the function finishes, by a "return" or the end of the function). So knowing that, we can build a useful generator:

```php
function doStuff() {
    $last = 0;
    $current = 1;
    yield 1;
    while (true) {
        $current = $last + $current;
        $last = $current - $last;
        yield $current;
    }
}
```

Can you tell what that does? At first glance, it looks like it will loop forever. And, in fact, it will if we let it. But looking further, it's a very simple implementation of the [Fibonacci sequence](http://en.wikipedia.org/wiki/Fibonacci_number).


Let's be clear about something here. This is not a replacement for iterators. It is a short-hand way to create them. Iterators still have a very strong use, especially in collection classes, where there is definitely an object state that needs to be maintained. But this is extremely useful for creating them.

### A More Complex Example


Let's say that we wanted to create a user-land implementation of [ArrayObject](http://us3.php.net/manual/en/class.arrayobject.php). Rather than implementing iterator, and handling the array iteration manually, we can do a little trick. The interface [IteratorAggregate ](http://us3.php.net/manual/en/class.iteratoraggregate.php)requires a single method, `getIterator()`. Since generator functions return an object that implements Iterator, we can make our `getIterator()` function a generator! Imagine the simplicity of this class:

```php
class ArrayObject implements IteratorAggregate {
    protected $array;
    public function __construct(array $array) {
        $this->array = $array;
    }
    public function getIterator() {
        foreach ($this->array as $key => $value) {
            yield $key => $value;
        }
    }
}
```

So simple; so to the point. So easy to follow. And, if you notice, we can return a custom key using the normal key syntax. The point here, is that it takes a complex task (storing state explicitly), and lets us do it implicitly, with the language adding the sugar necessary to complete it. So we can focus on getting things done, instead of trying to force things into a ton of boilerplate code. But we're not done...

### Sending Data Back

We also have the option to send data back to the generator method. The yield function can also return a value that's sent to the generator using `send()`. This could come in handy, depending on what we're trying to do. So, let's look at an example. Let's say we want to log data. Instead of coding a full blown logging class, and maintaining the state separately (which we could definitely do), we could simply use a generator:

```php
function createLog($file) {
    $f = fopen($file, 'a');
    while (true) {
        $line = yield;
        fwrite($f, $line);
    }
}
$log = createLog($file);
$log->send("First");
$log->send("Second");
$log->send("Third");
```

Pretty simple... While that may be a bit of a over-simplified reason, let's look at a more complicated example. One that uses co-routines (routines that work together, yielding control back and forth). Let's say that we wanted to build a queue system that fetches data, and sends data back and forth in batches. Such as happens when reading a binary stream which has embedded field length information. We could manually link them together, or we could create a series of generators to do it for us:

```php
function fetchBytesFromFile($file) {
    $length = yield;
    $f = fopen($file, 'r');
    while (!feof($f)) {
        $length = yield fread($f, $length);
    }
    yield false;
}
function processBytesInBatch(Generator $byteGenerator) {
    $buffer = '';
    $bytesNeeded = 1000;
    while ($buffer .= $byteGenerator->send($bytesNeeded)) {
        // determine if buffer has enough data to be executed
        list($lengthOfRecord) = unpack('N', $buffer);
        if (strlen($buffer) < $lengthOfRecord) {
            $bytesNeeded = $lengthOfRecord - strlen($buffer);
            continue;
        }
        yield substr($buffer, 1, $lengthOfRecord);
        $buffer = substr($buffer, 0, $lengthOfRecord + 1);
        $bytesNeeded = 1000 - strlen($buffer);
    }
}
$gen = processBytesInBatch(fetchBytesFromFile($file));
foreach ($gen as $record) {
    doSomethingWithRecord($record);
}
```

A bit complicated, but hopefully you can see what's happening. We've abstracted the fetching and the processing of the buffer. So we can accurately and efficiently fetch only the amount of data that we need at a certain time, while still enabling code re-use.

## Other Uses


Generators can be used for many other things. One really cool and powerful method would be to simulate threads. Basically, you define each "thread" as a generator. Then, you "yield" back execution context to the parent, so it can pass it to another child (this is basically how "green threads" work). So we can build a system that simultaneously processes data from multiple sources (as long as we use non-blocking I/O). Here's a quick example:

```php
function step1() {
    $f = fopen("file.txt", 'r');
    while ($line = fgets($f)) {
        processLine($line);
        yield true;
    }
}
function step2() {
    $f = fopen("file2.txt", 'r');
    while ($line = fgets($f)) {
        processLine($line);
        yield true;
    }
}
function step3() {
    $f = fsockopen("www.example.com", 80);
    stream_set_blocking($f, false);
    $headers = "GET / HTTP/1.1\r\n";
    $headers .= "Host: www.example.com\r\n";
    $headers .= "Connection: Close\r\n\r\n";
    fwrite($f, $headers);
    $body = '';
    while (!feof($f)) {
        $body .= fread($f, 8192);
        yield true;
    }
    processBody($body);
}
function runner(array $steps) {
    while (true) {
        foreach ($steps as $key => $step) {
             $step->next();
             if (!$step->valid()) {
                 unset($steps[$key]);
             }
        }
        if (empty($steps)) return;
    }
}
runner(array(step1(), step2(), step3()));
```

Remember that everything that's possible with a generator is already possible with an iterator. So this isn't really anything TOO special. But the key here is that the state in any step is maintained by the engine between steps. There's no need to do anything fancy. So converting existing code to this style of runner is as simple as inserting a yield statement wherever you want to yield control back to the parent. Of course the runner is special, but the rest of the working code doesn't care what's happening... All it knows is that it's yielding contextual control back to someone else...

### Conclusion

Generators are a VERY powerful concept. They can be used to greatly simplify code. Imagine being able to write an `xrange()` function in one line of code:

```php
function xrange($min, $max) {
    for ($i = $min; $i < $max; $i++) yield $i;
}
```

Short, simple and to the point. Easy to read, easy to understand, and has very good performance (faster than an iteration implementation for sure). And the real beauty of it all, is that a solid generator implementation opens the door for list comprehensions to be added... But more on that later...