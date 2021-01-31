---
layout: post
title: On PSR-0 Being Included In PHP's Core
permalink: 2011/11/on-psr-0-being-included-in-phps-core.html
date: 2011-11-03
comments: true
categories:
- Rant
tags:
- Best Practice
- Inconsistencies
- PHP
- Programming
- Rant
---
## Note: The voting phase has begun on php.net.  If you have an svn account somewhere on php.net, vote and share your opinion: [wiki.php.net SPLClassLoader Vote](https://wiki.php.net/rfc/splclassloader/vote)


Recently there has been a rather heated and intense discussion on whether the [PSR-0 autoloader "standard"](https://github.com/php-fig/fig-standards/blob/master/accepted/PSR-0.md) should be included as part of the [PHP core (in ext/spl to be exact)](https://wiki.php.net/rfc/splclassloader).  I've tried to stay out of the discussion and have successfully done so.  Until today.  I feel that there's something that's been missing to the discussion.  So rather then posting this to the internals list, I feel it's better served by a blog post on the subject.  So here's my take on it.

**TL;DR:**

I don't think it should be included in the core.

<!--more-->
## Why I Am Posting This


This comment on the internals list led me to write this post:

> With the point to being included in `/ext/spl/`; is to give a sense of "justification" of this standard and a base in which to push forward.


IMHO, that's the exact opposite of a proper justification.  That's saying "we want to justify the standard, so include it in the language" instead of what you should be saying in that "the standard is justified, so the language should support it".  We're talking about a language level implementation here, not adding capability to the language...  It's 100% possible to do everything you need to in PHP code, so it's not like you're adding support for it.  You're adding the implementation for it.

I can see 3 main issues with implementing `PSR-0` in core at this time:

## Issue #1 - It is inconsistent


It does not have any way of handling or even acknowledging edge cases such as the case sensitivity issue that was brought up earlier.  Because of that, it has internal inconsistencies with respect to how PHP handles things.  This alone should be enough to kill any language level implementation.  PHP has enough language level inconsistencies without adding more.  At least the current autoloader implementation in the core is consistent in that all filenames are lowercased.  `PSR-0` doesn't even address that.  Sure, you could say that falls under the pervue of coding standards, but that's not the job of the language.  The language is supposed to provide implementation without bias.  Implementing `PSR-0` here would bias the language towards a specific coding syntax and style (considering that if you don't follow that style, it won't work and things will sporadically break on different operating systems).  So the argument of `while (consistency) learning_curve--` is actually one for keeping this out of the core since the implementation has several inconsistencies with PHP itself (case sensitivities being the most obvious).

## Issue #2 - It is not a standard

`PSR-0` is not a standard in the true sense of the word.  From my knowledge, there was no public RFC for it, and it's missing quite a bit from what other communities require in a standard.  First off, there's no listed scope or motivation explicitly listed (which would then nail down what the standard is trying to accomplish).  Instead, it's just loosely defined based off the implementation.  Secondly, considerations such as security, backwards-compatibility and performance implications are not actually expressed in the standard.  This is a major problem since it doesn't even appear that these were considered (most RFCs have these listed explicitly for that reason).  Third, there are no acknowledgement or references at all.  While this may not seem like an issue, it is because right now there is no way of knowing who to contact or if there was research done to actually justify the standard.  


Remember, just because some people come to a conclusion doesn't make it a standard.  Almost everything we call a standard has had a formal RFC process with all of these steps (Such as [RFC2616](http://www.ietf.org/rfc/rfc2616.txt) and [RFC4329](http://www.rfc-editor.org/rfc/rfc4329.txt)).  While I think standardizing this is good for the community, I think doing it as a formal standard is extremely important.  Why is that?  Because a formal RFC shows the community what went into the proposal and exactly what was considered.  Right now, the only groups that really knew anything prior to it being accepted were those involved in constructing it.  How many non-project developers were talked to or reached out to (in this context, non-project refers to developers who have no vested interest in any open-source (or closed) projects.  More those that are developing applications and one-offs, not frameworks)?  Were considerations made for those developers who are building one-off or custom implementations?  Were considerations made for those who already have implementations on other systems (such as spl_autoload for example)?  This wasn't mentioned on any of the php.net lists until May of this year, after it was accepted and when it was asked to be included in the core...


Don't get me wrong, I think that creating standards is great and I don't want to knock the intent of the team that put this together.  In fact I think it's very important to do.  But now the standard is trying to be pushed into and onto the general community.  That's where the problem comes.  This "standard" (quotes indicating the above issues with that word) was created informally for and by a subset of developers (realistically, a very small subset).  Now that standard is trying to be applied to the community as a whole.  It doesn't work that way.  It shouldn't work that way.  If all the framework developers want to standardize their implementations, more power to them!  But if you're looking to enforce that standard beyond the scope of those that created and agree (which you are here), that's when it becomes a problem.  The language shouldn't enforce standards of the few.  That's not its job.  Its job is to support all use cases that it chooses.  Given PHP's history, that usecase is pretty well defined, and it's a significantly larger superset of usecases than most frameworks are targeting.

## Issue #3 - There's nothing for the core to gain

`PSR-0` is not perfect.  It doesn't try to be, but it still is not.  It's far worse and more counter-productive to force a one-size-fits-all solution on all projects than to take a neutral stance.  Aside from enforcing the standard, there is \*nothing\* practically that will be gained by including it in the core.  So I would argue it's more counter-productive to the eco-system to enforce a one-size-fits-all solution that doesn't take into account the needs of the eco-system (frameworks are a very small part of that.  A vocal part, but a very small one) than it is to let one or more "standards" exist and be chosen between.

## Conclusion

In conclusion, let me make one plea:

> Keep core PHP interests separate from framework interests.  PHP is a language with a complete different set of goals and constraints than the frameworks that are developed for it.  If they overlap, great.  But don't confuse them.  They are distinctly different...


And apparently I'm not the only one who thinks this way...  There are tons of blogs and posts along these lines, include one from [@go_oh](http://twitter.com/#!/go_oh): [Why the PSR-0 Classloader does not belong in SPL](http://gooh.posterous.com/why-the-psr-0-classloader-does-not-belong-int).  If you have an opinion on this matter, let it be heard!  Leave a comment, or write your own post and let me know (I'll keep a list going here if people get back to me on it)...

