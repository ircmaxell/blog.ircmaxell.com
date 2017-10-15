---
layout: post
title: Building A Multi-Version Build System
permalink: building-multi-version-build-system
date: 2012-07-09
comments: true
categories:
tags:
- Build
- CryptLib
- Jenkins
- PasswordLib
- PHP
---

I've been using Jenkins to manage builds of my projects for a while now. This was fine for a while, but now that my projects need to support multiple versions of PHP, it left something to be desired. I wanted a system that could build against multiple versions of PHP. And more so, I wanted to be able to build against multiple compiles of the same version (different options, etc). This is how I built just such a system...<!--more-->
## The Design


I had toyed around with the idea of running multiple Jenkins slaves, each with a different environment. That way, each project would be built on all of the slaves (potentially at the same time). That has some significant advantages, in that each environment would be completely separate, and hence could be built against different libraries, etc. However it posed a huge problem. Each one of those slaves would require a VM. And running 5 or 10 slaves would be a daunting task for RAM alone. Not to mention managing updates for 11 operating systems, fixing build issues, etc... So I had to find a better way.

I decided to settle upon a single OS install build system. I would build multiple versions of PHP, and have each Jenkins job "pick" the right version for the build... That way, I could choose the targets for each project, and build them separately (tracking them separately as well). By doing so, I can clearly separate failures on each different build, and clearly compare them.
## The Hardware


While planning this build system, I researched a number of different hardware alternatives. The need was clear: a multi-core x64 processor with decent power and support for a good bit of RAM. I also wanted something that would fit in my apartment and not cost me a ton in power consumption. The choice was clear. I purchased a base-model Mac Mini for the task. It came with 2gb of RAM, but I can upgrade it down the road to as much as 16gb... 
## The Operating System


I chose CentOS 6.2 for the build system. I wanted a server operating system that would be easy to manage. I've got a lot of experience with managing CentOS platforms, so it was the natural choice. So the first thing I did to the Mac Mini was to install CentOS. Then, I installed the php build system dependencies (automake, bison, re2c, etc).
## Building PHP


I wanted a script that would handle compiling the versions of PHP for me. I found [this one](http://derickrethans.nl/multiple-php-version-setup.html) online, and used it as a base.  After modifying it for my needs, I came up with [this build script](https://gist.github.com/3071768). Running it is simple, just tell it the version to build, and it does the rest. The only requirements are a git clone of [PHP](https://github.com/php/php-src) in php-src, and a git clone of [XDebug](https://github.com/derickr/xdebug) in xdebug in the same directory as the build script. It handles the rest.

Using it is simple. To build trunk:
```php
./php-build master
./php-build master debug
./php-build master debug zts
./php-build master nodebug nozts 32bit

```


This will install 4 versions of PHP trunk. They are installed into `/usr/local/php/{prefix}`. In this case, the 4 would be installed into: * master
 * master-debug
 * master-debug-zts
 * master-32bit

Then, I set up a cron-job to build master, 5.4dev and 5.3dev (head of the branch for each version, so the new release).
## Running PHP


Now that we have our builds, we need the ability to run them. You could hard-code the paths, but then things like PEAR which expect only one version would have some problems. So initially, to install my PEAR dependencies, I symlinked `/usr/local/bin/php` to one of the builds (5.4dev to be exact). Then, I installed pear into a central location (`/usr/local/lib/php` to be exact), and installed all of my dependencies (phing, phpunit, etc). So now all of those dependencies are expecting PHP to be at `/usr/local/lib/php`.

I experimented around with the idea of changing symlinks for each build. But that would be an issue as I could never run multiple builds in parallel on different versions. In addition, it made life a PITA when running PHP by hand. So, I decided to write another bash script to determine the version of PHP to run. Here's [that script](https://gist.github.com/3071845). 

Now if you look closely, there are two ways to pick the version. For builds, we just set the `PHP` environment variable to the name of the branch we want to run. For one-off command line execution, we can just add the version name right after php. So:
```php
$ php 5.4dev -v
PHP 5.4.5-dev (cli) (built: Jul  6 2012 19:17:31) 
$ php master -v
PHP 5.5.0-dev (cli) (built: Jul  6 2012 18:36:18)

```

## Setting Up Jenkins


After I had PHP setup, I installed Jenkins and started setting it up for the builds. I used something similar to the [PHP Template](http://jenkins-php.org/), but tweaked for my needs. Then I started a job for building [PasswordLib](https://github.com/ircmaxell/PHP-PasswordLib) via master (5.5). I built it just like a normal Jenkins install, with the exception of one plugin: EnvInject. I used that to inject an environment variable to choose which version of PHP is running. I set it to `PHP=master` for this build, and ran it. Everything worked like a charm. (Well, not really, it took days to get this working right, but that's the magic of a post, it eliminates trial and error)...

After I had it running how I wanted, I copied the project for 5.4. Then I just edited that one environment variable to `PHP=5.4dev`. When I built it, it indeed built with 5.4 instead, and everything worked the first time (really, this did actually happen). Then I copied it for 5.3. Now I had 3 jobs, each building against a different version of PHP. You could see the time differences, and even differences in skipped tests.

I then repeated the setup for my other project [CryptLib](https://github.com/ircmaxell/PHP-CryptLib).
## Wrapping Up


After all of this, I am left with a build system that builds nightly against the latest in the repo. If I find a bug in a specific type of compile, I can add that to the build cron job and prevent regressions in the future. Overall, I'm fairly happy with the results. I'd prefer to not have as much duplication (to have one job build against multiple versions), but with the reporting limitations and how I want to track everything separately, this should suffice for now. 

Check out the build system right now at [build.ircmaxell.com](http://build.ircmaxell.com/)...


Questions? Comments? Snide Remarks? Leave a comment, follow up on twitter, or post a follow up blog!