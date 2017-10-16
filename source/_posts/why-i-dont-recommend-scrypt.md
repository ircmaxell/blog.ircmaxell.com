---
layout: post
title: Why I Don't Recommend Scrypt
permalink: why-i-dont-recommend-scrypt
date: 2014-03-12
comments: true
categories:
- Security
tags:
- Cryptography
- Language Agnostic
- Password-Hashing
- PHP
- Programming
- Security
---
As many of you likely know, I have a "thing" for password storage. I don't know what it is about it, but it fascinates me. So I try to keep up as best as I can on the latest trends. In the past few years, we've seen the rise of a new algorithm called scrypt (it's 5 years old actually). It's gaining more and more adoption. But I don't recommend its use in production systems **for password storage**. Let me explain why:
<!--more-->

## Scrypt Design Criteria

Scrypt was not designed for password storage. It was designed as a key derivation function for generating keys from weak material (namely passwords). The prime type of attack that scrypt is designed to defeat is [ASIC](http://en.wikipedia.org/wiki/Application-specific_integrated_circuit) based attackers. It is not designed to try to favor CPU over GPU (and thereby defeat GPU based attacks). It is this fact that we can leverage to gain an advantage when used as a password hashing mechanism.

## Scrypt Is Not Perfect

Before I go on to detail some algorithm decisions that were designed in scrypt, let me make one thing clear. **NONE** of these limitations are fatal. Everything I'm going to describe **does** have practical implications, and reduces the overall strength of scrypt with respect to password hashing. But it's still practically secure compared to other algorithms (namely bcrypt and pbkdf2+sha256).

However, with that said, new issues could theoretically be found as researchers spend time using it. And considering the rise of scrypt-based crypto-currencies (namely Litecoin, Dogecoin and YACoin), there is real and significant money at stake. But enough meta talk, let's actually talk about the algorithm and stop hand-waving.

## SCrypt, Decomposed

There are 4 input variables to scrypt:

 1. `int N` - A factor to control the overall CPU/Memory cost
 2. `int r` - A factor to control the blocksize for each mixing loop (memory usage)
 3. `int p` - A factor to control the number of independent mixing loops (parallelism)
 4. `int dkLen` - The result hash.
Scrypt is basically composed of a chain of 4 operations (with Java-style pseudo-code)

 1. PBKDF2+SHA256 expansion
    
    The input is expanded from the raw password and salt to a value that's 128 \* p \* r bytes long.
    
    ```c
    byte[] blocks = new byte[128 * r * p];
    // Expand the password and salt to the full buffer length using a single iteration
    blocks = pbkdf2_sha256.hash(password, salt, 1, 128 * r * p);
    ```

 2. Block Mixing
    
    The block array is then mixed (in block sizes of `128 \* r bytes`).
    
    ```c
    for (int i = 0; i < p; i++) {
        blocks[128 * r * i : 128 * r] = roMix(r, blocks[128 * r * i : 128 * r], N);
    }
    ```

    Note that this can be parallelized, since each iteration works on a separate chunk of data (they can be done in separate threads for example).
    
    The mixing algorithm:
    
    ```c
    byte[128 * r] roMix(int r, byte[128 * r] block, int n) {
        byte[] X = block;
        byte[] V = new byte[128 * r * N];
        // Create array
        for (int i = 0; i < N; i++) {
            V[i] = X;
            X = blockMix(X);
        }
        for (int i = 0; i < N; i++) {
            int j = integerify(X) mod N;
            X = blockMix(X XOR V[j]);
        }
        return X;
    }
    ```
    The blockmix function is pretty simple, just an implementation of the Salsa20/8 algorithm in a loop (not worth typing out).
    
    The Integerify function simply interprets the argument as a little-endian integer (converts a byte array into an integer value)
 3. PBKDF2+SHA256 compression
    
    The block array is used as the salt in a single iteration of PBKDF2+SHA256 to compress the password again
    
    ```c
    byte[] derivedKey = new byte[dkLen];
    derivedKey = pbkdf2_sha256.hash(password, blocks, 1, dkLen);
    ```

## The First Limitation, Loop Unrolling

So, one of the benefits of scrypt is that it uses a lot of memory to compute a hash. This means that, when used with appropriate settings, it should be extremely hard to parallelize scrypt. The reason for this is that existing commodity hardware (CPU and GPUs) are typically more memory constrained than they are computation constrained. So while a GPU can compute a small amount of memory in extreme parallel (upwards of 7,000 concurrent calculations), the added memory constraints of scrypt basically make ASIC attacks impractical (and, by chance, GPU attacks). Or at least that's the theory.

In practice, there's a feature of the algorithm that let's us defeat this. Basically, the main body of memory is in a single array. This array is computed in the "memory expansion" phase. Then, the block mixing phase uses that array to modify another, much smaller value. That smaller value is then used to compute the final result.

What that means for us, is that we can avoid pre-computing that original large array entirely. Since the array is deterministically created, we can simply "unroll" the operations that created a particular array element locally every time we need to access that memory segment.

So, we can modify the mixing function above to the following:

```c
byte[128 * r] roMix(int r, byte[128 * r] block, int n) {
    byte[] X = block;
    // Create array
    for (int i = 0; i < N; i++) {
        X = blockMix(X)
    }
    for (int i = 0; i < N; i++) {
        int j = integerify(X) mod N;
        byte[] V = block;
        for (int k = 0; k < j; k++) {
            V = blockMix(V);
        }
        X = blockMix(X XOR V);
    }
    return X;
}
```

Let's check out an example using numbers. Using the recommended interactive parameters of:

```c
int N = 16384; // 2^14
int r = 8;
int p = 1;
```

Using those values, we can compute the total amount of memory required as `128 \* r \* N + 128 \* r \* p`, which in this case be approximately 16mb.

Using the attack described above, we could reduce that total amount to a little bit over `128 \* r \* p`, which would be in this case **1kb**.

So we reduced the memory usage by 5 orders of magnitude...

But we also increased the amount of CPU work. Using those same settings, we increased the amount of work by a factor of **8192** (on average, so `N/2`).

One of the prime advantages of scrypt is that it is memory-hard. This term is a little bit misleading, so let's dig on that for a second. Memory-hard, as termed by scrypt, is basically the principle that the algorithm is difficult to a constant time-memory trade-off factor. So while we may be able to change the amount of memory that scrypt uses, if we reduce it we must do significantly more work to compensate.

And as it turns out, that is true. When we do the math on the above attack, it turns out that it would take several thousand times the work to create the hash. So practically, we're no better off. Well, we are better off as we can now attack on both memory constrained and memory unconstrained systems.

I was the first person to identify and disclose this issue publicly [on this thread](https://drupal.org/comment/4675994#comment-4675994).

## Tune-able Reduced Memory Usages

The above loop traded off the entire large array for re-computation. We can actually take it a step futher tune the above attack to use the exact amount of memory we want. We can do this by storing only a portion of the values. If we want to half the memory usage, we'd store every other value, and then when requesting a value that's not there, re-compute it. For example:

```c
byte[128 * r] roMixHalf(int r, byte[128 * r] block, int n) {
    byte[] X = block;
    byte[] V = new byte[128 * r * N / 2];
    // Create array
    for (int i = 0; i < N; i++) {
        V[i] = X;
        X = blockMix(X);
        X = blockMix(X); // since we skip by 2
    }
    for (int i = 0; i < N; i++) {
        int j = integerify(X) mod N;
        byte[] T = V[Math.floor(j / 2)];
        if (j % 2 == 1) {
            T = blockMix(T);
        }
        X = blockMix(X XOR T);
    }
    return X;
}
```

Using this method, you can reduce the memory by any integer factor you choose (powers of 2 are going to be easier). This allows you to tune to the system you're building or working with (less memory, more CPU).

## Further Proof

YACoin is a [scrypt-based crypto currency](http://www.yacoin.org/). Using it as a base for real-world testing of mining, we can see that at its current settings (N=2^15, r=1, p=1), [CPU is as fast as GPU](http://yacoinwiki.tk/index.php/Mining_Hardware_Comparison). Note that those settings result in it using 4mb of RAM.

It's worth noting that those mining numbers are approximately the same as with bcrypt. Which indicates that scrypt at those settings is approximately as difficult to attack as bcrypt. [Further Reading](http://www.openwall.com/lists/crypt-dev/2013/12/31/1).

## Putting It In Perspective

To put it in perspective, scrypt requires approximately 1000 times the memory of bcrypt to achieve a comparable level of defense against GPU based attacks (again, for password storage). On one hand, that's still fine, as bcrypt uses 4kb, which means the equivalent effective scrypt protection occurs at 4mb. And considering the recommended settings are in the 16mb range, that should be clear that scrypt is definitively stronger than bcrypt.

This proves that scrypt is demonstrably weaker than bcrypt for password storage when using memory settings under 4mb. This is why the recommendations are 16mb or higher. If you're using 16+mb of memory in scrypt (p=1, r=8 and N=2^14, or p=1, r=1 and N=17), you are fine.

## So Scrypt Is Still Secure

As I indicated before, scrypt is still very much secure. The point that I want to make clear is that it was not explicitly designed for password storage, and it wasn't designed to mitigate the risks of GPU based attacks. Couple that with often-weak settings and you can wind up in a situation where you're significantly weaker than today.

And that's why I don't recommend it **for password storage**. Bcrypt is well understood, supported and tested.

I want to make one thing clear, as a [Key Derivation Function](http://en.wikipedia.org/wiki/Key_derivation_function), it is still very much useful and secure. It's only when used for password storage that I'm talking about.

## But Bcrypt Isn't Perfect!

Absolutely not! Bcrypt definitely has issues. One of the most glaring ones is the 72 character password limit. That's definitely an issue (although not a fatal one). On the other hand, as far as I've seen there's been no successful research into defeating bcrypt aside from pure computer horsepower (brute forcing).

The answer is, in my opinion, to stick with bcrypt **for now**. Encrypt the output using a strong cipher (AES-128-CBC) with a key rotation policy if you have high value passwords.

Cryptographers are currently designing new algorithms specifically for password storage. They are still very early into the process, but there's already been some promising research happening. It'll take a number of years before it completes, but it's progress. Check out the [Password Hashing Competition](https://password-hashing.net/).

So that's why I don't recommend production systems switch to scrypt today.

