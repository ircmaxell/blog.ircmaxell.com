---
layout: post
title: It's All About Time
permalink: its-all-about-time
date: 2014-11-28
comments: true
categories:
- Security
tags:
- PHP
- PHP-Internals
- Programming
- Security
- Timing-Attack
---
An interesting pull request has been opened against PHP to [make `bin2hex()` constant time](https://github.com/php/php-src/pull/909). This has lead to some interesting discussion [on the mailing list](http://marc.info/?l=php-internals&m=141692988212413&w=2) (which even got [me to reply](http://marc.info/?l=php-internals&m=141703117719514&w=2) :-X). There has been pretty good coverage over [remote timing attacks in PHP](http://blog.astrumfutura.com/2010/10/nanosecond-scale-remote-timing-attacks-on-php-applications-time-to-take-them-seriously/), but they talk about string comparison. I'd like to talk about other types of timing attacks.

<!--more-->
## What Is A Remote Timing Attack?

Ok, so let's say you have the following code:

```php
function containsTheLetterC($string) {
    for ($i = 0; $i < strlen($string); $i++) {
        if ($string[$i] == "c") {
            return true;
        }
        sleep(1);
    }
    return false;
}

var_dump(containsTheLetterC($_GET['query']));

```
It should be pretty easy to tell what it does. It accepts the `query` parameter from the URL, then goes letter by letter through it, checking to see if it's a lowercase `c`. If it is, it returns. If not, it sleeps for one second.

So let's imagine we passed in the string `?query=abcdef`. We'd expect that the check would take 2 seconds.

Now, let's image that we didn't know what letter was being looked for. Let's imagine that instead, the `"c"` was a different value that we don't know. Can you figure out how to figure out what that letter is?

It's simple. We construct a string `"abcdefghijklmnopqrstuvwxyzABCDEFGHIJ...."`, and pass it in. Then we can time how long it takes to return. Then we know which character is different!!!

That's the basis of a timing attack.

But we don't have code that looks like that in the real world. So let's look at a *real* example:

```php
$secret = "thisismykey";
if ($_GET['secret'] !== $secret) {
    die("Not Allowed!");
}

```

To understand what's going on, we need to look at [`is_identical_function` from PHP's source code](http://lxr.php.net/xref/PHP_TRUNK/Zend/zend_operators.c#is_identical_function). If you look at that function, you'll see that the result is defined by the following case:

```php
case IS_STRING:
    if (Z_STR_P(op1) == Z_STR_P(op2)) {
        ZVAL_BOOL(result, 1);
    } else {
        ZVAL_BOOL(result, (Z_STRLEN_P(op1) == Z_STRLEN_P(op2))
        && (!memcmp(Z_STRVAL_P(op1), Z_STRVAL_P(op2), Z_STRLEN_P(op1))));
    }
    break;

```

The `if` basically is asking if both variables are the same variable (like `$secret === $secret`). In our case, that's not possible, so we only need to look at the `else` block.

```php
Z_STRLEN_P(op1) == Z_STRLEN_P(op2)

```

So we immediately return if the string lengths don't match.

That means that more work is done if the strings are the same length!

If we time how long it takes to execute different lengths, we would see something like this:

<table><thead><tr><th align="center">length</th><th align="center">time run 1</th><th align="center">time run 2</th><th align="center">time run 3</th><th align="center">average time</th></tr></thead><tbody><tr><td align="center">7</td><td align="center">0.01241</td><td align="center">0.01152</td><td align="center">0.01191</td><td align="center">0.01194</td></tr><tr><td align="center">8</td><td align="center">0.01151</td><td align="center">0.01212</td><td align="center">0.01189</td><td align="center">0.01184</td></tr><tr><td align="center">9</td><td align="center">0.01114</td><td align="center">0.01251</td><td align="center">0.01175</td><td align="center">0.01180</td></tr><tr><td align="center">10</td><td align="center">0.01212</td><td align="center">0.01171</td><td align="center">0.01120</td><td align="center">0.01197</td></tr><tr><td align="center">11</td><td align="center">0.01210</td><td align="center">0.01231</td><td align="center">0.01216</td><td align="center">0.01219</td></tr><tr><td align="center">12</td><td align="center">0.01121</td><td align="center">0.01211</td><td align="center">0.01194</td><td align="center">0.01175</td></tr><tr><td align="center">13</td><td align="center">0.01142</td><td align="center">0.01174</td><td align="center">0.01251</td><td align="center">0.01189</td></tr><tr><td align="center">14</td><td align="center">0.01251</td><td align="center">0.01121</td><td align="center">0.01141</td><td align="center">0.01171</td></tr></tbody></table>

If you ignore the average column, you'll notice that there doesn't appear to be much of a pattern. The numbers are all within reason of each other.

But if you average a number of runs, you start to notice a pattern. You'll notice that length 11 takes longer (slightly) then the other lengths.

This example is *greatly* exaggerated. But it illustrates the point. It's [been shown](http://www.cs.rice.edu/~dwallach/pub/crosby-timing2009.pdf) that you can remotely detect differences in time down to about 15 nanoseconds using a sample size of about 49,000 (so 49,000 tries instead of 3 in the above example).

But so what, we found the length. That doesn't buy us much... But what about the second part? What about `memcmp(...)`?

If we look at the [implementation of `memcmp()`:](http://www.opensource.apple.com/source/tcl/tcl-3.1/tcl/compat/memcmp.c):

```php
int memcmp(const void *s1, const void *s2, size_t n)
{
    unsigned char u1, u2;

    for ( ; n-- ; s1++, s2++) {
        u1 = * (unsigned char *) s1;
        u2 = * (unsigned char *) s2;
        if ( u1 != u2) {
            return (u1-u2);
        }
    }
    return 0;
}
```

Wait a tick! That returns *at the first difference* between two strings!

So once we've identified the length of the string, we can try different strings to start detecting a difference:

```php
axxxxxxxxxx
bxxxxxxxxxx
cxxxxxxxxxx
dxxxxxxxxxx
...
yxxxxxxxxxx
zxxxxxxxxxx
```

And through the same technique, wind up noticing a difference with "txxxxxxxxxx" taking **ever so slightly longer** than the rest.

Why?

Let's look at what happens step by step in memcmp.

 1. First, it looks at the first character of each string.
    
    If the first character is different, return immediately.
 2. Next, look at the second character of each string.
    
    If they are different, return immediately.
 3. And so on.

So with `"axxxxxxxxxx"`, it only executes the first step (since the string we're comparing is `"thisismykey"`). But with `"txxxxxxxxxx"`, the first *and second* steps match. So it does more work, hence takes longer.

So once you see that, you know `t` is the first character.

Then it's just a matter of repeating the process:

```php
taxxxxxxxxx
tbxxxxxxxxx
tcxxxxxxxxx
tdxxxxxxxxx
...
tyxxxxxxxxx
tzxxxxxxxxx

```

Do that for each character, and you're done. You've successfully deduced a secret!

### Protecting Against Comparison Attacks

So that's a basic comparison attack. `==` and `===` are both vulnerable to that in PHP.

There are two basic ways of defending against it.

The first is to manually compare the two strings, and always compare every character (this is my function from [an earlier blog post](http://blog.ircmaxell.com/2012/12/seven-ways-to-screw-up-bcrypt.html):

```php
/**
 * A timing safe equals comparison
 *
 * @param string $safe The internal (safe) value to be checked
 * @param string $user The user submitted (unsafe) value
 *
 * @return boolean True if the two strings are identical.
 */
function timingSafeEquals($safe, $user) {
    $safeLen = strlen($safe);
    $userLen = strlen($user);

    if ($userLen != $safeLen) {
        return false;
    }

    $result = 0;

    for ($i = 0; $i < $userLen; $i++) {
        $result |= (ord($safe[$i]) ^ ord($user[$i]));
    }

    // They are only identical strings if $result is exactly 0...
    return $result === 0;
}
```

The second is to use PHP's built in [`hash_equals() function`](http://php.net/manual/en/function.hash-equals.php). This was added in 5.6 to do the same thing as our above code.

**NOTE** In general, it's **not** possible to [prevent length leaks](http://security.stackexchange.com/questions/49849/timing-safe-string-comparison-avoiding-length-leak). So it's OK to leak the length. The important part is that it doesn't leak information about the difference of the two strings.

## Other Types Of Timing Attacks - Index Lookup

So that's comparison. And that's quite well covered. But let's talk about index lookup:

If you have an array (or string), and you use secret information as the index (key), you can potentially leak information about that key.

To understand why, we need to get into a bit on how CPUs work with memory.

A CPU, in general, has fixed width registers. Think of these as small variables. On a modern processor, these registers are likely to be 64 bits (8 bytes) wide. That means that the largest variable that a CPU can ever deal with at a single time is 8 bytes. (Note: this is not true, as most processors have vector-based operations such as SIMD that allow it interact with more data. For the purposes of this discussion though that's not important).

So what happens when you want to read a string that's 16 bytes long?

Well, the CPU needs to load it in chunks. Depending on the operation, it may load the string 8 bytes at a time, and operate on it 8 bytes at a time. Or, more often, it operates on it one byte at a time.

So that means that it needs to fetch the rest of the string from somewhere. This "somewhere" is main memory (RAM). But memory is extremely slow. like REALLY slow. On the order of 100ns. Which is WAY over our 15 nanosecond threshold.

And since main memory is so slow, CPUs have little bits of memory on the CPU itself to act as a cache. In fact, they typically have 2 types of cache. They have L1 cache, which is specific to each core (each core gets its own L1 cache), a L2 cache, which is also specific to a core, and a L3 cache which is often shared across all cores on a single chip. Why 3 tiers? Because of speed:

<table><thead><tr><th align="left">Memory Type</th><th align="left">Size</th><th align="left">Latency</th></tr></thead><tbody><tr><td align="left">L1 Cache</td><td align="left">32kb</td><td align="left">0.5 ns</td></tr><tr><td align="left">L2 Cache</td><td align="left">256kb</td><td align="left">2.5 ns</td></tr><tr><td align="left">L3 Cache</td><td align="left">4-16MB</td><td align="left">10-20 ns</td></tr><tr><td align="left">RAM</td><td align="left">LOTS</td><td align="left">60 - 100 ns</td></tr></tbody></table>

So let's look at what happens when you do `string[index]` on a C string (`char \*`, a character array). Imagine you have this code:

```php
char character_at_offset(const char *string, size_t offset) 
{
    return string[offset]
}
```

The compiler will compile that as:

```php
character_at_offset:
    pushq   %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset 6, -16
    movq    %rsp, %rbp
    .cfi_def_cfa_register 6
    movq    %rdi, -8(%rbp)
    movq    %rsi, -16(%rbp)
    movq    -16(%rbp), %rax
    movq    -8(%rbp), %rdx
    addq    %rdx, %rax
    movzbl  (%rax), %eax
    popq    %rbp
    .cfi_def_cfa 7, 8
    ret
    .cfi_endproc
```

There's a lot of noise in there though. Let's trim it down to a non-functional, but more appropriate size:

```php
character_at_offset:
    addq    %rdx, %rax
    movzbl  (%rax), %eax
    popq    %rbp
    ret
```

The function takes two arguments, one of which is a pointer (the first element of the string), the second is an integer offset. It adds the two together to get the memory address of the character we want. Then, `movzbl` moves a single byte from that address and store it in `%eax` (it also zero's out the rest).

So, how does the CPU know where to find that memory address?

Well, it traverses up the chain of cache until it finds it.

So if it's in L1 cache, the overall operation will take approximately 0.5 ns. If it's in L2, 2.5ns. And so on. So by carefully timing the information, we can deduce where that item is cached (or if it's cached at all).

It's also worth noting that CPUs don't cache individual bytes. They cache blocks of memory called *lines*. A modern processor will typically have 64 byte wide cache lines. That means that each entry in cache is a continuous 64 byte block of memory.

So, when you do the memory fetch, the CPU will fetch a 64 byte block of memory into the cache line. So if your `movzbl` call needs to hit main memory, an entire block is copied into the lower cache lines. (note, this is a gross simplification, but it's for demonstration with what happens next).

Now, here's where things get **really** interesting.

Let's imagine that we're dealing with a large string. One that doesn't fit into L2 cache. So 1MB.

Now, let's imagine that we're fetching bytes from that string based off a secret sequence of numbers.

By watching how long it takes to fetch the bytes, we can actually determine information about the secret!!!

Let's imagine we fetch the following offsets:

 * `offset 10`
 * `offset 1`

The first fetch will cause a cache miss, which will load from main memory into the caches.

But the second fetch (`offset 1`) will fetch from L1 cache, since it's likely to be on the same cache line (memory block) as `offset 10` was. So it's likely to be a cache hit.

If we then fetched `offset 2048`, it's likely to not be in cache.

So by carefully watching the pattern of delays, you can determine some information about the relationships of sequences of the offsets. And by doing this with the right information a lot of times, you can deduce the secret.

This is called a cache-timing attack.

Now that seems really far fetched, right? I mean, how often do you fetch information that perfectly? How can that possibly be practical. [Well, it is 100% practical, and happening in the real world](http://cr.yp.to/antiforgery/cachetiming-20050414.pdf).

### Defense Against Cache-Timing Attacks:

There is only one practical way of defending against this style attack:

 1. Don't index arrays (or strings) by secrets.

It's really that simple.

## Branching Based Timing Attacks

How many times have you seen something like the following code?:

```php
$query = "SELECT * FROM users WHERE id = ?";
$stmt = $pdo->prepare($query);
$stmt->execute([$_POST['id']]);
$user = $stmt->fetchObject();

if ($user && password_verify($_POST['password'], $user->password)) {
    return true;
}
return false;
```

Surely that's secure?

Well, there is information leak there.

If you try different user names, it will take a different amount of time depending on if the username is there or not. If `password_verify` takes 0.1 seconds, you can simply measure that difference to determine if the username is valid or not. On average, requests for taken usernames will take longer than those for available ones.

Now, is this an issue? I don't know, it depends on your requirements. Many websites want to keep usernames secret, and try not to expose information about them (for example: not saying whether the username or password is invalid on a login form).

If you're trying to keep the username secret, you're not.

### Defense against branching based timing attacks

The only way to do this is to not branch. But there's a problem there. How do you get functionality like above if you don't branch?

Well, one idea would be to do the following:

```php
$query = "SELECT * FROM users WHERE id = ?";
$stmt = $pdo->prepare($query);
$stmt->execute([$_POST['id']]);
$user = $stmt->fetchObject();

if ($user) {
    return password_verify($_POST['password'], $user->password);
} else {
    password_verify("", DUMMY_HASH);
}
return false;
```

Which means that you run `password_verify` on both cases. This cuts out the `0.1` second difference.

But the core timing attack still exists. The reason is that the database will take a slightly different amount of time to return the query for one where it found the user, and one where it didn't. This is because internally, it's doing a lot of branching and conditional logic, and it eventually needs to transmit the data over the wire back to the program.

So the only way to defend against this style attack, is to not treat your username as a secret!!!

## A Note On "Random Delays"

Many people, when they hear about timing attacks, think "Well, I'll just add a random delay! That'll work!". And [it doesn't](http://events.ccc.de/congress/2012/Fahrplan/attachments/2235_29c3-schinzel.pdf).

To understand why, let's talk about what actually happens when you add a random delay:

The overall execution time is `work + sleep(rand(1, 10))`. If rand is well behaved (it's decently random), then over time we can average it out.

Let's say it's `rand(1, 10)`. Well, that means when we average out runs, we'll get an average delay of about 5. The same average added to all cases. So all we need to do is run it a few more times per run to average out the noise. The more times we run it, the more that random value will tend to average out. So our signal is still there, it just needs slightly more data to combat the noise.

So if we needed to run 49,000 tests to get an accuracy of 15ns, then we would need perhaps 100,000 or 1,000,000 tests for the same accuracy with a random delay. Or perhaps 100,000,000. But the data is still there.

Fix the vulnerability, don't just add noise around it.

## An Actual Delay That Works

Random delays don't work. But we can effectively use delays in two ways. The first is a lot more effective, and the only one I would "rely" on.

 1. **Make the delay dependent upon user input.**
    
    So in this case, you'd do something like hashing the user input with a local secret to determine the delay to use:
    
    ```php
    function delay($input, $secret_key) {
        $hash = crc32(serialize($secret_key . $input . $secret_key));
        // make it take a maximum of 0.1 milliseconds
        time_nanosleep(0, abs($hash % 100000));
    }
    ```

    Then just pass the user input used into the delay function. That way, as the user changes thier input, the delay will change as well. But it will change in the same way, such that they won't be able to average it out with statistical techniques.
    
    Note that I used `crc32()`. This doesn't need to be a cryptographic hash function. Since we're just deriving an integer, we shouldn't need to worry about collisions. If you wanted to be safer, you could replace it with a SHA-2 function, but I'm not sure it's worth the speed loss.

 2. **Make the operation take a minimum time (clamping)**
    
    So, one idea that many have floated is to "clamp" an operation to a specific runtime (or more accurately, make it take *at least* a certain runtime).
    
    ```php
    function clamp(callable $op, array $args, $time = 100) {
        $start = microtime(true);
        $return = call_user_func_array($op, $args);
        $end = microtime(true);
        // convert float seconds to integer nanoseconds
        $diff = floor((($end - $start) * 1000000000) % 1000000000);
        $sleep = $diff - $time;
        if ($sleep > 0) {
            time_nanosleep(0, $sleep);
        }
        return $return;
    }
    ```

    So you could then say that comparison must take a minimum amount of time. So instead of trying to make comparison take constant time, you simply make it take constant time.
    
    So, you could clamp equals to say 100 nano seconds (`clamp("strcmp", [$secret, $user], 100)`).
    
    Doing so, you protect the first part of the string. If the first 20 characters took 100 nanoseconds, then by clamping to 100 nanoseconds, you prevent differences in those from leaking.
    
    There are a few problems though:
    
     * It's exceedingly fragile. If you make the time too short, you lose all of your protection. If you make it too long, you risk adding un-necessary delay into your application (which can then expose DOS risks if you're not careful).
     * It doesn't actually protect anything. It just masks the problem. I consider this a form of security through obscurity. That doesn't mean it isn't useful or effective. It just means it's risky. It's hard to know if it's actually effectively making you more secure or just letting you sleep better at night. When used in layers, it may be OK.
     * It doesn't protect against local attackers. If an attacker can get code on the server (even unprivileged, on a different user account, such as a shared server), then they can view CPU usage and hence potentially see past the sleep. This is a stretch, and there are likely far more effective attacks in that situation, but it's worth noting at least.

## Defend Against DOS Attacks

All of these techniques take a lot of requests. They are based on statistical techniques that rely on large amounts of data to effectively "average out" noise.

That means to get enough data to actually execute an attack, an attacker may need to make thousands, hundreds of thousands or even millions of requests.

If you're practicing good DOS protection techniques (IP based rate-limiting, etc), then you're going to be able to bypass a lot of these style attacks.

But DDOS protection is a lot harder to protect against. By distributing the traffic, it's harder to protect against. But it's also harder on the attacker, since they have far more noise to deal with (not just a local network segment). So it's not really overly practical.

But like anything in security, defense in depth. Even though we don't think the attack will be possible, it's still worth protecting against it in case our original protections fail. Using defense in depth, we can make ourselves far more resilient to attacks of all scale.

## Back To The Point

There's currently a thread on PHP internals about whether to make certain core functions timing safe or not. The specific functions being discussed are:

 * `bin2hex`
 * `hex2bin`
 * `base64_encode`
 * `base64_decode`
 * `mcrypt_encrypt`
 * `mcrypt_decrypt`

Now, why those functions? Well, `bin2hex` and `base64_encode` are quite often used when encoding output to browsers (encoding session parameters for example). The more important ones however are the `hex2bin` and `base64_decode`, as they can be used for decoding secret information (like a key prior to using it for encryption).

The consensus among most of the respondents *so far* has been that it's not worth making them all slower just to get more safety. And I agree with that.

However, what I don't agree with is that it'll make them "slower". Changing comparison (from `==` to `hash_equals`) is slower because it changes the complexity (best, average, worst) of the function from `O(1, n/2, n)` to `O(n, n, n)`. That means that it will have a significant impact on performance for the average case.

But changing **encoding functions** doesn't affect the complexity. They will remain `O(n)`. So the question is, what's the speed difference? Well, I took a stab at benchmarking [bin2hex and hex2bin](https://gist.github.com/ircmaxell/c26ff31a80ac69b1349a) with the PHP algo and a timing safe one, and the difference wasn't overly significant. Encoding (bin2hex) was about the same (margin of error), and the difference for decoding (hex2bin) as about 0.5 µs. That's 5e-10 seconds more for a string of about 40 characters.

To me, that's a small enough difference to not worry about at all. How many times does the average application call one of those effected functions? Perhaps once per execution **maybe**? But what's the potential upside? That **perhaps** a vulnerability is prevented?

**Perhaps**. I don't think there's a strong reason to do it, in general these vulnerabilities are going to be extremely hard to pull off in the types of applications people write in PHP. But with that said, if the implementation was sane and fast enough (to me, 0.5Âµs is fast enough), then I don't think there's a significant reason *not* to make the change. Even if it helps prevent one single attack in all the millions of users of PHP, is that worth it? Yes. Will it prevent a single attack? I have no idea (likely not).

However, there are a few functions that I believe **must** be continuously audited for timing safety:

 * `mcrypt_\*`
 * `hash_\*`
 * `password_\*`
 * `openssl_\*`
 * `md5()`
 * `sha1()`
 * `strlen()`
 * `substr()`

Basically, anything we *know* will be used with sensitive information, or will be used as a primitive in sensitive operations.

As far as the rest of the string functions, either there's no need for them to be made timing safe (like `lcfirst` or `strpos`) or it's impossible (like `trim`) or it's already done (like `strlen`) or it has no business being in PHP (like `hebrev`)...

## Followup

So, there's been a bit of attention to this post from HackerNews and Reddit. There were a few common themes to the comments, so I'll follow up here. I've also edited the post inline to address these concerns.

### It's Impossible To Make Code Constant-Time

Well, I should have clarified the meaning of "constant". I don't mean constant in an absolute sense. I mean constant relative to the secret. Meaning that the time does not change dependent upon the data we are trying to protect. So overall the absolute time may fluctuate for any number of reasons. But we don't want the value that we're trying to protect to influence it.

It's the difference between:

```php
for ($i = 0; $i < strlen($_GET['input']); $i++) {
    $input .= $_GET['input'][$i];
}
```

Which is variable time but leaks nothing that's secret,

And

```php
$time = 0;
for ($i = 0; $i < strlen($_GET['input']); $i++) {
    $time += abs(ord($_GET['input'][$i]) - ord($secret[$i]));
}
sleep($time);
```

Now, that's an absurd example. But it demonstrates that both will vary time based upon the input, but one also varies based upon the secret we're trying to protect. That's what we mean when we say "constant time", not varying based on the **value** of the secret.

### What About Clamping To A Specific Runtime?

I've addressed this above in the body of the post.

### Doesn't DOS Protection Work?

Yes. I've added that to the lists of defenses. But considering that it doesn't work against DDOS (though timing differences will be harder to identify), I wouldn't ignore it for that reason.

### This Isn't Practical

Well, it is and it isn't. There are [videos](http://rdist.root.org/2010/11/09/blackhat-2010-video-on-remote-timing-attacks/) and [papers](http://matasano.com/research/TimeTrial.pdf) and [tools](https://github.com/dmayer/time_trial) and [more tools](https://github.com/aj-code/TimingIntrusionTool5000) and [more papers](http://www.cs.rice.edu/~dwallach/pub/crosby-timing2009.pdf) and [more videos](http://media.ccc.de/browse/congress/2011/28c3-4640-en-time_is_on_my_side.html#video).

So there's definitely something to it if attackers keep talking about it.

However, it's *a lot* of work to successfully exploit a timing attack. Therefore, attackers will generally look for easier and more common attacks such as SQLi, XSS, remote code execution, etc. But it really depends on a lot more factors. If you're protecting session identifiers for a blog site, then likely you don't have to worry about it. But if you're protecting encryption keys used for encrypting credit card numbers...

From a practical standpoint, I wouldn't worry about timing attacks until I was confident that the other potential vectors are secured. With that said, I do think it's quite interesting and worth knowing about. But like everything else in security and programming, it's all about tradeoffs.

