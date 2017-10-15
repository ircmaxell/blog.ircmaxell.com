---
layout: post
title: Security Issue: Combining Bcrypt With Other Hash Functions
permalink: security-issue-combining-bcrypt-with
date: 2015-03-12
comments: true
categories:
tags:
- BCrypt
- Best Practice
- Cryptography
- Password-Hashing
- PHP
- Security
---
The other day, I was directed at an interesting [question on StackOverflow](http://stackoverflow.com/q/28951359/338665) asking if `password_verify()` was safe against DoS attacks using extremely long passwords. Many hashing algorithms depend on the amount of data fed into them, which affects their runtime. This can lead to a DoS attack where an attacker can provide an exceedingly long password and tie up computer resources. It's a really good question to ask of Bcrypt (and `password_hash`). As you may know, Bcrypt is limited to 72 character passwords. So on the surface it looks like it shouldn't be vulnerable. But I chose to dig in further to be sure. What I found surprised me.

<!--more-->
## crypt.c

To start off, I looked at PHP's implementation of [`crypt()`](http://lxr.php.net/xref/PHP_TRUNK/ext/standard/crypt.c#154). The function we're interested in is called `php_crypt()`, and has the following signature:

```php
PHPAPI zend_string *php_crypt(const char *password, const int pass_len, const char *salt, int salt_len)

```
Now, check out the branch that does bcrypt:

```php
} else if (
        salt[0] == '$' &&
        salt[1] == '2' &&
        salt[3] == '$') {
    char output[PHP_MAX_SALT_LEN + 1];

    memset(output, 0, PHP_MAX_SALT_LEN + 1);

    crypt_res = php_crypt_blowfish_rn(password, salt, output, sizeof(output));
    if (!crypt_res) {
        ZEND_SECURE_ZERO(output, PHP_MAX_SALT_LEN + 1);
        return NULL;
    } else {
        result = zend_string_init(output, strlen(output), 0);
        ZEND_SECURE_ZERO(output, PHP_MAX_SALT_LEN + 1);
        return result;
    }
}

```
Notice anything? The `password` variable is a `char\*`. So `php_crypt_blowfish_rn()` doesn't know the length of the input password. Interesting. So I wonder how it knows the length? Well, at this point I have an idea, but I'm also scared by it...

So digging through `php_crypt_blowfish_rn()`, I notice that the only place the passsword (now called `key`) is sent is the function [`BF_set_key()`](http://lxr.php.net/xref/PHP_TRUNK/ext/standard/crypt_blowfish.c#BF_set_key). There's a bunch of comments about sign safety and mode switches, but the bulk of it boils down to this pair of nested loops (comments stripped out):

```php
const char *ptr = key;
/* ...snip... */
for (i = 0; i < BF_N + 2; i++) {
    tmp[0] = tmp[1] = 0;
    for (j = 0; j < 4; j++) {
        tmp[0] <<= 8;
        tmp[0] |= (unsigned char)*ptr; /* correct */
        tmp[1] <<= 8;
        tmp[1] |= (BF_word_signed)(signed char)*ptr; /* bug */
        if (j)
            sign |= tmp[1] & 0x80;
        if (!*ptr)
            ptr = key;
        else
            ptr++;
    }
    diff |= tmp[0] ^ tmp[1]; /* Non-zero on any differences */

    expanded[i] = tmp[bug];
    initial[i] = BF_init_state.P[i] ^ tmp[bug];
}

```
If you're not familiar with C, `\*` dereferences a pointer (returns the value it points to). So if we define `char \*abc = "abc"`, then `\*abc` would be `'a'` (well, technically, the numeric value of the codepoint of `'a'`). So then you can increment the pointer `abc++` and then `\*abc` would equal `'b`'. This is the standard way that "strings" work in C.

The loops basically iterate 72 times (`BF_N` is 16) and "eats" one byte of the string each iteration.

The key point here is the following line of code:

```php
if (!*ptr)
    ptr = key;
else
    ptr++;

```
Basically, if `\*ptr` is ever `0`, then reset it to the start of the string. This is how strings shorter than 72 characters are represented (since a "c-string" always ends with a null byte).

Think about that for a second. That means that `"test\0abc"` would be treated as `"test\0test\0test\0test\0test\0test\0test\0test\0test\0test\0test\0test\0test\0test\0te"`. In fact, every string that starts with `"test\0"` will be treated the same.

Basically, it ignores everything after the first null byte.

See the problem?

Nobody really uses null bytes in passwords anyway. So this isn't a problem. Right?

No, in fact, this is by-design. And it's not an issue because nobody uses passwords with null bytes.

So if you use `password_hash()` or `crypt()` directly, you're 100% safe.

But what if you're not using them directly? What if you're "pre-hashing"? Well, then you have a MAJOR problem...

## The Major Problem

Some people think bcrypt isn't enough, and instead choose to "pre-hash" passwords. This allows users to use passwords longer than 72 characters. Something like:

```php
password_hash(hash('sha256', $password, true), PASSWORD_DEFAULT)

```
Additionally, some people want to use a "pepper", so they pre-hash using a HMAC with a private key:

```php
password_hash(hash_hmac('sha256', $password, $key, true), PASSWORD_DEFAULT)

```
The problem here is the last argument to the two hash functions: `true`. They force raw output. This is normally how cryptographic functions are combined (using raw output rather than encoded output). And given that you can lose entropy from a sha512 by truncating it from 128 characters to 72, using raw output preserves some entropy.

But this means that the output can contain null bytes. In fact, it means that on average 1 out of every 256 passwords (or `0.39%`) will have a leading null byte. So we only need to try approximately 177 passwords to get a 50% chance of finding a hash with a leading null byte. And we only need to try approximately 177 users to get a 50% chance of finding a user with a leading null byte. So trying 31329 permutations of users and passwords gives us a 25% chance of finding one that will work. That's in the realm of possibility for online attacks (via distributed means).

This is **bad**. This is **really bad**.

Let's show an example of how we can find these collisions:

```php
$key = "algjhsdiouahwergoiuawhgiouaehnrgzdfgb23523";
$hash_function = "sha256";
$i = 0;
$found = [];

while (count($found) < 2) {
    $pw = base64_encode(str_repeat($i, 5));
    $hash = hash_hmac($hash_function, $pw, $key, true);
    if ($hash[0] === "\0") {
        $found[] = $pw;
    }
    $i++;
}

var_dump($i, $found);

```
I picked a random key. Then I made a "random" looking password (encoding the iteration count). Then I let it run. This is a stupid simple generator to generate these collisions (not even efficient). When I ran it, I got the following output:

```php
int(523)
array(2) {
  [0]=>
  string(16) "MzEzMTMxMzEzMQ=="
  [1]=>
  string(20) "NTIyNTIyNTIyNTIyNTIy"
}

```
Which means for that key, we found 2 colliding passwords in 523 attempts. The attempt number will change with different keys.

So let's try that out:

```php
$hash = password_hash(hash_hmac("sha256", $found[0], $key, true), PASSWORD_BCRYPT);

var_dump(password_verify(hash_hmac("sha256", $found[1], $key, true), $hash));

```
And we get:

```php
bool(true)

```
Amazing. Different passwords validate to the same hash.

## Detecting Problematic Hashes

Offline, there's a simple check to see if a given hash was created with a leading null byte:

```php
password_verify("\0", $hash)

```
Testing our hash from above:

> $2y$10$2ECy/U3F/NSvAjMcuBeI6uMDmJlI8t8ux0pXOAoajpv2hSH0veOMi

Gives us `bool(true)`. Which tells us it was created with a null byte as the first character.

So in an offline mode, it's trivial to detect these hashes.

But even if none of the hashes were created with leading null bytes, it doesn't mean you're safe (assuming you are using raw hashes). The reason is the same thing happens if the 2nd character was null:

```php
a\0bc
a\0cd
a\0ef

```
Will all collide as well. So you have a `0.39%` chance of colliding at the second character for each given first character. So of all the hashes that start with `a`, a given hash has a `0.39%` chance of having a null byte as the second character. Meaning that there's significantly less work to find this collision than to find a full-hash collision.

The problem goes all the way down the line.

## But I use CRYPT_SHA256!

Well, looking at [`php_crypt()`](http://lxr.php.net/xref/PHP_TRUNK/ext/standard/crypt.c#154), we can see that all of the `crypt()` options exibt this behavior. It's not really centralized around bcrypt (nor is it centralized around PHP, the `crypt(3)` c library itself has this same issue).

I talked about bcrypt in this post mainly because that's what `password_hash()` uses, and it's the current recommended algorithm in PHP.

Note that if you use `hash_pbkdf2()`, it's not susceptible to this issue. And if you use [scrypt](https://github.com/DomBlack/php-scrypt) you're fine as well.

## The Fix

The problem here isn't with bcrypt itself. It's with the combination of bcrypt and other crypto in an unsafe manner. It turns out that not all combinations are unsafe. In fact, [Mozilla's system](https://blog.mozilla.org/webdev/2012/06/08/lets-talk-about-password-storage/), which is basically `password_hash(base64_encode(hash_hmac("sha512", $password, $key, true)), PASSWORD_BCRYPT)`, is safe because it base64 encodes the raw salt. Additionally, you're safe if you use hex output of the hash/hmac (the final parameter `false`, which is the default).

You are 100% safe if you do one of the following:

 * Use straight `bcrypt` (don't pre-hash)
 * Use hex output from the pre-hash
 * Base64 encode the raw output of a pre-hash
If you are using raw output, encode it first, and you're safe.

## The Underlying Problem

The underlying problem is that combining cryptographic operators that weren't designed to be combined can be disastrous. Is it possible to do so safely? Yes. Is it a good idea to do it? No. This particular case is just one example where combining operations can be exceedingly dangerous.

Instead, just use algorithms as they were designed to be used. If you want additional protection beyond bcrypt, encrypt the output: `encrypt(password_hash(...), $key)`. It's using algorithms as they were designed to be used.

But the bottom line: **never** roll your own crypto. It can have fatal consequences.




