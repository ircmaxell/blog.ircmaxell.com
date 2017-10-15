<?php

if ($argc < 2) {
  die("Expecting a URL argument");
}

$url = $argv[1];

$parts = parse_url($url);

$html = file_get_contents($url);

libxml_use_internal_errors(true);

$dom = new DomDocument;

$dom->loadHtml($html);
$xpath = new DomXpath($dom);

$result = '---
layout: post
title: ' . extractTitle($dom, $xpath) . '
permalink: ' . extractPermalink($parts) . '
date: ' . extractDate($dom, $xpath) . '
comments: true
categories:
tags:
' . extractTags($dom, $xpath) . '
---
' . extractBody($dom, $xpath);


file_put_contents("source/_posts/" . extractPermalink($parts) . ".md", $result);




function extractTitle(DomDocument $doc, DomXpath $xpath): string
{
  $query = '//h3[@class="post-title entry-title"]';
  $nodes = $xpath->query($query);
  foreach ($nodes as $node) {
    return trim($node->nodeValue);
  }
}

function extractPermalink(array $parts): string
{
  return basename($parts['path'], '.html');
}

function extractDate(DomDocument $doc, DomXpath $xpath): string
{
  $query = '//h2[@class="date-header"]';
  $nodes = $xpath->query($query);
  foreach ($nodes as $node) {
    $date = DateTime::createFromFormat('l, F j, Y', $node->nodeValue);
    if ($date) {
      return $date->format('Y-m-d');
    }
    var_dump($node);
  }
}

function extractTags(DomDocument $doc, DomXpath $xpath): string
{
  $query = '//span[@class="post-labels"]/a';
  $nodes = $xpath->query($query);
  $result = [];
  foreach ($nodes as $node) {
    $result[] = $node->nodeValue;
  }
  if (empty($result)) {
    die("No tags found");
  }
  return '- ' . implode("\n- ", $result);
}

function extractBody(DomDocument $doc, DomXpath $xpath): string
{
  $query = '//div[@class="post-body entry-content"]';
  $nodes = $xpath->query($query);
  foreach ($nodes as $node) {
    return convertToMarkdown($node);
  }
  return '';
}

function convertToMarkdown(DomNode $node, string $indent = '', bool $inline = false): string
{
  $result = '';
  foreach ($node->childNodes as $child) {
    switch ($child->nodeName) {
      case '#text':
        $value = $child->nodeValue;
        if (($value === "\n" || $value === "\n\n") && !$inline) {
          continue;
        }
        $result .= str_replace("*", "\\*", $child->nodeValue);
        break;
      case 'h1':
      case 'h2':
        $result .= '## ' . trim(convertToMarkdown($child, '', true)) . "\n\n";
        break;
      case 'h3':
        $result .= '### ' . trim(convertToMarkdown($child, '', true)) . "\n\n";
        break;
      case 'h4':
        $result .= '#### ' . trim(convertToMarkdown($child, '', true)) . "\n\n";
        break;
      case 'div':
      case 'p':
        $result .= convertToMarkdown($child);
        break;
      case 'a':
        if (!$child->hasAttribute('href')) {
          if ($child->hasAttribute('name') && $child->getAttribute('name') === 'more') {
            $result .= "<!--more-->\n";
          }
          break;
        }
        
        $result .= '[' . convertToMarkdown($child, '', true) . '](' . $child->getAttribute('href') . ')';
        break;
      case 'br':
        $result .= "\n";
        break;
      case 'i':
      case 'code':
        $result .= '`' . convertToMarkdown($child, '', true) . '`';
        break;
      case 'u':
        $result .= '_' . convertToMarkdown($child, '', true) . '_';
        break;
      case 'em':
        $result .= '*' . convertToMarkdown($child, '', true) . '*';
        break;
      case 'b':
      case 'strong':
        $result .= '**' . convertToMarkdown($child, '', true) . '**';
        break;
      case 'strike':
        $result .= '~' . convertToMarkdown($child, '', true) . '~';
        break;
      case 'pre':
        $result .= "```php\n" . $child->nodeValue . "\n```\n";
        break;
      case 'blockquote':
        $result .= '> ' . trim(convertToMarkdown($child, '    ', true)) . "\n\n";
        break;
      case 'ul':
        foreach ($child->childNodes as $subChild) {
          if ($subChild->nodeName === '#text') continue;
          $result .= " * " . trim(convertToMarkdown($subChild, '    ')) . "\n";
        }
        break;
      case 'ol':
        $i = 1;
        foreach ($child->childNodes as $subChild) {
          if ($subChild->nodeName === '#text') continue;
          $result .= " " . $i++ . ". " . trim(convertToMarkdown($subChild,'    ')) . "\n";
        }
        break;
      case 'img':
        $result .= '![' . $child->getAttribute('alt') . '](' . $child->getAttribute('src') . ')';
        break;
      case 'script':
        $result .= '<script type="' . $child->getAttribute('type') . '" src="' . $child->getAttribute('src') . '"></script>';
        break;
      case 'style':
        $result .= '<style type="text/css">' . $child->textContent . '</style>';
        break;
      case 'table':
      case 'thead':
      case 'tbody':
      case 'tr':
      case 'td':
      case 'th':
      case 'span':
      case 'iframe':
      case 'dl':
      case 'dt':
      case 'dd':
        $result .= '<' . $child->nodeName;
        foreach ($child->attributes as $attr) {
          $result .= ' ' . $attr->name . '="' . $attr->value . '"';
        }
        $result .= '>' . convertToMarkdown($child) . '</' . $child->nodeName . '>';
        break;
      default:
      var_dump($child);
        die ("Tag type {$child->nodeName} not implemented yet\n");
    }
  }
  return reindent($result, $indent);
}

function reindent(string $source, string $indent): string
{
  return $indent . implode("\n$indent", explode("\n", $source));
}