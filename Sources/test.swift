import Foundation
import Kanna


public func test(template:String, path:String) -> String {
	let data: [String: Any?] = [
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

	let tc = BrilliantTemplate(template, data: data, path: path)
	return tc.getHTML()
}

