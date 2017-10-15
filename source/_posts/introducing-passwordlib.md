---
layout: post
title: Introducing: PasswordLib
permalink: introducing-passwordlib
date: 2012-04-14
comments: true
categories:
- Security
tags:
- Library
- Password-Hashing
- PasswordLib
- PHP
- Security
---

Today, I'm proud to announce the immediate availability of a new password hashing library for PHP: [PasswordLib](https://github.com/ircmaxell/PHP-PasswordLib). The project is a spin-off of another that I started about a year ago, [CryptLib](https://github.com/ircmaxell/PHP-CryptLib). I was unable to find a clean solution to a few problems in CryptLib, so dev work stalled for a while. I realized recently that the password hashing functionality was complete, so if I stripped out the incomplete parts, it would still be a very useful library. And so PasswordLib was born.<!--more-->

## What Is PasswordLib


Well, in short, PasswordLib is a 100% portable password hashing library. It uses the best available algorithms for hashing, salt generation and random number generation. Additionally, it was designed with interoperability in mind. It can create and validate password hashes from many popular open source projects (with more to come).## Why Do We Need A Library?


We need a password hashing library, because although it's not too difficult to do it properly, people just don't seem to understand how to do it. There are tons of articles out there that provide incorrect or downright dangerous code to hash passwords. By abstracting all of that away, a single library can provide a secure and consistent method for hashing passwords while being so easy to use that even the most junior developer can use it.## Why Not Just Use Crypt()?


Well, you can! In fact, this library uses [crypt()](http://us.php.net/crypt) internally. The problem with crypt though, is that its really a pain in the neck to work with. Its error states are non-obvious at best ("`\*0`" and "`\*1`", really?)... Salts are a pain to generate (22 characters of an awkward base64 encoded random string). And it's non-obvious to use the same API to hash and validate hashes. So, this library abstracts all that difficulty away behind an easy to use interface.## Why Not Just Use PHPASS?

[PHPASS](http://www.openwall.com/phpass/) is a really great library for generating password hashes. However, it's a bit out-dated. Blowfish hashes are 100% portable for modern versions of PHP (5.3+), yet if you ask PHPASS for a portable hash, it won't use Blowfish. Second, it uses an non-standard algorithm for hashing passwords in a portable manner. Additionally, it has been forked and modified several times by other projects (Such as Drupal) to improve the algorithm. So, rather than using a library which needs to be forked to improve, this library was designed to be extended without modification and to support as many possible hashing schemes as possible.## Ok, So How Do I Use It?


There are two basic ways to install PasswordLib for your use. If you use [Composer](https://github.com/composer/composer), simply add `"PasswordLib/PasswordLib": "\*"` to the `require` section of your your composer.json file ([Here's The Packagist Entry](http://packagist.org/packages/PasswordLib/PasswordLib)). Then, as long as you use the Composer autoloader, it will magically load the PasswordLib libraries for you.


If you don't use Composer, just download the latest [PasswordLib PHAR archive](https://github.com/ircmaxell/PHP-PasswordLib/downloads). Then, all you need to do is require that phar file, and it will configure and bootstrap itself for you, no other autoloader required.

From there, the base API is really simple to use. Just create a new instance of `[PasswordLib\PasswordLib()](https://github.com/ircmaxell/PHP-PasswordLib/blob/master/lib/PasswordLib/PasswordLib.php)`, and use its methods. Here's a quick example:

```php
$lib = new PasswordLib\PasswordLib;
$password = "foo";
$hash = $lib->createPasswordHash($password);
if ($lib->verifyPasswordHash($password, $hash)) {
    // Password Is Valid
} else {
    // Incorrect Password
}

```

It's really that easy!

By default, it will create all passwords using the most secure password hashing algorithm available to PHP, Blowfish (Crypt $2a$). If you want to generate a different style hash (for compatibility with other systems), just pass in the crypt style prefix as the second argument to `createPasswordHash`... Some supported hash prefixes for creation:

 * `**$apr1$**` - Apache .htaccess password hashes
 * `**$2a$**` - Blowfish (default)
 * `**$S$**` - Drupal
 * `**$1$**` - Crypt MD5 (iterated)
 * `**$pbkdf$**` - PBKDF2 hashes
 * `**$P$**` - PHPASS
 * `**$H$**` - PHPBB
 * `**$5$**` - Crypt SHA256 (iterated)
 * `**$6$**` - Crypt SHA512 (iterated)


You can create all of those types of hashes right through that same API. The library will abstract away salt creation, so you can just worry about the algorithm. For validating, it supports all of those hashes, plus:

 * Joomla style salted hashes
 * unsalted md5
 * unsalted sha1
 * unsalted sha256
 * unsalted sha512

The way the library is structured, you can add additional formats by simply dropping a new implementation in the [implementation directory](https://github.com/ircmaxell/PHP-PasswordLib/tree/master/lib/PasswordLib/Password/Implementation), or by registering the implementation with the [Password Factory](https://github.com/ircmaxell/PHP-PasswordLib/blob/master/lib/PasswordLib/Password/Factory.php#L93) (although this requires a little bit more setup).
## What About The License?


PasswordLib is released under the very liberal MIT license. However, if you need a different license, just contact me and we can work something out.

Check out the project on [GitHub](https://github.com/ircmaxell/PHP-PasswordLib) for more information!