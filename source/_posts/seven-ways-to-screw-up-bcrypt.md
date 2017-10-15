---
layout: post
title: Seven Ways To Screw Up BCrypt
permalink: seven-ways-to-screw-up-bcrypt
date: 2012-12-17
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

There are numerous articles on the web about how to properly use bcrypt in PHP. So this time, rather than write `yet-another-how-to-use-bcrypt` article, I'm going to focus on the mistakes that are commonly made when implementing bcrypt. So, let's dive right in:
<!--more-->


## #1: Using A Non-Random Salt


The first (and often biggest) mistake that people make with bcrypt is not using a random salt. To understand why this is a major issue, we must discuss the purpose of a salt. Salts in password hashing are basically there to prevent an attacker from attacking more than one password hash at the same time. If the salt for any two hashes is the same, then the attacker can re-use the computation to attack both at the same time (for brute force style attacks).

Therefore, the salt must be unique to provide as much protection from brute-forcing as possible. An important thing to note here is that the uniqueness is not limited to a specific site. So using the user's username as the salt isn't good, as if another site does the same, the attacker can attack both sites at the same time (assuming that you use different passwords for each site).
## #2: Using An Incorrect Random Source for Salt Generation


This is an interesting one, because it goes both ways (using too weak, or too strong of a random source). Let's look at the weak random sources first. Since the primary protection of a salt comes from it being unique, if we use too weak of a source, the chances (statistically) of a collision increase significantly. Additionally, some of the weak random sources suffer from problems known as "seed poisoning" where an attacker can effect future generated randomness. So PHP tools like `rand()`, `mt_rand()` and `uniqid()` are all out of the question.

On the other hand, using too strong of a random source can be problematic. So you shouldn't use Cryptographically Secure randomness for salts (Such as `/dev/random`). The reason is that most CS random sources included mechanisms to prevent generating randomness faster than it can gather entropy from the system. So what winds up happening is that if you read too much data, it will block until it can gather more entropy. That translates into Denial Of Service vulnerabilities.

Instead, you should use strong randomness while not using CS randomness. A perfect source would be `/dev/urandom.` Other sources would be `mcrypt_create_iv` when paired with `MCRYPT_DEV_URANDOM`. If neither of them are available, you can fall back to `openssl_random_pseudo_bytes` or `mt_rand` (at an absolute last resort).
## #3: Using Too Weak Of A Cost Parameter


One of the reasons that bcrypt is the preferred password hashing method in PHP is that it is designed to be slow. The cost parameter to the salt indicates how slow the hashing should be (it is designed to be forward-compatible with faster servers). Ideally, for most usages, each hash should take between 0.25 and 0.5 seconds. The interesting thing is that the exact runtime depends largely on the capabilities of the server it's running on.

That means that you'll need to test your server to find a cost parameter that's as strong as possible without being overly slow. So if you're using the lowest cost available (4), you're not getting nearly as much protection as you should. Instead, a minimum cost of 9 should be used, and larger if your servers can tollerate it (a modern desktop class processor can do a cost factor of 10 in about 0.3 to 0.4 seconds).
## #4: Using The Wrong PHP Version


Earlier versions of PHP acted weirdly if bcrypt support was not compiled in from scratch. Starting with 5.3.0, BCrypt is included (and enabled) by default. But older versions may or may not have support. The problem here is that if you used a bcrypt style salt in `crypt()` when bcrypt was not available, it wouldn't error out. Instead, it would fall back to using `DES` (which is extremely weak). Here's an example:```php
var_dump(crypt('foo', '$2a$04$thisisasaltthisisasale'));

```

When run on 5.3+:
```php
"$2a$04$thisisasaltthisisasaleDjUpLNqciaokdZZwyr82a58CUDIz/Se"

```

And when run on 4.3.0 -> 5.2.9
```php
string(13) "$2zJyhpjk3l9E"

```

So as you can see, you really need to be using 5.3+...

Additionally, there were several issues found in 5.3's implementation that were fixed in 5.3.7. So that should be the minimum version that you should use.
## #5: Using The Wrong Prefix


As part of the vulnerability fix that was introduced in 5.3.7, a pair of new prefixes were introduced. Before 5.3.7, the correct prefix for bcrypt was `$2a$`. However, after the vulnerability was found, `$2x$` was introduced as a "`legacy behavior`" prefix (to enable backwards compatibility if absolutely necessary). The other prefix, `$2y$`, was introduced as the "`always to specification`" prefix which always works correctly. It is the preferred prefix for all new implementations.

The `$2a$` prefix still works as of 5.3.7. The fix was introduced in such a way that it will still operate securely. However, there are some additional checks that it runs that aren't strictly needed for new implementations. So it's not `wrong` to use it, but if you are building a new implementation, I'd suggest sticking to `$2y$`.
## #6: Not Checking For Errors


