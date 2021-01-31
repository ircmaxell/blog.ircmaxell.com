---
layout: post
title: PHP's Source Code For PHP Developers - Part 1 - The Structure
permalink: 2012/03/phps-source-code-for-php-developers.html
date: 2012-03-12
comments: true
categories:
- PHP
tags:
- Learning
- PHP
- PHP Source Code For PHP Developers Series
- PHP-Internals
- Programming
---

As a PHP developer, I find myself referencing PHP's source code more and more in my normal everyday work.  It's been very useful in everything from understanding what's happening behind the scenes to figuring out weird edge-cases to see why something that should be working isn't.  And it's also very useful in the cases when the documentation is either missing, incomplete or wrong.  So, I've decided to share what I've learned in a series of posts designed to give PHP developers enough knowledge to actually read the C source code behind PHP.  No prior knowledge of C should be necessary (we'll cover some of the basics), but it will help.

This is the first post of the series.  In this post, we'll walk through the basics of the PHP application: where to find it, the general structure of the codebase and a few really fundamental concepts about the C language.  To be clear, the goal of the series is to get a reading comprehension of the source code.  So that means that at some points in the series, some simplifications will be made to concepts to get the point across without over-complicating things.  It won't make a significant difference for reading, but if you're trying to write for the core, there is more that will be needed.  I'll try to point out these simplifications when I make them...  

Additionally, this series is going to be based off the 5.4 codebase.  The concepts should be pretty much the same from version to version, but this way there's a defined version that we're working against (to make it easier to follow later, when new versions come out).

So let's kick it off, shall we?<!--more-->

## Where To Find The PHP Source Code


