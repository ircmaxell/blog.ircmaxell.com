<?php

$it = new DirectoryIterator("./source/_posts/");

foreach ($it as $file) {
	if ($file->isDot()) continue;
	$contents = file_get_contents($file->getPathname());
	$parts = explode("\n", $contents);
	$link = '';
	$rawlink = '';
	$date = '';
	foreach ($parts as $part) {
		if (substr($part, 0, 10) === "permalink:") {
			$link = trim(substr($part, 10));
			$rawlink = $part;
		}
		if (substr($part, 0, 5) === "date:") {
			$date = trim(substr($part, 5));
		}
		if ($link !== '' && $date !== '') break;
	}

	if (substr($link, -5) === '.html') {
		// strip off the excess
		$sublink = explode('/', $link);
		$link = end($sublink);
		list($link) = explode('.', $link);
	}

	$newLink = substr($date, 0, 4) . '/' . substr($date, 5, 2) . '/' . $link . '.html';
	if (!preg_match('(^\d{4}/\d{2}/[^.]+.html$)', $newLink)) {
		echo $file->getPathname() . " - $newLink\n";
		die();
	}
	$contents = str_replace($rawlink, "permalink: $newLink", $contents);
	
	file_put_contents($file->getPathname(), $contents);
}