If there's an error internally to crypt, or if you provide an invalid salt specification, crypt will return either "`\*0`" or "`\*1`" (depending on the salt provided). Coupling that with the odd results from #4, it's easy to see how not checking for these errors can result in garbage (at best) or vulnerable hashes (at worst) stored in the database for your users. Therefore, you should **always** check the result from crypt to see if there was an error. The easiest way to do that is to check if the return from crypt is longer than 13 characters. If it is, it's safe to assume that everything went fine. If the result is 13 characters or less, there was a problem and you shouldn't store it!
## #7: Not Using A Library


Given all of these potential ways of screwing up a bcrypt implementation, there's no reason to not use a library. And seeing how easy it is to install one with composer, there's no excuse not to. Another huge benefit of using a library, is that if any security issues are found in it, fixing it is as easy as upgrading the library. Here are a few libraries that will work well for you:

 1. [password-compat](https://github.com/ircmaxell/password_compat) - [Packagist](https://packagist.org/packages/ircmaxell/password-compat) - A compatibility library with the new 5.5 password_hash API.
 2. [PasswordLib](https://github.com/ircmaxell/PHP-PasswordLib) - [Packagist](https://packagist.org/packages/PasswordLib/PasswordLib) - A library for working with passwords from multiple systems.
 3. [PHPASS](http://www.openwall.com/phpass/) - A library for handling password hashing. NOTE: This is only recommended with "portable hashing" disabled.


## #8: Bonus: Not Using A Timing Safe Comparison


I included this as a bonus, because technically the implementation details of crypt theoretically mitigate any potential timing attack when used properly. If you use a strong random salt, timing attacks should not be possible (if the attacker can predict the salt, timing attacks are indeed possible). But I figured it was a good mention since it is a generic problem.

A [Timing Attack](http://rdist.root.org/2010/07/19/exploiting-remote-timing-attacks/) is basically where an attacker makes repeated requests slightly altering each one, and timing how long it takes to process the results. In certain cases, an attacker can measure the minute differences in an equals operation (`$foo == $bar`) to discern the actual value (assuming he has knowledge over how his input affects one of them). This class of attack is actually pretty easy to defend against. All you need to do is use a timing safe comparison function. Here's an example:```php

/**
 * A timing safe equals comparison
 *
 * To prevent leaking length information, it is important
 * that user input is always used as the second parameter.
 *
 * @param string $safe The internal (safe) value to be checked
 * @param string $user The user submitted (unsafe) value
 *
 * @return boolean True if the two strings are identical.
 */
function timingSafeEquals($safe, $user) {
    // Prevent issues if string length is 0
    $safe .= chr(0);
    $user .= chr(0);

    $safeLen = strlen($safe);
    $userLen = strlen($user);

    // Set the result to the difference between the lengths
    $result = $safeLen - $userLen;

    // Note that we ALWAYS iterate over the user-supplied length
    // This is to prevent leaking length information
    for ($i = 0; $i < $userLen; $i++) {
        // Using % here is a trick to prevent notices
        // It's safe, since if the lengths are different
        // $result is already non-0
        $result |= (ord($safe[$i % $safeLen]) ^ ord($user[$i]));
    }

    // They are only identical strings if $result is exactly 0...
    return $result === 0;
}

```

So just use that in place of `==` for any sensitive equality checking.

Note that I said this is not technically required for bcrypt when implemented properly. I wouldn't knock an implementation that didn't use a timing-safe comparison with bcrypt. But I figured it would be worth mentioning...
## #9: Bonus 2: Not Encoding The Salt Correctly


I am including this as a bonus because while it should be done, it doesn't `necessarily` make an implementation bad. BCrypt expects a 128 bit salt encoded in a base64 format, resulting in 22 characters of salt. Many implementations will just substring off 22 characters from a hex output of `MD5`, `SHA1`, or `SHA256`. The problem with doing this is that each character of salt only has 4 bits of entropy, as opposed to 6 bits from a base64 encoding.

A proper encoding technique will encode the maximum amount of entropy into the salt. Therefore, to properly format a salt, a binary (each character is a full byte, 0-255) salt should be generated, then encoded using something like this:```php
$salt = substr(strtr(base64_encode($randomSalt), '+', '.'), 0, 22);

```

It's pretty straight forward, but not doing it limits the entropy that you provide. A hex output will only have 86 bits of entropy, where a properly encoded one will have 128 bits. 86 MAY be ok, but wouldn't you want to maximize the entropy?## Conclusion:


Just use a library. Seriously, it's not worth constantly re-writing it. Just use one...