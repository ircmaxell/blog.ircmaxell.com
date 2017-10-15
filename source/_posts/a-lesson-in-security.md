---
layout: post
title: A Lesson In Security
permalink: a-lesson-in-security
date: 2014-10-31
comments: true
categories:
- Security
tags:
- Anatomy of an Attack
- Drupal
- PHP
- Programming
- Security
---
Recently, a severe SQL Injection vulnerability was found in [Drupal 7](https://www.drupal.org/SA-CORE-2014-005). It was fixed immediately (and correctly), but there was a problem. Attackers made automated scripts to [attack unpatched sites](https://www.drupal.org/PSA-2014-003). Within hours of the release of the vulnerability fix, sites were being compromised. And when I say compromised, I'm talking remote code execution, backdoors, the lot. Why? Like any attack, it's a chain of issues, that independently aren't as bad, but add up to bad news. Let's talk about them: What went wrong? What went right? And what could have happened better? There's a lesson that every developer needs to learn in here.

<!--more-->
## The Original Vulnerability

Drupal 7.x comes with a database connection wrapper which basically provides helper functions to make creating prepared statements easier. In general, it's a pretty good abstraction (and if you've read my blog before, you know how hard I am on abstractions).

One of those "helpers" is a protected method called [`expandArguments(&$query, &$args)`](https://github.com/drupal/drupal/blob/7e1429630dd0c3be3b9a387b709541a3440f5905/includes/database/database.inc#L718). This takes an array of arguments, each of which could be an array, and expands those nested arrays into individual placeholders. Here's the code with comments stripped out (click the function name above for the original source):

```php
protected function expandArguments(&$query, &$args) {
    $modified = FALSE;
    foreach (array_filter($args, 'is_array') as $key => $data) {
        $new_keys = array();
        foreach ($data as $i => $value) {
            $new_keys[$key . '_' . $i] = $value;
        }
        $query = preg_replace(
            '#' . $key . '\b#', 
            implode(', ', array_keys($new_keys)), 
            $query
        );
        unset($args[$key]);
        $args += $new_keys;
        $modified = TRUE;
    }
    return $modified;
}

```
To see what it would do, let's look at an example:

```php
$query = "SELECT * FROM foo WHERE id IN (:ids)";
$args = [
    'ids' => [
        1,
        2,
        3,
    ]
];
$db->expandArguments($query, $args);

// $query = SELECT * FROM foo WHERE id IN (:ids_0, :ids_1, :ids_2)
// $args = ['ids_0' => 1, 'ids_1' => 2, 'ids_2' => 3]

```
It's a really helpful tool for handling things like `IN` expansion (like the example above).

What's the problem? Can you spot it?

Well, what happens if you passed this argument array:

```php
$args = [
    'ids' => [
        '0); DROP TABLE foo; --' => 1
    ],
];

```
The query that would be generated would be:

```php
SELECT * FROM foo WHERE id IN (:ids_0); DROP TABLE foo; --)

```
Boom, injected.

## The Fix

The fix was a trivial change. Simply change `foreach ($data as $i => $value)` to `foreach (array_values($data) as $i => $value)`. A 14 character diff. And it just throws away the keys.

```php
- foreach ($data as $i => $value) {
+ foreach (array_values($data) as $i => $value) {

```
So simple.

And the Drupal security team did a fantastic job getting the patch out there, and messaging the communication.

## Compounding Problems

There are a few compounding problems that made this vulnerability far worse than it could have been. What I am about to detail is not a knock on Drupal, not by any means. It's just analyzing the situation, one that could happen to any project.

 1. **Drupal Uses Emulated Prepared Statements**
    
    You may have seen me [write about the dangers of emulation before](http://stackoverflow.com/questions/134099/are-pdo-prepared-statements-sufficient-to-prevent-sql-injection/12202218#12202218). In Drupal's case though, they weren't vulnerable to this style attack.
    
    They chose to force [Emulated Prepared Statements](https://github.com/drupal/drupal/blob/3310afeb856564d2bc0c03512566bff60029d7be/includes/database/mysql/database.inc#L47) for two reasons:
    
     1. On old versions of MySQL (before 5.1), real prepared statements skipped query cache
     2. Real prepared statements are marginally slower (due to a second network round trip for the data)

    Normally, this is only a theoretical risk. In fact, prior to this attack, I was OK with them using emulated prepares. But there's one killer problem with emulated prepares that turned the primary vulnerability from "Huge" to downright MASSIVE.
    
    MySQL prepared statements are limited to a single query. So
    
    ```php
    $db->prepare("SELECT * FROM foo; INSERT INTO foo ---");
    
    ```
    Would error. Because there is more than one query to prepare!
    
    But PDO's emulated prepared statements split that query into two. Meaning that it becomes valid again.
    
    Without this emulation, to successfully modify the database, an attacker would need to find an appropriate write query that they can inject into. This is often non-trivial and significantly limits the damage an attacker can do. But by using emulated prepares, it allows the attacker to do arbitrary writes into the database.
    
    Check.
    
    *Note:* It's worth noting that using emulated prepares in this case is not a vulnerability. It just opened a door that wouldn't have been there if they weren't turned on.
 2. **Input Was Not Always Filtered Appropriately**
    
    There are tons of places in Drupal's core where user input is not filtered prior to being passed to the database layer. Normally, this is not a vulnerability, but it does violate the [FILTER IN-ESCAPE OUT principle](http://blog.ircmaxell.com/2011/03/what-is-security-web-application.html).
    
    For example, the [user login module](https://github.com/drupal/drupal/blob/3310afeb856564d2bc0c03512566bff60029d7be/modules/user/user.module#L2149) passes esentially raw input to the database layer. This normally wouldn't be a problem (since it's a read query, not a write query). But this does mean that an attacker simply needs to pass in a crafted array to exploit it:
    
    Replace
    
    ```php
    name=username
    
    ```
    With
    
    ```php
    name[0); DROP TABLE foo; --]=username
    
    ```
    And boom, injected.
    
    This means that an attacker can hit almost any query, not just ones that use an `IN` clause expansion.
    
    By itself, this is not a major issue. Normally (short of the main vulnerability) this would not result in a problem. But coupling them together does increase the attack surface significantly.
    
    Check Mate.
 3. **Drupal Can Execute Code From The Database**
    
    Drupal 7 ships with a module called [PHP](https://github.com/drupal/drupal/tree/3310afeb856564d2bc0c03512566bff60029d7be/modules/php) which allows for inserting arbitrary PHP code into the database, which it will then evaluate. This sounds bad, but normally it requires site administrator privileges to turn on, and to use. So a user that can actually inject PHP code already has admin access to do the same. So it's normally not a major issue.
    
    However, if you can inject into the database, you can turn on modules that used to be off. And you can inject arbitrary content, as if it was authored by anyone on the system.
    
    So that means that an attacker can enable the PHP module, inject a back door, and then execute that back door to further compromise the site.
    
    This is a classic [Remote-Code-Execution](http://en.wikipedia.org/wiki/Arbitrary_code_execution) vulnerability.
    
    Game Over.
    
    *Note:* It's worth noting that Drupal 8 removed this module for exactly this reason.
    
    *Note #2:* This is [not the only place code is executed from the database](https://www.acquia.com/blog/learning-hackers-week-after-drupal-sql-injection-announcement).
None of these three are normally vulnerabilities. Normally, they can co-exist quite fine. But combined with the SQLi vulnerability, it's basically a perfect storm.

## How Did This Happen?

Everyone makes mistakes.

Everyone.

It's going to happen sooner or later. Heck, this vulnerable code was in the database layer since **2008**, and was just discovered two weeks ago. That says something about how complex vulnerabilities can be.

The key is not "did it happen", but how is it dealt with.

 1. **Was it fixed quickly and correctly?**
    
    In this case, yes, yes it was.
 2. **Was it communicated appropriately?**
    
    In this case, yes, yes it was.
 3. **Were appropriate practices followed to prevent it?**
    
    Mostly. There are definitely areas they could do better (the three I included above could have been done differently).
    
    However, none of this is cut-and-dry. Everything is a tradeoff. With emulated prepares, they chose speed and efficiency over a *theoretical* security bump. And at the time, this seemed like a reasonable decision. But in hindsight, it combined with another issue to make things worse. Does that mean that it was wrong to do back then? I don't think it's fair to say that. It could open the door today to ask that question of *going forward* what should happen. But it's definitely not a "OMG YOU GUYZ WERE NEGLIGENT".
## The Big Lesson

I consider the Drupal security team one of the best I've encountered in OSS. They are on the ball, quick to respond, and know their stuff. In general, Drupal is far more secure for it. They promote good practices (in general).

But bad things happen from time to time. It's the nature of the beast.

There are two ways to look at it:

 * Use a CMS/Framework, because they are better than you and can fix vulnerabilities quickly, so everyone benefits.
 * Don't use a CMS/Framework, because any vulnerabilities found can be exploited en masse.
And the truth of it, is that both are correct. **From a security standpoint**, using a CMS/Framework is both a risk, and a benefit. Like **everything** when it comes to security, it's a tradeoff. Does that mean you should avoid CMS's and Frameworks? No. What it means is that you need to think and plan on how to mitigate risks.

You're never safe. If you're running a system, it's either been compromised, or will be. The key is how you deal with it.




