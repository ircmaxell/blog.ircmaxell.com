---
layout: post
title: Preventing CSRF Attacks
permalink: preventing-csrf-attacks
date: 2013-02-19
comments: true
categories:
- Security
tags:
- Best Practice
- CSRF
- PHP
- Security
---

There's been a bit of noise in the past week about the proper way to prevent Cross-Site-Request-Forgery (CSRF) attacks. It seemed to have started with [this post](http://www.eschrade.com/page/generating-secure-cross-site-request-forgery-tokens-csrf/). There's been discussion in the comments, and on Twitter about it, and there seems to be several opposing viewpoints on the matter. I want to start off by saying that I agree completely with the post in question. But I figured I'd write a post to explain WHY I agree with it.
<!--more-->

## What Is A Request Forgery?


I figured the easiest way to get started is to talk about the root of the problem we're trying to solve. So, with that said, what is a Request Forgery? All a Request Forgery is, is a request that the user did not intend to make. That's it. So an attacker somehow creates a forged request, and submits it on the user's behalf. As it turns out, there are five main types of request forgeries:

 1. **From A JS Injection On The Target Site**: This happens if an attacker can get JS onto the page of a target site. Typically, this results from most froms of XSS vulnerabilities. If the attacker can get JS onto the page, they can do anything the user can do legitimately. So the best (and sometimes only) way to fix these types of attacks is to protect against XSS vulnerabilities.
 2. **From A Man-In-The-Middle Attack**: This happens when an attacker hijacks a request, and acts as the server (forwarding tampered requests to the real server). The only effective protection against this is the use of SSL with strong certificates. If the attacker can get in the middle, they can do anything the user can do. You cannot protect against this reasonably from the application layer.
 3. **From A Replay Attack**: This is similar to the Man-In-The-Middle Attack, but it doesn't require interception of the original request. It simply requires that the attacker watch the original request so they can steal the request payload. Then, they can re-submit the request while altering form data to do what they want. If you use SSL, you are protected against replay style attacks. There are other defenses, but we'll talk about them in a few minutes.
 4. **From A Browser-In-The-Middle Attack**: This happens when an attacker hijacks the browser of its victim. Since they have access to the browser, they can do anything the user can do. You cannot protect against this style of attack. It is up to the user to secure their browser.
 5. **From Another Site**: This happens when an attacker on another site (one they have control over) submits a request to the target site. The browser will send cookies to the target site, so if a user has permissions on the remote site, the action will be performed. No defense that we mentioned so far will effectively protect against this. Because it requires two sites to execute, it's called a Cross-Site-Request-Forgery (CSRF).


## Defense Against CSRF, Step 1

The first line of defense that we can put in to defend against CSRF is to include a hidden token in any sensitive form submissions. This is commonly referred to as a CSRF Token. The only requirement for effective defense against CSRF is that it is unique per user. So it's fairly common to use the user's session identifier in the form. The identifier cannot be accessed from the remote site (due to browser Cross-Site security policies). Therefore, it will become a proof-of-knowledge which prevents CSRF.

There are two significant problems with it though. The first is that it does nothing to combat replay attacks. That means that if I can sniff one request between the victim and the target server, I can fake my own attacks (note that if you use SSL, that's not a concern). The other issue is that if I can compromise a single request (via sniffing, or guessing the token, etc), I can compromise all requests in the future from that user. This is related to [session hijacking](http://en.wikipedia.org/wiki/Session_hijacking) attacks, but it is different because it can use the victims browser (so all validity checks would still pass).

## Defense Against CSRF, Step 2


We can improve our original concept by changing the token, so it's not the same for every request. We could do this by creating a separate derived token for each form. For example, we could use a cryptographic hash (like SHA512), and hash together the form name with the session token. This would mean that an attacker would need to get the token from the specific form they want to attack. But notice that it does nothing about protecting against replay attacks. And once an attacker compromises a specific form, they can attack it all they want. Still not good.

## Defense Against CSRF, Step 3


So let's take that concept of changing the token, to changing it for every request. We can do that by using a [random number generator](http://blog.ircmaxell.com/2011/07/random-number-generation-in-php.html) to generate the token. Then we can store the token in the user's session data, and invalidate it when we see it next. This makes the token a [nonce](http://en.wikipedia.org/wiki/Cryptographic_nonce) (a number used once). This protects us against replay attacks (since the number is only valid on the first submission), and it protects us against future attacks (compromising one nonce gives nothing for future nonces).

So there we have it. Here's a basic sample of what I'm talking about (Using [RandomLib](https://github.com/ircmaxell/RandomLib)):

```php
function getCSRFToken() {
    $generator = (new \RandomLib\Factory())->getMediumStrengthGenerator();
    $nonce = $generator->generateString(64);
    if (empty($_SESSION['csrf_tokens'])) {
        $_SESSION['csrf_tokens'] = array();
    }
    $_SESSION['csrf_tokens'][$nonce] = true;
    return $nonce;
}

function validateCSRFToken($token) {
    if (isset($_SESSION['csrf_tokens'][$token])) {
        unset($_SESSION['csrf_tokens'][$token]);
        return true;
    }
    return false;
}

//Render Form
$token = getCSRFToken();
echo '<input type="hidden" name="csrf_token" value="' . $token . '"/>'

//Validate Form
$token = isset($_POST['csrf_token']) ? $_POST['csrf_token'] : '';
$valid = !empty($token) && validateCSRFToken($token);
if (!$valid) {
    // Attack Detected! Fail!
}
```

Pretty simple, easy to implement, and gives us adequate protection against everything we can effectively protect against. That's what we want... Most frameworks provide this for you either out of the box, or with minimal configuration. But the key is that you want to be using random nonce tokens. Anything less can compromise forward security or introduce new attack vectors.