The easiest way to download the source code is from [PHP's SVN repository](http://www.php.net/svn.php).  For our purposes, we'd check out the 5.4 branch.  This is great if you want to make a bleeding edge build of PHP, or want to actually develop for it (fixing bugs, implementing features, etc).  It's worth noting that the PHP community is currently (as of this writing) in process towards moving towards a GIT repository.  Once that's complete, I'll update this post to reference that fact.

The reality is that downloading the source code isn't really that useful for our purposes.  We don't want to edit it, we just want to use it and trace how calls are made.  We could download it, and load it into a good IDE, which would allow us to click around function definitions and the like, but I find that's a bit more difficult than it should be.  There has to be a better solution.

As it turns out, the PHP community maintains a **REALLY** good tool for our purposes.  It's know as [lxr.php.net](http://lxr.php.net/).  This basically is an auto-generated searchable listing of source code, that's also syntax highlighted and fully linked.  This is what I use almost exclusively for browsing the C source code, it's that good (even when I'm making patches, I still reference lxr instead of the codebase I'm working on).  We won't get into how to make effective use of search just yet, but we'll get to that in a later post when we talk about PHP core functions.

From here, we're going to talk about the PHP 5.4 version.  For those purposes, we'll use [this lxr link](http://lxr.php.net/xref/PHP_5_4/) as the basis for the rest of the post.  Any time I reference "`5.4's root`", that means this page.

So, now that we can view the source tree, let's start talking about what's there.

## PHP's Structure

So when you look at the file and directory listing in `5.4's root`, there's a lot going on there.  I want you to ignore everything with the exception of two directories: **ext **and **Zend**.  The rest of the files and directories are important for PHP's execution and development, but for our purposes we can ignore them completely.  So why are these two directories so important?

Well, the PHP application is split into, you guessed it, two main parts.  The first part is the Zend Engine, which powers the runtime environment that our PHP code runs in.  It handles all of the "language level" features that PHP provides, including: variables, statements, syntax parsing, code execution and error handling.  Without the engine, there would be no PHP.  The source code for the engine is located in the **Zend** directory.

The second part of PHP's core, are the extensions that are included with PHP.  These extensions include every single core function that we can call from PHP (such as `strpos`, `substr`, `array_diff`, `mysql_connect`, etc).  They also include core classes (`MySQLi`, `SplFixedArray`, `PDO`, etc).  

An easy way to determine where the functionality you want to look at lies in the core, is to look at the [main documentation](http://www.php.net/manual/en/) for PHP.  It is also split into two main sections (for our purposes), the [Language Reference](http://www.php.net/manual/en/langref.php) and the [Function Reference](http://www.php.net/manual/en/funcref.php).  As a gross overgeneralization, if what you're looking for is defined in the Language Reference, it's likely to be found in the **Zend** folder.  If it's in the Function reference, it's likely to be found in the **ext** folder.

## A Few Basic C Concepts

This section is not meant to be a primer to C, but a "readers companion guide".  So with that said:

### Variables

In C, variables are statically and strictly typed.  This means that before a variable can be used, it must first be defined with a type.  And once it's defined, you can't change its type (you can cast it to another later, but you  would have to use a different variable for that).  The reason for this is that in C, variables don't really exist.  They are just labels for memory addresses that we use for convenience. Because of that, C doesn't have references the way that PHP does.  Instead, it has pointers.  For our purposes, think of a pointer as nothing more than a variable that points to another variable.  Think of it like a variable variable in PHP.

So, with that said, let's talk about variable syntax.  C doesn't prefix its variables by anything.  So one way to tell the difference (for our purposes) is to look at the definition.  If you see a line at the top of the function (or in the signature of a function) with a type followed by a space, what follows is a variable.  One key point to make though is that the variable name can have one or more symbols before it.  The star (`\*`) symbol indicates the variable is a pointer to that type (a reference).  Two star symbols indicate the variable is a reference to a reference.  And three indicates the variable is a reference to a reference to a reference.

This indirection is important, since PHP internally uses double level pointers quite a bit.  That's because the engine needs to be able to pass blocks of data (PHP variables) around, and handle all sorts of fun things like PHP references, copy-on-write, and object references, etc.  So just realize that `\*\*ptr` just means that we're using two levels of reference (not referencing the value, but referencing a specific reference to the value).  It can become a little confusing, but if references are completely new to you, I'd suggest doing a bit of reading on the subject (although not necessary strictly to read C, which is our goal).  But it can help.

Now, one other important thing to understand about pointers is how they apply to arrays in C (not PHP arrays, but arrays in C variables).  Since a pointer is a memory address, we can declare an array by allocating a block of memory, and traversing it by incrementing the pointer.  In plain terms, we can use the C data type `char` which stands for a single character (8 bits) to store a single character of a string.  But we can also use it like an array to access later bytes in the string.  So, instead of having to store the whole string in a variable, we can just store a pointer to the first byte.  Then, we can increment the pointer (increment its memory address) to walk the string:

```c
char *foo = "test";
// foo is now a pointer to "t" in a memory segment that stores "test"
// To access "e", we could do any of the following:
char e = foo[1];
char e = *(foo + 1);
char e = *(++foo);
```

For additional reading on variables and pointers in C, check out this [excellent free book](http://home.netcom.com/~tjensen/ptr/pointers.htm).

### Pre-Processor Instructions

C uses a step called `pre-processing` prior to being compiled.  This allows for optimizations to be made, and code to be dynamically written depending on the options that you passed the compiler.  We're going to talk about two main pre-processor instructions: Conditionals and Macros.

Conditionals allow for code to be included in the compiled output or not based on definitions.  These normally look like the following example.  This allows for different code to be written for different operating systems (so that a function can function efficiently on both Windows and Linux, even though they have different APIs).  Additionally, it can allow for sections of code to be included or not based on a configuration directive.  In fact, this is internally how the `configure `step of compiling PHP works.

```c
#define FOO 1
#if FOO
    Foo is defined and not 0
#else
    Foo is not defined or is 0
#endif
#ifdef FOO
    Foo is defined
#else
    Foo is not defined
#endif
```

The other instruction I'm going to call Macros.  These are basically mini functions that allow for code simplification.  They aren't actually functions, but just simple text replacement that the pre-processor does prior to compilation.  For this reason, macros don't need to actually do any function calls.  You can write a macro for a function definition (PHP actually does this, but we'll get into that in a later post).  The point is that macros allow for simpler code that's resolved prior to compiling.

```c
#define FOO(a) ((a) + 1)
int b = FOO(1); // Converted to int b = 1 + 1

```

### Source Files

The final part that we should go over is the different types of files that the C source code uses.  There are two main files: **.c** and **.h**.  The **.c** files contain the source code that the file is supposed to be building.  In general, the **.c** file contains the private implementations of functions that are not shared across files.  The **.h** (or header) file defines which functions defined in the **.c** file should be seen by other files, as well as any pre-processor macros.  The way the header file determines the public API, is by re-stating the function signature without the body (similar to the way PHP treats interface and abstract methods).  This allows for source code to be `linked` together by nothing more than the header files.

### In The Next Part


In the next part of this series, we'll go into how internal functions are defined in C.  So you'll be able to take any internal function (such as `strlen`) and look up its definition and see what it's doing.  Stay tuned!


Questions?  Comments?  Snide Remarks?  Feel free to comment below, or use your favorite method of communication to make your point known!