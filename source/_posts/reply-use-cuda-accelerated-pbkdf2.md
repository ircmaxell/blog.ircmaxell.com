---
layout: post
title: Reply: Use Cuda Accelerated PBKDF2
permalink: reply-use-cuda-accelerated-pbkdf2
date: 2012-06-13
comments: true
categories:
tags:
- Language Agnostic
- Password-Hashing
- PHP
- Rainbow Table
- Rant
- Security
---

Yesterday, I read an article about using GPUs to accelerate password hashing: [No, Heavy Salting of Passwords Is Not Enough, Use CUDA Accelerated PBKDF2](http://www.f-secure.com/weblog/archives/00002384.html). The article makes some very interesting points about password hashing. But the conclusion of the article really misses a huge point, and get a major point fundamentally wrong (bordering on misunderstanding). Let's start with the part they got wrong...<!--more-->

## What Is A GPU Good At?


The entire premise of the article is that `attackers are using GPUs to crack passwords, so let's beat them to the punch and use them ourselves`. Well, that is true (that attackers are using GPUs). But why are they using them? 

Is it because they can execute logic faster than a CPU? No. In fact, without branch prediction or a lot of the optimizations present in CPUs, they usually are slower than a CPU. 

Is it because GPUs can do more work than a CPU can? Sort of. I'm going to say no right now, but will explain why it could be interpreted as yes in a minute.

Is it because they are cheaper than a CPU? No. The best GPUs are \*more expensive\* than entire computers. So that was the gain, why not buy a bunch of cheap computers and let them all work together?

So why are GPUs so good at it? The answer lies in how the GPU is designed. A normal CPU has one or more cores. Each core can only execute one instruction from one thread at a time (sort of, but the details are outside of the scope of this article). So a 4 core processor can only execute 4 threads at one point in time (one clock cycle for example). A GPU is similar in that it has multiple cores as well (1 to 4 is typical). 

Where the GPU differs is in what each core does. The GPU shines when you need to perform the same instruction on a lot of data (threads) at the same time. Each core can typically execute a single instruction against thousands of pieces of data **at the same time **(in fact, some GPU core designs can execute upwards of 7,000 of these `"data threads"` at once). That's where the real gain is in a GPU. The ability to do the same thing at the same time to a lot of data.

One way to visualize the difference is to picture assembling a car from parts. There are a set of instructions that take parts as input, and produce a slightly more assembled car at each step in the way. A CPU in this case would equate to a small shop with one person assembling the car. They can react quite quickly to changing requirements (such as compensating for incorrect parts). But they can only do one step at a time to one car.

On the other hand, imagine an automated assembly plant with one computer controlling assembly. You can have that one computer controlling a dozen robots, but they can only tell those 12 robots the same instruction at one time. So that allows you to build 12 cars at the same time. But if a part is incorrect (even on just one car), the whole operation screeches to a halt because the computer must take care of that.

And that's why a GPU is so good at brute forcing passwords. You can feed literally thousands of words at a time into the GPU, and compute hashes of all of those words in the same time it would take to hash one of them (on a CPU or a GPU).## The Article's Mistake


The article incorrectly assumes that since a GPU can do thousands of hashes in one go, then each one must take 1/1000 the time it takes on a CPU to compute. And that's just not true. Indeed, that's the error here. Let me quote the article:> Even with a single CUDA capable card per password server, you can compute password hash checks in 1ms, so that the enemy will also need 1ms to try to crack that password, which means that instead of billions of attempts per second, an attacker will be limited to thousands of attempts per second.


That's true. An individual password will take 1ms to compute on either system (if that's how the algorithm is tuned). But to an attacker, they can do thousands of them in that same 1ms. So in reality, the attacker would still be able to do tens of millions of attempts per second (in aggregate). (The difference between billions and millions is due to the algorithm change where billions indicates md5 or sha1, and millions the tuned PBKDF2 algorithm)...


But further, the article goes on to say:
> Of course an attacker can get, let's say 100 CUDA or powerful ATI cards, but that would be prohibitively expensive and would provide such an attacker with only 100,000 attempts per second, not 230,000,000,000 attempts per second.


And there's the real hand-wave. With 100 GPUs, we should be able to hit tens of billions of attempts per second, because so much of the work is done concurrently... And that can brute force all 6 character passwords (90 printable characters, **a-zA-Z0-9!@#$%^&\*()<>?,./;':"[]{}\|** - about 531 billion - in well under a minute). And that's a pure brute force, not even a dictionary attack. ## There Is A Benefit


There is a benefit to offloading password hashing to a GPU: That it frees up CPU time on your server. That's about the only tangible benefit to doing it. And at that point, instead of spending $500 per server to add the GPU, you'd likely be better off getting a separate authentication server that does nothing but hash passwords as a service to the rest of your stack. It all depends on the scale of site you're dealing with. If you're handing hundreds of logins per second, it's a huge problem. But hundreds of logins per second is a scale that few will ever deal with (imagine what the page views per second must be). Otherwise, forget it, and just use a solid algorithm...