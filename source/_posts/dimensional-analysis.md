---
layout: post
title: Dimensional Analysis
permalink: dimensional-analysis
date: 2015-03-16
comments: true
categories:
- Programming
tags:
- Analysis
- Engineering
- Functional Programming
- Mathematics
- PHP
- Programming
- Types
---
There's one skill that I learned in College that I wish everyone would learn. I wish it was taught to everyone in elementary school, it's that useful. It's also deceptively simple. So without any more introduction, let's talk about Dimensional Analysis:

<!--more-->
## What Is Dimensional Analysis

In short, it's a way of analyzing an equation or formula to see if it's correct from a "dimension" (unit) perspective. But it's more than just a way of error-checking, it's also a method of looking and analyzing a problem to help understand it better.

Let's take a simple example to get started. Let's say that you wanted to convert 100 miles into Kilometers. So to do this from a dimensional-analysis method, we start by writing the following equation:

$$ 100: miles \* \left ( \frac{\underline{\hspace{30px}}}{\underline{\hspace{30px}}} \right ) = \underline{\hspace{30px}} kilometers$$

The part in `()` is the *conversion factor*. But what should it be?

Well, we can easily see the units of the conversion factor. They need to be such that the miles cancel out. So:

$$ 100: miles \* \left ( \frac{\underline{\hspace{30px}}}{\underline{\hspace{30px}}: miles} \right ) = \underline{\hspace{30px}} kilometers$$

So now the left side is left dimensionless. That's not good. So the top of the conversion factor needs to be km:

$$ 100: miles \* \left ( \frac{\underline{\hspace{30px}}: kilometers}{\underline{\hspace{30px}}: miles} \right ) = \underline{\hspace{30px}} kilometers$$

So now we know we need to use a relationship of kilometers to miles. We also don't need to worry about whether to multiply or divide. We just plug the numbers in.

A quick Google will show that 1 km is approximately 0.621 miles. So we can simply plug those numbers in:

$$ 100: miles \* \left ( \frac{1: kilometers}{0.621: miles} \right ) = \underline{\hspace{30px}} kilometers$$

And doing the math:

$$ 100: miles \* \left ( \frac{1: kilometers}{0.621: miles} \right ) = 161: kilometers$$

Now that was a trivial conversion. And it was really easy to see how we got there. In fact, that's something that most people can do without needing to write it out. But the analysis method tells us that it's the correct answer from the start. Awesome.

But what about a more complex example?

## Units Of Force and Work

In Physics you probably learned the following formula at some point:

$$F = m \* a$$

Or Force equals mass times acceleration.

But what are the units of Force? Well, you're always taught that it's *Newtons* (or *Pounds*). But that looks really weird, as from a dimensional analysis standpoint it's wrong:

$$\underline{\hspace{15px}} newtons = \underline{\hspace{15px}} kilograms \* \underline{\hspace{15px}} \frac{meters}{second^{2}}$$

That looks really weird. But instead, we can say that a Newton is simply shorthand for Kilogram-Meters per second squared.

