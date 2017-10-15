---
layout: post
title: Don't Worry About BREACH
permalink: dont-worry-about-breach
date: 2013-08-08
comments: true
categories:
tags:
- Cryptography
- CSRF
- PHP
- Rant
- Security
- XSS
---

Last week at the BlackHat security conference, a new attack on SSL secured content was unveiled. This attack is called [BREACH](http://breachattack.com/), and has been generating a lot of buz on the internet. Tech blogs have been plastering their sites with articles about how there's no fix, and how you can try to defend against BREACH. Well respected security people have [been writing about it](http://blog.astrumfutura.com/2013/08/breach-attacks-extracting-https-encrypted-data-in-under-a-minute-without-encryption-cracking/). 

And I'm here to say don't worry about it. <!--more-->
## Disclaimer


This post and my opinion is based on my personal research into the attack based on what's available. If someone can prove me wrong, I'll be more than happy to change my position and rewrite this post. 

With that said, let's go on.
## What Is BREACH


BREACH is, at its core, an attack against secured HTTPS traffic that can allow attackers to extract information from within the encrypted body of information. Basically, it leverages the details of HTTP compression to identify if a string is already present on the page. 

That means that an attacker can make repeated guesses to find any content that appears on the page. One of the biggest places this seems like a problem is with CSRF tokens. Somewhere on your page you'll have a hidden form element like:
```php
<input type="hidden" name="csrf" value="1sfgafu23r23p9oig" />

```


By guessing different "values", an attacker can determine the actual value (over thousands of requests). That's because compression will see the content in two places on the page. So by watching the size change of the response, they can determine what the value was.
 * Guess: `1sfa` - Total Content Length: 950
 * Guess: `1sfb` - Total Content Length: 950
 * Guess: `1sfc` - Total Content Length: 950
 * ...
 * Guess: `1sfg` - Total Content Length: 949


The real attack is a lot more complicated (and sophisticated). But that's the basic premise. It's actually very similar to a timing attack.

There are 3 requirements for this attack to work:
 * Using HTTP Compression (GZIP / DEFLATE)
 * Reflection of user-supplied-data
 * A secret to steal

The reflection piece means that user-supplied data (such as a URL argument) is outputted somewhere (note: where is not important) on the page in a predictable fashion (it can be escaped).


So yes, this is significant. It is a massive breach. It has significant privacy concerns (imagine an ISP being able to check for the presence of certain words in the content you're viewing). It will affect future designs of systems. But it's not the holy grail that people are making it out to be. Let's see why:
## Only Body Content Is Available


Note that since this leverages details of HTTP compression (gzip or deflate), the headers sent by the server are not subject to snooping. That means that unless you put cookie values into the body of the request, cookies (and other header content) are safe from this technique.

Note the significance there. Unless you embed the session id into the body of the request (which isn't best practice anyway), this attack **cannot** be used for session attacks. 

Let's review that again. Unless the attacker has the session id already (via another vulnerability), or you have violated best practice and embedded your session id in the body of the page, the session itself is not vulnerable to BREACH.
## Cross Origin Problems


Since you can't get the session id, the best attack you can do is a browser based attack (via an embedded iframe or the like). In this case, your code would have the browser issue many requests from an iframe, and measure the results. That way you could extract the CSRF token from an iframe without having access to the content!!!

But wait a minute. Browsers protect us from having access to the cross-origin data. So even if an attacker was able to get to you in an iframe, they couldn't see the size of the response to actually execute the attack in-browser...
## An Actual Problem


So there is one case where this attack is actually plausible for gaining access to session based information. If an attacker can get access to watch your traffic (think of an ISP), and get you onto a page which would issue iframe requests, then it's possible for the attacker to snoop out a CSRF token. The attacker could then use that deciphered token to issue a post request (via a web-form, or the like) with the proper CSRF token. Which would be interpreted by the remote server correctly (since it can't tell the difference between that and a normal request).

However, this requires someone to literally be able to watch your raw packet stream. NSA jokes aside, if a bad guy can do that, they can already do some significant damage. So while it is very much an issue, and reduces the level of security of HTTPS, it's practically not significant.

But wait a minute. If you've followed my recommendations in the past about [Preventing CSRF Attacks](http://blog.ircmaxell.com/2013/02/preventing-csrf-attacks.html), you're already safe from this vector! Since each CSRF token is a nonce (number used once), it's never in more than one request body. Meaning that the attacker cannot guess it.

So in sort, you're vulnerable if you're using standard (static) CSRF tokens. If you're using randomized nonce's, you're safe.
## The True Problem


The true problem here is information disclosure. If it exists as text on the page, the attacker can guess it. This is a major problem for things like bank sites, where your account number may be showing on the page in plain text. An attacker can use this style attack to determine your account number. Which is a problem.

But they can't use it to issue fake requests (since they can't compromise the session). So it's a problem (a big one), but not an `all-is-lost` one. 
## The Bottom Line


SSL has traditionally provided three types of protection:
 * `Identity` - You're talking to who you thought you were talking to (via certificates).
 * `Privacy` - Nobody can see what you're saying.
 * `Message Authentication` - The message that was sent is the message that was received.


This attack has no effect on `Identity`. It also has no effect on `Message Authentication` (since the request still needs to originate at the source browser). Instead, this attack compromises only the privacy component.

In effect, this attack reduces HTTPS to encrypting headers only. Most other content on the page is susceptible to some sort of sniffing (depending on the presence of XSS for example).

Now realize that encrypting the headers is still quite significant. An attacker can't tell what URL you're visiting (unless they are setting it). They can't tell what host (only the IP address of the server). They can't tell any header. They can't tell any cookie. 
## Protections


I said don't worry about this attack. **Well, I lied.** There are some relatively simple precautions that you can take:
 1. Use a randomized nonce-based CSRF token. Seriously, you should have been doing that anyway.
 2. Disable compression for pages containing sensitive information (banks, health info, etc). If you're concerned about this, just disable it for all pages.
 3. Randomly pad responses. Note that the length of padding will vary significantly (it needs to be random length). So you'd want to add between 1 character and say 32 characters somewhere in the body.

```php
$randomData = mcrypt_create_iv(25, MCRYPT_DEV_URANDOM);
echo "<!--"
    . substr(
        base64_encode($randomData), 
        0, 
        ord($randomData[24]) % 32
    ) 
    . "-->";

```

## Protecting Yourself


The above works if you have control over the application. If you only have control over your browser, you can protect yourself from this attack using a simple browser extension: [Change HTTP Request Header](https://chrome.google.com/webstore/detail/change-http-request-heade/ppmibgfeefcglejjlpeihfdimbkfbbnm/related?hl=en) (Chrome).

Basically, I set up an automatic profile to match all sites and alter the request header `Accept-Encoding` to be `Accept-Encoding: identity`, which disables gzip and deflate for all compliant servers. This should mean that any traffic you send to any server should be safe from this style attack...
## Wrapping Up


BREACH is a serious vulnerability. But it's not going to live up to the hype that it's being given in the presses and on the blogs. If you're following best practices, attackers need to go out of their way (significantly) to be able to execute an attack. They'd need to compromise some network component between you and the server. If you're on open wifi, this is trivial. Otherwise, it's not trivial.

Once they compromise the connection, they need to get you to a compromised URL. We know with malware that this isn't hard. It's not trivially easy, but it's pretty close to it.

Once they get you to a compromised URL, they need to have data on the page they need to find. Session based secrets should be safe (if you're following best practice).

It's definitely an issue. But it's not worth running around making rash decisions. And it's not worth flipping out over.

Let me make one thing clear. XSS and SQLi (among others) are still a WAY more practical attack vector into your sites. Focus on fixing those issues. There's no solid fix for BREACH, so don't panic over it...