---
layout: post
title: The Secure Programmer's Pledge
permalink: secure-programmers-pledge
date: 2012-07-16
comments: true
categories:
tags:
- Best Practice
- Language Agnostic
- Learning
- PHP
- Rant
- Security
---

Every day I come across code that is insecure. Sometimes the code is so hilariously insecure that any 10 year old could break it. I've also gotten into discussions with people who should know better about their practices. It's very, how to put this, disheartening. It's sad that the average developer knows (and cares) so little about proper security practices. So, I've put together a simple pledge (or manifesto, if you'd like).<!--more-->
## The Pledge


I am a secure programmer: 1. <span style="background-color: white;">I will not store sensitive data in plain text, I will protect it in a suitable manner.</span>
 2. <span style="background-color: white;">I will always protect my users' data as if it was my own.</span>
 3. <span style="background-color: white;">I will only use vetted and published algorithms, I will not invent my own.</span>
 4. <span style="background-color: white;">I will use existing libraries where possible, and only write my own implementation where no suitable alternative exists.</span>
 5. <span style="background-color: white;">I will always use parameterized queries when executing SQL, I will not trust escaping.</span>
 6. <span style="background-color: white;">I will take vulnerabilities seriously, and not just ignore them when found.</span>
 7. <span style="background-color: white;">I will understand the </span>[OWASP Top 10](https://www.owasp.org/index.php/Category:OWASP_Top_Ten_Project)<span style="background-color: white;"> vulnerabilities, and will always protect my applications from them.</span>
 8. <span style="background-color: white;">I will not assume that I know better, but instead will try to constantly learn.</span>
 9. <span style="background-color: white;">I will not trust the security of systems that I have not personally examined.</span>
 10. <span style="background-color: white;">I will always try to educate others.</span>
## Elaborating


### I will not store sensitive data in plain text


Sensitive data in this context is any data that could negatively impact someone if leaked. This can include user data, system data, company data, etc. Some examples would be passwords, social security numbers, credit card numbers, addresses, password security questions/answers, etc. Instead, store the data in a suitable format. Do you need to only verify the information is correct? Then hash it using a strong one-way hashing function. Do you need to get the original value later for some use? Then encrypt it using a strong encryption function. But don't just store it in plain text.
### I will always protect my user's data


This protection can mean a lot of things. It can mean protecting your overall application from security threats, or adding specific defenses for their data. But the point is that all user data should be protected, and only common information, and information that's made clear to the user is public should ever be exposed. This means that you need to take privacy seriously, and not give away your users information, as you would not want your information given away.
### I will only use vetted and published algorithms


This is a lot more serious than many take for granted. There are tons of examples (some from popular open source projects) of people inventing their own cryptographic and security algorithms. The point here though is that security and cryptography are **hard**. It's a task best left to experts. Only use algorithms that are publicly available and have been peer reviewed. An even better approach would be to only use algorithms specified in public standards (Like RFC backed algorithms, and NIST recommended algorithms).
### I will use existing libraries where possible.


Writing secure code is difficult. Writing secure algorithms is even more difficult. It's quite hard to test for all possible edge-cases. So it's better to use a common, maintained and vetted library than to write your own version of a standard algorithm. Sometimes however, you can't find a library that implements the algorithm that you need (in the language or format you need it). In that case it's OK to write your own version, but be sure to be careful and test it thoroughly.
### I will use parameterized queries when executing SQL


It is possible to write secure escaped SQL. But it's very difficult. There are a lot of factors that you need to take into account (especially when dealing with MySQL). Escaping is only secure if you do everything exactly right, it's not forgiving. Parameterized queries (prepared statements fit into this category) are a better way of solving the problem, because it doesn't require any escaping, and lets the database engine handle it for you.
### I will take vulnerabilities seriously


Far too often I hear something along the lines of `"But this is an internal application, I don't need to worry about ${x}"`... That's never a valid excuse. The only valid excuse for ignoring vulnerabilities is that there isn't one. Always write secure code, and you'll never wind up in a situation where things change and all of a sudden an internal system gets exposed (or a proof-of-concept system gets pushed into production).
### I will understand the OWASP top 10


The OWASP top 10 project catalogs the top 10 security vulnerabilities and attack vectors used against web applications. By understanding the detailed vulnerabilities, and how to defend against them, you can better secure your applications. 
### I will not assume that I know better


Security is a tricky thing. It's constantly changing and evolving. The only way to stay proficient is to keep learning and studying the changing environment. Complacency kills, so the only way to stay safe is to constantly question what you read and learn, and constantly improve yourself. 
### I will not trust the security of systems


Just because a system is open source, or maintained by professionals does not mean that it uses best practices or is secure. Just look at something like Wordpress, almost every release fixes some sort of security vulnerability (some of them are major). Don't trust a system just because it's someone else's responsibility. Look into the system, and ensure that it's using the best practices. And if it's not, find out why it's not. Don't just trust it blindly.
### I will always try to educate others


This is more general than most of the other points, but it's just as valid. Not only is the best way to learn to teach, but by educating others we as a community gain value. If you see something wrong in someone else's code, teach them what they did wrong, and how to fix it. Don't just ignore it because it's "not your problem". Security is a problem for the entire community. You're either part of the solution, or part of the problem.
## Take The Pledge Now


Are you a secure programmer? Do you want to be? Then take the pledge, and fight for the security of your applications. It's all of our responsibility, so do your part! To not do so, is not only bad, but negligent. And given some of the recent court rulings, you may be held personally liable if you don't secure your systems. 

Tell the world that you're a secure programmer, take the pledge on twitter (or your favorite blog) with the hashtag #IAmASecureProgrammer!