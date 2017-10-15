---
layout: post
title: Tries and Lexers
permalink: tries-and-lexers
date: 2015-05-15
comments: true
categories:
tags:
- Data Structures
- Javascript
- Lexer
- Library
- Parser
- Performance
- PHP
- Programming
- Trie
---
Lately I have been playing around with a few experimental projects. The current one started when I tried to make a templating engine. Not just an ordinary one, but one that understood the context of a variable so it could encode/escape it properly. Imagine being able to put a variable in a JavaScript string in your template, and have the engine transparently encode it correctly for you. Awesome, right? Well, while doing it, I went down a rabbit hole. And it led to something far more awesome.

<!--more-->
So, while working on the templating engine, I needed to build a parser. Well, actually, I needed to build 4 parsers. One for HTML, one for templating markup, one for JavaScript and one for CSS. The JavaScript and the CSS parsers would be easier (or so I thought), since they are just standard parsers. But since HTML and template markup can be intermixed fully, neither could be parsed independently of the other. Meaning that I had to build a stateful pair of parsers that intertwined (switching back and forth on the input as the modes switched from HTML to templating syntax).

I decided to hand write this dual-mode parser. It went a lot easier than I expected. In a few hours, I had the prototype built which could fully parse Twig-style syntax (or a subset of it) including a more-or-less standards-compliant HTML parser. A lot easier than I expected.