It turns out that if we look up the unit on [Wikipedia](http://en.wikipedia.org/wiki/Newton_%28unit%29), that's exactly what we see.

This becomes really cool, because we can now start really understanding what these values mean.

For example, Work (joule) is defined as:

$$\underline{\hspace{15px}} joules = \underline{\hspace{15px}} newtons \* \underline{\hspace{15px}} meters$$

Therefore, the dimensions of a Joule is Newton-Meters. But since we can expand Newtons, we can then expand Joule as well into *kilogram meter^2 / second^2*.

Immediately, we can start to derive formulas from this:

$$ Work = Mass \* Distance \* Acceleration $$

Which is:

$$\underline{\hspace{15px}} joules = \underline{\hspace{15px}} kilograms \* \underline{\hspace{15px}} meters \* \underline{\hspace{15px}} \frac{meters}{second^{2}}$$

Or:

$$\underline{\hspace{15px}} newtons = \underline{\hspace{15px}} joules \* \frac{1}{\underline{\hspace{15px}}: meters}$$

Using nothing more than dimensional analysis we can start to derive conversion formulas. All we need to do is get both sides of the equations down to the same primitives.

Forget having a cheat-sheet of forumlas, if you know the roots of units, we can derive our own formulas.

## A More Esoteric (But Fun) Example

In [XKCD's What-If #11](https://what-if.xkcd.com/11/), Randall demonstrates a really cool property of dimensional analysis (what he calls unit-cancelation). You can draw really cool conclusions from simply breaking down units.

To use his example, we start with Miles / Gallon. But a Gallon is really just volume, so we can convert 1 gallon to cubic feet:

$$\underline{\hspace{15px}} \frac{miles}{gallon} \* \frac{1: gallon}{0.133: feet^{3}} = \underline{\hspace{15px}} \frac{miles}{feet^{3}}$$

And since Mile can be trivially converted into feet:

$$\underline{\hspace{15px}} \frac{miles}{gallon} \* \frac{1: gallon}{0.133: feet^{3}} \* \frac{5280: feet}{1: mile} = \underline{\hspace{15px}} \frac{feet}{feet^{3}}$$

But wait, Feet / Feet ^ 3 is really just 1 / Feet^2

$$\underline{\hspace{15px}} \frac{miles}{gallon} \* \frac{1: gallon}{0.133: feet^{3}} \* \frac{5280: feet}{1: mile} = \underline{\hspace{15px}} \frac{1}{feet^{2}}$$

And we can invert the whole thing:

$$\frac{1}{\underline{\hspace{15px}} \frac{miles}{gallon} \* \frac{1: gallon}{0.133: feet^{3}} \* \frac{5280: feet}{1: mile}} = \underline{\hspace{15px}} feet^{2}$$

So we just went from a fuel-mileage calculation to a unit of area.

Randall showed a really cool result of this. Fuel mileage can be thought of as nothing more than the cross-sectional area of a pipe. So to compute how much fuel it would take to go from point A to point B, you'd just need a pipe as long as the trip with the cross-sectional area of our calculation. So the total fuel would be the volume of the pipe.

Pretty cool.

## A More Useful Example

Let's say you're a fan of Kerbal Space Program. And you want to convert between meters per second and miles per hour. Because you really want to get a sense for how fast your spaceplane is flying and meters per second is rather hard for us to equate.

Well, we could do a single-conversion by looking up a conversion number. But that's no fun. And it's quite hard to know if you're right.

Instead, let's do it in two stages. First by converting meters to miles, then seconds to hours:

$$\underline{\hspace{15px}} \frac{meters}{second} \* \frac{\underline{\hspace{30px}}}{\underline{\hspace{30px}}} = \underline{\hspace{15px}} \frac{miles}{hour}$$

Well, first, I don't know the conversion from meters to miles. But I know the conversion from kilometers to miles. So let's first convert meters to kilometers:

$$\underline{\hspace{15px}} \frac{meters}{second} \* \frac{1: kilometers}{1000: meters} \* \frac{\underline{\hspace{30px}}}{\underline{\hspace{30px}}} = \underline{\hspace{15px}} \frac{miles}{hour}$$

Now, I can look above to our first example, and directly pull our km to mile conversion:

$$\underline{\hspace{15px}} \frac{meters}{second} \* \frac{1: kilometers}{1000: meters} \* \frac{0.621: miles}{1: kilometer} \* \frac{\underline{\hspace{30px}}}{\underline{\hspace{30px}}} = \underline{\hspace{15px}} \frac{miles}{hour}$$

Now we just need to convert seconds to hours. If we didn't know that there were 3600 seconds in an hour, we could do two expansions:

$$\frac{1: minute}{60: seconds} \* \frac{1: hour}{60: minutes}$$

But in the interest of brevity, I'll just do it directly:

$$\underline{\hspace{15px}} \frac{meters}{second} \* \frac{1: kilometers}{1000: meters} \* \frac{0.621: miles}{1: kilometer} \* \frac{1: hour}{3600: seconds} = \underline{\hspace{15px}} \frac{miles}{hour}$$

Looks good?

Well, no. Note that I made a mistake there. The units don't cancel correctly. So the left side gives us mile-hours per second^2, and the right side is miles / hour. That doesn't match.

Oh, I inverted the seconds conversion. We can tell this easily because the "seconds" unit is on the bottom for both the original and the conversion (they need to be opposite to "cancel out"). Let's fix that:

$$\underline{\hspace{15px}} \frac{meters}{second} \* \frac{1: kilometers}{1000: meters} \* \frac{0.621: miles}{1: kilometer} \* \frac{3600: seconds}{1: hour} = \underline{\hspace{15px}} \frac{miles}{hour}$$

And there we have it. Without looking anything up (aside from a few basic definitions of primitives) we were able to go from meters per second to miles per hour. And we are able to verify not only how, but the correctness of the conversion.

Collapsing that, we get:

$$\underline{\hspace{.5in}} \frac{meters}{second} \* \left ( 2.23 \frac{mile-seconds}{meter-hour}\right ) = \underline{\hspace{.5in}} \frac{miles}{hour}$$

So using that, we can see that 10 meters / second is approximately 22.3 miles per hour.

## In Practice

Now in practice, you're not going to use this much. Even 10 years ago people still did manual unit conversion by hand, where dimensional analysis was critical. But today, we have tools like Google. Instead of breaking out formulas to do the conversion, you'd just type `10 meters per second to miles per hour` into Google and out will pop the answer.

So why do I think that this is an important tool? Why do I think that everyone should know it? And why am I writing about it on a programming blog?

Well, imagine that you have a list of data and you need to convert it into a different form.

You could string together function calls until you get it into the form you wanted. And in practice many people do just this.

But with dimensional analysis you can look at it differently. You can look at the data as the left-hand side of the equation, with the operations you perform on it as "transformations". Then the output is the right hand side.

We can now, without running the code, see if it makes sense.

Let's say you wanted to sum the total value of a list of bank transactions. We could specify this as `Transaction[]` to indicate an array of transaction objects. Then our end result is an integer. So we have:

```php
Transaction[] * (operation) = int

```
Well, what do our operation(s) need to be? Well, the first thing we need is to extract a value for each transaction:

```php
Transaction[] * (Transaction[] -> int[]) * (operation) = int

```
So we apply a function (operation) that takes an array of transactions and produces an array of integers (the extracted totals). So now we're left with `int[]` on the left side. So now we need an operation that totals up those integers:

```php
Transaction[] * (Transaction[] -> int[]) * (int[] -> int) = int

```
But wait, we can go a little bit simpler. Note that our first operation `Transaction[] -> int[]` accepts and produces arrays of the same size. Therefore, we can drop the `[]` from the end.

So we can describe the operation as:

```php
Transaction[] * (Transaction -> int) * (int[] -> int) = int

```
And this is basically map-reduce at the type level. That code would be equivalent to the pseudo code:

```php
$transactions
    ->map(function ($transaction) { 
        return $transaction->total 
    })
    ->reduce(
        function ($total, $new_amount) { 
            return $total + $new_amount 
        }, 
        0
    );

```
Now, from a type standpoint this is perfectly valid. We can see the conversions happening and we get a nice clear picture as to the type movement in our program.

You can in fact reduce entire programs (in strict typed languages at least) to simple type equations.

```php
input * (input -> output) = output

```
Where `input -> output` is your program (a function that takes input and produces output).

This is an incredibly powerful way of modeling programs.

There is however an incredibly strong gotcha here. You can only model programs like this if you stick to a strict type model. If types can change (a function returns more than one type for example), then this entire technique goes out the window. Additionally, functions cannot have side-effects (their results must depends solely on their inputs).

## Wrap It Up

Give this a try the next time you write a formula or need to do data conversion. It takes a bit of practice to get used to, but once you do it's an incredibly useful technique.

<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>