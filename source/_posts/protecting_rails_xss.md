---
layout: post
title: Protecting Against XSS In RAILS - JavaScript Contexts
permalink: protecting-rails-xss
date: 2018-06-21
comments: true
categories:
- Security
tags:
- XSS
- Ruby-On-Rails
- Ruby
- Programming
- Security
---
Recently my team was working to implement [Brakeman](https://github.com/presidentbeef/brakeman) in our CI processes to automatically scan our codebase for security vulnerabilities. Among a few other issues, it identified a handful of similar XSS vulnerabilities of a similar pattern:

```html
<script type="text/javascript">
  var FOO = "<%= raw whatever %>";
  ReactDOM.render(<Blah
    foo={window.FOO}
  />, document.getElementById('some_place'));
</script>
```

This is a pretty straight forward vulnerability, since passing `"; alert(1); "` for `whatever` will result in the code being rendered as `var FOO = ""; alert(1); "";` which isn't good.

The fix, isn't so simple. I've searched high and low, and couldn't find a single source that had the correct solution to the problem. So here it is...
<!--more-->

## Incorrect Fix #1: Just HTML Escaping

The first "fix" would be to switch to using Rails's built in HTML escaping:

```javascript
var FOO = "<%= whatever %>";
```

Note that this is what rails does by default. This would theoretically protect against *most* XSS vulnerabilities here, but there are still two problems:

First, if the input contains newlines, it will render invalid JavaScript resulting in a syntax error (and in some circumstances potentially a vulnerability). This is because, if we pass in `\nalert(1); //`, the rendered code will be:

```javascript
var FOO = "
alert(1); //"
```

And since JavaScript doesn't support multi-line strings, syntax error. So not good.

The second problem (and the reason `raw` was added in the first place), is that we're using the result of that variable in a data context in JavaScript. Which means that HTML entities won't be decoded. So passing in `This & That` will get rendered as:

```javascript
var FOO = "This &amp; That";
```

But since React is treating the variable as a data entity (just as jQuery's `.text()` method), it won't decode that entity. Resulting in a bug where you're displaying entities to the user. Not good.

## Incorrect Fix #2: Escape JavaScript

Another fix that's often cited on is to just use `escape_javascript`. So:

```javascript
var FOO = "<%= escape_javascript whatever %>";
```

It's also aliased as `j` since it's used often:

```javascript
var FOO = "<%= j whatever %>";
```

This solve the first issue from before, where newlines would break the JavaScript and result in syntax errors. So that's good.

The second problem is still there though. It's still HTML encoding the output. But how?

## The hidden "magic" that's breaking everything and keeping it together

If we look at the docs for [`escape_javascript`](http://api.rubyonrails.org/classes/ActionView/Helpers/JavaScriptHelper.html), we'll see nothing about HTML encoding. But if we look closely at the example, we can see what's happening:

```javascript
$('some_element').replaceWith('<%= j render 'some/element_template' %>');
```

Notice the jQuery function that's being called: [`replaceWith`](https://api.jquery.com/replacewith/). That takes an **HTML** string and inserts it. Meaning, that the string that's being rendered with `escape_javascript` in this case is HTML, not data. So what's actually happening, is Rails is escaping for JS **then** escaping for HTML before it renders. This is because `escape_javascript` doesn't mark the result as HTML safe.

But there's a really subtle problem with all of this. The order of execution is different on encode and decode.

When encoding (Rails is rendering), the value is processed in this order:

 1. By `escape_javascript` (resulting in `\\` being added before `\\`, `</`, `\r`, `\n`, `'`, and `"`)
 2. By `html_escape` (resulting in `&`, `>`, `<`, `"` and `'` being converted to HTML entities)

When the browser decodes this data, it does it *in the same order*:

 1. By first processing the JavaScript (looking at `"` and escaped newlines, etc)
 2. When rendering via HTML context, process the HTML entities

Is this safe? In theory, no. One of the rules for escaping for multiple contexts is that each context should form a "wrapper" around the inner ones, and escaping/unescaping should happen in the reverse sequences. In this case, if we decode as JavaScript then HTML, we should encode as HTML *then* as JavaScript, so that the outer most encoding is the first one to get decoded. Think of these like "shells" where JavaScript "contains" the HTML.

In practice though, is this safe? The short answer is kind-of. There are two ways we could in-theory break this: breaking out of the JS string, or injecting something unsafe into the resulting HTML. 

Breaking out of the JS string *could* be possible if `html_escape` restored or altered something that `escape_javascript` fixed. In this specific case, it appears that didn't happen (since every character `html_escape` changes it changes to an entity which is safe).

Breaking out of the resulting HTML isn't possible either, since the only way to get that character into JS without hitting `html_escape` would be using an escape sequence (`\x3C` would become `<` for example). But `escape_javascript` will automatically escape any free `\` characters we have in the string.

So it appears it is actually safe. Though I do want to stress here, it's not safe by design, but simply by the specifics of the implementation. A change to either implementation (`escape_javascript` or `html_escape`) could open new vulnerabilities due to this design issue.

## Correct Fix: Escaping JavaScript Only

Since we're later going to use the value as data, the proper solution is to mark the value as `html_safe` so Rails won't run `html_escape` on it:

```javascript
var FOO = "<%= escape_javascript whatever.html_safe %>";
```

This will prevent double-encoding of entities, and will be safe from XSS.

However, if we later use `FOO` in a HTML context (such as via `$(blah).html(FOO))` that will be injected). Instead, we need to ensure that the usages will treat it as data and not as HTML (in jQuery, switching to `$(blah).text(FOO)`. 

This is a bit counter-intuitive, since the value isn't really `html_safe`. What's really happening is that we don't want to encode for HTML because that will be done later by another process. There's no way to indicate that to Rails that otherwise would pass "XSS" checks. 

The other way we could do it (functionally equivalent):

```javascript
var FOO = "<%= raw escape_javascript whatever %>";
```

The only problem with this, is that Brakeman will still flag this as XSS, as the majority of time you use raw in a template, it's XSS. It's hard for it to know the subtle nuances of the usage, and as such has to default to sane rules. Though perhaps that's something that can be fixed in Brakeman in the future (allowing `raw` before `escape_javascript` in quoted script contexts).

## The Takeaway

What matters at the end of the day, is that you know where your data is going, and what expectations surround it. Are you rendering HTML to be interpreted by the browser? Are you rendering data that will be interpreted by another application and escaped later?

This is just another example where "just let the framework handle it" leads to either a sub-par result (rendered HTML entities) or an insecure one. In order to be able to effectively use a tool, you need to understand what it's doing under the hood so that you can use it appropriately.

Oh, and security scanners like [Brakeman](https://github.com/presidentbeef/brakeman) are amazing (though definitely not perfect), why aren't you using one?

