---
layout: post
title: Prefix Trees and Parsers
permalink: 2015/05/prefix-trees-and-parsers.html
date: 2015-05-18
comments: true
categories:
- Programming
tags:
- Data Structures
- Lexer
- Parser
- Performance
- PHP
- Radix Tree
- Routing
- Trie
---
In my [last post, *Tries and Lexers*](http://blog.ircmaxell.com/2015/05/tries-and-lexers.html), I talked about an experiment I was doing related to parsing of JavaScript code. By the end of the post I had shifted to wanting to build a HTTP router using the techniques that I learned. Let's continue where we left off...

<!--more-->
## Lexing HTTP Routes

My first idea was to actually lex and parse routes just like we do with programming languages. I already had a lexer infrastructure built (Using the Trie based approach), so why not use it?

I wrote some glue code to parse a set of routes into components, then generate a set of lexer tokens and parser rules out of it. I started with a few routes (3) just to see how things went:

```php
$routes = [
    "/user/{name}" => "User::findByName",
    "/user/{name}/{id:[0-9]+}" => "User::findByNameAndId",
    "/post/{name}" => "Post::findByName",
];
```

I parsed these routes, and produced a series of tokens:

```php
$tokens = [
    T_USER => "user",
    T_POST => "post",
    T_NUMBER => "[0-9]+",
    T_SLASH => "/",
    T_ANY =>"[^/]",
];
```

I also then generated a series of parser rules:

```php
$parserRules = [
    [[T_SLASH, T_USER, T_SLASH, T_ANY], "User::findByName"],
    [[T_SLASH, T_USER, T_SLASH, T_ANY, T_SLASH, T_NUMBER], "User::findByNameAndId"],
    [[T_SLASH, T_POST, T_SLASH, T_ANY], "Post::findByName"],
];
```

It should be easy to see how that works. It makes our parser behave exactly like our lexer. Which means we can re-use code! Yay!

```php
$parser = new Trie;
foreach ($parserRules as $rule) {
    $node = $parser;
    foreach ($rule[0] as $token) {
        if (!isset($node->data[$token])) {
            $node->data[$token] = new Trie;
        }
        // Reset the node for the next character
        $node = $node->data[$token];
    }
    $node->value = $rule[1];
}
```

Now, we can parse easily:

```php
function parse(array $tokens, Trie $root) {
    $length = count($tokens);
    $i = 0;
    $node = $root;
    // We want to iterate over the entire string.
    while ($i < $length) {
        // Get the current character
        $token = $tokens[$i];
        if (isset($node->data[$token])) {
            // We have a valid next token
            $i++;
            // Move to the next state
            $node = $node->data[$token];
        } else {
            // We can't continue parsing this node
            // Since the URL must terminate with a single
            // parsed result, we return false;
            return false;
        }
    }
    return $node->value;
}
```

And that's how we do that.

So, we generate a lexer as before, and now with our generated parser, our router becomes:

```php
public function route($url) {
    $tokens = lex($url, $this->lexerRoot);
    return parse($tokens, $this->parserRoot);
}
```

We still have the same loading problem as before, though to not as severe of a degree. Performance is pretty good, about 2-3x slower than preg_match.

Using the 3 routes, this takes a few hundred kilobytes for the structures. Well within reason.

Then I tried compiling a list of 163 routes that I got on the internet. And we're back to 3gb of data. Not good.

## Changing the Lexer Behavior

So the problem was there were just too many states to the lexer. Each character resulted in a new state. Meaning that a regex like `[^/]` resulted in 255 new states. It just multiplied from there.

How do we solve this problem? Well, I decided to optimize the "default" case of `[^/]`. So I did two things. First, I added a member to the Trie implementation called "default":

```php
class Trie {
    public $data = [];
    public $value = false;
    public $default = false;
}
```

If the current character isn't in the `$data` array, then check to see if there's a default value. If there is, treat it like a match.

This cut down the size of the data structure dramatically. Instead of generating 3gb of data, we only generated about 100mb.

But 100mb is still way too much. What else could we do? Well, I decided to move away from the CPU-optimal Trie structure for the more Memory conservative minimal [RadixTree](https://en.wikipedia.org/wiki/Radix_tree).

The class looks very similar:

```php
class Radix {
    public $length = 0;
    public $data = [];
    public $value = false;
    public $default = false;
}
```

But now we have this new "length" property. It stores the length of the *longest* subkey. Let's look at a simple example, "apple" and "ape".

```php
$root = new Radix;
$root->data["ap"] = new Radix;
$root->data["ap"]->data["e"] = new Radix;
$root->data["ap"]->data["e"]->value = "T_APE";
$root->data["ap"]->data["ple"] = new Radix;
$root->data["ap"]->data["ple"]->value = "T_APPPLE";
$root->data["ap"]->length = 3; // strlen("ple")
$root->length = 2;
```

In other words, we now have a tree using the longest common prefix for the children.

Implementing this is a bit more tricky, since insertion requires checking of the prefix. So let's actually make that a method on the class:

```php
public function add(Radix $child, $key) {
    if (isset($this->data[$key])) {
        throw new \Exception("Already exists");
    }
    foreach ($this->data as $subkey => $subchild) {
        // get the length of the common part of the key
        $common = strspn($key ^ $subkey, "\0");
        if ($common !== 0) {
            if ($common === strlen($key)) {
                // the key is a proper prefix of the existing one
                unset($this->data[$subkey]);
                $this->data[$key] = $child;
                $child->add($subchild, substr($subkey, $common));
                // stored key length changed, rebuild it
                $this->rebuildLength();
                return;
            } elseif ($common === strlen($subkey)) {
                // the subkey is a proper prefix of the new one
                $subchild->add($child, substr($subkey, $common));
                return;
            }
            // there's a shared prefix, create a new radix
            unset($this->data[$subkey]);
            $radix = new Radix;
            $this->data[substr($key, 0, $common)] = $radix;
            $radix->add($subchild, substr($subkey, $common));
            $radix->add($child, substr($key, $common));
            $this->rebuildLength();
            return;
        }
    }
    $this->data[$key] = $child;
    $this->rebuildLength();
}

protected function rebuildLength() {
    $this->length = array_reduce(
        array_map("strlen", array_keys($this->data)),
        "max",
        0
    );
}
```

Combined with our "default" case, we now can pack using FAR less objects.

In terms of memory, this brings us down quite a bit. Instead of using 100mb, we're down to about 5mb.

However, this comes at a cost. Because the keys at each stage are variable length, we need to increase the complexity of runtime. Now we need to always read ahead `$length` characters prior to taking the `$default` path. This drastically increases runtime to about 5x slower than preg_match. Here's a sample implementation:

```php
function lex($string, Radix $root) {
    $length = strlen($string);
    $i = -1; // start negative
    $tokens = [];
    $node = $root;
    $buffer = '';
    $c = '';
    $cl = 0;
    // We want to iterate over the entire string.
    while ($i + 1 < $length) {
        // Append the current character to the character buffer
        $c .= $string[++$i];
        if (isset($node->data[$c])) {
            // Save the character in the buffer
            $buffer .= $c;
            // reset the character buffer
            $c = '';
            $cl = 0;
            // Move to the next state
            $node = $node->data[$c];
        } elseif ($cl > $node->length || $i + 1 >= $length) {
            if ($node->default) {
                // We have a default, so eat the first character
                $buffer .= $c[0];
                $i -= $cl;
                $c = '';
                $cl = 0;
                $node = $node->default;
            } elseif ($node->value) {
                // We have a value and no valid next character
                // Emit the token
                $tokens[] = [$node->value, $buffer];
                // Clear the buffer
                $buffer = '';
                // Reset back to the root for the next token
                $node = $root;
                $i -= $cl + 1;
                $cl = 0;
                $c = '';
            } else {
                throw new Exception("Syntax error at offset $i");
            }
        }
    }
    if ($cl !== 0) {
        // no buffer and an over-read, shouldn't happen
        throw new Exception("Syntax error at offset $i");
    }
    if ($buffer !== '') {
        // We finished without flushing one token
        if ($node->value) {
            $tokens[] = [$node->value, $buffer];
        } else {
            // Not a valid complete token
            throw new Exception("Syntax error at offset $i");
        }
    }
    return $tokens;
}
```

Pretty straight forward, but a few little gotcha's in there.

Overall, pretty fast, but not nearly as fast as I think it could be. So I decided to go a step further.

What if, instead of descending the `Radix` at runtime, I precompiled it to PHP code. As a series of switches and gotos. Surely that would be faster... Right?

## Code Generation

The next step I took was to generate out the code into a series of switches. Being smart, I decided to group the keys of like length together. Something like the following for tokens "apple" and "ape":

```php
$len = strlen($string);
$tokens = [];
$i = -1;

restart:
    $c = '';
    $cl = 0;
    $buffer = '';
    $token = false;
    if ($i >= $len - 1) {
        return $tokens;
    }
lex1:
    while ($i < $len -1 && $cl < 2) {
        $c .= $string[++$i];
        $cl++;
    }
    switch ($c) {
        case "ap":
            $buffer .= $c;
            $c = '';
            $cl = 0;
            goto lex2;
    }
    goto fail;

lex2:
    while ($i < $len -1 && $cl < 1) {
        $c .= $string[++$i];
        $cl++;
    }
    switch ($c) {
        case "e":
            $buffer .= $c;
            $token = ["T_APE", $buffer];
            goto emitToken;
    }
    while ($i < $len -1 && $cl < 3) {
        $c .= $string[++$i];
        $cl++;
    }
    switch ($c) {
        case "ple":
            $buffer .= $c;
            $token = ["T_APPLE", $buffer];
            goto emitToken;
    }
    goto fail;

emitToken:
    $tokens[] = $token;
    goto restart;
```

This is pretty verbose, but you should get the idea. This is a pretty simple example of a [Finite State Machine](https://en.wikipedia.org/wiki/Finite-state_machine). Basically, at each state, we can do one of a few things: read more data or switch states. There's a little bit more this does (such as saving additional metadata), but the foundations are the same as any FSM.

The cool thing is that this is **fast**. We cut our execution time from approximately 5x of preg_match, down to about even with it. But we're back to generating about 100mb of source code... Not great...

## Idea

We're generating a lot of data because we're actually lexing the code. This makes the parser **way** more efficient, but lexers are expensive.

What if we could skip the lexer step.

What if we could somehow turn the URL into a list of tokens without lexing...

Wait a minute. Each rule cannot have a "/" in it (otherwise it would be parsed into 2 rules). So why not just explode on "/"???

```php
$tokens = explode("/", $url);
```

Could this work?

It would complicate our parser slightly, but in the end it shouldn't matter too much since we'd be saving a lot on the lexer.

Let's try it.

```php
$parserRules = [
    [["user", "[^/]+"], "User::findByName"],
    [["user", "[^/]+", "[0-9]+"], "User::findByNameAndId"],
    [["post", "[^/]+"], "Post::findByName"],
];
```

Using our new minimal radix tree, the only thing left to work out is the regular expression match. Using the old way, we can treat it just like the Trie and generate valid children and circular references to implement +. Doing that yields us a parser that's fairly small, weighing in about 2mb for our large route file. This is small enough to be useful in production.

Benchmarking the in-memory router, it turns out that it's about as fast as a preg_match based approach. So our router is about equal in speed to FastRoute once built. Building it takes about 50ms, so still not perfect there (but reasonable). But we have three more tricks up our sleeves that we can pull out.

We could try compiling this tree into raw PHP just like we did with the lexer. And we can severely optimize the generated code, minimizing the state jumps to the absolute minimum needed. And there's one more trick that we can pull out...

But more on that later...




