---
layout: post
title: In Response To: Building Secured Web Applications Using PHP - The Basics
permalink: in-response-to-building-secured-web
date: 2011-06-24
comments: true
categories:
tags:
- Best Practice
- PHP
- Rant
- Security
---

Today an article popped into my feed reader that raise my eyebrows.  The article's title is "[Building Secured Web Applications Using PHP - The Basics](http://noobcode.blogspot.com/2011/05/building-secured-web-applications-using.html)".  The summary of the item looked interesting, so I decided to open it up...


What I found blew me away.  It was filled with loads of bad information including some down-right wrong suggestions.  Let me go through point by point and shed some light on the subject...

<!--more-->

## We Can Get Outside Information Through



Yes, everyone realizes that you can get outside information in through the standard methods ($_GET, $_POST, $_REQUEST, $_COOKIE, etc).  Reiterating it here seems kind of a weird start to an article on security, but I can see that it's targeted towards beginners. 


However, there's a bunch left unstated, and some wrong information stated.  It is better to use $_GET or $_POST directly in the general term.  But if you're building a generic function that uses input, it is not a security issue to use $_REQUEST.  Contrary to popular opinion, $_POST is no safer than $_GET.  Therefore, it's no issue to use $_REQUEST over one of the others.  Of course, if you know where to expect your data from, use the proper variable.  But in those cases that you can't predetermine it, just use $_REQUEST, it's ok.


What about $_SERVER?  That didn't make the list, yet an attacker can certainly send harmful data down at least some of the variables in the $_SERVER array (REQUEST_URI, QUERY_STRING and any of the HTTP_\* variables).  And depending on the webserver and configuration being used, others may be able to be faked as well. 


What about data from a "trusted" source such as a session, the database or filesystem?  Chances are that the data in there came from a user at one point in time.  Why should we magically trust it just because it came from somewhere we trust (Hint: we shouldn't trust it)? 


My usual statement as far as what data to trust is: If it's hard coded in the source code of the application, it `may` be ok to trust it.  Otherwise, don't...

## Register Global



It's 2011.  Really.  Why do we still have issues with a deprecated language feature?  Thankfully it'll be removed in the next release (fingers crossed for 5.4, but def in 6)...

## Checking The Data Type



I am assuming that the author meant: checking the data type of user input.  If that's the case, all data is either a string, or an array of strings.  Therefore, is_int($_POST['age']) will **always** return false.  It's a string, not an integer.  If you want to check if it contains only number, you can use the ctype_digit() function. 


But validation is typically more complex than that.  For that reason, you should use either custom write your validation logic for the task at hand, or just use the filter_input function provided by PHP. 

## Cleaning Outside Information



HTML tags can never do harm to a database.  The only time they can do harm is when they enter a document that's interpreted as HTML (parts of an RSS feed, or the main HTML document of a page).  Yes, you can use strip_tags and htmlspecialchars to help try to clean up the data.  But preventing XSS is a significantly harder problem to solve than simply running a function on the data. 


If you want to know how to protect against Cross Site Scripting attacks, either read [my blog post](http://blog.ircmaxell.com/2011/04/xss-web-application-security-post-2.html) on the subject, visit [OWASP.org](http://owasp.org/) or come see me [talk next week](http://blog.ircmaxell.com/2011/06/talk-on-xss-nyphp-in-collaboration-with.html)...

## Checking Outside Information With Regular Expression



Yes, you can do that.  But see my above comments for "Checking The Data Type"

## Storing Information



This is just plain wrong.  Sure, everyone who has access to the webserver can view text files stored on the server.  But did you know the same is true with session data (after all, it's just a flat file by default)?  And did you know the same is true with a database?!?!?!  Databases store their information on disks.  Anyone who has access can read all the data that's stored (some small exceptions exist)!  That's why we have a system that provides filesystem permissions.  If you have access to other peoples files on your server, get a new host.  So in reality, as long as you don't do anything stupid, storing data in a text file is just as safe (sometimes safer) as in a database.


Let me say that again:  Storing data in a text file can be just as safe if not safer than in a database. 

## Handling Errors



The author made the suggestion to turn off errors on a production server.  On the surface, this seems like a good idea.  However, I will assert that it's the wrong advice.  Any error that happens is a bug in your code.  You should be monitoring error logs and fixing those bugs as they appear.  Therefore, the only change you should make on a production server is to set display_errors to Off.  They should still be reported, otherwise you'll lose valuable debugging information.


This is especially important to aid in detecting security breaches.  What happens if someone manages to inject PHP code into your server?  If they throw an error, you'd see an error in your logs that may tip you off to the attack.  If you have error_reporting turned off, you'd miss these clues.  Sure, it seems like a streatch, but the point stands: errors should **never** be ignored.

## MySQL Security



At this point the author actually conveys some meaningful information.  Point 1 under MySQL Security is basically stating the Principle of Lease Privilege.  And it is very good advice.  Point 2 is basically describing how SQL Injection works, and again is pretty good at doing it.

## Escaping The Quotes



And then the author falls down to new levels of failure.  Magic Quotes?  It's 2011!  That setting shouldn't even exist anymore (it's deprecated now).  It is not secure for a nubmer of reasons.  And then addslashes()?  It does work, but only if you have tight control over your environment.  So it's highly recommended to avoid it.


And then we come to the last line of the article.  mysql_real_escape_string()...  Yes, it does work.  But you need to be careful.  You need to setup the database connection properly (calling mysql_set_charset() instead of SET NAMES). 


But where's the industry standard best-practice method of defending against SQL Injection?  Where is Parameterized Queries (Prepared Statements)?  Conpicuously missing...

## In The End...



I wasn't going to post a response to this.  But when I saw it on [PHPDeveloper.org](http://phpdeveloper.org/), I felt like I had to.  Most people will likely realize the misinformation provided and safely ignore it.  But I'm posting this because of those who don't realize it's bad advice.


Security is not something you can learn in a page.  It's not something that you can learn in a single book.  It takes a lot of time and effort.  It should not be trivialized into a simple "Do this and you'll be secure" style post.  It sends the wrong message...

[![](http://1.bp.blogspot.com/-3-j8ifBTJ5w/TgTUIZqfOJI/AAAAAAAAACM/WEwgXPtHCZQ/s320/duty_calls.png)](http://xkcd.com/386/)

Thanks for reading my vent/rant...
