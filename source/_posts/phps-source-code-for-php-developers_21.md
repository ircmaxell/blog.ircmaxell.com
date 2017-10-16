---
layout: post
title: PHP's Source Code For PHP Developers - Part 3 - Variables
permalink: phps-source-code-for-php-developers_21
date: 2012-03-21
comments: true
categories:
- PHP
tags:
- PHP
- PHP Source Code For PHP Developers Series
- PHP-Internals
---

In this third post of the `PHP's Source Code for PHP Developers` series, we're going to expand on the prior posts to help understand how PHP works internally.  In [the first post](http://blog.ircmaxell.com/2012/03/phps-source-code-for-php-developers.html) of the  series, we looked at how to view PHP's source code, how it's structured as well as some basic C pointers for PHP developers.  The [second post](http://nikic.github.com/2012/03/16/Understanding-PHPs-internal-function-definitions.html) introduced functions into the mix.  This time around, we're going to dive into one of the most useful structures in PHP: variables.

<!--more-->
## Enter the ZVAL

In the core, PHP land variables are called `ZVAL`s.  This middle structure is necessary for a number of reasons, not least of which is that PHP uses dynamic typing where C uses strict typing.  So how does this ZVAL thing solve that problem?  Well, to answer that question, we need to actually look at the definition of the ZVAL type.  To do that, let's try searching [lxr.php.net](http://lxr.php.net/) for [zval in the definition box](http://lxr.php.net/search?q=&project=PHP_5_4&defs=zval&refs=&path=&hist=).  At first glance, it doesn't look like we found anything useful.  But there is a `typedef` line in `zend.h (`typedef is a way to define new data types in C) .  That `might` be what we're looking for, so let's [check that out](http://lxr.php.net/opengrok/xref/PHP_5_4/Zend/zend.h#287).  Initially, this looks like a red-herring.  There doesn't appear to be anything useful here.  But just to be sure, let's try clicking on that [_zval_struct](http://lxr.php.net/opengrok/xref/PHP_5_4/Zend/zend.h#_zval_struct) line.


```c
struct _zval_struct {
 /* Variable information */
 zvalue_value value;  /* value */
 zend_uint refcount__gc;
 zend_uchar type; /* active type */
 zend_uchar is_ref__gc;
};
```

And there we have the foundation for all of PHP, the zval.  Looks quite simple, right?  It is, but there's some pretty significant magic in there as well.  Note that this is a `struct` or structure.  Basically, think of this like a class definition in PHP with only public properties.  In this case, we have 4 properties: a value, a `refcount__gc`, a type and a `is_ref__gc`.  Let's examine each of these properties one by one (slightly out of order):

### Value


The first element that we come across is named value, and has a type of `zvalue_value`.  I don't know about you, but I've never heard of a `zvalue_value` before...  So let's try to figure out what it is.  Like other parts of that site, you can click on the type to see its definition.  And if you do, you'll notice that its definition is literally [right before it](http://lxr.php.net/opengrok/xref/PHP_5_4/Zend/zend.h#307) in the file.

```c
typedef union _zvalue_value {
 long lval;  /* long value */
 double dval;  /* double value */
 struct {
  char *val;
  int len;
 } str;
 HashTable *ht;  /* hash table value */
 zend_object_value obj;
} zvalue_value;
```

Now, there is some serious dark voodoo going on here.  See that `union` declaration?  That means that this is not actually a structure, but a single type.  But there are more than one types in that list!  How can it be a single type, if there are multiple types?  I'm glad you asked.  To understand this, we must first remember back to our talk about types in C from the first post. 

Remember that in C, variables are just labels for raw memory addresses.  Well, it also follows that types are just a way of denoting what a particular block of memory is used for.  There's nothing in C separating a 4 byte string from an integer.  They are both just blocks of memory.  The compiler will try to enforce it by "labeling" the memory segments as variables and enforcing those types from that variable, but it's not always able to (incidentally, when one variable "overwrites" its allocated memory segment, that can become a segmentation fault). 

So, with that in mind, a `union` is simply a single type that can be interpreted in different ways depending on how its accessed.  This allows us to have one value declaration that can support all of our types.  The caveat is that all types must therefore take the same amount of memory to store.  In this case on a 64 bit compile, a long and a double will both take 64 bits to store.  The string struct will take 96 bits (64 bits for the char pointer, and 32 bits for the int length).  The hash table will take 64 bits, and the zend_object_value member will take 96 bits (32 for the handle element, and 64 for the handlers pointer).  So the overall union will take the same size as the largest element, so in this case 96 bits.

Now if we look closer at the union, we can see only 5 of our PHP data types represented (long == int, double == float, str == string, hashtable == array, zend_object_value == object).  So what happened to the rest of the data types?  Well, as it turns out, this is enough to store the rest of the data types as well.  BOOL is stored as long (int), NULL doesn't use the value segment, and RESOURCE uses long as well.

### Type

Now, since the value union doesn't actually control how it's accessed, we need some way of keeping track of the type of the variable.  This way, we can know how to access the value information from value type.  This is handled by the type byte (zend_uchar is a single unsigned character, or a single byte of memory).  This holds the information from the [zend type constants](http://lxr.php.net/xref/PHP_5_4/Zend/zend.h#564).  There's really no magic here, it's just `zval.type = IS_LONG` to define an integer.  So this field and the value field are enough to know the data type and value of a PHP variable.

### IS_REF

This field denotes if the variable is a reference.  What that means, is that you've done `$foo = &$bar` with the variable.  If it's a `0`, then the variable is not a reference, and if it's a **1**, it is a reference.  This really doesn't do much by itself.  So before we write this value off, let's look at the fourth member of the zval struct.

### REFCOUNT

This field is really just a counter of the number of PHP variables that point to this internal variable representation.  So a refcount of 1 indicates that there's exactly one PHP variable pointing to the internal representation.  A value of 2 indicates that there are 2 PHP variables pointing to the same zval instance.  By itself, this isn't really useful information, but when coupled with the `is_ref `parameter, we have the basis for both garbage collection and copy-on-write.  This lets us use the same internal zval storage for more than one PHP variable.  Reference counting semantics are beyond this post, but if you want to dig further, I'd suggest[ this documentation article](http://php.net/manual/en/features.gc.refcounting-basics.php).

So that's all there is to the `ZVAL`...

## How Is It Used?

In PHP's core, the zval is passed around to internal functions just like any other C variable, as a memory segment, or a pointer to a memory segment (or a pointer to a pointer, etc).  Once we have the variable, we want to access data from it.  So how do we do that?  We use the macros that are defined in [zend_operators.h](http://lxr.php.net/opengrok/xref/PHP_5_4/Zend/zend_operators.h) to make working with zvals much easier.  One important thing to realize is that there are multiple copies of each macro.  The difference is the suffix.  For example, to determine the type of a zval, there's the `Z_TYPE(zval)` macro, which returns an integer describing the type from the passed in zval entry.  But there's also `Z_TYPE_P(zval_p)` macro, which does the same thing, but for a pointer to a zval.  In reality, there's no functionality difference between them other than the nature of the argument (value vs pointer vs pointer to pointer, etc), and we could actually do `Z_TYPE(\*zval_p)` ourselves, but the `_P` and `_PP` copies make life a little bit easier...


To get the value of the zval, we can use the `VAL` macros.  To get the integer value (for integers and resources), you'd call `Z_LVAL(zval)`.  To get the floating point value: `Z_DVAL(zval)`.  There are others, but  for now that should suffice.  The key to note is that to get a C value from a zval, you need to use a macro (well should use).  So when we see a function that uses them, we know it's extracting a value from the zval.

## But What About Types?

So far, we've just talked about the type and value the zval had.  As we know, PHP does type juggling for us.  So we can treat a string like an integer if we want.  The way to do that is using the `convert_to_**type**` functions.  So, to convert a zval to a string, we'd call [convert_to_string](http://lxr.php.net/xref/PHP_5_4/Zend/zend_operators.h#convert_to_string).  This would modify the type of the ZVAL we passed in.  So if you see a function doing something along those lines, you know it's playing around with the types of its arguments.

### Zend_Parse_Parameters

In the last post, we saw the function `[zend_parse_parameters()](http://lxr.php.net/opengrok/xref/PHP_5_4/Zend/zend_API.c#887)` introduced.  Now that we know how PHP variables are represented in C, we can dive deeper.

```c
ZEND_API int zend_parse_parameters(int num_args TSRMLS_DC, const char *type_spec, ...) /* {{{ */
{
 va_list va;
 int retval;

 RETURN_IF_ZERO_ARGS(num_args, type_spec, 0);

 va_start(va, type_spec);
 retval = zend_parse_va_args(num_args, type_spec, &va, 0 TSRMLS_CC);
 va_end(va);

 return retval;
}
```

Now, from the surface, this may look confusing.  The important thing to understand is that the `va_list` type is basically just an array listing the arguments that were specified using `...`.  So it's similar to the `func_get_args()` construct in PHP.  With that, we can see that zend_parse_parameters just proxies to another method called `[zend_parse_va_args()](http://lxr.php.net/opengrok/xref/PHP_5_4/Zend/zend_API.c#700)`.  Let's take a look at that one...


This function seems interesting.  At the first look, it appears to be doing a lot of work.  But let's look a bit closer.  First off, we notice a `for` loop.  This basically is iterating over the `type_spec` string that was passed in from `zend_parse_parameters`.  Inside, we can see that it's basically just counting the number of arguments to expect.  How it does that is left as a lesson to the reader.


As we continue, we can see that there's some sanity checking (checking to see that variables are populated correctly, etc), and error checking to see that the required number of arguments were passed.  Then comes the loop that we're interested in.  The loop that actually parses the parameters.  Inside, we notice 3 main if statements.  The first just handles the optional parameter specifier.  The second handles `var-args` (variable number of arguments).  The third if statement is what we're interested in.  We can see the [`zend_parse_arg()` ](http://lxr.php.net/xref/PHP_5_4/Zend/zend_API.c#zend_parse_arg)function is called.  Let's take a deeper look at that one...


As we look, we notice something very interesting here.  That function proxies to another (`zend_parse_arg_impl`), and then raises some errors.  This is a common pattern in PHP, extracting the error handling out of the function that does the work to a parent function.  That allows the implementation and the error checking to remain separate, and maximizes reuse.  You can dig through that function, it's pretty simple and easy to follow.  But let's take a closer look at [`zend_parse_arg_impl()`](http://lxr.php.net/xref/PHP_5_4/Zend/zend_API.c#zend_parse_arg_impl)...


And there we have it.  We've arrived at exactly how internal PHP functions parse their parameters.  Let's take a look at the first branch of the switch statement, which is used for parsing integer parameters.  From there, the rest of it should be understandable.  So let's start off with the first line of the branch:

```c
long *p = va_arg(*va, long *);

```

If you remember way back when we said that `va_args` is how C handles variable arguments.  So this basically defines a pointer of type integer (`long` is an integer in C).  However, it gets that pointer from the `va_arg` function.  Which basically means that it gets a pointer to the argument that was passed into the call to `zend_parse_parameters`.  So that's the result pointer that we'll populate with the final result of the branch.  Next, we can see that we're switching on the type of the passed in variable (zval).  Let's take a peak at the `IS_STRING` branch first (which is called when a string is passed into an internal function expecting an integer).

```c
case IS_STRING:
{
 double d;
 int type;

 if ((type = is_numeric_string(Z_STRVAL_PP(arg), Z_STRLEN_PP(arg), p, &d, -1)) == 0) {
  return "long";
 } else if (type == IS_DOUBLE) {
  if (c == 'L') {
   if (d > LONG_MAX) {
    *p = LONG_MAX;
    break;
   } else if (d < LONG_MIN) {
    *p = LONG_MIN;
    break;
   }
  }

  *p = zend_dval_to_lval(d);
 }
}
break;

```

Now, there's really a lot less going on here than it looks like.  It all boils down to the `is_numeric_string` function.  Basically, that function checks to see if the string contains only numeric characters, and if not returns 0.  If it does, it parses that string into an actual variable (integer or float, `p` or `d` respectively) and returns the type.  So we can see that if the string is not a number, it returns the string `"long"`.  This returned string is then used in the wrappers error handling.  Instead, if the string represents a double (float), it first checks to see if the float is too big to be represented as an integer, then it parses the double into an integer using the helper function `zend_dval_to_lval` (which makes sure the conversion is consistent).  And there we have it.  We've parsed our string parameter.  Let's take a look at the other branches:

```c
 case IS_DOUBLE:
  if (c == 'L') {
   if (Z_DVAL_PP(arg) > LONG_MAX) {
    *p = LONG_MAX;
    break;
   } else if (Z_DVAL_PP(arg) < LONG_MIN) {
    *p = LONG_MIN;
    break;
   }
  }
 case IS_NULL:
 case IS_LONG:
 case IS_BOOL:
  convert_to_long_ex(arg);
  *p = Z_LVAL_PP(arg);
 break;

```

Here, we can see the parsing for floats, which is oddly similar to the way that strings representing floats were parsed (coincidence?).  One important thing to notice here is that if the parameter specification is not a capital `L`, it falls back to being treated just like any other variable (there's no break on the case statement).  Now, we have one more interesting function here, `convert_to_long_ex()`.  This is basically identical to the `convert_to_**type()**` function set that we talked about earlier, in that it takes any variable and converts it to the requested type.  The only difference is that it separates (copies) the passed in variable if it's not a reference (since it's changing the type).  This is copy-on-write working its magic.  So if we pass in a float to a non-referenced integer parameter, the function will see it as an integer, but we'll still have our float.

```c
 case IS_ARRAY:
 case IS_OBJECT:
 case IS_RESOURCE:
 default:
  return "long";

```

Finally, we have the other 3 cases.  As we can see, if you pass an array, an object, a resource or an unknown type to an argument expecting an integer, you'll get an error...


I'll leave the rest of the implementations up to the reader.  Reading `zend_parse_arg_impl` is actually a really good way to better understand PHP's type juggling system.  Just take it part by part, and try to keep track of the states and types of the different C variables being passed around.

## The Next Part

The next part of this series will be over on [Nikic's Blog](http://nikic.github.com/) (we'll be bouncing back and forth for each part of the series).  In it, he'll cover arrays in all their glory.