# BrilliantTemplate

BrilliantTemplate is template processor for Swift to process HTML5.

Was created with designers in mid, BrilliantTemplate avoid dirty code by using tags and attibutes for variables and control structures.

Merge the data with the template is easy, just prepare a dictionary with all values and then, use BrilliantTemplate with your html5 template.

> This readme wants to show what BrilliantTemplate can do, is not a reference manual, you can get more information and usage guide in the wiki of this project in github: https://github.com/ucotta/BrilliantTemplate

Here is a dictionary example:

``` swift
let data: [String: Any?] = [
	"lang": "en",
	"title": "web title",
	"keywords": "one, two, three",
	"description": "meta description",
	"links": [
		["link": "https://github.com/ucotta", "title": "ucotta's repositories"],
		["link": "https://github.com/ucotta/BrilliantTemplate", "title": "this repository"],
	],
	"user": [
		"name": "username",
		"id": 10
	],
	"javascriptVars": "var id=10;",
	"amount": 1020.30,
	"total": 20
]
```

The template for example.html
``` html
<!DOCTYPE HTML>
<html aid="lang:lang">
<head>
	<title tid="title:upper:cap"></title>
	<meta name="keywords" aid="content:keywords:lower">
	<meta name="description" aid="content:description">

	<script jsid="javascriptVars">
		// this javascript will be replaced by the javascriptVars data
		// The designer will use this ids in his/her editor.
		var ids = [1,2,3,4];
	</script>
</head>
<body>
	<include file="menu.html"></include>

	<h1 tid="title:cap" aid="data-val:importe:currency/en_US">Title example</h1>

	<article>
		<div tid="amount:currency/en_US">show currency in US</div>
		<div tid="amount:decimal/es_ES/4">show decimal number with thousang separator in spaniard format</div>
		<div tid="total:decimal/es_ES/4">shame case with a Int number.</div>
		<div tid="total">Default not formatted</div>
	</article>

	<div tid="links">
		<p><a aid="href:link" tid="title">some document...</a></p>
	</div>
</body>
</html>
```

And this is menu.html
``` html
	<div class="coco">
		<!-- comment in menu -->
		<div class="menu">
			this is the menu!!
		</div>
	</div>
```


This is the call to library:

``` swift
import BrilliantTemplate

var tc = BrilliantTemplate("example.html", data: data, path: "/var/www/templates")
print(tc.getHTML())

```

And this will be the result for this code:

``` html
<!DOCTYPE HTML>
<html lang="">
<head>
	<title>web title</title>
	<meta name="keywords" content="one, two, three">
	<meta name="description" content="meta description">

	<script>
		var id=10;
	</script>
</head>
<body>
	<div class="coco">
		<!-- comment in menu -->
		<div class="menu">
			this is the menu!!
		</div>
	</div>

	<h1 data-val="">Web Title</h1>

	<article>
		<div>$1,020.30</div>
		<div>1.020,3000</div>
		<div>20,0000</div>
		<div>20</div>
	</article>
	<div>
		<p><a href="https://github.com/ucotta">ucotta&apos;s repositories</a></p>
	</div>
	<div>
		<p><a href="https://github.com/ucotta/BrilliantTemplate">this repository</a></p>
	</div>
</body>
</html>

```

The final HTML was retabuled for easy reading.

# Installation

Create this files in a new directory:

**Package.swift**
```swift
import PackageDescription

let package = Package(
	name: "MyTest",
	targets: [],
	dependencies: [
		.Package(url: "https://github.com/ucotta/BrilliantTemplate.git", majorVersion: 0)
	],
	exclude: ["BrilliantTemplateTests"]
)
```

**Sources/MyTest/main.swift**
```swift
import BrilliantTemplate

// This data will be merged
var data: [String: Any] = [
	"title": "This is the title",
	"welcome": "this is your first example!!",
	"more": "and you can do a lot of stuff",
	"buttonColor": "btn-blue btn-sm btn"
]

// Load a raw HTML 
let URLINDEX = "https://raw.githubusercontent.com/ucotta/BrilliantHTML5Parser/master/examples/index.html"

if let url = URL(string: URLINDEX) {
	let html = try String(contentsOf: url)
	let bt = BrilliantTemplate(html: html, data: data, path: "/tmp")
	print(tc.getHTML())
} else {
	print("error in URL \(URLINDEX)")
}
```

**Create the project, open it**

```bash
swift package generate-xcodeproj && open MyTest.xcodeproj
```

Now select the correct scheme and run!.


# More information in the Wiki of this project
https://github.com/ucotta/BrilliantTemplate/wiki

```
