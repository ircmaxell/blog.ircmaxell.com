---
layout: post
title: Anatomy of an Attack: How I Hacked StackOverflow
permalink: anatomy-of-attack-how-i-hacked
date: 2012-11-12
comments: true
categories:
- Security
tags:
- Anatomy of an Attack
- PHP
- Security
- StackOverflow
---

Almost two years ago I had stumbled upon a pretty significant vulnerability in the StackExchange network. I say stumbled, because I wasn't actually trying to attack the site. Circumstance just showed me a door. The actual attack is pretty interesting, and it holds a lesson for everybody who builds or maintains websites or server infrastructure. So here's the story on how I hacked StackOverflow...

<!--more-->

## The Setup


At the time, I was working for a small company which had a firewall that was rather draconian. It would strip all non-HTTP/1.1 spec headers from requests and responses (Actually, it stripped some valid HTTP/1.1 headers as well). Something which played hell with modern websites which rely on things like `X-Requested-With.` So for most of my non-internal usage, I had setup a proxy. 

I had a few public servers at the time, so I just installed Squid on one of them. I was somewhat smart with it, and limited its connections to 127.0.0.1. I would then setup a SSH tunnel to the server and point my browser to a proxy on localhost. The browser would connect to the tunnel, which would connect to the server's squid. All was better. Not only was my connection secure, but it also enabled me to use modern websites without any issue.

For those of you who would point out the ethical implications of this, I would point you to the fact that I had access to do this. It wasn't just that I could, I was explicitly told to use it, as we had to work with some of those sites that didn't work through the firewall. So I wasn't doing anything "wrong".
## The Attack


So I was hanging out on StackOverflow's chat fairly frequently at that point. At that time, it was still very new, and still had a bug or two. One day I started noticing stack traces on the main site. I didn't think anything of it at that point, because I'd been used to seeing them all over the internet. In fact, almost every time I got an error page on an ASP.NET site, I'd see a stack trace. But at this point, I didn't put 2+2 together. 

It wasn't until I noticed a new menu item in the chat application that it really clicked. This new menu item was named "Admin". Curious, I clicked the link, figuring I'd be immediately denied access. What happened next surprised me. Not only was I not denied access, but I was granted full access to everything. I had the developer console to see what people were doing. I had a database query interface where I could directly query any database that I wanted. I had admin access to chat. 
## What Happened Next


The next thing that I did was what I felt was the responsible thing to do: I pinged a moderator. In a few short minutes, I was in a private chat with the moderator as well as two developers. We found the cause of the issue in about 10 minutes. They had a workaround in place about 10 minutes later. The full fix took a few hours, but it was quickly done and rolled out. Really, they could not have responded better. I still have the chat log, and let's just say that those developers deserve every accolade that I can give them. They responded quickly and professionally. And they solved the problem within minutes of me reporting it.
## The Vulnerability


If you're clever, you should be able to figure out what happened. But in case you didn't, here's how it went down. When I had my connection proxied through Squid, it added a `X-Forwarded-For` header. The value of this header was the IP of my source browser which made the request. But because of the SSH tunnel, the IP was localhost. To Squid, there was no difference between my browser and local. So it added `X-Forwarded-For: 127.0.0.1`...

The really interesting part was what ASP was reporting. When they configured a page which would dump the raw request headers, my requests came through as `Remote_Addr: 127.0.0.1`!!! In their application, they were checking the correct header value. But IIS was misconfigured to rewrite `Remote_Addr` from `X-Forwarded-For` if it existed. So thanks to a misconfiguration, I was able to get admin access as easily as using my proxy.
## The Takeaway


There are a few takeaways from this that I think are important to point out. The first is the simple one. Never rely upon `X-Forwarded-For` for anything with respect to security. Always use `Remote_Addr`. And given that, I think it's worth asking the question if you need IP based security in the first place. Or at least don't rely on IP based security, and just use it as a defense-in-depth tool. But don't rely on it.

The next takeaway is an interesting one. It's worth noting that the developers did use the proper header check. This takeaway is that you should never blindly trust your infrastructure. This attack was possible because of a difference of configuration between the server and the application. Little things like that happen every day. The application assumes one thing, and the server assumes another. The problem is that these types of trust can completely undermine security. In this case, the developers trusted the header value (which I think is reasonable), but the server was misconfigured. Of course there are going to be cases where you have to trust the server or other components, but the point here is that blind trust isn't a good thing. Think about it, and put layers of defense in there to protect against it.

The third takeaway is a very positive one. The SO team was absolutely incredible to deal with during this. They were fast, responsive and reasonable. They asked for my help (which I gladly gave), and were both professional and respectful. And not only did they do all of this, but they found and fixed the exact problem faster than I would have ever expected. I really can't talk up the developers enough. They did a fantastic job. We should all take a lesson from them. Treat vulnerability reports seriously. Respond professionally and quickly. And work the problem while trying not to create new ones...
## Applying This To PHP


The interesting thing here is that PHP applications may have the same style vulnerability. Check out [Symfony2's Request class](https://github.com/symfony/symfony/blob/master/src/Symfony/Component/HttpFoundation/Request.php#L589). On the surface it looks great. Until you notice that it uses a static variable to determine if it should use the proxy information. That means that if ANY part of your application wants proxy information (such as a logging class), all of your application after that will get the proxied information. So to see if you're vulnerable to this style attack, grep your code for `$request->trustProxy()`. Also note that there's no in-built mechanism to untrust the proxy. Once it switches to true, it will stay true. Sounds like a major design flaw to me...

It's worth nothing that Zend Framework 2 does not have this functionality. They have an [IP session validator](https://github.com/zendframework/zf2/blob/master/library/Zend/Session/Validator/RemoteAddr.php#L93), which behaves similar to Symfony's Request class (in terms of getting the IP). However, Zend Framework 1 did have functionality to [get the IP address](https://github.com/komola/ZendFramework/blob/master/Controller/Request/Http.php#L1054). And in my opinion, this is the right way to do it. Don't rely on brittle state or even global state. Have the requestor explicitly choose what they want, defaulting to the secure alternative.
## Conclusion


This issue came about because of a combination of issues. Each by themselves is very easy to overlook and has little consequence to the overall application. But when you combine them in the right way, you get a very serious security issue. And the biggest lesson is that you really can't trust anything outside of your application. If you can code around it (such as not trusting headers like REMOTE_ADDR), then you can make your application more secure. But most of all, think about the code you write and the systems you build. And then support them. 