---
layout: post
title: Properly Salting Passwords, The Case Against Pepper
permalink: properly-salting-passwords-case-against
date: 2012-04-17
comments: true
categories:
- Security
tags:
- Best Practice
- Language Agnostic
- Password-Hashing
- PHP
- Programming
- Rainbow Table
- Security
---

The other day I [announced the release](http://blog.ircmaxell.com/2012/04/introducing-passwordlib.html) of my new password hashing library, [PasswordLib](https://github.com/ircmaxell/PHP-PasswordLib). As I've come to expect, [Reddit](http://www.reddit.com/r/PHP/comments/s9r6f/introducing_passwordlib_a_library_for_hashing/) was full of interesting commentary on the topic. Some was good, some was bad and some surprised me. What surprised me was the insistence on a global salt (otherwise known as a *["pepper"](http://barkingiguana.com/2009/08/03/securing-passwords-with-salt-pepper-and-rainbows/)*). So, I started thinking about it some more, and I figured I'd write a post on why I don't use peppers in my hashing algorithms (and why you may want to rethink it too).<!--more-->

## What Is A Salt

To explain what a pepper is, we must first talk about what a salt is. To put it simply, a salt is a unique value that you use to differentiate multiple hashes from each other. Now, there are a few key words in there. First, for a salt to be effective, it does not need to be random! The only condition that needs to be satisfied is that it's unique. That means that it does not need to be a cryptographically secure pseudo-random number. Why does it only need to be unique? Well, it has to do with the primary reason for adding salts in the first place.

So, I had said that salts are used to differentiate multiple hashes from each other. In terms of password security, that means that if three users entered the same password, all three hashes would be different. Why is that important? Because the reason that hashes are secure is that they are difficult to reverse (practically impossible). So that means that the only practical attack (for passwords at least) is to brute force the password (or use a dictionary, but basically trying passwords one after another). If the three hashes weren't unique, that workload could be shared for cracking all three passwords. In fact, without salts, we could generate an entire database (or even transform it into a rainbow table) of hash to password mappings, and just "look up" the hash.

Adding a salt to the hash cycle forces all of the work to be duplicated for each password an attacker attempts to crack.

## What A Salt Is Not

It's important to note that a salt is not a cryptographic secret. In symmetric key cryptography, the security of a good algorithm is directly dependent upon the secrecy of the key. If the key is leaked, the algorithm provides absolutely no security. Therefore, the key is a cryptographic secret. In password hashing, the security of the algorithm is not impacted by the publicity of the salt. The work of brute forcing the password hash must be still be redone for each and every password hash attempted. Therefore, there is no need to keep the salt secret, as it adds no security to the algorithm.

I know what you're thinking. It adds security if the attacker doesn't know the salt, as it's more they would need to guess! Therefore, keeping the salt secret would only improve security, right? Well, it's not that simple. Keeping cryptographic secrets, well secret, is not an easy task at all. In fact, in practice, it's very difficult to do properly. Especially if your salt is unique per password, that means that you're likely to keep it in a database. And a database is no place for cryptographic secrets (as at that point, what's the point in separating them from the password). So that yields either to a really complex cryptographic secret storage system, or to not try to keep them secret. As it turns out, [Complexity is the enemy of security](http://www.schneier.com/news-038.html). Therefore, you shouldn't attempt to keep salts secret.

## What Is A Pepper

A Pepper is very similar to a salt. It is a single value that's stored unique for a site. That value is used in each and every password (in addition to the salt) to prevent the same hashes from working on multiple sites. It's different from a salt, because it's not stored with the password, or unique to the password. Therefor, the additional benefit to a pepper is that an attacker wouldn't know it, and therefore have to guess what it could be, providing additional security. At that point, it's important to note that the pepper becomes a cryptographic secret, as the security of adding the pepper is directly related to how private it is (meaning: if the pepper is disclosed, all benefit is lost).

Sounds good, right?

## The First Flaw

There is actually no documentation that a pepper actually increases security that was written by security experts. All of the documentation that I've seen has been written by ordinary developers. There are no RFCs that recommend adding peppers to hashes. There are no significant academic papers that prove they improve security (that I've seen at least). In the world of security, just because a concept sounds good doesn't mean anything. It has to be proven. And peppers, up until this point, have not been proven to improve security.

Now, I'll admit, this by itself isn't a very strong argument against including peppers. But it is the first nail in the coffin.

## The Second Flaw

There are no publicly vetted hashing algorithms that accept a pepper as an argument. This is related to the first flaw, but it's important to note that approved algorithms (such as PBKDF2) only rely upon a salt. That means that in order to include a pepper, one must modify an algorithm to do so. And modifying a secure algorithm can have disastrous results. It's something that should be left to security experts to do.

Sure, you could argue that you could simply combine the salt and pepper into one field and pass that into the algorithm. But how do you combine the salt and the pepper? No matter how you do it, you're adjusting the algorithm. Which is a big no-no when it comes to security. But let's say that you can do it securely.

## The Third Flaw

As it turns out, there's another type of algorithm in cryptography whose security depends upon a cryptographic secret: a block cipher. They are designed from the ground up to randomize and secure data based upon a secret. Better still, they are publicly vetted and approved to do so!

So, if you want to add a level of security on top of salted hashes, simply encrypt your passwords with a standard block cipher (such as AES) before storing them. At that point, you're combining the best of both worlds, using approved and vetted algorithms while still boosting the security of your stored password hashes.

So there's no reason to use a pepper. Just encrypt the hash using a cipher, and you get the same exact benefit, but with a far stronger (and provable) cryptographic security.

## The Final Flaw

This one is a biggie. The entire concept of a pepper is based around a flawed premise. The premise is that your passwords will be more secure if your password database is leaked. The flaw in that premise is that it's often not just your database that's leaked. A common misconception is that SQL Injection can lead to leaked password hashes. While it's possible, the vast majority of applications will not leak password hashes if injected into. The reason is how SQL Injection works. It modifies existing queries used by the application, sometimes adding new ones. But unless your application displays all columns returned from the database on queries, getting the password hashes out would be quite difficult.

It turns out, most password database leakages are actually the result of other vulnerabilities. Sure, SQL Injection can be used, but usually it's only a gateway to another more powerful vulnerability like privilege escalation or code injection. And with the greater vulnerability comes the realistic chance of direct disk access. If the attacker can get direct access to your disk, then they can get any information that your application can (either by reading it directly, or by injecting malicious code that runs in your application which does it). Therefore, your pepper (and hashing algorithm) will become known to the attacker.

Once that happens, anything gained by adding a pepper is immediately lost.

## Does That Mean It's Not Worth It?

Well, that's a lot harder of a question to answer. Using a pepper in the original way described in this post, no, it's not worth it. It is far better to use standard, proven algorithms then to create your own to incorporate a pepper. If it's doing the same thing by using a cipher to encrypt the results prior to storage, then the answer is a little bit less clear. 

The question I would ask is what are you trying to protect? Are you trying to protect your users from an attacker gaining access to your application through a broken password hash (such as a banking application), where there's a lot to lose if a password is broken? If so, then I would take the extra step to incorporate a block cipher, as the added complexity is justified you'll likely have the resources to do it properly (such as properly storing the secret). If not, I would avoid the additional complexity and stick to a strong hash to protect your users. The added complexity of adding a block cipher is not trivial, and can wind up hurting overall security if done incorrectly.

Remember, the most dangerous kind of security is a false sense of it. Thinking you've made your application more secure, when in fact you've weakened it, is the worst thing you could possibly do.

Thoughts? Comments? Reactions?