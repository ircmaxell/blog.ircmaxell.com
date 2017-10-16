---
layout: post
title: "Security Review: Creating a Secure PHP Login Script"
permalink: security-review-creating-secure-php
date: 2011-08-01
comments: true
categories:
- Security
tags:
- Best Practice
- Code Review
- PHP
- Rant
- Security
---

The other day, an article popped up in my feed reader that had a very interesting title (to me at least), [Simple and Secure Login Script](http://www.devshed.com/c/a/PHP/Creating-a-Secure-PHP-Login-Script-59941/).  As usual, I decided to click the link and give the article a read.  Not overly shocking was the fact that I didn’t find the content of the article to be, how shall I say this…, overly factual.  It’s not really a “tutorial”, but more of a “here’s some code that’s secure”.  A quick review of the code found more than one vulnerability, and some significant things that I would change about it (as well as a few “really bad practices”).


So, rather than write a “rant post” about the code, I’ve decided to take another tactic.  In this article, I’m going to walk you through my process for performing a security code review.  Inline with the review, we’ll take note of any issues that we do find, and number them.  Then at the end of the review, we’ll go over each one and look at potential mediation that we can apply and how to fix the issues.
<!--more-->

If you want to follow along, start by downloading the code [here](http://www.php-developer.org/crawltrack3-1-1/php/countdownload.php?url=http://www.php-developer.org/wp-content/uploads/scripts/securelogin.zip) (it’s a direct link to the zip file).  Or if you’d like to follow along online, I’ve posted the formatted code into a [gist](https://gist.github.com/1118405), and will link to that whenever I post line numbers.

## Let's Get Started

The first thing that I see when I open that code up is a whole bunch of mess.  There’s no formatting at all in the file.  No indentation, and inconsistent spacing.  So, my first real step is to use my favorite Netbeans feature, Format.  It will automatically format the code to a readable and consistent level.  I did this for each file in the download.

So, the first actual step towards reviewing the code that I take, is to get a general understanding of the architecture of the codebase from a reasonably high level.  When I look at the file layout, it doesn’t tell me much.  The only real hint to the architecture is in the article.  It instructs you to “add `require(‘authenticate.php’);` to the top of all scripts  you want to protect”.  So now we have a starting point.  It appears that authenticate.php somehow handles authentication.  The rest of the “application” appears simple to understand, it seems like there is a configuration file, and a few other “template” files.  Let’s start at the core, authenticate.php...

## [Authenticate.php](https://gist.github.com/1118405#file_authenticate.php)

The first thing I do when looking at a new file is to take a quick look at it to get a general sense of its structure.  Looking at this file tells me quite a bit.  It contains nothing but procedural code.  There is no structure to the code other than execution order.  There are a significant number of variables that are defined all over the place, and used again far from the initialization.  There is SQL all over the place in the file (some of which is not needed at all).  And finally, there are cryptographic algorithms intermixed with other application logic.  One thing that this tells me right off the bat is that this is not going to be trivial to analyze.  But let’s try anyway.

Since there’s little file structure, lets start by following the execution flow, starting at the top of the file.  The first thing it does is start a session and verify it.  So let’s look at the session initialization bit first.

### Session Initialization ([Authenticate.php lines 37 - 88](https://gist.github.com/1118405#L37))

Notice the order of execution there.  First it starts the session, then it loads the config file.  And that brings us to our first potential security issue (a minor one, but still worth noting):

 1. It is not possible to set appropriate cookie flags for the session cookie via the inbuilt configuration mechanism.  Flags such as http_only, secure, etc.

    Also it’s worth noting that other secure session options are not set prior to starting the session.  And with that, comes our fourth potential issue:

 2. The ini setting session.use_only_cookies is not set.  This can lead to certain types of session fixation attacks and session leakage attacks on some PHP configurations.

    Next it checks if this is the first request to the session.  If not, it attempts to verify the IP address and UserAgent to confirm that the browser is the same one that owns the session.  This is usually good practice, but the way it’s implemented has a few flaws.  Rather than just storing each piece of information in the session, the author chose to hash them together into a single field.  Couple that with the fact that all data needed to make the hash is actually transmitted by the user, and we can see our next attack vector:

 3. Due to verifying only the hash of IP + UserAgent, a collision vulnerability in the sha1 primitive may allow an attacker to create a forged UserAgent which comes out to the same hash (from a different IP address).

    Notice what it does when the hashes don’t match.  It issues a location header, then exits the application.  Then a few lines later, it enforces an expiration time on the session.  But notice what happens if the session is expired.  It destroys the session and “unsets” it.  But then it redirects without the exit.  Notice that I put “unsets” in quotes.  The session_unset() function never actually unsets the session data.  It just unsets additionally registered global variables (such as those used by register_globals).  The main $_SESSION array will still be populated.  So, we arrive at our third attack vector so far:

 4. By not exiting directly on session expiration, a single request after expiration of an otherwise valid session will execute in its entirety.

    That’s about all the code there for the session.  The only other piece is simply storing a timestamp in the session.  I think it’s worth while pointing out that the “last activity” part is redundant, since PHP will handle that for you if you set the session ini params properly (`session.gc_max_lifetime`).  

So, the next part of the code looks like it’s doing brute force detection.  So let’s take a look at that next.

### Brute Force Detection ([Authenticate.php lines 90 - 116](https://gist.github.com/1118405#L90))

The code starts off by predefining a few variables.  While this definitely is a good thing, I’d rather see it done closer to their usages (since none of them are actually used in the next 50 lines).  Moving on, it looks like its running a query to determine if the current IP address is past the valid number of attempts.  The interesting thing is that this query is run on each and every single page view that passes the session validation routine.  Additionally, 2 queries are run which could be optimized down to one (especially since the first query result is ignored, it’s only used to see the presence of the row in the table).  So, we arrive at our fifth issue so far:

 5. The queries should only be run in contexts where the user is trying to do something (such as login or register).  Running it on all page views opens a minor DOS vulnerability as it is using resources to verify something that cannot change in certain contexts (hence using those resources unnecessarily)..

The rest of the brute force detection is straight forward and without issue.  It just does a simple integer check to make sure that the failed login attempts are less than the configured maximum number of login attempts.  If it is not, it will redirect to the forbidden URL.


The next few lines are straight forward enough (it’s simply defaulting the logged_in session variable to false).  So let’s skip that and go to the next section of code. 

### Authentication ([Authenticate.php lines 126 - 295](https://gist.github.com/1118405#L126))

This block is quite big, so we’ll actually look at it in a few sections.  But there are a few things to go over prior to diving into it.  Notice that the entire block is only executed if the session is new (`LAST_ACTIVITY` is false) AND if there is post data that contains both keys “user” and “pass”.  So basically the entire block is executed on form submission.

A second anti-pattern in this large block is the inner function “sanitize”.  First of all, it’s conditionally defined, which is generally a very bad idea.  Second and more importantly, it’s encoding HTML entities and escaping data for SQLInjection at the same time.  This is a horrible idea.  Escaping is context dependent.  Doing a raw escaping on data without that context can lead to incorrectly escaped data.  While this is definitely an anti-pattern, we don’t know of any attack vectors at this point in time, so let’s look at the next chunk of code.

### Registration Check and Brute Force Detection ([Authenticate.php lines 142 - 175](https://gist.github.com/1118405#L142))

The first thing that it does is issue a query to look up the username in the database, and if it does not exist, to set the $registered flag to false.  This violates some principles in security that state that the defaults should always be the least privilege level possible.  So rather than setting $registered to false if the account does not exist, we should assume that the account does not exist until proven otherwise.  While not a specific vulnerability, this is another “best-practice” violation.

Next, it runs yet another query if the username is registered to determine the number of failed login attempts the account has had.  This again exposes a similar DOS vulnerability to the one we saw above.  Here’s our 6th vulnerability so far (note that the query on line 183 also is lumped into this vulnerability).

 6. Multiple queries are being run which could be easily combined with no additional cost.  Therefore the additional queries are actually wasted resources all the time, leading to a DOS vulnerability.

The next block of code appears to check if it is necessary to load the captcha library, and check it if it is needed.  This is pretty straight forward, so let’s not spend a lot of time on it.  So, on to the next section.

### Password Verification ([Authenticate.php lines 179 - 189](https://gist.github.com/1118405#L179))

This is where things get interesting.  If the user is registered (passed the previous query), yet another query is run against the same table (opening the DOS vulnerability #6) to select the hashed password.  The password is then validated using a sha256 with a 64 character salt.  We’ll look deeper at the algorithm later, but for now let’s say it looks ok.  So then the submitted password is hashed against the stored salt.  So far so good.


Notice that the $userhash variable is undefined prior to the registered block.  That means that the check on line 189 will use an undefined variable if $registered == false.  That could open up attack vectors via register_globals or other global variables defined by the parent application.  It doesn’t due to the additional conditions on the if statement, but I’d rather see the variable predefined.

### Brute Force Prevention ([Authenticate.php lines 193 - 243](https://gist.github.com/1118405#L193))

There’s some weird architecture in here.  Notice that both branches of the if statement on line 197 are doing the exact same thing with the exception of 3 lines.  This could be reduced a more simple algorithm, but we’re not reviewing the code quality here, just the security.  If it’s a registered user attempting to login, 3 more queries are executed to log the attempts (2 write queries, one read). If it’s an unregistered attempt, only 2 queries are executed (1 write and 1 read).  This also leads to possible brute force issues, since the write queries actually cause the query cache in mysql to flush.  So that leads to yet another vulnerability.

 7. Multiple queries are being run to update statistics.  However these queries are blocking and hence open a DOS vulnerability.

### Logging In ([Authenticate.php lines 244 - 293](https://gist.github.com/1118405#L244))

The first thing it does when it realizes it has a valid login is to zero out the brute force detection tables.  While this appears fine, I’d much rather have seen it delete the rows from the ipcheck table.  By deleting the rows, it can mitigate a potential vulnerability with resource allocation.  From a practical standpoint this should not be an issue as even millions of unique IP addresses could be stored in a reasonable table size (100mb table size would be able to store about 5 million IP addresses).

Next comes the function getRandomString.  This function credits a third party blog with the source of the function.  However, the bounds on the random function are wrong, and will result in invalid offset errors.  Therefore the function will return results at random that are less than 50 characters long.  But this is mainly a bug issue, and doesn't pose a significant security threat, considering the random data isn't used for anything requiring cryptographic strength random numbers.

The rest of the function is pretty straight forward.  One thing to notice is the IP address used in the hash.  If we trace the source of `$iptocheck`, we’ll see that it’s the raw IP address that’s been escaped for database usage.  If for some reason the IP address contained unsafe characters, this would cause the verification of the signature to fail since the generation of the signature and the validation of the signature are working on slightly different forms of the data.  And finally, the session id is regenerated (which is a good thing).  

So that’s the first file.  We’ve found 7 potential vulnerabilities so far.  Let’s look at the next interesting file, register.php

## [Register.php](https://gist.github.com/1118405#file_register.php)

A quick look at the file shows us that it’s a registration form and submission logic.  So let’s dive into it.

### Initialization ([Register.php](https://gist.github.com/1118405#file_register.php) lines 35 - 45)

So, we can see that the first thing it does is to require the configuration file, similar to how authenticate.php worked.  Then, it predefines a bunch of variables.  Note how the defaults are all set to be valid.  So that means the file is assuming the data is valid until proving otherwise.  This is decidedly not best practice.  We should always assume that input is invalid until proving otherwise.  But this is not a vulnerability yet.  So let’s continue.

### Processing The Registration ([Register.php](https://gist.github.com/1118405#file_register.php) lines 48 - 152)

The first thing that this code does, is define a sanitize function again.  This is the same function that’s in the Authenticate.php file, with the same concerns we already discussed.  Then the submitted username, password and verification password are all “sanitized”.  So far so good.

Then, we have some data validation steps.  The empty check ensures that the username is at least one character long, and the next check verifies that the username consists of only alphanumeric characters and is no more than 11 characters.  Then, it does a query on the database to see if the username is present.  Up to this point, everything looks ok.

Next, the password is validated.  It first checks that the password is not empty.  This is a redundant check since the next step verifies that it’s at least 8 characters long.  But the next concern comes with the alphanumeric check against the password.  That means that the password can only contain alphanumeric characters.  This is definitely not best practice, and actually could be seen as a vulnerability:

 8. Passwords are artificially constrained to alphanumeric characters only.

Then, it checks a captcha verification to ensure that the captcha was submitted correctly.  Finally, it tests to see that all verification steps are completed correctly.  If so, we go on to the next step.

Next, we come across the HashPassword function.  One thing to note with the salt function.  While it's not bad to use a secure salt, there's no significant reason for a `highly random` salt.  All that matters is that the salt is reasonably unique.  But it doesn't hurt to make it more random.  However, there is a significant issues here that we need to be concerned about.  After the salt generation, it does a simply `sha256` against the salt and password.  The way it is implemented actually leads to a very interesting vulnerability.

 9. By not stretching the hash function, the stored hashed password is vulnerable to brute forcing (even with the salt).

Finally, the valid user is saved to the database and an email is sent to the administrator.  The rest of this file looks pretty straight forward and simple, so I’ll skip the rest.

## [Logout.php](https://gist.github.com/1118405#file_logout.php)

This file is quite short and simple.  However, a quick view of the file shows a fairly interesting issue.  It requires the signature computed by logging in to be presented to the user to submit to the login page.  Presumably this was done as a form of CSRF protection.  However, it also leaks the data necessary to take over a session to the user.  So we come to our 11th vulnerability so far:

 10. Logout functionality requires the leaking of the sensitive signature line to the user (and exposing the salt in the process).

## The Rest

The rest of the files of the application are really straightforward.  They are either example files, or libraries.  There’s not much reason to go into detail on them, so we’ll stop here.

## The Vulnerabilities In Detail

By doing a quick code review (it took me maybe 15 minutes to do the actual review, but much longer to type all of this), we’ve found at nearly a dozen potential vulnerabilities.  So let’s go over each one and see why the vulnerability exists and how we can fix it.

 1. `It is not possible to set appropriate cookie flags for the session cookie via the inbuilt configuration mechanism.  Flags such as http_only, secure, etc.` (authenticate.php line 37)
    
    
    Cookies are inherently an insecure method for transmitting data.  However, by setting the http_only flag, cookies are protected by the browser from theft via javascript code.  And by passing the secure flag, we can prevent the cookie from being transmitted over insecure (non-https) connections, further preventing theft of the cookie data.
    
    
    The fix for this one is fairly simple.  All that we need to do is flip the configuration loading to before the session_start() call.  That way, the configuration file can set the session cookie options prior to the session being started.

 2. `The ini setting session.use_only_cookies is not set.  This can lead to certain types of session fixation attacks and session leakage attacks on some PHP configurations.` (authenticate.php line 37)
    
    
    A secure authentication system should force the ini setting session.use_only_cookies to be on to prevent certain types of attacks.  This could be done in the config.php file, or it could be done inline.  But it should be done.  The current code does not use that at all.  To fix, simply add the following single line:  
    
    ```php
    ini_set('session.use_only_cookies', 1);
    ```

 3. `Due to verifying only the hash of IP + UserAgent, a collision vulnerability in the sha1 primitive may allow an attacker to create a forged UserAgent which comes out to the same hash (from a different IP address).` (authenticate.php line 61)
    
    
    The IP address is fetched from `$_SERVER['REMOTE_ADDR']`.  This is not forgeable without compromising the server itself, so we can reasonably assume that if the IP address is the same, the request came from the same place.  But by hashing the IP address with user forgeable input (the UserAgent), the user can control the resulting hash.  And since the forgeable input is last, padding attacks can be leveraged to forge a new UserAgent which would verify the hash.
    
    
    The fix is simple here as well.  Get rid of the "secret" hash method of verifying the user.  Simply store both the IP and the UserAgent in separate strings in the session.  Then verify them individually.  That will completely eliminate this collision attack.

 4. `By not exiting directly on session expiration, a single request after expiration of an otherwise valid session will execute in its entirety.` (authenticate.php line 85)
    
    
    The lack of an exit directive after the block means that the user will be seen as having a valid session for the rest of the request.  The session data is never actually unset (meaning the data in the $_SESSION array).  The session is destroyed, so the next request will not be authenticated, but the current one will be.
    
    
    To fix, simply add an exit() after the header line.

 5. `The queries should only be run in contexts where the user is trying to do something (such as login or register).  Running it on all page views opens a minor DOS vulnerability as it is using resources to verify something that cannot change in certain contexts (hence using those resources unnecessarily)..` (authenticate.php line 100)
    
    
    By running multiple brute force detection queries on every single page view, an attacker simply needs to request the correct page to add unnecessary load to the database server.  If the query was necessary, it is a valid risk and no longer an issue.  But seeing as multiple queries are run for every page view, regardless of if the current view is an attempt at logging in or not, unnecessary load is added.
    
    
    To fix, all we need to do is refactor a little bit to surround the queries in if blocks that will only execute on an attempted login.

 6. `Multiple queries are being run which could be easily combined with no additional cost.  Therefore the additional queries are actually wasted resources all the time, leading to a DOS vulnerability.` (authenticate.php line 105)
    
    
    Each and every query executed adds networking cost to the application.  It's far better to run 1 efficient query than it is to run 3 efficient queries.  By splitting apart queries into individual -almost identical- queries, we actually are artificially adding load to the database server.  This therefore opens up an additional DOS vulnerability due to the additional traffic to the database.
    
    
    To fix this minor issue, simply combine all of the queries into 2 fundamental queries (one for selecting from the `ipcheck` table, and one from the `authentication` table).

 7. `Multiple queries are being run to update statistics.  However these queries are blocking and hence open a DOS vulnerability.` (authenticate.php line 203)
    
    
    This is actually more of a design issue then it is an implementation issue.  Relational databases are not designed for high insert rates such as we would see in a logging implementation.  While it does work, there are better alternatives available which handle concurrency much better.
    
    
    To fix this architectural issue, I'd suggest switching to a memory storage system for this task (such as APC, Memcached, Redis, MongoDB, etc).

 8. `Passwords are artificially constrained to alphanumeric characters only.` (register.php line 94)
    
    
    By restricting passwords to alphanumeric content, the available entropy in the password is greatly reduced.  With an 8 character password, there are only 218 x 10^12 possibilities.  That sounds like a lot, but it's only 2^47 bits of entropy.  ~Thanks to the Birthday Attack, we would only need to try about 14 million random passwords to have a 50% chance of guessing the correct one.  ~So to achieve a 50% chance of guessing the password, we only need to compute 2^46 passwords (about 70,300,000,000,000).  Contrast that to allowing any Latin-1 character, which would give us approximately 2^64 bits of entropy and require about 2^63 random passwords for the same 50% chance (about 9,220,000,000,000,000,000).
    
    
    To fix this, simply remove the alphanumeric character check.  Let the user enter whatever they want for their password (character wise).  There's no point in artificially restricting the password.

 9. `By not stretching the hash function, the stored hashed password is vulnerable to brute forcing (even with the salt).` (register.php line 135)
    
    
    We showed above that we only need to compute around 70 trillion random hashes to have a 50% probability of guessing an 8 character password.  While this sounds like a lot, it really is not.  A modern graphics card can do upwards of **1.12 billion** sha256 hashes every second.  So that means that we can have a 50% chance of guessing the password in about **`_62,500 seconds (about 17 hours)!!!_`** (So much for brute force prevention)! And we can search the entire reduced 8 character search space in about 34 hours.
    
    
    Therefore, we need a mechanism to slow down brute forcing.  There are two we should look at.  The first, is using a password hash algorithm that was designed from the ground up for the task, [bcrypt](http://en.wikipedia.org/wiki/Bcrypt).  BCrypt is significantly harder to parallelize and slower to compute in the first place, making the brute force option harder.  This is the best option, as it was designed for the task.
    
    
    The other method is to iterate over a hash function.  I'd suggest using the [PBKDF2](http://en.wikipedia.org/wiki/PBKDF2) function (here's an example):
    
    ```php
    function pbkdf2($hashAlgo, $password, $salt, $iterations, $length = 64) {
        $len = ceil($length / strlen(hash($hashAlgo, '', true)));
        $result = '';
        for ($i = 1; $i <= $len; $i++) { 
            $tmp = hash_hmac(
                $hashAlgo, 
                $salt . pack('N', $i), 
                $password, 
                true
            );
            $res = $tmp;
            for ($j = 1; $j < $iterations; $j++) {
                $tmp = hash_hmac(
                    $hashAlgo, 
                    $tmp, 
                    $password, 
                    true
                );
                $res ^= $tmp;
            }
            $result .= $res;
        }
        return substr($result, 0, $length);
    }
    ```

    It iterates over the hashing function to make it slower.  And since each iteration depends on the iteration before it, it's very difficult to parallelize.  So if we set $iterations to 1,000,000 the resulting hash will take over 2,000,000 sha256 hashes to compute.  That drops the rate from 1.12 billion hashes per second down to about 300 hashes per second.  So our 50% search space will take about 7,430 years.  And the full space will take about 14,861 years.
    
    
    It's important to note that these figures are only applicable for a single GPU.  If you setup a GPU farm, or use an [ASIC](http://en.wikipedia.org/wiki/Application-specific_integrated_circuit), these numbers can drop drastically.  But the important thing to note is that using the stretched hash will be significantly more resistant to brute forcing than a simple salt.

 10. `Logout functionality requires the leaking of the sensitive signature line to the user (and exposing the salt in the process).` (logout.php line 11)
    
    
    By leaking the signature, the salt that was used is also exposed.  Therefore an attacker can use this information to help generate a UserAgent that when hashed against his IP will give the same signature.  This can facilitate and significantly reduce the computational cost of vulnerability #3 above.
    
    
    To fix the issue, the check should be changed to the random session identifier, or even better would be to let it be a random post variable.

## Conclusion

All in all, it's not horrible.  But there are definitely some issues with the code.  I think the worst possible thing about it is its complete lack of structure and `in-your-face` unreadability.  If this is supposed to be part of a tutorial, I expect a lot more.  Sure, there are lots of comments, but most of them are pointless and are just reiterating what the code is doing.


So I hope that walk through helped to show you how I approach code audits.  Start with the general (the overall structure), and then progress section by section through the code.  All that it requires is some background knowledge and a little bit of critical thinking.  Most of it is common sense...

> Edited: Revised password brute forcing estimates as the Birthday Attack is not really appropriate in the context presented.