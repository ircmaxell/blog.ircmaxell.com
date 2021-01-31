---
layout: post
title: The Power of Technical Debt
permalink: 2012/03/power-of-technical-debt.html
date: 2012-03-28
comments: true
categories:
- Programming
tags:
- Best Practice
- Good Enough
- Language Agnostic
- PHP
- Programming
---
Lately, I've found myself in a number of discussions about Technical Debt and how it applies to project development. Overall, I think it's a very powerful tool that -- when used wisely -- can be a great asset to any team. It seems to me that most of the people that I've been talking to really don't agree, and see Technical Debt as a plague that should be eliminated at first sight. So, I figured I'd share my opinions, and see what you think...
<!--more-->

## What Is Technical Debt

I think the best way that I can explain the essence of technical debt is to let someone else do it for me. Martin Fowler [summarizes the concept](http://www.martinfowler.com/bliki/TechnicalDebt.html) with this analogy:

> *...doing things the quick and dirty way sets us up with a technical debt, which is similar to a financial debt. Like a financial debt, the technical debt incurs interest payments, which come in the form of the extra effort that we have to do in future development because of the quick and dirty design choice. We can choose to continue paying the interest, or we can pay down the principal by refactoring the quick and dirty design into the better design. Although it costs to pay down the principal, we gain by reduced interest payments in the future.*

I particularly like the financial analogy, so let's use that as a starting point. Just like financial debt, technical debt comes in many forms: it can be very good, or very bad, depending on how and when it is used. And just as in real life, each form has a varying amount of risk that will manifest in its own way. So, let's look at four basic types of technical debt and how each equates to a financial equivalent.

## Payday Loan

The easiest and most obvious form of technical debt is basically the payday loan. You don't have enough money to pay your bills, so you take a loan against a future pay check that you're going to receive. In the programming world, this equates to not having enough time to finish the application properly before a deadline and choosing the quick and dirty method to get yourself to the finish line. In both cases, this is a **really** bad idea and you should only use it in a dire emergency.

The problem with payday loan debt is that once you've taken it on, you usually can't have enough time to pay it back. That is because there is usually another deadline coming that you also won't be able to hit without taking additional debt. Remember, debt is never free; it will always reduce your overall availability to work. So if you can't complete your task in the allotted time without taking on debt, you won't be able to complete the next one either. So you accumulate more debt. And it continues as a vicious cycle.

It's usually far better to bite the bullet and admit that you can't make the deadline. When this happens, communication is key. It's better to present to the stakeholders that in order to make the deadline you'd have to accumulate a significant amount of debt, and that future deadlines would need to be pushed back to repay the debt. Don't be silent. Don't let it slide and hope to recover. Be open, and it usually won't be a problem... Remember:

> *If you don't have enough time to do it right, when will you have time to do it over?*

## Mortgage

This form of debt is also very common, but its relationship to technical debt is a little less obvious than the payday loan. In the financial world, you would accrue a mortgage loan in order to make a major purchase  (like a home) for which spreading out the payments over a long time makes sense. When developing, you might take on "mortgage debt" when you only build a small part of a much larger system (because that's the only part you need right now). This is an extremely common and powerful concept, but if not understood carefully can really cause pain. Let's take an example of a real world problem that you would use this technique for.

> Let's say we're building an application that is going to communicate with the [Stack Exchange API](https://api.stackexchange.com/). We could build a data mapper and domain logic to communicate with everything the API offers. But instead, what if we choose to design our libraries so that they can talk with the full API, but only actually implement the methods we need at the current time? If we do this, we're taking a mortgage out against that library, as we are delaying a major payment, and spreading it out over time as needed.

The thing to realize here is that we're taking a risk by doing this. If we wind up needing the full API, we'll wind up repaying a lot of interest in that it will take longer and be more expensive to pay back the loan piecemeal than at one time in a lump sum. Further, this method exposes us to future delays when we expect something to work which wasn't fully implemented. It's a bit like a variable rate mortgage in that you might end up paying a higher interest rate than you initially expected.

In the business world, successfully leveraging debt results in much greater returns than paying for everything up front. It follows, then, that when used properly, this "mortgage" technical debt can also be a very good thing. Sometimes it's even preferable to accrue mortgage debt, as it can prevent you from writing code which you will never use. Of course, like any debt, it's important to make sure that you don't accrue too much and end up underwater...

## Credit Card

In the financial world, a credit card can be used when you're not quite sure what you need, and as such the cost is not fully known at the time of opening the debt. The same thing happens when we're developing an application: we run into situations where we don't understand the problem sufficiently enough to build an appropriate solution. So instead of trying to build a perfect solution, we build a sub-optimal solution which lets us work on the more important parts of the problem.

By doing this, we're admitting that we don't quite have enough information to solve the problem optimally, so instead we implement a temporary solution that will allow us to understand the scope of the problem better. Personally, I use this paradigm all the time and I'll admit that sometimes when writing a section of an application I don't fully understand the problem I'm solving. Often, it's only after seeing the solution that we have enough information to know how it should be solved.

However, in these scenarios we don't always go back and correct our original implementation. When this happens, we accrue technical debt. This type of debt usually has a very high interest rate, and will become painful in the near future as you'll find trouble implementing features that use this sub-optimal implementation. As a result, this type of debt is best payed off as soon as possible, preferably even before committing the code (or pushing to master in a DVCS).

When used properly, this kind of debt can pay major dividends in the short-run, allowing us to enjoy our purchases (working on more important aspects of the application) interest free for a brief period before paying off the debt. However, if you don't consistently pay off your balance, this can quickly put your entire application behind the eight-ball, because the interest on short-term "Credit Card" technical debt is exorbitant.

## Hidden Debt

Financially speaking, hidden debt results from no fully understanding the impact of a regular debt, or sometimes not even realizing that a debt has be incurred at all. For example, this can happen if you don't read the line item in your loan that says if you don't pay it off in 12 months, the interest rate will jump to 125% (yes, these loans do exist). When programming, we sometimes make decisions that we think are right at the time, but that turn out down the road to be bad for the application. Don't fool yourself into thinking that these are just normal work-flows for development; this is technical debt as well, and it's also the most dangerous form of technical debt, because you're likely not even aware of its existence.

## Putting It Together

As you have probably already surmised, each form of debt is applicable in different situations. My standpoint is that when working in a team setting, each form has a different acceptable level and need to be approved by the appropriate team member(s). That said, Payday Loans have no place in a production codebase. If you need to do it because you communicated the concerns to the business, and still **HAVE** to in order to make a deadline, then the entire team should be part of that decision. The team should work together to ensure that the debt is repaid as soon as possible to prevent it from taking down the entire project.

Mortgages on the other hand are quite useful in a team setting. But just like a family buying a house, the entire team should be part of the decision of whether or not to take on the debt. By expanding the decision to multiple team members, the edge cases for the additional functionality can be more clearly seen, and the debt can be dealt with appropriately.

I believe that Credit Card debt is a judgment call that the individual developer needs to make. Are you going to push sub-optimal code to the repository? If so, let your team know so that they are aware of the debt. If not, then use your best judgment to determine when Credit Card debt is appropriate in your own workflow.

Hidden debt is harder to talk about. Because you don't know it exists, you can't by definition decide when and how you want to accrue it. Instead, when you find the debt, it's important to to categorize it as one of the other three types (as best you see fit) and then decide whether or not to repay it now or accrue it for later payment. The most important thing, though, is to acknowledge the debt when you find it and don't just pretend it will go away on its own.

## How to Identify Hidden Debt

I think that it's worthwhile to point out a few methods to identify pockets of hidden debt in your application. If we look hard enough, there are basically three forms of hidden debt to be found:

 * Architecture Debt - This is basically when the debt is incurred in the application's structure and the way classes and objects interact with one another. Problems in this area tend to be very pervasive and very difficult to repay than other forms of debt.
 * Design Debt - This is when you structure the component correctly, but instead muddy the API with poorly named methods (and similar style related problems). This tends to be pervasive, but is reasonably easy to repay as long as you catch it early. If not, you can wind up touching a lot of code to fix one simple naming convention.
 * Implementation Debt - This is where you accumulate debt in an implementation of a method. This tends to be very localized, and can usually be repaid very easily by simply refactoring the method.

Implementation debt is actually one of the easiest ones to identify. Look at a method. Does it look to be doing anything wonky? No? Then you're likely debt free there. Automated testing tools such as [PHPMD](http://phpmd.org/) can really help with identifying and preventing certain forms of implementation debt, such as having a method that's way too long (lines of code), does way too much (NPath Complexity) or is using poor practices (`exit()`, `goto`, `eval()`, etc).

Design debt is a little bit harder to identify, in that you need to think about the object in its use-context. When you read a method's name, does the method answer the question "*What does this method do on this object*"? If not, it probably needs a better name. An example of a poor name is [`SplObjectStorage::getHash()`](http://us.php.net/manual/en/splobjectstorage.gethash.php)... What does that do? I can't tell without referencing the documentation. An example of a good name is: [`SplObjectStorage::removeAllExcept()`](http://us.php.net/manual/en/splobjectstorage.removeallexcept.php)... I can almost read it like a sentence: "This method removesAllExcept (param) from an SplObjectStorage instance"...

Architecture debt is a lot tougher to identify. Really, the best tip that I can give to ferret out architecture debt is that if you find yourself trying to solve a problem that's tricky with respect object relationships, your architecture is probably flawed. A good example is if you want to prevent child objects from making a protected method publicly visible. This is non-obvious, and isn't something you'd normally do. To me this triggers an instinct to look at **why** I need to solve this problem in the first place. Usually, it's because I'm trying to use inheritance to force one class tree to do the job of two or more trees. Really, it's more of a feeling and a judgment call that can only be made with experience.

## But Technical Debt Doesn't Exist With Agile!

While researching for this post, I came across [a rather interesting post](http://nerds-central.blogspot.com/2011/10/agile-does-technical-debt-exist.html) claiming that the concept of technical debt does not exist when using an agile methodology. The post does make some very good points on the surface. But I think his conclusion is actually flawed. He makes a very good case that Payday Loans don't actually exist in this context, since from the view point of the customer, the feature is working, therefore it is just trading off current velocity for future velocity. That sounds very much like the very definition of technical debt to me, the ability to amortize short-term gain over the long term. You can call a pot a chicken, but in the end it's still a pot...

One point that I do agree with is that Mortgage debt isn't a negative in the realm of agile development. If you don't need the feature now, don't write the code for it. I think it's important to recognize that this is still debt, as it can be non-obvious in the long term why something appears half complete.

However, one point that I think he gets wrong is the concept of Credit Card debt. He equates it to poor code that should be corrected by review, training and pair programming. While all three steps can help, they won't always be able to identify the true impact of the decision at that point. Sometimes it won't become clear how to properly solve a problem for a significant amount of time after it was written, even among members of a team. This doesn't necessarily mean that the programmer was deficient for writing that code. It just means the requirements weren't clear enough at the time the code was written. This happens all the time, to even the best programmers. Identify it as debt, and move on until the solution becomes clear. It's better to spend your time doing productive work, then mucking around in something you don't understand. Just don't forget about it; revisit it form time to time and eventually you should be able to repay the debt.

> Technical debt in the commercial world is an idea that code owned by the shareholders of a company is accumulating debt created by the coders. The coders feel they have been forced to get the share holders into debt because the executive forced features out too fast.

I believe that this is applicable only to a subset of the reasons for incurring technical debt and that sometimes we incur technical debt because we realize that there is a difference between [Good and Good Enough](http://blog.ircmaxell.com/2011/03/difference-between-good-and-good-enough.html). Further, we don't ignore that distinction, but embrace it. Once we arrive at the point that we can accept "Good Enough" as a positive outcome, and not as a negative or limitation, then we can truly be professionals. Technical debt is not about blame, but about admitting that we are not perfect. I don't know about you, but I know I have written some really wonky code in my life... Let's accept that, and embrace technical debt as a powerful tool to embrace our imperfection and solve problems better in the long run...

## Now What?

Well, at this point, we've decided that we want to accrue technical debt to help us develop an application. This is a great thing! But we must be careful. Once you decide to accrue technical debt, you must track it, and more importantly, you **must** dedicate time to repay the debt along with ongoing development. One method for tracking the debt is to include comments right in the code indicating what and where the debt is. However, that requires us to look at the code to determine where the debt is. How often do we see a *TODO* comment, and summarily ignore it? Honestly? I do it all the time.

Instead, I'd suggest treating technical debt as an application feature or requirement. Are you using SCRUM (or a similar style agile system)? If so, put in user stories for your technical debt (as in, one story per item). That way, it'll always be in front of you during planning sessions, and it's in a place where nobody can hide from it. If you're using more of a waterfall approach, consider adding technical debt to your issue tracker as actual bugs and prioritize them appropriately.

You don't have to make the debt repayments a high priority unless the specific debt is going to pose a problem for a feature you're working on now. Just make sure you keep it in mind when planning new features...

As I said before, don't be silent. Don't ignore debt or it will cripple you. Accept it gladly, because if you use it properly it will make you much more efficient and result in higher quality software that can be released faster. But also remember to be prudent in how you use it. Don't accrue debt just because you can, or because you want to impress your boss with how fast you can get something done. Be smart with how you use it, and you can do amazing things in surprisingly little time...

I'll leave you with a final thought:

> *It's hard enough to find an error in your code when you're looking for it; it's even harder when you've assumed your code is error-free.* - Steve McConnell

What do you think? Feel free to leave a comment, follow up on twitter, or post a reply on your blog!