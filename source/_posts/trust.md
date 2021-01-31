---
layout: post
title: Trust
permalink: 2017/01/trust.html
date: 2017-01-12
comments: true
categories:
- Security
tags:
- PHP
- Security
- Thoughts
- Trust
---
Stop and take a moment to think about how much trust is required to live your everyday life. Every single aspect of your life is built up on layer after layer of trust, it's nothing short of staggering. Different aspects of life will contain different levels of trust, with some being very guarded and some being very lax. We don't often talk about this trust and we often make the blind assumption that trust is inherently a bad thing. That's most definitely not the case. Let's explore why.

<!--more-->

## Driving

Let's look at the simple(ish) case of driving. There's an extraordinary amount of trust required. When you're behind the wheel, you're not only trusting every single engineer who designed every component of your vehicle, but of every surrounding vehicle as well. You're trusting the quality assurance processes of each manufacturer. You're trusting the assembly line technician. You're trusting the mechanics. The part manufacturers. Not to mention the surrounding infrastructure (who would want a road to collapse when they are driving on it).

You also need to trust the drivers around you. You trust that the person driving next to you on the highway isn't going to randomly jerk the wheel into you and cause an accident. You trust that they aren't drunk or otherwise impaired. That they are also driving in the shared best interest of safety.

Yet we all know that blind trust in any of those items is bad. Driving schools teach "Defensive Driving" techniques, to prepare you if someone does drive poorly around you. You take your car to mechanics to be inspected so you can verify that the parts that the engineer said were going to last, are going to be safe and last.

Each and every one of these "Trusts" are leaky, meaning that we all know of instances that each and every one of them have failed (remember the Ford Pinto?). Yet it's far more useful to us to trust than not to, even though we all know that trust isn't perfect.

As a society, we've built mechanisms to balance the benefits of reducing the necessary trust against the costs that the measures take to implement.

## An Aviation Lesson

Compare driving a car to flying a plane. The regulations are far stiffer for the pilot in pretty much all cases. You probably know that it's **far** harder to get a pilot's license than a driver's license. A basic pilot's license takes 40-80 hours of training plus a comprehensive exam, plus 6 hours of training every 2 years. And there are many more licenses beyond that.

What you may not know though is that airplanes have mandatory maintenance schedules that require inspections and service as few as every 25 hours of operation. Compare that to automobiles which typically get serviced once per year if the owner is diligent; FAR less in many cases. The stakes are simply far lower with a car.

Another great example is in the case of air traffic control. Airspace (in the USA at least) is divided into 7 "classes", with 3 of them being "controlled" (you're not allowed to enter without talking to someone first).

Away from metropolitan areas, you can fly in uncontrolled airspace without talking on a radio. You're flying all by yourself using "Visual Flight Rules" (you need to see where you're going). You trust that other pilots are looking for you, are following rules as well as established conventions. In areas with more traffic, the rules increase.

As with any rule increase, the overhead and therefore costs increase dramatically. Instead of being able to take a quick 10 minute flight to a neighboring airport, you now need to file a flight plan and put yourself at the mercy of a controller. What could have taken 20 minutes including planning now takes over an hour. This added cost increases safety and reliability dramatically.

## Trust Is Always Required

No matter what situation you're in, there will *always* be some amount of required trust. Take AWS for example. You're trusting that Amazon really doesn't have the keys to the server they built for you. You're trusting that they are going to give you the uptime they promise (or in Amazon's case, that they imply). You're trusting that the machine is what they say it is. You're trusting them for a whole lot more than that in reality, but there's always trust required.

But as with driving, blind trust is also not always the best. So we can install measures to verify that trust and ensure that nothing too bad happens without us at least knowing about it.

Tools like Tripwire are perfect examples of this concept. You need to give *someone* access to your production machines (or access to the machines that have access, or access to the machines that have access to the machines that have access, etc). How do you ensure that they are doing what they say they are, not modifying files directly in prod? A tool such as tripwire that helps verify that the trust wasn't broken.

Could you prevent the possibility in the first place? Not in the generic case. Someone effectively needs access to the root key (either directly, or through another machine). You can lock your engineers down or you can give them total freedom. Or, you could do the smart thing and give them enough freedom so they can do their jobs effectively, and implement "verification" systems to detect breach of trust (even for "honorable" reasons).

This is what many companies do. Trust, but verify.

## Perfectly Secure Applications Are Unusable

Security is always a trade-off against usability. The only  way to make a perfectly secure system is to not make the system in the first place. The trick isn't making the system perfectly secure, the trick is balancing the security requirements with the costs (monetary, time and usability) to implement those requirements.

It's important to note that I'm not talking about security requirements that are about diligence in construction, such as SQL Injection, XSS, etc. Those costs are literally nothing compared to the wrong way, if you do it right from the beginning. So the investment in education and training on those types of attacks is vital and should never be traded away. There's no reason to go out to sea in a boat full of holes in the hull.

The costs I'm talking about come in terms of UX tradeoffs, in terms of application-level security (requiring approvals, multi-factor authentication, etc) and costs associated with controlling access (authentication, access control, scopes and federation, etc).

It's easy to find an attack vector (they always exist). The key is weighing the cost of exploit against the cost of mitigation against the cost of breach (the damage it will do).

Effective security doesn't end with all boxes checked. Effective security comes from the *right* boxes checked. This is always a continuing question and dynamic. One that changes over time.

After all, you're going to trust a janitor in a supermarket a **lot** more than you're going to trust a janitor in a nuclear power plant. Both require trust, but must you tailor the limitations and mitigations to the problem at hand.
