---
layout: post
title: Error Handling in PHP
permalink: error-handling-in-php
date: 2011-08-04
comments: true
categories:
- Programming
tags:
- Best Practice
- Exceptions
- PHP
- Programming
---

Let’s face it: error handling in PHP is crap.  Actually it’s worse than crap, it’s craptastic.  The core has almost no support at all for handling errors.  Sure, PHP has a robust error reporting and logging system, but it has no real way of handling those errors.  If you want to write robust code, you need to be able to actually handle errors.  So how can we handle errors in PHP?
<!--more-->

## What is an Error



If we believe Merriam-Webster, the [definition of an error](http://www.merriam-webster.com/dictionary/error?show=0&t=1312312282) is “an act that through ignorance, deficiency, or accident departs from or fails to achieve what should be done”.  So basically, it’s when something (a piece of code) didn’t do what it said it was going to do (for whatever reason).  So for purposes of this post, I’m going to assert that there are 3 fundamental types of errors: Incidental Errors, Exceptional Errors and Application Errors.

## Incidental Errors



These are errors in code that don’t prevent the application from continuing on the current task.  What I mean by that is that an incidental error is an error that should be noted, but doesn’t really need to be handled since the task was still able to complete.  Let’s look at an example.

```php
if (strpos(‘foo’, ‘bar’, 5) !== false) {
```


That code will throw a warning: Offset not contained in string.  But the fact that the warning was thrown is irrelevant to the result of the function.  Even though the offset isn’t contained in the string, we know that the string ‘bar’ is not in the string ‘foo’ after the 5th position.  So even though we got an error, we still get the correct result from the operation.  Most notices are also incidental errors.  


It’s important to note that incidental errors are not to be ignored.  They do provide valuable debugging information and can provide clues to issues with application structure and code prior to discovering bugs.  Therefore it’s common that incidental errors are logged to a file (or displayed to the user in development environments).  It’s for that reason that I treat all incidental errors as a bug in the application which should be fixed.

## Exceptional Errors



These type of errors are the real crux of this post.  These are errors that indicate that the current task could not be completed.  A simple example of this is if you are trying to open a non-existent file for reading.  If the file does not exist, an error is raised saying that, and the file is not opened.  Therefore you cannot continue as if the file was opened successfully, but have to actually make a decision in your code as to how to proceed.  Let’s look at another example.

```php
$min = min($foo);
```


That code will throw a warning: When only one parameter is given, it must be an array.  The fact that the warning was raised indicates that data was lost because the function could not continue with its primary task.  We got an error, and we would presumably need to adjust our workflow accordingly.  If we did not, the `$min` variable would be `null` instead of the expected value of `$foo`.

## Application Errors



Application errors are errors which do alter the state of the application, but do not put the application into an unstable state.  The best way to describe this type of error is with a simple example.  Let's say you have a form that users submit that you need to validate.  If the validation fails, that is an Application Error.  It is not exceptional, since you completely know the state of the application afterwards and can continue if you choose to.  It is also not incidental since you more than likely will make application flow decisions based on the error.  So it doesn't really fit either mold of Exceptional or Incidental.


For application errors, you should not use exceptions to transmit the information.  Other methods exist which are far better situated to the task.  Depending what you are doing, you can either use a return code to indicate the nature of the error, or possibly have methods to check for certain errors.  Another common method is to return an error object which describes the error.  But an exception is not the right tool to use, since they will cause full script termination if it's not handled.  Since the application is not in an unstable state when an Application Error is raised, terminating it because one was raised is not the correct cause of action.


I'm not going to explore application errors any further in this post because they are a completely separate architectural discussion.  Handling application errors is completely user-land (meaning your code), and as such requires no support from the core of the language.  So we won't focus on it.

## Depending Upon The Abstraction



It’s important to note that the classification of a particular error can change depending upon the level of abstraction which you are looking at.  This change is always in the direction from an exceptional error to an incidental error to no error.  If you’re working with a class that reads CSV files, if a file does not exist, it is an exceptional error and needs to be treated as such.  But if we raise the abstraction level one notch to looking at a package that stores rows of data in a table (which uses the CSV class internally as an implementation), the fact that the file does not exist still remains exceptional, but for a different reason.  It’s no longer exception because the `file` does not exist, but it’s exceptional because the data source does not exist.


If all we cared about doing was reading information from the file, then we could safely demote the exceptional error to an incidental error and get on with life.  Doing this is fine, as long as we know that it’s a safe assumption to make.  Is it safe to assume that everything is ok if the file you tried to read from doesn’t exist?  The answer is quite simply, “It depends on what you are doing”.  


However, if we tweak the example slightly to look at writing data to the table, the error demotes from an exceptional error to an incidental error.  This is because we don’t really care that the file didn’t exist before, but we now only care if the file was able to be created and written to.  So the class of an error really depends upon the context of which you are looking at.


As another example, imagine if we are implementing the function `[touch()](http://us3.php.net/manual/en/function.touch.php)` in PHP.  If the filename provided does not exist, it is not any kind of error, since that’s an expected condition.  So in that case the exceptional error that would normally be raised can be safely demoted to no error at all.  That’s because one of the assumptions we make when defining the file is that the file may or may not exist.  We know that ahead of time, and can therefore safely demote the error.


It’s very important to realize that demoting the error is not the same thing as ignoring it.  Demoting the error is a conscious decision based upon the details of the error, whereas ignoring it is not caring about the error or why it was thrown.  In the context of the touch example, we don’t care if the file doesn’t exist, and can demote that error.  But if we got back an error that the filesystem itself was corrupted (or full, or whatever), that still remains an exceptional error because our function couldn’t complete its task.

## Why Should We Handle Errors



To put it simply, exceptional errors should always be handled and incidental errors should always be logged or displayed.  Why should we handle exceptional errors?  If we do not handle them, our application will be left in an inconsistent state.  Handling errors can include as little as skipping a few lines of code, or as much as a completely different workflow.  But the important thing to realize is that the error must be handled appropriately for the task at hand, based upon the assumptions that have been made in the code.  

## Reporting Errors in PHP



PHP has two basic error reporting systems, Errors and Exceptions.  Errors are useful for incidental errors only, since they do not alter the request flow at all, and require string parsing to determine the cause of the error.  Errors which are not fatal do not alter the code flow in any way, nor do they directly indicate the mode of failure (which is what makes them suitable for incidental errors only).  There’s no clean programmatic way of determining the cause or type of the error (short of string parsing).  Unfortunately, the PHP core uses the error system for just about all errors.  


Exceptions on the other hand are only useful for exceptional errors (That’s an odd coincidence).  They do interrupt the processing flow and will cause the code to go into a special state where it looks for a handler to handle the exception (either a try/catch block, or an exception handler if it can’t find one).  But more importantly, the type of the exception that’s thrown can be tailored to the actual error that occurred. Thereby comes the power of the exception.  By tailoring the catch block(s), we can effectively declare what types of exceptions we want to handle.  If we used the base Exception class, all exceptions would be caught.  If we used a derived class InvalidArgumentException, we would only catch exceptions of that type (or any of its child classes, based on normal inheritance rules).

```php
try {
    foo();
} catch (InvalidArgumentException $e) {
    // Handle this case
} catch (FileNotFoundException $e) {
    // Handle this case separately
} catch (Exception $e) {
    // Handle all other exceptional errors
}
```


Now, remember that we talked about demoting exceptional errors to regular errors.  If we want to do that, we can change an exception into an error quite simply:

```php
try {
    foo();
} catch (SomeException $e) {
    trigger_error($e->getMessage(), E_USER_WARNING);
}
```

## Maintaining The Abstraction



We already talked about how the type of the error can change depending upon the abstraction level.  It’s also important to note that we should maintain the abstraction that we are currently working on.  This is also known as maintaining encapsulation, or the law of leaky abstractions.  To better understand this, let’s revisit the Table package (with the CSV parser) again.


To the CSV parser, a FileNotFoundException is quite meaningful since it’s internally dealing with filesystem interactions.  But to the table package, it’s an implementation detail that “leaks”.  If we had multiple “storage” classes (of which CSV was one), we’d then need to add multiple exception handlers for each possible type of storage malfunction (database error, network error, etc).  But if we look at it from the package level, we really don’t care exactly what failed.  We care about the type of failure that occurred.  So instead of having handlers for a FileNotFound error and one for a DatabaseTableNotFound error and one for a NetworkStorageTableNotFound error, we could abstract that to a generic TableNotFound error.  


So if you can’t handle the exceptional error, and you can’t demote the exceptional error to an incidental error (or no error), then you are left with two options.  Either leak the abstraction details and let the exception bubble up, or catch the exception and wrap it with a more generic exception that’s meaningful to the abstraction level above it.  So in the CSV parser case, inside the CSV parser, we might do something like this:

```php
try {
    $f = fopen(‘a file that doesnt exist’, ‘r’);
} catch (FileNotFoundException $e) {
    throw new TableNotFoundException(‘The table was not found’, 0, $e);
}
```


It’s important to note two things about doing this.  The abstraction is maintained, since we are no longer leaking the implementation details of the class.  But we’re also not losing information in the process.  When we throw the new exception, we also include the original exception.  Therefore if we later decide to demote the error to an incidental one, we still have information about the root cause of the error.

## Handling Errors In PHP



PHP does not include any system or method of actually handling errors that the core raises.  Let me say that again.  PHP does not include any method of actually handling errors that the core raises.  Should I say that again?  Handling core errors appropriately is not possible in PHP.


What PHP is very good at is logging and reporting on incidental errors.  Unfortunately that means that all errors thrown by PHP are automatically incidental errors.  There is no method for the vast majority of the PHP core to raise an exceptional error.  It’s up to you to determine if the incidental error is truly exceptional or not.


There are however a number of “hacky” solutions that we can implement to try to handle errors.  None of them is as good as if the core supported proper error handling, but we will make do with them (because we don’t have much of a choice).  

## Suppress Those Errors



Yes, I am talking about the oft-beloved [`**@**` operator](http://php.net/manual/en/language.operators.errorcontrol.php).  That’s a good way of dealing with errors, right?  Just silence them...?  Well, that’s not actually handling the error, it’s just preventing the error from being reported and logged.  But without knowing what the error was, it’s not possible to properly handle it.  Thanks to the track_errors setting and the `$php_errormsg` variable, we can tell what happened for non-fatal errors.  So the `@` operator doesn’t handle the error, but it will prevent the error from being logged and displayed.  Then it’s up to you to manually parse the error message to determine how to appropriately handle the error.


It’s very important to realize that the **@** operator will suppress all errors indiscriminately.  So if a fatal error is thrown by code that’s been silenced by the operator, all that will be shown to the user is a white screen and nothing will enter the logs.  This should never happen, so for that reason, avoid the `@` operator at all cost.

## Use an Error Handler



Error handlers are not built to handle errors.  They were designed to run whenever an error occurred, but there’s no way to programmatically change the execution to handle the error.  All it does is run a callback whenever an error (of any matching error_type) is raised.  This is quite useful for logging errors and reporting on them, but PHP is already good at that.  It’s important to realize that you can only have one error handler installed at a time.  So if you use a library that installs one, you can only either use their error handler, or install your own.  So, oddly enough, the error handler cannot actually handle an error (Well, that’s a partial lie).

## Use ErrorExceptions



ErrorExceptions make use of the error handler to throw exceptions whenever an error occurs (hence the lie).  The default ErrorException code in the docs does this indiscriminately, and as such **all** errors are converted into exceptions (even incidental errors).  All type information is lost by this conversion, so trying to actually handle errors is the same as with the error suppression operator (requiring string parsing in user-land code).


So ErrorExceptions allow us to start handling errors.  But it’s not really clean since we can’t leverage the type system in PHP to make our lives easier determining the cause of the error.  And further more it is indiscriminate at the errors that it converts.  So by using the default ErrorException method, we lose all our ability to log incidental errors.  Therefore we’ve just made sure that we need to take care of errors ourselves in entirety (not just handling them, but also logging and reporting as well).  That’s no good.

## Custom Error Exception Throwing



Another option we have is to use an error handler to try to string parse the error, and determine if it’s an exceptional error.  If it’s an exceptional error (for the low level abstraction level), throw an appropriately typed exception.  If it’s an incidental error, just return false so the default PHP error handler can handle the error.  This gives us the best of both worlds since we can handle exceptional errors in an appropriate manner, and we can log the incidental errors with almost no change to our code.  But it’s not a perfect solution for two reasons.  First, it requires string parsing (which is fragile and not exactly fast).  Second, since only one error handler can be installed, a library may overwrite it.  So by installing a 3pd library, it could break your otherwise working code...


I’ve whipped up an example of this kind of error handler up [on GitHub](https://github.com/ircmaxell/ErrorExceptions).  It’s not complete (it only covers about one third of the overall errors raised by the PHP core).  It’s not really production ready.  It’s more of an example of what you can do.  Initializing it is quite easy:

```php
require_once 'lib/ErrorExceptions/ErrorExceptions.php';
$handler = new ErrorExceptions\ErrorExceptions(E_ALL | E_DEPRECATED);
$handler->register();

```


So there’s two real examples to show what it can do:

```php
try {
    strpos('test', 'bar', 10);
} catch (Exception $e) {
    // Not executed, since it's an incidental error
    var_dump(get_class($e));
}
```


That shows it ignoring incidental errors, which would then generate a traditional error (E_WARNING in this case) which would be handled and logged by PHP’s default error handler.

```php
try {
    $f = fopen('bar.baz.biz', 'r');
} catch (FileNotFoundException $e) {
    // Caught it!
    $f = fopen(‘someotherfilethatexists’, ‘r’);
}
```


This is the real power of this method.  Now, we can check for errors, and handle them appropriately.


It’s worth noting that this code is not intended to be used in production (not now at least).  It’s merely meant to be a demonstration of the concept.  It uses a \*lot\* of regular expressions to determine the cause of the error.  So it’s not exactly the most efficient thing in the world.  It’s fast enough for most use cases, but it’s not great.

## The Best Solution



The best solution would be if the PHP core threw exceptions for exceptional errors instead of using the error reporting system.  Unfortunately, there seems to be a huge distaste from the core developers towards implementing exceptions in the core.  One of their arguments is that PHP is used by both procedural developers and OOP developers alike, and exceptions are an OOP concept.  I would argue that Exceptions may be more of a traditional OOP concept, but that’s no reason it can’t be used by a procedural language.  After all, C emulates exceptions with [setjmp/longjmp](http://en.wikipedia.org/wiki/Setjmp.h#Exception_handling)...  


Exceptions are a **`really`** powerful tool for handling exceptional errors.  They also can be abused quite easily.  They should not be feared for use with exceptional errors, but they should not be used for other types of errors.  They are reasonably easy to understand (at least compared to a lot of other concepts PHP developers need to learn - such as dynamic typing - they are easy).  I’d argue that they are significantly easier to understand than actually trying to handle errors with the default error system.  I’d rather see the core implement a system which works, rather than to stick with one that doesn’t because it’s easier to understand (or for other arcane reasons).
