---
layout: post
title: To Comment Or Not To Comment - A Tale Of Two Stories
permalink: 2012/06/to-comment-or-not-to-comment-tale-of.html
date: 2012-06-05
comments: true
categories:
- Rant
tags:
- Best Practice
- Comments
- Good Enough
- Language Agnostic
- PHP
- Programming
- Rant
---

A few weeks ago I was sparked into a twitter conversation with Larry Garfield ([@Crell](https://twitter.com/#!/Crell)) about the value of comments in code. Really, twitter is not the best place for that conversation, so I decided to write this post to illustrate my beliefs on commenting. Let's start this story with the tweet from Larry that set off the conversation:

> Nothing drives home the need for good code comments like working on code that doesn't have them.

A pretty innocuous comment that is quite insightful. But that led me to respond with:

> Nothing drives home the value of good, clean code by working on code that doesn't need comments.


That led to an interesting discussion that just couldn't fit on twitter. So let me explain...

<!--more-->

## What Are Comments?

Let's start off by talking about a few different types of comments (yes, there are multiple types). When most people talk about comments, they are referring to anything within a comment block in code (ignored by the interpreter/compiler). That's not what I'm talking about. Let's break apart the different types of these comment blocks to indicate more of what I mean... 

 * **DocBlocks** - These are the bits of documentation before a function, method or class. They usually document parameters, behavior and other non-code level information. The only code-level information that is usually present are those that the language is not capable of describing (for PHP, this can be scalar parameters, return types, what exceptions are thrown, etc).

 * **Comments** - These are bits of inline information within code used to provide additional information or clarity that the code is not capable of describing.

 * **Legal Information** - These are the blocks at the top of most open source files indicating the copyright of the file, what license it's under, etc.

What we're discussing here are comments. Realistically, there are two types of information that a comment (this definition) can provide: 

 * **What** - What is the code doing. What is its purpose. What short-cuts were made. How does it fit in the larger picture. How does it work.
 * **Why** - Why is the code written like this. Why does it look the way it does. Why didn't we do it another way. For example: [this comment](https://github.com/ircmaxell/PHP-CryptLib/blob/master/lib/CryptLib/Random/Generator.php#L113):

    ```php
    $mask  = (int) (pow(2, $bits) - 1);
    /**
     * The mask is a better way of dropping unused bits.
     * Basically what it does is to set all the bits in
     * the mask to 1 that we may need.  Since the max
     * range is PHP_INT_MAX, we will never need negative
     * numbers (which would have the MSB set on the max 
     * int possible to generate).  Therefore we can just
     * mask that away.  Since pow returns a float, we
     * need to cast it back to an int so the mask will
     * work.
     *
     * On a 64 bit platform, that means that PHP_INT_MAX
     * is 2^63 - 1.  Which is also the mask if 63 bits 
     * are needed (by the log(range, 2) call). So if the
     * computed result is negative (meaning the 64th bit
     * is set), the mask will correct that.
     *
     * This turns out to be slightly better than the
     * shift as we don't need to worry about "fixing"
     * negative values.
     */
    ```

In other words, **What** comments describe the code itself at its abstraction level. **Why** comments describe the code above its abstraction level.## The Good, The Bad, The Ugly


A bad comment is infinitely worse than no comment. So what makes a bad comment? Well, it's actually pretty easy to discern. A bad comment talks about what the code is doing. Why is that bad? Well, it's simple. The code itself talks about what it's doing. So now you have two things that try to tell the same story. And often times, they will not agree 100%. When they don't agree, which one is correct? The code. Code never lies. Since it never lies, I ignore comments about the code, and just read the code. So if I have to ignore the comment to learn what the code is doing, it's a bad comment. Take for example:

```php
function foo($bar, $baz) {
    $result = array();
    foreach ($bar as $value) {
        foreach ($baz as $value) {
            // Compute a result array with
            // The values of baz and bar mixed
            $result[] = $value;
        }
    }
```

Now a lot of people will say that what if the code and the comments do agree 100%? Then it's ok, right? Well, no... As it turns out, for any non-trivial project with multiple developers, comments will get out of sync with the code it's intended to describe. Someone will come in and fix a bug and invalidate the comment without realizing it. It happens. And when it happens, the comment becomes useless.

So I have a rule that I follow almost religiously. I do not write **What** comments. If I find that my code is in need of a **What** comment to understand it, it's an indicator that my code needs refactoring. So I refactor to eliminate the need for the comment. Why? Because code is read way more than it's written. So taking the time to refactor and make it easier to read will pay huge dividends down the road for maintainability. Therefore, if **What** comments are needed, it's a sign that something else is wrong with your code...

Now, I'm a huge believer in [Good Enough](http://blog.ircmaxell.com/2011/03/difference-between-good-and-good-enough.html), so at some point you have to say it's ok as is. At that point, I look at the code and decide if a comment is needed, and if so, I put one in. But I use that comment as a last resort, not as a first rule.## Surely There Are Exceptions!

Of course there are exceptions. Here are just a few cases when **What** comments are completely justified: 

 * When your code uses language edge-cases and relies upon behavior that's not well known. Such as [this comment](https://github.com/ircmaxell/PHP-CryptLib/blob/master/lib/CryptLib/Random/Generator.php#L99):

    ```php
    } elseif ($range > PHP_INT_MAX || is_float($range)) {
        /**
         * This works, because PHP will auto-convert it to a 
         * float at this point, But on 64 bit systems, the
         * float won't have enough precision to actually
         * store the difference, so we need to check if it's
         * a float and hence auto-converted...
         */
        throw new \RangeException(
            'The supplied range is too great to generate'
        );
    }
    ```

 * When you're interfacing with code you can't refactor (such as a 3pd library) that forces you to do odd behavior. Although in this case you may want to isolate that code to an [Adapter pattern](http://sourcemaking.com/design_patterns/adapter).
 * When you optimize a piece of code (at the right time).
 * When working on legacy code without them (adding them to help future developers)

## Conclusion

Focus on writing clean code. Focus on commenting about **Why** your code does what it does. Only ever comment **What** as a last resort when all of your other options are exhausted. That's my take on it at least...

What are your thoughts? Follow up in a comment, on Twitter or in a blog post of your own!