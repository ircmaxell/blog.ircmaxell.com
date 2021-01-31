---
layout: post
title: Random Number Generation In PHP
permalink: 2011/07/random-number-generation-in-php.html
date: 2011-07-18
comments: true
categories:
- Security
tags:
- CryptLib
- PHP
- Random
- Security
---

## What is “random”?

When we talk about “random” numbers, we generally talk about two fundamental properties: Predictability and Bias.  Both are closely related, but are subtly different.  Predictability in reference to random numbers is the statistical problem of predicting the next value when knowing any number of previous values.  Bias on the other hand is the statistical problem of predicting the next value when knowing the distribution of previous values.

<!--more-->

## Predictability

Let’s start off with the assertion that there is no such thing as pure randomness.  That means that all numbers are deterministic (to some degree at least) given enough information about the source of the numbers.  Even typically “random” events such as the radioactive decay of an atom can be seen as deterministic if you know all the information that leads to the decay (the exact position and momentum of each particle in the source element).  Now, according to Quantum Mechanics, you cannot know all of this information (thanks to Heisenberg’s [Uncertainty Principle](http://en.wikipedia.org/wiki/Uncertainty_principle)).  But even quantum mechanics is based off of statistical equations.  So while you cannot predict the exact values with any form of precision, you can make a good statistical guess.


So following from that, all random events are only unpredictable if there is a lack of information about how they are generated.  That does not mean that randomness is security through obscurity (although it can be).  All that means is that without knowing all of the information that led to the generation of a random number (which may be physically impossible), it’s impossible to strongly predict the outcome of a future random value.


So let’s take a look at an example.  If I gave you the number sequence “`8, 8, 1`”, could you provide me with the next number of the sequence?  The answer is likely a strong “no”.  But if I told you that the sequence was generated from the first [762 digits](http://en.wikipedia.org/wiki/Feynman_point) of PI, all of a sudden the number becomes far more predictable.  If I then generate the number 7, you’d immediately know the sequence would continue with “`4, 8, 8, 1, 5`”.  So while the distribution is random, by watching the sequence and knowing the generation algorithm, you can predict the next number.


All random events are subject to this dichotomy of information.  By knowing enough about past events and about the generator, you can theoretically predict the next value to a greater degree than the raw random distribution alone.  A good RNG is dependent upon "hiding" this internal state (either by not exposing the seed, or by hiding behind quantum mechanical laws - as in the case of a radioactive decay RNG).

## Bias

In a purely random sequence, each element in the sequence should occur with the exact same probability.  So given enough elements in the sequence, the number of occurrences of each unique element should be about the same.  If you flip a coin a million times, you’d expect to see approximately 500,000 landing with heads up, and 500,000 with tails up.  While that won’t always happen, with a good random distribution, you’d expect to see something close to that medium.  But if there was a bias (such as a weighted coin, or some other factor we’re not seeing), we could see very skewed results.  A result of 10 heads and 999,990 tails would raise suspicion.  


There’s something very special about the coin analogy that we should point out.  Each coin toss is a separate event.  That means that the prior outcomes have absolutely no discernable bearing on the next outcome.  Note that I said discernable, I said it for a very important reason.  Every time you toss a coin, you’re doing a very slight bit of damage to the coin (wearing out the edge where it hit the ground first perhaps).  This ever so slight bit of damage will add up over time.  If the coin was flipped fairly, we’d expect this damage to be pretty uniform and hence cancel itself out.  But thanks to the laws of physics, as each flip damages the coin, it will alter the probability of the next result (albeit ever so slightly).  So each coin flip does actually alter the potential outcome of the next flip, but it does not do so in any significant manner.


So let’s look at a common mistake made when generating random numbers.  Let’s say we have a very strong random source, where each event is very unpredictable and has no bias at all.  Let’s call this source `rand($min, $max)` (where $min and $max define the output bounds of the generated random number).  So `rand(0, 10)` will generate a single random number between 0 and 10, with no bias.  What happens if we multiply two of those calls together: `rand(0, 10) \* rand(0, 10)`?  Since both are integers, we know the result will be an integer in the range of 0 to 100.  We can see the bias if we create a results table (with the result of one source on the top, and the other on the side):

<table style="border-spacing: 0px; border: 1px solid black;" width="100%"><tbody><tr><td style="border: 1px solid black;"></td><td style="border: 1px solid black;">**0**</td><td style="border: 1px solid black;">**1**</td><td style="border: 1px solid black;">**2**</td><td style="border: 1px solid black;">**3**</td><td style="border: 1px solid black;">**4**</td><td style="border: 1px solid black;">**5**</td><td style="border: 1px solid black;">**6**</td><td style="border: 1px solid black;">**7**</td><td style="border: 1px solid black;">**8**</td><td style="border: 1px solid black;">**9**</td><td style="border: 1px solid black;">**10**</td> </tr><tr><td style="border: 1px solid black;">**0**</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">0</td> </tr><tr><td style="border: 1px solid black;">**1**</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">1</td><td style="border: 1px solid black;">2</td><td style="border: 1px solid black;">3</td><td style="border: 1px solid black;">4</td><td style="border: 1px solid black;">5</td><td style="border: 1px solid black;">6</td><td style="border: 1px solid black;">7</td><td style="border: 1px solid black;">8</td><td style="border: 1px solid black;">9</td><td style="border: 1px solid black;">10</td> </tr><tr><td style="border: 1px solid black;">**2**</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">2</td><td style="border: 1px solid black;">4</td><td style="border: 1px solid black;">6</td><td style="border: 1px solid black;">8</td><td style="border: 1px solid black;">10</td><td style="border: 1px solid black;">12</td><td style="border: 1px solid black;">14</td><td style="border: 1px solid black;">16</td><td style="border: 1px solid black;">18</td><td style="border: 1px solid black;">20</td> </tr><tr><td style="border: 1px solid black;">**3**</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">3</td><td style="border: 1px solid black;">6</td><td style="border: 1px solid black;">9</td><td style="border: 1px solid black;">12</td><td style="border: 1px solid black;">15</td><td style="border: 1px solid black;">18</td><td style="border: 1px solid black;">21</td><td style="border: 1px solid black;">24</td><td style="border: 1px solid black;">27</td><td style="border: 1px solid black;">30</td> </tr><tr><td style="border: 1px solid black;">**4**</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">4</td><td style="border: 1px solid black;">8</td><td style="border: 1px solid black;">12</td><td style="border: 1px solid black;">16</td><td style="border: 1px solid black;">20</td><td style="border: 1px solid black;">24</td><td style="border: 1px solid black;">28</td><td style="border: 1px solid black;">32</td><td style="border: 1px solid black;">36</td><td style="border: 1px solid black;">40</td> </tr><tr><td style="border: 1px solid black;">**5**</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">5</td><td style="border: 1px solid black;">10</td><td style="border: 1px solid black;">15</td><td style="border: 1px solid black;">20</td><td style="border: 1px solid black;">25</td><td style="border: 1px solid black;">30</td><td style="border: 1px solid black;">35</td><td style="border: 1px solid black;">40</td><td style="border: 1px solid black;">45</td><td style="border: 1px solid black;">50</td> </tr><tr><td style="border: 1px solid black;">**6**</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">6</td><td style="border: 1px solid black;">12</td><td style="border: 1px solid black;">18</td><td style="border: 1px solid black;">24</td><td style="border: 1px solid black;">30</td><td style="border: 1px solid black;">36</td><td style="border: 1px solid black;">42</td><td style="border: 1px solid black;">48</td><td style="border: 1px solid black;">54</td><td style="border: 1px solid black;">60</td> </tr><tr><td style="border: 1px solid black;">**7**</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">7</td><td style="border: 1px solid black;">14</td><td style="border: 1px solid black;">21</td><td style="border: 1px solid black;">28</td><td style="border: 1px solid black;">35</td><td style="border: 1px solid black;">42</td><td style="border: 1px solid black;">49</td><td style="border: 1px solid black;">56</td><td style="border: 1px solid black;">63</td><td style="border: 1px solid black;">70</td> </tr><tr><td style="border: 1px solid black;">**8**</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">8</td><td style="border: 1px solid black;">16</td><td style="border: 1px solid black;">24</td><td style="border: 1px solid black;">32</td><td style="border: 1px solid black;">40</td><td style="border: 1px solid black;">48</td><td style="border: 1px solid black;">56</td><td style="border: 1px solid black;">64</td><td style="border: 1px solid black;">72</td><td style="border: 1px solid black;">80</td> </tr><tr><td style="border: 1px solid black;">**9**</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">9</td><td style="border: 1px solid black;">18</td><td style="border: 1px solid black;">27</td><td style="border: 1px solid black;">36</td><td style="border: 1px solid black;">45</td><td style="border: 1px solid black;">54</td><td style="border: 1px solid black;">63</td><td style="border: 1px solid black;">72</td><td style="border: 1px solid black;">81</td><td style="border: 1px solid black;">90</td> </tr><tr><td style="border: 1px solid black;">**10**</td><td style="border: 1px solid black;">0</td><td style="border: 1px solid black;">10</td><td style="border: 1px solid black;">20</td><td style="border: 1px solid black;">30</td><td style="border: 1px solid black;">40</td><td style="border: 1px solid black;">50</td><td style="border: 1px solid black;">60</td><td style="border: 1px solid black;">70</td><td style="border: 1px solid black;">80</td><td style="border: 1px solid black;">90</td><td style="border: 1px solid black;">100</td> </tr></tbody></table>

We can see the bias right in front of us.  First, we can see that 0, which should occur approximately 1% of the time, actually occurs 20% of the time.  Numbers >= 50, which we would expect 50% of the time, only occur 21% of the time.  Numbers >= 75 are expected 25% of the time, but only occur 6% of the time.  Numbers <= 10 are expected 10% of the time, but actually appear 48% of the time.  So by multiplying the two unbiased sources together, we have biased the result towards lower numbers.  

## Random Number Generators

So, what makes a good random number generator?  The numbers it generates should be both unpredictable (meaning, given a sequence, it should be hard or impossible to predict the next with any certainty) and unbiased (meaning it will output all numbers in its output range with even chance).  


PHP has 2 basic random number generators, `[rand()](http://us.php.net/manual/en/function.rand.php)` and `[mt_rand()](http://us.php.net/manual/en/function.mt-rand.php)`.  Each generates a random number via its own internal algorithm from a seed.  Think of the seed as a starting state of the algorithm.  If the starting state is unknown, the generated numbers are quite strong.  However, if the starting state is known (or set by an attacker), the generated sequence is 100% predictable.  Unfortunately, both of these functions are susceptible to an attack known as “[seed poisoning](http://www.suspekt.org/2008/08/17/mt_srand-and-not-so-random-numbers/)”.  That means an attacker can artificially “seed” the random number generator with a known value, and have your application generate “known” random numbers instead.

PHP has one other basic random number generator, `[lcg_value()](http://us.php.net/manual/en/function.lcg-value.php)`.  This method generates weaker random numbers than `mt_rand()`, but because the seed is internal it is less susceptible to seed attacks.  However, it is seeded on the first call only, and to a value based off the process id and the current time.  So that means that if an attacker can make the first call to that function for the process, they should be able to reasonably predict the remaining sequence.

PHP’s `[uniqid()](http://us.php.net/manual/en/function.uniqid.php)` function is also able to help generate random strings.  The interesting thing about uniqid is that it internally uses the current time and calls `lcg_value()`.  So if `lcg_value()` is compromised (as above), the output of uniqid can be guessed fairly well.  Note that it’s not easy to guess the exact value, but it is fairly easy to guess a small domain of values that could be correct (far smaller than the 2^23 possible outputs).

The operating system usually provides a random number generator as well (`/dev/random` and `/dev/urandom`).  These are usually far more secure than anything living in PHP.  However, that does not mean that they cannot be compromised.  Both systems gather entropy from the operating system (typically through drivers and the like).  This means that there are a lot of opportunities for an attacker to poison the entropy pool to have the sources return less-than-ideal strength numbers.  There are preventions in place for this type of attack, but it is still possible.

PHP extensions also provide a few other sources of randomness. OpenSSL provides `[openssl_random_pseudo_bytes()](http://us.php.net/manual/en/function.openssl-random-pseudo-bytes.php)`.  However, the internal OpenSSL call to `[RAND_pseudo_bytes(3)](http://swoolley.org/man.cgi/3/RAND_bytes)` is not a strong random number generator (as indicated on the man page).  

MCrypt provides `[mcrypt_create_iv()](http://us.php.net/manual/en/function.mcrypt-create-iv.php)`, which internally uses `/dev/urandom` or `/dev/random` as its source (and hence is susceptible to the same issues). Even with these issues withstanding, `mcrypt_create_iv()` with `MCRYPT_DEV_RANDOM` appears to be the best method in PHP to generate strong random numbers.

## Enter RFC 4086

It turns out that this “problem” isn’t all too uncommon.  In fact, there are accepted ways of dealing with these problems.  The method I’m going to talk about here is the one discussed in [RFC 4086 – Randomness Requirements for Security](http://tools.ietf.org/html/rfc4086).  The premise is simple: Any single pseudo random source is corruptible.  Therefore, let’s use as many sources as possible to generate our randomness requirements.  

And that’s exactly what I did when I implemented the RNG in [PHP-CryptLib](https://github.com/ircmaxell/PHP-CryptLib/)’s Random package.  Basically, it uses between 2 and 8 random number sources (depending upon strength requirements and system configuration) as random input. Then, it takes those random bits and “mixes” them together to produce a strong random output.  The exact method of mixing turns out to be quite important.

If any number of the random sources that are used are compromised (except all of them), the end result will still be unpredictable.  So that satisfies one of the requirements of a good RNG.  PHP-CryptLib uses sources derived from `rand()`, `microtime()`, `mt_rand()`, `uniqid()`, `openssl_random_pseudo_bytes()`, `[CAPICOM.getRandom()](http://msdn.microsoft.com/en-us/library/aa388182(v=vs.85).aspx)`, `/dev/random` and `/dev/urandom`.  I know that `microtime()` is not traditionally considered a random source, due to biasing and predictability issues.  However, due to the way the mixer works, even weak sources can increase the entropy of the output!

What about biasing?  Well, if we used a trivial XOR mixer (where we just xor all of the sources together to produce the result), we face a biasing problem on a compromise of an RNG.  Let’s say that we seed poison PHP’s `rand()` call.  Then, since we have a predictable output, the output of the RNG will be artificially biased towards those predictable outputs.  Meaning that since we know the result of one of the generators, we effectively bias the overall result in a way where some outputs are not possible (and as such reducing the output space of the function).  In practice the bias will be small to non-existent, but let’s not take any chances.

PHP-CryptLib has a total of 4 mixing functions that it chooses as a tradeoff between speed and security.  If you need a non-cryptographic random number, the XOR mixer (which has the biasing problem discussed above) will suffice.  But if you want cryptographic quality random numbers, CryptLib will choose a mixer for you that’s much stronger.  The other mixers include a HMAC based mixer (using hash_hmac), a DES encryption based mixer and a rijndael-128 (AES) based mixer.  They all function the same, with the only difference being the underlying mixing function.  Basically, it applies the mixing function to each source’s data using another as the key.  By doing this in an alternating and cyclical manner, as long as one input in unpredictable, the output will be unpredictable.  


One striking benefit to this method of generating random numbers is that it’s not weakened by adding a weak source (it’s not a chain: “A chain is only as strong as its weakest link”).  But in this case, even a weak link will actually strengthen the output (due to how the results are mixed)!

## A Note On Suhosin

If you browse the source code of the random sources, you’ll notice some interesting conditionals in the getStrength() methods of some of the sources (such as the [Rand source](https://github.com/ircmaxell/PHP-CryptLib/blob/master/lib/CryptLib/Random/Source/Rand.php#L46)).  With the Suhosin patch (which also defines S_ALL), rand() and mt_rand() are automatically re-seeded on every single function call.  This does increase the strength of both rand() and mt_rand().  ~However, it also seeps entropy from /dev/urandom (which it uses for the re-seeding).  This means that the strength of /dev/urandom is actually decreased (due to the added data being pulled from it).  So when the Suhosin patch is installed, CryptLib will promote both Rand and MTRand sources one level, while at the same time demoting the URandom source down one level.~  As it was pointed out to me, /dev/urandom should have enough entropy that even this additional load should not affect the output at all.  I have since patched the behavior to not demote URandom to Low strength.  But both rand() and mt_rand() are still promoted one level.

## Using PHP-CryptLib’s RNG

Using it is really simple!  You can use the base CryptLib object.  This will generate medium strength numbers (which are useful for most cryptographic needs including salt generation, but not key generation).

To get an integer between 0 and 10:

```php
require_once dirname(__DIR__) . '/lib/CryptLib/CryptLib.php';
$cryptLib = new \CryptLib\CryptLib;
$number = $cryptLib->getRandomNumber(0, 10);
```

You can also generate a "token" (which is a string with printable ASCII characters only, such as would match the following regex: `/^[a-zA-Z0-9./]{$size}$/`):

```php
require_once dirname(__DIR__) . '/lib/CryptLib/CryptLib.php';
$cryptLib = new \CryptLib\CryptLib;
$token = $cryptLib->getRandomToken(5);
```

Or, you can generate a random string (which consists of full-byte, 0-255 characters):

```php
require_once dirname(__DIR__) . '/lib/CryptLib/CryptLib.php';
$cryptLib = new \CryptLib\CryptLib;
$string = $cryptLib->getRandomBytes(5);
```

Or, you could use the factory to create a custom generator for whatever strength you may need. 

Let's say we wanted to get a random bit of data to generate a key for encryption (we wouldn't use the data directly, but would derive a key from it).  We could create a high-strength generator, and tell it to generate 512 bits of random data (64 characters):

```php
require_once dirname(__DIR__) . '/lib/CryptLib/CryptLib.php';
$factory = new \CryptLib\Random\Factory;
$generator = $factory->getHighStrengthGenerator();
$string = $cryptLib->generate(64);
```

See the [examples](https://github.com/ircmaxell/PHP-CryptLib/tree/master/examples/Random) section of the library for more information.

Remember, 

> The generation of random numbers is too important to be left to chance - Robert R. Coveyou.
