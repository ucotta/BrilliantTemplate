//
//  BrilliantTemplateTests.swift
//  BrilliantTemplateTests
//
//  Created by Ubaldo Cotta on 7/11/16.
//
//

import XCTest
@testable import BrilliantTemplate

class BrilliantTemplateTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func test_htmlAttributeLang() {
		let HTML = "<!DOCTYPE html><html aid=\"lang:lang\"></html>"
		let HTML_RESULT = "<!DOCTYPE html><html lang=\"en\"></html>"

		let data: [String:Any?]? = ["lang": "en"]
		let template = BrilliantTemplate(html: HTML, data: data)

		XCTAssertEqual(template.getHTML(), HTML_RESULT)
	}

	func test_tid_basic() {
		let HTML = "<!DOCTYPE html><html lang=\"en\"><head><title tid=\"title\"></title></head></html>"
		let HTML_RESULT = "<!DOCTYPE html><html lang=\"en\"><head><title>this is the title</title></head></html>"

		let data: [String:Any?]? = ["title": "this is the title"]
		let template = BrilliantTemplate(html: HTML, data: data)

		XCTAssertEqual(template.getHTML(), HTML_RESULT)
	}

	func test_tid_repeater() {
		let HTML = "<!DOCTYPE html><html lang=\"en\"><body><h1 tid=\"h1\"></h1><p tid=repeater><a aid=\"href:link\" tid=title></a></p></body></html>"
		let HTML_RESULT = "<!DOCTYPE html><html lang=\"en\"><body><h1>Example with repeaters</h1><p><a href=\"http://www.example.com/test1.html\">Example test 1</a></p><p><a href=\"http://www.example.com/test2.html\">Example test 2</a></p></body></html>"

		let data: [String:Any?]? = [
			"h1": "Example with repeaters",
			"repeater": [
				["link": "http://www.example.com/test1.html", "title": "Example test 1"],
				["link": "http://www.example.com/test2.html", "title": "Example test 2"]
			]
		]
		let template = BrilliantTemplate(html: HTML, data: data)
		XCTAssertEqual(template.getHTML(), HTML_RESULT)
	}


	/*
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

	*/
    
}
