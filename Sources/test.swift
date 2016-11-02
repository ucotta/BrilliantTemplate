
var data: [String: Any?] = [
	"lang": "en",
	"title": "web title",
	"keywords": "one, two, three",
	"description": "meta description",
	"links": [
		["link": "http://www.google.com", "title": "title link 1"],
		["link": "http://www.bing.com", "title": "title link 2"],
	],
	"user": [
		"name": "username",
		"id": 10
	],
	"errorLogin": [],
	"vars": "var id=10;",
	"importe": 1020.30,
	"total": 20
]



var tc = BriTestingCositas("example.html", data: data, path: "/Users/ukamata/Fuentes/Ubaldo/MasPruebasHTML/resources")


var a = tc.getHTML()


print(a)

