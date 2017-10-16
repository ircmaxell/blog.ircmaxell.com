---
layout: post
title: PHP Install Statistics
permalink: php-install-statistics
date: 2014-12-30
comments: true
categories:
- PHP
tags:
- PHP
- PHP-Versions
- Rant
---
After [yesterday's post](http://blog.ircmaxell.com/2014/12/being-responsible-developer.html), I decided to do some math to see how many PHP installs had at least 1 known security vulnerability. So I went to grab statistics from [W3Techs](http://w3techs.com/technologies/details/pl-php/5/all), and correlated that with known Linux Distribution supported numbers. I then whipped up a spreadsheet and got some interesting numbers out of it. So interesting, that I need to share...
<!--more-->

<style type="text/css">table.data {border: 1px solid black;border-spacing: 0px;margin-bottom: 1em;}table.data td, table.data th {border: 1px solid black;padding: 4px;font-weight: bold;color: #000000;}table.data .secure {background-color: #98FB98;}table.data .insecure {background-color: #FFA07A;}</style>

## UPDATE:

Wow, this post got traction pretty fast. I started applying the same analysis to other platforms (where w3techs had data). Rather than doing a new post, I'll just like the raw data [in a Google Sheet](https://docs.google.com/spreadsheets/d/1nIknWM8no-3oyd85wbnFbUFs40k3rvrQFOk2l55YB1U/edit?usp=sharing) (If you want to edit, just duplicate the sheet. Everything is formula driven so update away).

So, what's the breakdown?

<table class="data"><thead><tr><th>Platform</th><th>% Installs That Are Secure</th></tr></thead><tbody><tr><td>Perl</td><td>82.27%</td></tr><tr><td>Python</td><td>77.59%</td></tr><tr><td>Nginx</td><td>64.48%</td></tr><tr><td>Apache</td><td>61.96%</td></tr><tr><td>WordPress</td><td>60.45%</td></tr><tr><td>Drupal</td><td>45.23%</td></tr><tr><td>PHP</td><td>25.94%</td></tr></tbody></table>

Note that the PHP version numbers are slightly higher than in the rest of this post. This is due to adding Fedora, as well as 5.4.34 to Debian 7 support list (over-counting Debian 7 again).

## What Is A Secure And Supported Version?

Well, for purposes of this analysis, we'll call versions that have no known vulnerabilities (more recent than the most recent security release) secure.

That gives us the following secure versions:

 * *5.6.4*
 * *5.5.20*
 * *5.4.36*
We'll also count those that are maintained by Linux distributions in supported releases. For example, Debian 5.0 is no longer maintained, so the version of PHP it ships with is considered no longer supported or secure (5.2.6).

So that brings us with the following table:

<table class="data"><thead><tr><th>Distribution</th><th>Distro Version</th><th>PHP Version</th></tr></thead><tbody><tr><td>Debian</td><td>7 (Wheezy)</td><td>5.4.4</td></tr><tr><td>Debian</td><td>6 (Squeeze)</td><td>5.3.3</td></tr><tr><td>Ubuntu</td><td>14.10 (Utopic)</td><td>5.5.12</td></tr><tr><td>Ubuntu</td><td>14.04 (Trusty)</td><td>5.5.9</td></tr><tr><td>Ubuntu</td><td>12.04 (Precise)</td><td>5.3.10</td></tr><tr><td>Ubuntu</td><td>10.04 (Lucid)</td><td>5.3.2</td></tr><tr><td>CentOS</td><td>7.0</td><td>5.4.16</td></tr><tr><td>CentOS</td><td>6.6</td><td>5.3.3</td></tr><tr><td>CentOS</td><td>5.11</td><td>5.1.6</td></tr></tbody></table>

Now, for our purposes, we'll assume that *any* *5.4.4* install will be secure, since we can't distinguish Debian versions (supported) from non-Debian installs (unsupported).

This means that our "secure" numbers will be over-inflated. But let's plug it in and see what happens.

So that means our total list of secure PHP versions (with no known vulnerabilities) is:

 * *5.6.4*
 * *5.5.20*
 * *5.5.12*
 * *5.5.9*
 * *5.4.36*
 * *5.4.16*
 * *5.4.4*
 * *5.3.10*
 * *5.3.3*
 * *5.3.2*
 * *5.1.6*
## PHP 5.6

So, looking at the W3Techs numbers, we can see that 5.6 has a total adoption rate of *0.4%*. This means that *0.4%* of all PHP installs use *5.6.x*. So let's look at the breakdown:

<table class="data"><thead><tr><th>Version</th><th>% Of Minor</th><th>% Of Total</th><th>Secure?</th></tr></thead><tbody><tr class="secure"><td>5.6.4</td><td>6.7</td><td>0.0268</td><td>Yes</td></tr><tr class="insecure"><td>5.6.3</td><td>29.1</td><td>0.1164</td><td>No</td></tr><tr class="insecure"><td>5.6.2</td><td>31.8</td><td>0.1272</td><td>No</td></tr><tr class="insecure"><td>5.6.1</td><td>5.2</td><td>0.0208</td><td>No</td></tr><tr class="insecure"><td>5.6.0</td><td>27.2</td><td>0.1088</td><td>No</td></tr></tbody></table>

So, *6.7%* of all PHP 5.6 installs are running 5.6.4, and are therefore secure (since it's the only secure and maintained PHP 5.6 version).

So, correlating that to our list of secure PHP versions, we come up with the following breakdown for 5.6:

<table class="data"><thead><tr><th>Type</th><th>% Of Minor</th><th>% Of Total</th></tr></thead><tbody><tr class="secure"><td>Secure 5.6</td><td>6.7</td><td>0.0268</td></tr><tr class="insecure"><td>Insecure 5.6</td><td>93.3</td><td>0.3732</td></tr></tbody></table>

So only *6.7%* of PHP 5.6 installs are running secure versions. And only *0.0268%* of all PHP installs are running a secure version of PHP 5.6...

## PHP 5.5

PHP 5.5 is a bit more interesting, with a total adoption of *6%*. And there are a lot more releases to look at:

<table class="data"><thead><tr><th>Version</th><th>% Of Minor</th><th>% Of Total</th><th>Secure?</th></tr></thead><tbody><tr class="secure"><td>5.5.20</td><td>3.6</td><td>0.216</td><td>Yes</td></tr><tr class="insecure"><td>5.5.19</td><td>14.2</td><td>0.852</td><td>No</td></tr><tr class="insecure"><td>5.5.18</td><td>14.2</td><td>0.852</td><td>No</td></tr><tr class="insecure"><td>5.5.17</td><td>5.6</td><td>0.336</td><td>No</td></tr><tr class="insecure"><td>5.5.16</td><td>4.5</td><td>0.27</td><td>No</td></tr><tr class="insecure"><td>5.5.15</td><td>3.3</td><td>0.198</td><td>No</td></tr><tr class="insecure"><td>5.5.14</td><td>2.9</td><td>0.174</td><td>No</td></tr><tr class="insecure"><td>5.5.13</td><td>1.8</td><td>0.108</td><td>No</td></tr><tr class="secure"><td>5.5.12</td><td>2.7</td><td>0.162</td><td>Yes</td></tr><tr class="insecure"><td>5.5.11</td><td>2.9</td><td>0.174</td><td>No</td></tr><tr class="insecure"><td>5.5.10</td><td>1.6</td><td>0.096</td><td>No</td></tr><tr class="secure"><td>5.5.9</td><td>30.3</td><td>1.818</td><td>Yes</td></tr><tr class="insecure"><td>5.5.8</td><td>3.2</td><td>0.192</td><td>No</td></tr><tr class="insecure"><td>5.5.7</td><td>1.4</td><td>0.084</td><td>No</td></tr><tr class="insecure"><td>5.5.6</td><td>1.1</td><td>0.066</td><td>No</td></tr><tr class="insecure"><td>5.5.5</td><td>0.6</td><td>0.036</td><td>No</td></tr><tr class="insecure"><td>5.5.4</td><td>0.5</td><td>0.03</td><td>No</td></tr><tr class="insecure"><td>5.5.3</td><td>4.3</td><td>0.258</td><td>No</td></tr><tr class="insecure"><td>5.5.2</td><td>0.1</td><td>0.006</td><td>No</td></tr><tr class="insecure"><td>5.5.1</td><td>0.6</td><td>0.036</td><td>No</td></tr><tr class="insecure"><td>5.5.0</td><td>0.6</td><td>0.036</td><td>No</td></tr></tbody></table>

Things look a bit better here.

<table class="data"><thead><tr><th>Type</th><th>% Of Minor</th><th>% Of Total</th></tr></thead><tbody><tr class="secure"><td>Secure 5.5</td><td>36.6</td><td>2.196</td></tr><tr class="insecure"><td>Insecure 5.5</td><td>63.4</td><td>3.804</td></tr></tbody></table>

Our total increased here. *33.6%* of all 5.5 installs are running secure versions. This is MUCH better than 5.6, but still horrifically low...

## PHP 5.4

With PHP 5.4 we again see a huge jump in overall adoption at *26.4%* of all PHP installs. So let's break it down by version:

<table class="data"><thead><tr><th>Version</th><th>% Of Minor</th><th>% Of Total</th><th>Secure?</th></tr></thead><tbody><tr class="secure"><td>5.4.36</td><td>0.9</td><td>0.2376</td><td>Yes</td></tr><tr class="insecure"><td>5.4.35</td><td>20.8</td><td>5.4912</td><td>No</td></tr><tr class="insecure"><td>5.4.34</td><td>17.4</td><td>4.5936</td><td>No</td></tr><tr class="insecure"><td>5.4.33</td><td>6.7</td><td>1.7688</td><td>No</td></tr><tr class="insecure"><td>5.4.32</td><td>5.5</td><td>1.452</td><td>No</td></tr><tr class="insecure"><td>5.4.31</td><td>4.4</td><td>1.1616</td><td>No</td></tr><tr class="insecure"><td>5.4.30</td><td>4.6</td><td>1.2144</td><td>No</td></tr><tr class="insecure"><td>5.4.29</td><td>3.5</td><td>0.924</td><td>No</td></tr><tr class="insecure"><td>5.4.28</td><td>3.1</td><td>0.8184</td><td>No</td></tr><tr class="insecure"><td>5.4.27</td><td>3.6</td><td>0.9504</td><td>No</td></tr><tr class="insecure"><td>5.4.26</td><td>2.9</td><td>0.7656</td><td>No</td></tr><tr class="insecure"><td>5.4.25</td><td>1.9</td><td>0.5016</td><td>No</td></tr><tr class="insecure"><td>5.4.24</td><td>2.7</td><td>0.7128</td><td>No</td></tr><tr class="insecure"><td>5.4.23</td><td>1.9</td><td>0.5016</td><td>No</td></tr><tr class="insecure"><td>5.4.22</td><td>1.3</td><td>0.3432</td><td>No</td></tr><tr class="insecure"><td>5.4.21</td><td>1.1</td><td>0.2904</td><td>No</td></tr><tr class="insecure"><td>5.4.20</td><td>1.2</td><td>0.3168</td><td>No</td></tr><tr class="insecure"><td>5.4.19</td><td>1</td><td>0.264</td><td>No</td></tr><tr class="insecure"><td>5.4.18</td><td>0.3</td><td>0.0792</td><td>No</td></tr><tr class="insecure"><td>5.4.17</td><td>1.2</td><td>0.3168</td><td>No</td></tr><tr class="secure"><td>5.4.16</td><td>1.6</td><td>0.4224</td><td>Yes</td></tr><tr class="insecure"><td>5.4.15</td><td>0.3</td><td>0.0792</td><td>No</td></tr><tr class="insecure"><td>5.4.14</td><td>0.6</td><td>0.1584</td><td>No</td></tr><tr class="insecure"><td>5.4.13</td><td>0.3</td><td>0.0792</td><td>No</td></tr><tr class="insecure"><td>5.4.12</td><td>0.4</td><td>0.1056</td><td>No</td></tr><tr class="insecure"><td>5.4.11</td><td>0.4</td><td>0.1056</td><td>No</td></tr><tr class="insecure"><td>5.4.10</td><td>0.2</td><td>0.0528</td><td>No</td></tr><tr class="insecure"><td>5.4.9</td><td>0.7</td><td>0.1848</td><td>No</td></tr><tr class="insecure"><td>5.4.8</td><td>0.2</td><td>0.0528</td><td>No</td></tr><tr class="insecure"><td>5.4.7</td><td>0.4</td><td>0.1056</td><td>No</td></tr><tr class="insecure"><td>5.4.6</td><td>0.7</td><td>0.1848</td><td>No</td></tr><tr class="insecure"><td>5.4.5</td><td>0.1</td><td>0.0264</td><td>No</td></tr><tr class="secure"><td>5.4.4</td><td>8.1</td><td>2.1384</td><td>Yes</td></tr><tr class="insecure"><td>5.4.3</td><td>0.1</td><td>0.0264</td><td>No</td></tr><tr class="insecure"><td>5.4.2</td><td>0</td><td>0</td><td>No</td></tr><tr class="insecure"><td>5.4.1</td><td>0</td><td>0</td><td>No</td></tr><tr class="insecure"><td>5.4.0</td><td>0.1</td><td>0.0264</td><td>No</td></tr></tbody></table>

Things look far more grim again here:

<table class="data"><thead><tr><th>Type</th><th>% Of Minor</th><th>% Of Total</th></tr></thead><tbody><tr class="secure"><td>Secure 5.4</td><td>10.6</td><td>2.7984</td></tr><tr class="insecure"><td>Insecure 5.4</td><td>89.6</td><td>23.6544</td></tr></tbody></table>

Note here that the total is 100.2%. This is due to precision errors in the figures reported by W3Techs. But it shouldn't affect our overall figures.

So *89.6%* of 5.4 installs are vulnerable. Yay.

## PHP 5.3

Now we get to the big one. Accounting for a whopping *45.9%* of all PHP installs, 5.3 hits big. So let's look at the numbers:

<table class="data"><thead><tr><th>Version</th><th>% Of Minor</th><th>% Of Total</th><th>Secure?</th></tr></thead><tbody><tr class="insecure"><td>5.3.29</td><td>23.7</td><td>10.8783</td><td>No</td></tr><tr class="insecure"><td>5.3.28</td><td>15.5</td><td>7.1145</td><td>No</td></tr><tr class="insecure"><td>5.3.27</td><td>7.2</td><td>3.3048</td><td>No</td></tr><tr class="insecure"><td>5.3.26</td><td>2.4</td><td>1.1016</td><td>No</td></tr><tr class="insecure"><td>5.3.25</td><td>0.9</td><td>0.4131</td><td>No</td></tr><tr class="insecure"><td>5.3.24</td><td>1</td><td>0.459</td><td>No</td></tr><tr class="insecure"><td>5.3.23</td><td>1.5</td><td>0.6885</td><td>No</td></tr><tr class="insecure"><td>5.3.22</td><td>0.6</td><td>0.2754</td><td>No</td></tr><tr class="insecure"><td>5.3.21</td><td>0.8</td><td>0.3672</td><td>No</td></tr><tr class="insecure"><td>5.3.20</td><td>0.6</td><td>0.2754</td><td>No</td></tr><tr class="insecure"><td>5.3.19</td><td>0.8</td><td>0.3672</td><td>No</td></tr><tr class="insecure"><td>5.3.18</td><td>0.9</td><td>0.4131</td><td>No</td></tr><tr class="insecure"><td>5.3.17</td><td>1</td><td>0.459</td><td>No</td></tr><tr class="insecure"><td>5.3.16</td><td>0.5</td><td>0.2295</td><td>No</td></tr><tr class="insecure"><td>5.3.15</td><td>0.9</td><td>0.4131</td><td>No</td></tr><tr class="insecure"><td>5.3.14</td><td>0.6</td><td>0.2754</td><td>No</td></tr><tr class="insecure"><td>5.3.13</td><td>3.2</td><td>1.4688</td><td>No</td></tr><tr class="insecure"><td>5.3.12</td><td>0</td><td>0</td><td>No</td></tr><tr class="insecure"><td>5.3.11</td><td>0</td><td>0</td><td>No</td></tr><tr class="secure"><td>5.3.10</td><td>9</td><td>4.131</td><td>Yes</td></tr><tr class="insecure"><td>5.3.9</td><td>0.3</td><td>0.1377</td><td>No</td></tr><tr class="insecure"><td>5.3.8</td><td>1.5</td><td>0.6885</td><td>No</td></tr><tr class="insecure"><td>5.3.7</td><td>0</td><td>0</td><td>No</td></tr><tr class="insecure"><td>5.3.6</td><td>1.2</td><td>0.5508</td><td>No</td></tr><tr class="insecure"><td>5.3.5</td><td>0.7</td><td>0.3213</td><td>No</td></tr><tr class="insecure"><td>5.3.4</td><td>0.1</td><td>0.0459</td><td>No</td></tr><tr class="secure"><td>5.3.3</td><td>22.6</td><td>10.3734</td><td>Yes</td></tr><tr class="secure"><td>5.3.2</td><td>2.3</td><td>1.0557</td><td>Yes</td></tr><tr class="insecure"><td>5.3.1</td><td>0.1</td><td>0.0459</td><td>No</td></tr><tr class="insecure"><td>5.3.0</td><td>0.1</td><td>0.0459</td><td>No</td></tr></tbody></table>

The case here is almost identical to 5.5:

<table class="data"><thead><tr><th>Type</th><th>% Of Minor</th><th>% Of Total</th></tr></thead><tbody><tr class="secure"><td>Secure 5.3</td><td>33.9</td><td>15.5601</td></tr><tr class="insecure"><td>Insecure 5.3</td><td>66.1</td><td>30.3399</td></tr></tbody></table>

Not much else to comment on here.

## PHP 5.2

Note that PHP 5.2 is not maintained by any current release of any of the 3 main distributions. Therefore, we can safely skip the version-by-version breakdown and jump right to the conclusion:

<table class="data"><thead><tr><th>Type</th><th>% Of Minor</th><th>% Of Total</th></tr></thead><tbody><tr class="secure"><td>Secure 5.2</td><td>0</td><td>0</td></tr><tr class="insecure"><td>Insecure 5.2</td><td>100</td><td>20.1</td></tr></tbody></table>

## PHP 5.1

PHP 5.1 accounts for *1.2%* of all PHP installs. So let's break it down:

<table class="data"><thead><tr><th>Version</th><th>% Of Minor</th><th>% Of Total</th><th>Secure?</th></tr></thead><tbody><tr class="secure"><td>5.1.6</td><td>94.8</td><td>1.1376</td><td>Yes</td></tr><tr class="insecure"><td>5.1.5</td><td>0.2</td><td>0.0024</td><td>No</td></tr><tr class="insecure"><td>5.1.4</td><td>1.4</td><td>0.0168</td><td>No</td></tr><tr class="insecure"><td>5.1.3</td><td>0</td><td>0</td><td>No</td></tr><tr class="insecure"><td>5.1.2</td><td>3.1</td><td>0.0372</td><td>No</td></tr><tr class="insecure"><td>5.1.1</td><td>0.4</td><td>0.0048</td><td>No</td></tr><tr class="insecure"><td>5.1.0</td><td>0</td><td>0</td><td>No</td></tr></tbody></table>

And totaling:

<table class="data"><thead><tr><th>Type</th><th>% Of Minor</th><th>% Of Total</th></tr></thead><tbody><tr class="secure"><td>Secure 5.1</td><td>94.8</td><td>1.1376</td></tr><tr class="insecure"><td>Insecure 5.1</td><td>5.2</td><td>0.0624</td></tr></tbody></table>

So the situation here is actually quite good, with *94.8%* of all 5.1 installs being secure.

But it's 5.1...

## Totalling It Up:

Let's sum up all of the total columns:

<table class="data"><thead><tr><th>Type</th><th>% Of Total</th></tr></thead><tbody><tr class="secure"><td>Secure</td><td>21.71</td></tr><tr class="insecure"><td>Insecure</td><td>78.27</td></tr></tbody></table>

These numbers are optimistic. That's because we're counting all version numbers that are maintained by a distribution as secure, even though not all installs of that version number are going to be from a distribution. Just because 5.3.3 is maintained by CentOS and Debian doesn't mean that every install of 5.3.3 is maintained. There will be a small percentage of installs that are from-source.

Therefore, the real "secure" number is going to be less than quoted.

Additionally, it also assumes that the distribution installs are always updated. So just because you're running Debian's 5.3.3 doesn't mean you've got all of the latest patches and updates for it.

So *21.71%* is an upper bound on the number of secure installs.

## This Is Pathetic

This is absolutely and unequivocally pathetic. This means that **over** *78%* of all PHP installs have at least one known security vulnerability. Pathetic.

Check your installed versions. Push for people to update. Don't accept "if it works, don't fix it."... You have the power to change this, so change it.

Security is everyone's problem. What matters is how you deal with it.