## Edit - Some Explanation Of Inconsistencies Of PSR-0

It seems like people still aren't grasping the inconsistencies with PSR-0 and the rest of the PHP language.  Let me go through a few examples...

### Case Sensitivity

Identifiers in PHP (such as class names) are case insensitive.  Some filesystems however are case sensitive (NTFS being the most common, but not the only one).  The problem here is that the mapping from PHP identifiers to filesystem identifiers in PSR-0 is case sensitive.  So it's completely possible to create code that works on some machines and not others, or that breaks in certain circumstances but not others.

Let's say we have a file stored in `Foo.php`:

```php
new Foo();
new foo();
```

That will work on all systems and at all times with PSR-0.  However, if we switch the two around, we run into trouble:

```php
new foo();
new Foo();
```

That will work fine on case insensitive filesystems such as NTFS, but fail on case sensitive ones.  So you can develop code that works quite fine on Windows, but when you push to Linux will fail.

### Doesn't play nice with other loaders

If a file doesn't exist, PSR-0 doesn't play nice with other autoloaders.  It will try to require the file, but then the require will fail and fatal error out.  This is a problem since a later autoloader may know how to load it.  So it's not following the normal convention of "if you can't load it, don't error out".  This is fine if all code that lives in the application follows PSR-0 guidelines, but it makes interoperating with code using a different loader system/standard potentially difficult.  Here's an example using the [SPLClassLoader](https://gist.github.com/221634) specified in PSR-0:

Let's say you have a loader defined as `new SplClassLoader('foo', '/lib/foo/');`.  So that would only load classes from ``\foo\\*`` namespace (which is good practice to limit it).  Now what happens if I need to add a class to that namespace (such as `\foo\bar()` stored in `/lib/myfoo/foo/bar.php`).  Note that it's 100% valid and allowed PHP to do so.  Now, when I do:

```php
new \foo\bar;
```

What happens depends on the order of the autoloaders.  If I load mine first and then the foo one, it will work fine.  But if I load the foo one (such as provided by a framework), the whole application will fatal error.


Now, I know you're thinking, "it's not a good idea to do that".  But there are examples of cases similar to that happening right now (Kohana for one).  The point is, the language supports that 100%.  So why add something that could **fail** if you're doing something that's otherwise valid...  And we're not talking about just not working, we're talking about throwing a fatal error...

### Multiple Classes Map To The Same File


With PSR-0, multiple classes actually map to the same file.  For example, all of the following map to the same file (`Foo/Bar/Baz.php`):

 * `\Foo\Bar\Baz`
 * `\Foo\Bar_Baz`
 * `\Foo_Bar_Baz`

So, assuming the three classes didn't all actually live in that one file (for example, they could be autoloaded by another autoloader), consider the following code:

```php
new \Foo\Bar\Baz;
new \Foo\Bar_Baz;
new \Foo_Bar_Baz;
```

PSR-0 will **not** play nice here.  It will try to load the same file 3 times.  And when it does, it will fail since it's using `require` over `require_once`...  So it'll fatal error because it included the same file twice (and get duplicate class definition errors, etc).  Something that's 100% valid PHP (those 3 classes are distinct) and can have valid use cases (interacting with PEAR for example) would mysteriously raise unrelated fatal errors...


There are other inconsistencies, but those are more related to how the class is structured itself rather than the "standard" (example: you can set the namespace separator to something that will completely bork other included libraries)...
