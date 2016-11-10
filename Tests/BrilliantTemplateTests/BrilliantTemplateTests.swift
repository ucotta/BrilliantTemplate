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
    var _pathTemplates: String? = nil
    
    override func setUp() {
        super.setUp()
        
        var parts = #file.components(separatedBy: "/")
        parts.removeLast()
        parts.append("files")
        _pathTemplates = parts.map { String($0) }.joined(separator: "/")
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func getPathTemplates() -> String {
        return _pathTemplates ?? ""
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
    
    func test_include() {
        let HTML_RESULT = "<!DOCTYPE html>\n<html lang=\"en\">\n<body>\n<div class=\"menu\"><span>the file was included</span>\n\n</div>\n</body>\n</html>\n"

        let template = BrilliantTemplate(file: "test_include.html", data: [:], path: getPathTemplates())
        
        XCTAssertEqual(template.getHTML(), HTML_RESULT)

    }

    func test_include_error() {
        let HTML_RESULT = "<!DOCTYPE html>\n<html lang=\"en\">\n    <body>\n        <div class=\"menu\">error opening file this_file_doesnt_exist.html\n        </div>\n    </body>\n</html>\n"

        
        let template = BrilliantTemplate(file: "test_include_error.html", data: [:], path: getPathTemplates())
        
        XCTAssertEqual(template.getHTML(), HTML_RESULT)
        
    }
    
    
    
    func test_include_travesal_attack() {
        let HTML_RESULT =  "<!DOCTYPE html>\n<html lang=\"en\">\n    <body>\n        <div class=\"menu\">included file not found\n        </div>\n    </body>\n</html>\n"
        let template = BrilliantTemplate(file: "test_include_travesal_attack.html", data: [:], path: getPathTemplates())
        
        
        XCTAssertEqual(template.getHTML(), HTML_RESULT)
        
    }
    
    func test_brilliant_tag() {
        let HTML_RESULT = "<!DOCTYPE html>\n<html lang=\"en\">\n    <body>\n        \n            Single tag to be replaced\n        \n        Hello!\n    </body>\n</html>\n"
        
        let template = BrilliantTemplate(file: "test_brilliant_tag.html", data: ["sayHello":"Hello!"], path: getPathTemplates())
        
        XCTAssertEqual(template.getHTML(), HTML_RESULT)
        
        
    }
    
    func test_attribute_plus() {
        let HTML_RESULT = "<!DOCTYPE html>\n<html lang=\"en\">\n    <body>\n        <div class=\"previouClass newClass otherClass\"></div>\n    </body>\n</html>\n"

        let template = BrilliantTemplate(file: "test_attribute_plus.html", data: ["extra":"newClass otherClass"], path: getPathTemplates())
        
        print(template.getHTML())
        XCTAssertEqual(template.getHTML(), HTML_RESULT)
        
    }
    
    func test_attribute_comparable() {
        let HTML_RESULT = "<!DOCTYPE html>\n<html lang=\"en\">\n    <body><!-- test with aid -->\n        \n        <h1 data-id=\"10\">= 10</h1>\n        <h1 data-id=\"10\">&gt; 11</h1>\n        <h1 data-id=\"10\">&lt; 09</h1>\n        <!-- with value sustitution -->\n        \n        <h1 class=\"red\">= #ff0000</h1>\n        <!-- test with tid -->\n        \n        <h2>10</h2>\n        <h2>10</h2>\n        <h2>10</h2>\n    </body>\n    \n    \n</html>\n"

        let template = BrilliantTemplate(file: "test_attribute_comparable.html", data: ["value":"10", "color": "#ff0000"], path: getPathTemplates())
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