Then I started building the JS parser. Rather than hand-write yet another parser, I decided to generate it using a parser generator (very similar to the one Nikita used in [PHP-Parser](https://github.com/nikic/PHP-Parser/tree/1.x/grammar)). After a little bit I had a parser generated. Awesome. But I ran into a problem. I didn't have a lexer...

## Lexers

A lexer is a tool that performs [Lexical Analysis](https://en.wikipedia.org/wiki/Lexical_analysis) on an input string. If you have heard the term "tokenization", it's the same process.

Basically, it's the process of turning an arbitrary string into a stream of structured "tokens". For example:

```php
result = 5 + 13;

```
Could be lexed into the following tokens:

```php
[T_IDENTIFIER, "result"]
[T_WHITESPACE, " "]
[T_EQUAL, "="]
[T_WHITESPACE, " "]
[T_NUMBER, "5"]
[T_PLUS, "+"]
[T_NUMBER, "13"]
[T_SEMICOLON, ";"]

```
Simple parsers can skip this step and simply parse directly off the input stream. But as parsers get more complicated, it becomes far easier to have a stand-alone lexer to convert the input stream into a token stream. Lexer generators exist for C (PHP internally uses [re2c](http://re2c.org/)), but I wasn't aware of any for PHP. So I decided to write one.

But how? C lexers operate efficiently because characters are integers (and hence can efficiently index into memory). PHP can't do that easily (not without function calls at least). So what other solution can exist?

## Trie Datastructure

Enter the [Trie](https://en.wikipedia.org/wiki/Trie). A Trie is a specific data structure that is used to represent a group of strings as a tree.

[![Trie](https://upload.wikimedia.org/wikipedia/commons/b/be/Trie_example.svg)](https://en.wikipedia.org/wiki/Trie)

So starting with a source string, we would simply walk down the trie for each character in our string until we can't go any further. If that node has a value (the number in the image above), then that's our token. If not, it means we encountered an unknown character (syntax error). Pretty simple.

Implementing it in PHP is quite straight forward:

```php
class Trie {
    public $data = [];
    public $value = false;
}

```
Now that we have the data structure, we need to fill it with our expected tokens. Let's say we have three tokens for simplicity sake.

```php
$tokens = [
    "apple" => "T_APPLE",
    "ape" => "T_APE",
    "cape" => "T_CAPE",
];

```
To populate the data structure, we just need to iterate over each character of each token, and build the tree:

```php
$root = new Trie;
foreach ($tokens as $name => $value) {
    $node = $root;
    // For each character in the string
    for ($i = 0; $i < strlen($name); $i++) {
        $char = $name[$i];
        if (!isset($node->data[$char])) {
            // If we don't have a child with that char
            // Create it
            $node->data[$char] = new Trie;
        }
        // Reset the node for the next character
        $node = $node->data[$char];
    }
    // Finally, set the value on the final node
    $node->value = $value;
}

```
It may not be clear how that works, or the structure it produces. So let's take a closer look at a `var_dump($root)`:

```php
object(Trie)#1 (2) {
    ["data"]=>
    array(2) {
        ["a"]=>
        object(Trie)#2 (2) {
            ["data"]=>
            array(1) {
                ["p"]=>
                object(Trie)#3 (2) {
                    ["data"]=>
                    array(2) {
                        ["p"]=>
                            Object(Trie)#4 (2)
                            /**snip**/
                    }
                }
                ["e"]=>
                object(Trie)#7 (2) {
                    "data"=>
                    array(0) {
                    }
                    ["value"]=>
                    string(5) "T_APE"
                }
            }
            ["value"]=>
            bool(false)
        }
        ["c"]=>
        object(Trie)#8 (2) {
            /**snip**/
        }
    }
    ["value"]=>
    bool(false)
}

```
That output may be a bit hard to read, so let's look at the trie in-action directly:

```php
// "ape" is a valid token, so we expect T_APE
var_dump($root->data['a']->data['p']->data['e']->value); // T_APE
// "ap" is not a valid token, so we expect false
var_dump($root->data['a']->data['p']->value); // bool(false)

```
So as you can see, it's a bit unwieldy, but it works.

Now all we need to do is automate the scanning of an input string:

```php
function lex($string, Trie $root) {
    $length = strlen($string);
    $i = 0;
    $tokens = [];
    $node = $root;
    $buffer = '';
    // We want to iterate over the entire string.
    while ($i < $length) {
        // Get the current character
        $char = $string[$i];
        if (isset($node->data[$char])) {
            // We have a valid next character
            $i++;
            // Save the character in the buffer
            $buffer .= $char;
            // Move to the next state
            $node = $node->data[$char];
        } elseif ($node->value) {
            // We have a value and no valid next character
            // Emit the token
            $tokens[] = [$node->value, $buffer];
            // Clear the buffer
            $buffer = '';
            // Reset back to the root for the next token
            $node = $root;
        } else {
            // We can't continue parsing this node
            throw new Exception("Syntax error at offset $i");
        }
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
And boom. We're done.

Now all we need to do is generate the Trie with our production data, and we have a fully functional lexer.

Production data...

Yeah...

## Javascript Tokens

The problem that I ran into was that JavaScript has a non-trivial amount of tokens. But the real problem is the regular expressions. For example, Numbers can be defined in a lot of ways:

```php
/0[xX][0-9a-fA-F]+/
/\.[0-9]+/
/\.[0-9]+[eE][0-9]+/
/\.[0-9]+[eE][+-][0-9]+/
/0/
/[1-9][0-9]*/
/0[eE][0-9]+/
/[1-9][0-9]*[eE][0-9]+/
/0[eE][+-][0-9]+/
/[1-9][0-9]*[eE][+-][0-9]+/
/0\.[0-9]+/
/[1-9][0-9]*\.[0-9]+/
/0\.[0-9]+[eE][0-9]+/
/[1-9][0-9]*\.[0-9]+[eE][0-9]+/
/0\.[0-9]+[eE][+-][0-9]+/
/[1-9][0-9]*\.[0-9]+[eE][+-][0-9]+/

```
The regular expressions aren't *that* hard to compile. Actually, the ones here are quite easy. The basic concept is the same as compiling a normal string into the trie. The difference is that instead of each step creating a single node for the next step to use, it can create an array of them. The actual parsing is a bit tedious, so I won't include that here for now, but suffice it to say that it generates a lot of data.

And by a lot, I mean gigabytes. The JavaScript lexer took over 5 minutes to generate using regular expressions. It wound up consuming about 2.5GB of RAM.

Once it was generated, it was quite fast. It could lex a large string (jQuery source) about 5x faster than a single call to `preg_match_all()` with a lexer regular expression:

```php
(\G(?:(\<\=)|(\>\=)|(\=\=\=)|(\!\=\=)|(\=\=)|(\!\=)|(\+\+)|(\-\-)|(\>\>\>\=)|(\>\>\=)|(\<\<\=)|(\>\>\>)|(\>\>)|(\<\<)|(&&)|(\|\|)|(\+\=)|(\-\=)|(\*\=)|(%\=)|(&\=)|(\|\=)|(\^\=)|(/\=)|([\r\n\x{2028}\x{2029}])|([\x09\x0b\x0c\x20\xa0\p{Z}]+)|(/\*[\s\S]*?\*/)|(//[\s\S]*?[\r\n\x{2028}\x{2029}])|((?:0[xX][0-9a-fA-F]+|\.[0-9]+(?:[eE][-+]?[0-9]+)?|(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][-+]?[0-9]+)?)(?![\\pLu\\pLl\\pLt\\pLm\\pLo\\pNl$_]|\\\\u[a-fA-F0-9]{4}))|((?:[\pLu\pLl\pLt\pLm\pLo\pNl$_]|\\u[a-fA-F0-9]{4})(?:[\pLu\pLl\pLt\pLm\pLo\pNl$_]|\\u[a-fA-F0-9]{4}|[\pMn\pMc]|[\pNd]|[\x{005f}\x{203F}\x{2040}\x{2054}\x{fe33}\x{fe34}\x{fe4d}\x{fe4e}\x{fe4f}\x{ff3f}]|[\x{200c}\x{200d}])*)|("(?:[^\\"\r\n\x{2028}\x{2029}]|\\(?:['"\\bfnrtv]|[\r\n\x{2028}\x{2029}]|0(?![0-9])|x[a-fA-F0-9]{2}|u[a-fA-F0-9]{4}))*"|'(?:[^\\'\r\n\x{2028}\x{2029}]|\\(?:['"\\bfnrtv][^\\\r\n\x{2028}\x{2029}]|[\r\n\x{2028}\x{2029}]|0(?![0-9])|x[a-fA-F0-9]{2}|u[a-fA-F0-9]{4}))*')|(/(?:[^\r\n\x{2028}\x{2029}*\\/\[]|\\[^\r\n\x{2028}\x{2029}]|\[(?:[^\r\n\x{2028}\x{2029}\]\\]|\\[^\r\n\x{2028}\x{2029}])+\])(?:[^\r\n\x{2028}\x{2029}\\/\[]|\\[^\r\n\x{2028}\x{2029}]|\[(?:[^\r\n\x{2028}\x{2029}\]\\]|\\[^\r\n\x{2028}\x{2029}])+\])*/(?:[\pLu\pLl\pLt\pLm\pLo\pNl$_]|\\u[a-fA-F0-9]{4}|[\pMn\pMc]|[\pNd]|[\x{005f}\x{203F}\x{2040}\x{2054}\x{fe33}\x{fe34}\x{fe4d}\x{fe4e}\x{fe4f}\x{ff3f}]|[\x{200c}\x{200d}])*)|(\{|\}|\(|\)|\[|\]|\.|;|,|\<|\>|\+|\-|\*|%|&|\||\^|\!|~|\?|\:|\=|/)))ux

```
That regex will completely tokenize JavaScript (each match is precisely one token, with the capture group that matched identifying the regex). And no, I didn't hand-write this, I generated it.

## So now I had a problem

I had a lexer that ran *extremely* fast. But it also took an completely insane amount of memory and a completely unreasonable amount of time to actually load.

So I tried a few things. Rather than building the objects directly each time, what if I compile it out to classes. So our "T_APPLE" example from above could look like this:

```php
class S {
    public static $objects = [];
    public function load($class) {
        if (!isset(self::$objects[$class])) {
            self::$objects[$class] = new $class;
            // separate to allow recursive dependencies
            self::$objects[$class]->load();
        }
        return self::$objects[$class];
    }
}
class S0 {
    public $value = false;
    public $a;
    public $c;
    public function load() {
        $this->a = S::load(S1::class);
        $this->c = S::load(S7::class);
    }
}
class S1 {
    public $value = false;
    public $p;
    public function load() {
        $this->p = S::load(S2::class);
    }
}
class S2 {
    public $value = false;
    public $p;
    public $e;
    public function load() {
        $this->p = S::load(S3::class);
        $this->e = S::load(S4::class);
    }
}
/*snip*/
class S4 {
    public $value = "T_APE";
    public function load() {}
}
/*snip*/

```
The benefit here, is that the building phase happens at compile time. The drawback, is that it's still a ton of memory.

Generating the JavaScript lexer took 250,000 classes, 2.5GB of memory for PHP to compile the file, and another 2GB of memory to instantiate the objects.

But once running, it was extremely fast. About 2x faster than the Trie approach (so 10x faster than a single preg_match call).

## What's Next

A this point, I had an idea. Since most HTTP routers in PHP use preg_match() to actually execute the route, I wondered if this approach could build a faster router.

I just needed to solve the problem of memory. If I could get the memory usage down to under 10mb (or less) without sacrificing too much runtime performance, I would have a real contender for the fastest router out there.

So I started experimenting. But more on that next week...




