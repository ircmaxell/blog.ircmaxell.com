---
layout: post
title: All about hashing and security
permalink: all-about-hashing-and-security
date: 2011-03-15
comments: true
categories:
- Security
tags:
- Password-Hashing
- PHP
- Security
- StackOverflow
---

Here's a quick link to a [StackOverflow answer](http://stackoverflow.com/questions/4948322/fundamental-difference-between-hashing-and-encryption-algorithms/4948393#4948393) that I wrote explaining password hashing. 

> A key feature of cryptographic hash functions is that they should be very fast to create, and **very** difficult/slow to reverse (so much so that it's practically impossible). This poses a problem with passwords. If you store `sha512(password)`, you're not doing a thing to guard against rainbow tables or brute force attacks. Remember, the hash function was designed for speed. So it's trivial for an attacker to just run a dictionary through the hash function and test each result.

I think it does a pretty good job explaining hashing and encryption, and is worth sharing
