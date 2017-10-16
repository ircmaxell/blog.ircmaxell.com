---
layout: post
title: XSS - Web Application Security - Post 2
permalink: xss-web-application-security-post-2
date: 2011-04-01
comments: true
categories:
- Security
tags:
- PHP
- Security
- Web Application Security Series
- XSS
---

In the [first post of this series](http://blog.ircmaxell.com/2011/03/what-is-security-web-application.html), we looked at some fundamental concepts of Web Application Security, and introduced the concept of *Filter In, Escape Out*.  In today's post, we will be examining the single most prolific vulnerability plaguing web applications today: Cross-Site Scripting (otherwise known as XSS).  Not only is it prolific, it's also commonly under-estimated and is often just a low priority after-thought.  In reality, XSS is a formidable threat and needs to be treated as such.

<!--more-->
## What Is Cross-Site Scripting?

In one sentence, we could summarize XSS as: A user having the ability to inject a client-side script into a web page to be executed by other uses.  Now, what does that mean exactly?  Well, client-side scripts include any programming language that's designed to run in the browser or on the client's computer.  This can be JavaScript, but it also can be Flash, SilverLight, Java Applets, ActiveX Controls or VBScript.  Let's take an example to demonstrate the concept.  Let's say you have the following code:

```php
<input type="text" value="<?= $_GET['user']; ?>" />
```


What happens if a user passes in the following for $_GET['user']:

```html
foo"/><script type="javascript">alert("hi");</script><br class="

```


The following will be the generated HTML (whitespace added for clarity):

```html
<input type="text" value="foo"/>
  <script type="text/javascript">alert("hi");</script>
<br class="" />

```

As you should be able to see, we've now just performed an XSS attack!  In practice, the injected content will not be a simple alert, but something far worse...

## Why Should We Care?

Well, there are a few facets to why we should be significantly concerned about stopping XSS.  A few of the facets are quite trivial and are commonly seen as nothing more than an annoyance.  However, some of them are quite significant and can not only harm your users, but can harm you as well. Here are just some of the things that an attacker can use a XSS vulnerability to accomplish (In no particular order):

 * **Site Defacement**.  XSS vulnerabilities can be used to change the look of your site to just about anything the attacker wants.  This can make your site into a giant advertising banner for whatever message the attacker wants to push.  It can also make your site nothing more than a political statement.
 * **Distributing Malware**.  An attacker can use an XSS vulnerability to attach and distribute malware to each and every one of your visitors.  If that happens, Google will likely pull your site to (rightly) protect people from the threat your site poses.
 * **Link Farming**. Another common use is to inject links that the attacker wants to promote into your site.  This has the effect of making their sites appear more important to search engines and making your site seem less important (since you're linking to more pages, it can reduce your ranking).
 * **Enabling Other Vulnerabilities**.  An open XSS vulnerability can open additional attack vectors for your site.  We'll explore this in more detail in future posts about the other specific vulnerability types.
 * **Other Nasty Effects**.  With XSS, a smart attacker will have the ability to do just about anything to your site.  They can change content, make it appear like you're saying something that you're not, change your advertisements, etc.

## What Types Of XSS Are There?

There are two main types of XSS attacks.  The difference is actually rather simple.  You can either have Persistent XSS or Drive By XSS. Persistent XSS is when the attacker injects scripting into a stored page so that it's displayed to basically all users who view the page.  Drive By XSS is when the attacker manipulates the request in such a way that it will only show the injected scripting to the user who requested it.  The main difference is whether the injected script shows itself to other users.  Let's see a trivial example of each:

 1. Drive By XSS:
    ```php
    <b><?php echo $_GET['foo']; ?></b>
    ```

    - This is a drive by XSS vulnerability since the compromised data is not stored.

 2. Persistent XSS ($row comes from the database):
    ```php
    <b><?php echo $data['username']; ?></b>
    ```

    - This is a persistent XSS vulnerability since the compromised data was stored in the database prior to display.


There is a caveat however.  Some forms of Drive By XSS can be used to inject scripts on other users pages. This is usually done by passing a tampered URL to an unsuspecting victim.  But something important to note is that Drive By XSS will never effect every single user on the site, whereas Persistent XSS will.


For the purposes of XSS prevention, the distinction between the different types of XSS does not matter much, they are protected using the same techniques.  However when we look at other attack methods (including Cross Site Request Forgeries for example), the difference between the types will matter.  So it's important to understand the distinction now, since we will revisit it later.

## How Do We Prevent It?

Remember that last time we had talked about `Filter In, Escape Out`.  Well, that's going to form the basis of our defense against XSS attacks.  The basis of our defense will depend upon the nature of the content we wish to display.  For the purposes of XSS protection, let me assert that there are 3 types of content: Unformatted Content, Formatted Content and HTML Content.  All of the content that you put into a page (whether from user input or not) should fall firmly within one of the 3 categories.  Let's look at each one a little bit closer:

## Unformatted Content

This is the simplest type of content to work with (in general and for XSS prevention).  Basically, it's any data where you are not expecting any form of markup or formatting.  So a good example would be a post's title.  Another example would be a username.  What matters is the value, not the way it looks.


So, how do we protect Unformatted Content from XSS vulnerabilities?  Using a single function: [`htmlspecialchars()`](http://php.net/manual/en/function.htmlspecialchars.php).  This one function will escape all Unformatted Content and basically prevent XSS attacks **for any content passed in to it**.  So let's see an example:

**Unsafe Code**
```php
<b><?php echo $data['username']; ?></b>
```

**Safe Code** (Split out onto multiple lines for readability)
```php
<b><?php 
    echo htmlspecialchars(
        $data['username'], 
        ENT_QUOTES, 
        'UTF-8'
    ); 
?></b>
```

Note the usage of the character set parameter.  This is extremely important both for preventing additional attacks, and for preserving your content.  Make sure that you populate it correctly for the content you are displaying!

If you're using a templating engine such as [Twig](http://www.twig-project.org/) or [Smarty](http://www.smarty.net/), this should be done for you automatically.  However you still need to consult the documentation for the library that you are using to make sure that you are using it properly.  Each engine has the ability to be bypassed, so don't fall into the trap where you assume that you're safe just because you're using a templating engine.

## Formatted Content

This is a special type of content that uses non-HTML markup to introduce formatting into the data.  There are actually several methods of formatting that can be used for Formatted Content including BBCode, MarkDown, Wiki Syntax, Textile and Plain Text Formatting (using <pre>).

Unfortunately, protecting Formatted Content is really dependent upon the formatting and the formatter that you use.  My suggestion would be to be very careful about using third party libraries unless they are reasonably popular and well maintained.  There are a lot of implementations out there that were designed to function well, but were not designed with any thought of security and XSS prevention. 

As far as how to prevent XSS when writing a formatting library, I would suggest a good place to start is by being merciless and stripping out all unnecessary HTML right from the start.  When I say unnecessary, I mean that you should come up with a white-list of allowed HTML tags for the formatter, and strip everything else.  Then render the formatting into HTML.  Then, pass it back into a filter and strip out any attributes that may be dangerous while at the same time filtering those that exist to a white-list of known and acceptable values.  We'll cover that more when we discuss HTML Content.

## HTML Content

This content type uses HTML markup to format data.  That poses a very unique problem to us, since filtering and escaping HTML is not a trivial task.  But luckily for us, some very smart people have built libraries to do all of the difficult work for us.  So my suggestion would be that you use a well maintained sanitization library such as [HTMLPurifier](http://htmlpurifier.org/).  You shouldn't try to filter it on your own.  You shouldn't try running it through a function such as [strip_tags()](http://www.php.net/manual/en/function.strip-tags.php), since it doesn't really treat html properly and can still leave certain types of XSS in place (Especially if you allow any tags).  Stick to a well supported library and you'll be fine.

## When To Escape And Filter

Well, we know that we should filter input and escape output.  But when should we do that?  Should we do that when the data is stored?  Should we do it when the data is outputted?  Well, the best solution is to filter it when it comes in, and escape it when it goes out (Big surprise, I know).  So what does that mean from a practical standpoint? 

When filtering input, you should figure out what acceptable values for the particular content item are first.  Then, you should filter the input to those acceptable values.  So if you only want to allow alpha-numeric characters in a username, then when receiving input you should filter appropriately and reject any usernames that do not match appropriately.  By doing this diligently, only acceptable values should ever enter the database.

When escaping output, you should always escape just prior to output.  Never store an escaped string!  The reason for that is twofold.  First, you can never be 100% sure your escaping works perfectly.  So if you escape when you display, any fixes that you apply will work for all content rather than just new content.  Second, you can never be sure of the context with which you will be displaying the data when you store it.  Sure, you may only support HTML output now,  but what if requirements in the future change and you need to support another output format?  By escaping it only when you are finally going to display the data, you're making yourself flexible and safe at the same time.

When we introduce the concept of formatted content, we're also introducing a rather interesting question: "When do you render formatted content into HTML?".  I would also suggest that you render the formatted content when you output the content.  It does add a slight performance penalty, but it's worth while for the same reasons you shouldn't escape prior to storing the data.  The same should also be said for sanitization of user-submitted HTML content.  In short, you should always take care of any XSS cleaning methods you will apply right before you finally output the data.

## Further Reading

 * [OWASP XSS Prevention Cheat Sheet](http://www.owasp.org/index.php/XSS_(Cross_Site_Scripting)_Prevention_Cheat_Sheet)
 * [OWASP XSS Guide](http://www.owasp.org/index.php/Cross-site_Scripting_(XSS))
 * [WebAppSec Guide To Cross Site Scripting](http://projects.webappsec.org/w/page/13246920/Cross-Site-Scripting)
 * [Chris Shiflett on Character Sets and XSS](http://shiflett.org/blog/2005/dec/googles-xss-vulnerability)

## Conclusion

Now we've covered the single biggest vulnerability plaguing websites today.  It's not that hard of a concept to understand.  And it's not that hard of a vulnerability to circumvent.  We will be referencing this concept of Cross Site Scripting again in later articles, so be sure that you understand the concepts here as well as those we talked about in the first post of the series!  And as usual, feel free to leave a comment if there's anything that's not clear.

 1. [What Is Security - Web Application Security Series - Post 1](http://blog.ircmaxell.com/2011/03/what-is-security-web-application.html)
 2. XSS - Web Application Security Series - Post 2
