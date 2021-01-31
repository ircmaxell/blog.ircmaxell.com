---
layout: post
title: DAOs and MySQL - A Response
permalink: 2012/07/daos-and-mysql-response.html
date: 2012-07-25
comments: true
categories:
- Programming
tags:
- Answers
- Database
- Email Response
- Good Enough
- Learning
- Object Oriented Programming
- PHP
- Programming
---

In response to last week's ask for questions, I received a number of questions that I'd like to address. Since it would only do the question justice to have a dedicated post for each question. So I'm going to try to do one post per week on a user-submitted question (probably on Wednesday, but no promises). This week's question is a rather abstract one: 

> I've been learning a lot about service layers and managers and domain objects and one thing really confuses me. Why is MySQL being turned into a non-relational database? It has so much power, so much flexibility, but it seems like many programmers want to abstract it to the point of near uselessness.


Now, there are so many facets to that question that it's hard to find a starting point. But let's try:<!--more-->


### What Does Relational Mean?


To properly understand the question, and frame this response, we should probably first talk about what the term "relational" means in the context of database data. Let me assert my own definition of relational, and then we can talk about what it means:> Relational data is when we store related data as unique and separate records, and link them together using a stored relationship.


So the meaning there is pretty ambiguous. The important part is that the data is stored separately. So if you have a list of books, and their authors (and associated metadata), you'd store the book records separately from the author records, and them link them together using a relationship. In the database context, that relationship could be a join table or a foreign key (depending on the nature of the relationship). Either way, it just means that we separate out the different data types into different records, and then link them together. 

Why would we want to do this? Well, it makes each piece of data first-class. We can query easily for all books by a particular author, or for all authors for a specific book. We can also do aggregate queries very easily. For example, we could find the number of books an author has written by a simple group query: `SELECT COUNT(book_id) FROM book_to_author WHERE author_id = ? GROUP BY author_id;`. Simple, straight forward and powerful.
### The Problem With Relational Models


There's no fundamental problem with relational models. There, I said it. They are not broken, they are not bad, they are not inefficient. They exist for a reason (because some data storage needs are best implemented using a relation model). The reason that there's push-back against relational databases in recent time is that most of the problems that we're solving don't really need a relational model. If you're writing a blog engine, there's usually no need to add tens of join tables. Just store the post document as a whole, and fetch it when needed. <span style="background-color: white;">In the off case that you need a relational style query, such as finding the number of posts by a specific author, you can simply use a non-relational tool like map-reduce to query against it.</span><span style="background-color: white;">
</span><span style="background-color: white;">Once you accept that not all problems are relational (or best solved by relational models), things become a lot easier. Database design becomes trivial. Database storage operations (CRUD) become trivial. A lot becomes trivial. And, since you don't have the relational overhead when you don't need it, it allows for higher performance database engine designs.</span><span style="background-color: white;">
</span>
The point is that you need to realize there's no silver bullet. Not every problem is a relational one. And not every problem is a non-relational one. Both models fit and can work together.
### A Reason For Abstraction


When you're designing an application, you're likely going to be implementing business objects. Those business objects will need to know how to work together to either represent state, or modify state within your application. So your application business objects will evolve to contain implicit (and sometimes explicit) relationships with the other business objects in your system. So when it comes to persisting the data from those business objects, the first glance solution is to just store them in the same hierarchy. In fact, this is exactly what Active Record does. It mimics the business object's relationships in the persistence layer (database).

The problem with this approach is that it tightly couples your application design to your database design. So if you need to re-implement something in your database to be more efficient, or re-implement a business object to better represent a new use-case, you're screwed. You're stuck with ugly data migration hacks and a lot of pain. But, as it turns out, there's a pattern out there that solves this for us. It's called a [Data Mapper](http://martinfowler.com/eaaCatalog/dataMapper.html).

By abstracting persistence from business logic, both are free to vary independently. If you want to change how you're persisting data, you just need to update your mapper. If you need to change how you're structuring your business logic, you just need to update the mapper. It allows for both implementations to vary independently. Internally, the mapper may be using an ORM, or it may be using raw SQL. Or it may be doing something we haven't thought of today. But the point is that `-to the business objects-` it doesn't matter. It's just an abstracted detail.


Taken a step further, the details needed to determine what to fetch are very easy to determine: the method called on the mapper, and the arguments to the mapper. This makes it trivially easy to implement a caching proxy for the data mapper. All you need to do is intercept the call to the mapper (by decorating it - for example), hash an id out of the method name, class name, and arguments, and do a cache fetch. Really, it can make adding meaningful object caching quite simple...


Furthermore, for a large number of applications the details of data persistence are unimportant. Either they are not dealing with large volumes of data, or the relationships are very simple and easy to model. Or, perhaps it just isn't important enough to worry about (for that application). In those cases, it's not even worth writing SQL. That's the case when an ORM or query builder can be of full use. You can write simple mappers very quickly which handle the basic CRUD for you. So rather than taking a few hours to write your data persistence logic, you can just "let it be done for you" so you can go on to worry about other things. I stress here that this is not something that should be done for important applications, since you really should be thinking about persistence in those cases (not saying not to use ORM, but to not just "let it be done for you", and think about it)...
### <span style="background-color: white;">Harnessing</span> The Power Of SQL


The true beauty of the data mapper concept is that if you want to run a specialized query to build a specific result set, just add it as a query on the appropriate mapper. Since the dependencies are segregated, it lets you just implement it.

But now let's imagine that you don't want to construct business objects out of the database result set. Let's say you just want the results of the query, but you're not going to use them for any business logic. Well, that's not really a valid statement. You're **always** going to be using a result for business logic. The key is that displaying results is a business responsibility. So to say that "you just want the results" is a bit of a misnomer. What you're really after is the results without the normal business object mapping going on.

There's a special term for that: reporting. You don't want to act on the data (specifically at least), you just want to use the data in a simple form. So the easy way to do that would be to build a generic report-set business object. It would contain the normal business rules around reporting, but would return the data in a reasonably raw form. Pretty simple.

But beware that there's a hidden danger to doing this. If you expose raw data via a reporting class like that, you can wind up either duplicating code between business objects (at best), or having holes in your business logic (at worse). Imagine if you had a business rule that post bodies could only be displayed if the user was an administrator. The post object checks for this rule, and handles it for you. But the report class just proxies the data for you. So you wind up with a security breach, since you duplicated data and effort.
### Conclusion


The big thing to grasp here is that [There's A Difference Between Good And Good Enough](http://blog.ircmaxell.com/2011/03/difference-between-good-and-good-enough.html). Depending on the logic demands and generic requirements of the application, the correct choice is far from clear. There's really a lot of judgement calls to be made, and a lot to be considered. But the key is to understand the different methods of persisting and fetching data, and why (and when) each should be used. Then, make the appropriate decision for your application. No-SQL is not right for every project. SQL is not right for every project. Analyze your requirements, and decide what you need.


Do you have a question that you want me to try to answer? Something about how PHP works internally? Something about OO Design? Something related to PHP? Shoot me an email at `ircmaxell [at] php [dot] net`, and I'll see if I can answer it!
