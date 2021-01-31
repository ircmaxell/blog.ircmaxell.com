---
layout: post
title: The Anatomy Of Equals - Opcode Analysis
permalink: 2012/07/the-anatomy-of-equals-opcode-analysis.html
date: 2012-07-18
comments: true
categories:
- PHP
tags:
- Answers
- Email Response
- Learning
- PHP
- PHP-Internals
- Programming
---

I was asked an interesting question via email yesterday. The question is fairly simple. The answer, not so much... So, rather than reply in an email, I figured that I'd write a post about it instead. The question, simply stated, is: *When comparing a float to an integer using ==, where does the conversion happen?*

So, let's begin...

<!--more-->

## The Test Code

So the first step that we need to do prior to answering the question, is to define the simplest code that we can to analyze the process. So, we could start with this code:

```php
<php 1 == 1.0;
```

But that's a bit `too` simple. We want to know what happens with the variables, but there are no variables!!! So instead, let's add a few variables:

```php
<php
$i = 1;
$j = 1.0;
echo $i == $j;
```

Now we're in good shape. So, the next step is to figure out what's going on. The easiest way to do so is to look at the generated opcodes. I used the [Vulcan Logic Disassembler](http://derickrethans.nl/projects.html#vld) with 5.4.4 to do that.

## The Opcodes

Those 4 lines of PHP generate these 8 lines of opcode:

```php
line     # *  op           fetch  ext  return  operands
--------------------------------------------------------
   3     0  >   EXT_STMT
         1      ASSIGN                         !0, 1
   4     2      EXT_STMT
         3      ASSIGN                         !1, 1
   5     4      EXT_STMT
         5      IS_EQUAL               ~2      !0, !1
         6      ECHO                           ~2
   6     7    > RETURN                         1
```

Now, for our purposes, we're interested in opcode 5, the `IS_EQUAL` call. But before we dig into that, let's talk for a second about the output we've been provided. The first bit of interesting information is in the `"op"` column. This tells us the operation that's going to be executed (we'll look up one in a little bit). Then, there are a bunch of numbers on the right. The ones that are prefixed (~ and ! here) are variables, and the others are raw numeric values. The difference between ~ and ! is that ! is a compiled variable (a normal PHP variable), where ~ indicates a temporary variable (used when directly passing values from one opcode to another).

So, up to opcode 5, we've just assigned the two values to the two variables (it's worth noting that **!1** -and hence **$j**- is a float, the decimal is just not outputted here). So by the time we hit line 5, we have all the information we need to figure out what `IS_EQUAL` does.

## Opcode Handlers

Before we can dig too deep into `IS_EQUAL`, we need to first talk about opcode handlers. When PHP generates its VM (yes, it's generated), it has multiple "versions" of each opcode that it can use. For `IS_EQUAL`, you can imagine that the code needed to fetch arguments is different if the operands are constants (1 and 1.0) as opposed to variables (the variable handling code needs to be different). 


So the handlers are defined in [Zend/zend_vm_execute.h](http://lxr.php.net/xref/PHP_5_4/Zend/zend_vm_execute.h). They have the naming convention: `ZEND_{$OPCODE}_SPEC_{$VAR1_TYPE}_{$VAR2_TYPE}_HANDLER`. So, by looking at the operands to our `IS_EQUALS` call, we can tell that they are both complied variables. Therefore, we're looking for the `ZEND_IS_EQUALS_SPEC_CV_CV_HANDLER` definition. And sure enough, it's on [line 34805](http://lxr.php.net/xref/PHP_5_4/Zend/zend_vm_execute.h#34805). Here's the code:

```c
static int ZEND_FASTCALL  ZEND_IS_EQUAL_SPEC_CV_CV_HANDLER(ZEND_OPCODE_HANDLER_ARGS)
{
    USE_OPLINE

    zval *result = &EX_T(opline->result.var).tmp_var;

    SAVE_OPLINE();
    ZVAL_BOOL(result, fast_equal_function(result,
        _get_zval_ptr_cv_BP_VAR_R(EX_CVs(), opline->op1.var TSRMLS_CC),
        _get_zval_ptr_cv_BP_VAR_R(EX_CVs(), opline->op2.var TSRMLS_CC) TSRMLS_CC));


    CHECK_EXCEPTION();
    ZEND_VM_NEXT_OPCODE();
}
```

Let's ignore all the code with the exception of the `fast_equal_function`. The arguments are pretty straight forward, with the one exception of the funky `_get_zval_ptr_blah_blah_blah` lines. All those do is get the variable (zval, remember?) from the opcode array. Then, we're just calling `fast_equal_function(result, var1, var2)`.

## Fast Equal Function

Continuing on, we need to look inside of `fast_equal_function` to see what's going on. It's important to note that we haven't modified any variables up to this point. So !0 ($i) and !1 ($j) are still an integer and a float (respectively). So let's check out the [definition of `fast_equal_function`](http://lxr.php.net/xref/PHP_5_4/Zend/zend_operators.h#818)...

```c
static zend_always_inline int fast_equal_function(zval *result, zval *op1, zval *op2 TSRMLS_DC)
{
    if (EXPECTED(Z_TYPE_P(op1) == IS_LONG)) {
        if (EXPECTED(Z_TYPE_P(op2) == IS_LONG)) {
            return Z_LVAL_P(op1) == Z_LVAL_P(op2);
        } else if (EXPECTED(Z_TYPE_P(op2) == IS_DOUBLE)) {
            return ((double)Z_LVAL_P(op1)) == Z_DVAL_P(op2);
        }
    } else if (EXPECTED(Z_TYPE_P(op1) == IS_DOUBLE)) {
        if (EXPECTED(Z_TYPE_P(op2) == IS_DOUBLE)) {
            return Z_DVAL_P(op1) == Z_DVAL_P(op2);
        } else if (EXPECTED(Z_TYPE_P(op2) == IS_LONG)) {
            return Z_DVAL_P(op1) == ((double)Z_LVAL_P(op2));
        }
    }
    compare_function(result, op1, op2 TSRMLS_CC);
    return Z_LVAL_P(result) == 0;
}
```

It looks like there's a lot going on in there. But in reality, it's pretty simple. One thing that's worth noting, is that `EXPECTED()` is just a macro wrapper for something we don't need to worry about, for our purposes we can treat it like it wasn't there. So, at the root of the function, we have 3 branches. The first is if the first variable is an integer. The second is if the first variable is a float. The third and final branch occurs if the first variable is anything else. 

Inside each of the first 2 branches, there are another 2 branches that check to see if the second argument is an integer or a float. If so, it does a simple numeric comparison. If not, it falls back to the generic comparison function below.

So there's our answer. `$i == $j` does no zval cast at all. It only does a simple C variable numeric cast (which is value based, has no lasting side-effects and requires no additional memory allocation). So both source variables are left untouched. There is no "conversion" going on.

## Conclusion

Reading the source isn't difficult, if you know where to look. Give it a try. For an exercise, take a look at `[compare_function()](http://lxr.php.net/xref/PHP_5_4/Zend/zend_operators.c#1402)` and figure out what would happen if one argument is a string `"2abc"` and the other is an integer `2`...

Do you have a question that you want me to try to answer? Something about how PHP works internally? Something about OO Design? Something related to PHP? Shoot me an email at `ircmaxell [at] php [dot] net`, and I'll see if I can answer it!