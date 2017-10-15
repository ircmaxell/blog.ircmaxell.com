---
layout: post
title: Introducing Recki-CT
permalink: introducing-recki-ct
date: 2014-08-29
comments: true
categories:
tags:
- Compiler
- HHVM
- JitFu
- libjit
- Open Source
- Optimization
- Performance
- PHP
- Recki-CT
---
Over 1.5 years ago, I introduced [PHPPHP](https://github.com/ircmaxell/PHPPHP) to the world. It was the first implementation of the PHP language written in PHP itself. But PHPPHP suffered from a few problems which relegated it to toy status (such as performance). Today, I get to introduce you to another implementation of PHP, written in PHP. But this one is no toy. This one... This one is fun...
<!--more-->


## Recki-CT

I'd like to introduce you to [The Recki Compiler Toolkit (Recki-CT)](https://github.com/google/recki-ct).

## What Is It?

It's a Compiler written in PHP that targets a subset of the PHP language (a less dynamic subset). This means that it does not support things like references or variable-variables. It also does not support global variables (at all, not even super-globals). What's the point of that you ask?

Well, if you're able to write code that's static enough, then we can reason about it. We can analyze it. We can optimize it. And we can statically compile it to machine code.

Yes, that's right. Recki-CT compiles PHP down to machine code.

But it's fundamentally different from other approaches at doing so. HHVM and HippyVM both use [Just In Time Compilation](http://en.wikipedia.org/wiki/Just-in-time_compilation) to compile PHP. That means that the compilation happens at run-time. Which means that the compilation process must be *fast*.

Recki-CT on the other hand uses [Ahead-of-Time Compilation](http://en.wikipedia.org/wiki/AOT_compiler) (or more precisely, lets you cache an intermediary which can be compiled at run-time). This means that more aggressive optimizations can be applied. And it means that more efficient code can be generated. And it means that code produced by Recki-CT can be run along side (inside technically) another engine.

Right now, the only engine that's supported is PHP. However there's nothing stopping porting the [JitFu extension](https://github.com/krakjoe/jitfu) to HHVM, which would then enable running compiled code inside of HHVM. And that's what's different about this approach. It isn't all-or-nothing. It's incremental. You can port individual functions to Recki-CT, while the rest of the application still works 100% on the engine that it's currently running on!!!

## How Fast Is It?

Well, that's a very difficult question to answer. Based on trivial benchmarks, it's **blindingly fast**. It can execute a recursive Fibonacci generator in about the same amount of time as C code can (without GCC's optimizations turned on that is). But this is something that HHVM can already do well. Can Recki-CT outperform HHVM?

Let's find out. Using a simple test script, based off of [PHP's own `bench.php`](http://lxr.php.net/xref/PHP_TRUNK/Zend/bench.php), we can compare the relative performance differences of a number of PHP implementations. The numbers are normalized to the fastest implementation (which becomes 1.0). So a result of `45` means it's 45 times slower than the fastest implementation. And note that parsing (and any compilation that happens prior to calling the function) is not included in the numbers.

[The Actual Test Script Used](https://gist.github.com/ircmaxell/8859d7f1bbee7b2f6e16) (which is based off of PHP's internal [bench.php](https://github.com/php/php-src/blob/master/Zend/bench.php)). It runs each test 5 times, and throws away the slowest `two` runs. Then averages the fastest three to get the final answer. So this should remove the overhead of JIT compilers, and just focus on the last bits of performance that we can squeeze out.

The results:

<style type="text/css">.benchmark {border: 1px solid black;border-spacing: 0px;}.benchmark td {padding: 0.4em;border: 1px solid black;}.benchmark th {padding: 0.5em;border: 1px solid black;}.win {font-weight: bold;background-color: #82FA58;}.lose1 {background-color: #D0F5A9;}.lose10 {background-color: #F2F5A9;}.losebad {background-color: #FA5858;}</style>

<table class="benchmark"><thead><tr><th></th><th>php 5.5</th><th>Recki-CT</th><th>hhvm 3.2</th><th>hippy-c</th><th>qb</th></tr></thead><tbody><tr><td>simple()</td><td class="losebad">139.63357</td><td class="win">1.00000</td><td class="lose10">8.30447</td><td class="lose10">7.65693</td><td class="lose10">8.35018</td></tr><tr><td>simplecall()</td><td class="losebad">38.99476</td><td>FAIL</td><td class="lose1">1.32552</td><td class="win">1.00000</td><td>FAIL</td></tr><tr><td>simpleucall()</td><td class="losebad">54.02041</td><td class="win">1.00000</td><td class="lose10">3.52439</td><td class="lose1">1.51072</td><td class="losebad">47.91090</td></tr><tr><td>simpleudcall()</td><td class="losebad">52.14534</td><td class="win">1.00000</td><td class="lose10">3.75936</td><td class="lose10">1.41614</td><td class="losebad">47.55259</td></tr><tr><td>mandel()</td><td class="losebad">21.26249</td><td class="win">1.00000</td><td class="lose10">2.03372</td><td class="lose10">2.11208</td><td>FAIL</td></tr><tr><td>mandel_typed()</td><td class="losebad">23.16553</td><td class="win">1.00000</td><td class="lose10">2.11128</td><td class="lose10">2.09212</td><td class="lose10">3.00061</td></tr><tr><td>mandel2()</td><td class="losebad">24.43275</td><td class="win">1.00000</td><td class="lose10">2.57704</td><td class="lose1">1.87802</td><td>FAIL</td></tr><tr><td>mandel2_typed()</td><td class="losebad">23.79989</td><td class="win">1.00000</td><td class="lose10">2.90105</td><td class="lose1">1.57193</td><td class="lose10">7.11054</td></tr><tr><td>ackermann(7)</td><td class="losebad">35.04870</td><td class="win">1.00000</td><td class="lose10">2.27557</td><td class="losebad">103.45436</td><td class="losebad">621.72526</td></tr><tr><td>ary(50000)</td><td class="lose1">1.39338</td><td>FAIL</td><td class="win">1.00000</td><td class="lose10">4.47888</td><td>FAIL</td></tr><tr><td>ary2(50000)</td><td class="lose1">1.26952</td><td>FAIL</td><td class="win">1.00000</td><td class="lose10">2.28231</td><td>FAIL</td></tr><tr><td>ary3(2000)</td><td class="lose10">5.96015</td><td>FAIL</td><td class="lose1">1.70997</td><td class="win">1.00000</td><td>FAIL</td></tr><tr><td>fibo(30)</td><td class="losebad">39.48440</td><td class="win">1.00000</td><td class="lose1">1.60647</td><td class="losebad">16.40883</td><td>FAIL</td></tr><tr><td>hash1(50000)</td><td class="lose1">1.70014</td><td>FAIL</td><td class="win">1.00000</td><td class="lose10">3.27314</td><td>FAIL</td></tr><tr><td>hash2(500)</td><td class="lose10">2.23648</td><td>FAIL</td><td class="win">1.00000</td><td class="lose1">1.30044</td><td>FAIL</td></tr><tr><td>heapsort(20000)</td><td class="lose10">3.67800</td><td>FAIL</td><td class="win">1.00000</td><td class="lose10">4.96699</td><td>FAIL</td></tr><tr><td>matrix(20)</td><td class="lose10">4.38364</td><td>FAIL</td><td class="win">1.00000</td><td class="losebad">37.72782</td><td>FAIL</td></tr><tr><td>nestedloop(12)</td><td class="losebad">29.24924</td><td class="win">1.00000</td><td class="lose10">2.91459</td><td class="lose10">3.07568</td><td>FAIL</td></tr><tr><td>sieve(30)</td><td class="losebad">10.95413</td><td>FAIL</td><td class="win">1.00000</td><td class="lose10">4.95152</td><td>FAIL</td></tr><tr><td>strcat(200000)</td><td class="lose1">1.48186</td><td>FAIL</td><td class="lose10">2.06003</td><td class="win">1.00000</td><td>FAIL</td></tr><tr><td>jumpapaluza(50, 50)</td><td class="losebad">11.67746</td><td class="lose1">1.09240</td><td class="lose1">1.48192</td><td class="win">1.00000</td><td>FAIL</td></tr><tr><td>bitapaluza1(21)</td><td class="losebad">63.33357</td><td class="win">1.00000</td><td class="losebad">21.39655</td><td class="lose1">1.46851</td><td>FAIL</td></tr><tr><td>bitapaluza2(18)</td><td class="losebad">21.83346</td><td class="win">1.00000</td><td class="lose10">6.19715</td><td class="lose10">2.59416</td><td>FAIL</td></tr></tbody></table>
<span class="win">Winner</span>, <span class="lose1">Within Factor Of 2</span>, <span class="lose10">Within Factor Of 10</span>, <span class="losebad">> 10 times slower</span>

Note that the *Fail* indications for Recki-CT are not true failures, but instead compile errors due to using not-implemented features (in this case, arrays).

But these benchmarks aren't real. They show off best-case use-cases. They don't show off how well it'll work for your application. Only testing your application directly can determine that.

## How does it work?

Well, there's documentation to answer [exactly that question](https://github.com/google/recki-ct/blob/master/doc/2_basic_operation.md)!

## Who's behind this project?

I wrote the initial release myself. However, I relied heavily upon (and worked closely with) [Joe Watkins](https://twitter.com/krakjoe). His work on [JIT-Fu](https://github.com/krakjoe/jitfu) both was an inspiration and the prime reason for this project existing.

I also would like to thank [Igor Wielder](https://twitter.com/igorwhiletrue) and [Benjamin Gruenbaum](http://stackoverflow.com/users/1348195/benjamin-gruenbaum) for guidance and pointing me in the right direction on numerous occasions.

I also relied very heavily upon a few other open source projects, without which I wouldn't have been able to do this. I'd like to thank:

 * [Nikita Popov](https://twitter.com/nikita_ppv) for his amazing work on [PHP-Parser](https://github.com/nikic/PHP-Parser/) which this project uses heavily.
 * [Sam Boyer](https://twitter.com/sdboyer) for his awesome graph library [Gliph](https://github.com/sdboyer/gliph) which is a foundation for this project.
Other projects were used, and there are too many individuals to thank each one. Many helped without knowing what they were helping with (in fact, most). So to everyone else, thank you!!! :-D

## How can you contribute?

You can always open bugs, and help document! And if you're feeling really adventurous, then you could try submitting some code (due note that all code contributions are subject to [signing a CLA](https://github.com/google/recki-ct/blob/master/CONTRIBUTING.md)). Take on a bug! Take on a new optimization! Add a new compiler back-end! Have fun!

## I have more questions!

Check out the [Introduction and FAQ](https://github.com/google/recki-ct/blob/master/doc/0_introduction.md). And if you still have one, reach out to me!

Have fun, and let me know what you think of the project!!!

