---
layout: post
title: Unit Testing When You Have File-System Interaction
permalink: unit-testing-when-you-have-file-system
date: 2011-03-29
comments: true
categories:
- Testing
tags:
- Best Practice
- CryptLib
- PHP
- Unit Testing
---

While working on testing out my new Cryptography library (appropriately called [PHP-CryptLib](https://github.com/ircmaxell/PHP-CryptLib)), I ran into a rather interesting problem.  How do you unit test a method that interacts with the file-system?  Traditionally, this problem has been solved by either not testing the method or creating temporary directory structures, testing, and then deleting the temporary directories.  There has to be a better way.  And as it turns out there is!

<!--more-->

## The Problem

So, one of the classes in CryptLib ([Core\AbstractFactory](https://github.com/ircmaxell/PHP-CryptLib/blob/e8251c3c52a99fd9fc330386494d91e337666ec2/lib/CryptLib/Core/AbstractFactory.php)) has the following method:

```php
protected function loadFiles($directory, $namespace, $callback) {
   foreach (new \DirectoryIterator($directory) as $file) {
      $filename = $file->getBasename();
      if ($file->isFile() && preg_match('/\.php$/', $filename)) {
         $name  = substr($filename, 0, -4);
         $class = $namespace . $name;
         call_user_func($callback, $name, $class);
      }
   }
}
```


It should be fairly obvious what the method does.  It accepts a file-system path, a namespace prefix and a callback.  Then it iterates over all of the files in the directory, and if it's a PHP file it will call the callback with the determined class name.  It's a fairly basic method, and considering how much of a pain testing file-systems can be, it's tempting to just not test the method.  But what would be the point of this post if we did that?

## The Solution

Enter [vfsStream](http://code.google.com/p/bovigo/wiki/vfsStream).  It's actually quite a ingenious little package.  Basically, it utilizes PHP's stream wrapper functionality to create an on-demand virtual file-system.  The documentation is fairly light, but it should be pretty easy to figure out how to use it.  So, to solve our problem, we need to first install the package.  Installing is remarkably easy thanks to pear:

```php
$ pear channel-discover pear.php-tools.net
$ pear install pat/vfsStream
```


Now that we have it installed, we can get down to writing the test.  Now, there are two things that we need to do.  First, we need to setup the virtual file-system.  After it's setup, we can then use it to test.  So, to setup the vfs, we need to decide on a directory structure that we want to use.  Here's the structure we want to create:

```php
CryptLibTest/Core/
CryptLibTest/Core/badlocation.php
CryptLibTest/Core/AbstractFactory/
CryptLibTest/Core/AbstractFactory/test.php
CryptLibTest/Core/AbstractFactory/Some234Foo234Bar98Name.php
CryptLibTest/Core/AbstractFactory/Invalid.csv
```


Now that we have the structure, we need to convert it into a virtual file-system.  The way this works, is that we need to set up the structure item by item.  It's fairly verbose, but it's pretty clear.  So, here's how we do it:

```php
// Create Folders
$root = vfsStream::setup('CryptLibTest');
$core = vfsStream::newDirectory('Core')->at($root);
$af = vfsStream::newDirectory('AbstractFactory')->at($core);

// Create Files
vfsStream::newFile('test.php')->at($af);
vfsStream::newFile('Some234Foo234Bar98Name.php')->at($af);
vfsStream::newFile('Invalid.csv')->at($af);
vfsStream::newFile('badlocation.php')->at($core);
```


It's really that easy.  You just create each file and folder, one at a time, and point them to their parent.  So, now that we're all setup, let's actually create the test:

```php
public function testLoadFiles() {
    $dir = vfsStream::url('CryptLibTest/Core/AbstractFactory');

    $result = array();
    $callback = function($name, $class) use (&$result) {
        $result[$name] = $class;
    };
    $factory = new Factory();
    $factory->loadFiles($dir, 'foo\\', $callback);
    
    $expect = array(
       'test' => 'foo\\test', 
       'Some234Foo234Bar98Name' => 'foo\\Some234Foo234Bar98Name'
    );
    $this->assertEquals($expect, $result);
}
```


That's it!  You can see the actual implemented test [over on GitHub](https://github.com/ircmaxell/PHP-CryptLib/blob/06a6aaa8ed3ccd7b8eeb51928045fd0c993084bc/test/Unit/Core/AbstractFactoryTest.php)  After running the test, it passes!  Now, we've successfully unit tested our method.  And best of all, it's a true unit test since there's no dependency on anything external to the test!  Now there's no excuse for not unit testing any method because it interacts with the file-system...
