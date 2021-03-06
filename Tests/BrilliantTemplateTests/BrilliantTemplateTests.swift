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
	
	
	func test_tid_basic() {
		let HTML = "<!DOCTYPE html><html lang=\"en\"><head><title tid=\"title\"></title></head></html>"
		let HTML_RESULT = "<!DOCTYPE html><html lang=\"en\"><head><title>this is the title</title></head></html>"

		let data: [String:Any?]? = ["title": "this is the title"]
		let template = BrilliantTemplate(html: HTML)

		XCTAssertEqual(template.getHTML(data: data), HTML_RESULT)
	}

	func test_tid_repeater() {
		let HTML = "<!DOCTYPE html><html lang=\"en\"><body><h1 tid=\"h1\"></h1><p tid=repeater><a bid-href=\"link\" tid=title></a></p></body></html>"
		let HTML_RESULT = "<!DOCTYPE html><html lang=\"en\"><body><h1>Example with repeaters</h1><p><a href=\"http://www.example.com/test1.html\">Example test 1</a></p><p><a href=\"http://www.example.com/test2.html\">Example test 2</a></p></body></html>"

		let data: [String:Any?]? = [
			"h1": "Example with repeaters",
			"repeater": [
				["link": "http://www.example.com/test1.html", "title": "Example test 1"],
				["link": "http://www.example.com/test2.html", "title": "Example test 2"]
			]
		]
		let template = BrilliantTemplate(html: HTML)
		XCTAssertEqual(template.getHTML(data: data), HTML_RESULT)
	}
    
    func test_include() {
        let HTML_RESULT = "<!DOCTYPE html>\n<html lang=\"en\">\n<body>\n<div class=\"menu\"><span>the file was included</span>\n\n</div>\n</body>\n</html>\n"

        let template = BrilliantTemplate(file: "test_include.html", path: getPathTemplates())
        
		XCTAssertEqual(template.getHTML(), HTML_RESULT)

    }

    func test_include_error() {
        let HTML_RESULT = "<!DOCTYPE html>\n<html lang=\"en\">\n    <body>\n        <div class=\"menu\">cannot open file this_file_doesnt_exist.html\n        </div>\n    </body>\n</html>\n"

        
        let template = BrilliantTemplate(file: "test_include_error.html", path: getPathTemplates())
        
        XCTAssertEqual(template.getHTML(), HTML_RESULT)
        
    }
    
    
    
    func test_include_travesal_attack() {
        let HTML_RESULT =  "<!DOCTYPE html>\n<html lang=\"en\">\n    <body>\n        <div class=\"menu\">cannot open file ../BrilliantTemplateTests.swift\n        </div>\n    </body>\n</html>\n"
        let template = BrilliantTemplate(file: "test_include_travesal_attack.html", path: getPathTemplates())
        
        
        XCTAssertEqual(template.getHTML(), HTML_RESULT)
        
    }
    
    func test_brilliant_tag() {
        let HTML_RESULT = "<!DOCTYPE html>\n<html lang=\"en\">\n    <body>\n        \n            Single tag to be replaced\n        \n        Hello!\n    </body>\n</html>\n"
        
        let template = BrilliantTemplate(file: "test_brilliant_tag.html", path: getPathTemplates())
        
        XCTAssertEqual(template.getHTML(data: ["sayHello":"Hello!"]), HTML_RESULT)
        
        
    }
    
    func test_attribute_plus() {
		let HTML_RESULT = "<!DOCTYPE html>\n<html lang=\"en\">\n    <body>\n        <div class=\"otherClass\"></div>\n        <div class=\"previousClass otherClass\"></div>\n        <a href=\"activity.html?id=2\"></a>\n\t\t<h1 class=\"prev customClass\">prev plus customClass</h1>\n\t\t<h1 class=\"prev \">prev only</h1>\n    </body>\n</html>\n"


        let template = BrilliantTemplate(file: "test_attribute_plus.html", path: getPathTemplates())

        XCTAssertEqual(template.getHTML(data: ["active": true, "extra":"otherClass", "id": UInt32(2)]), HTML_RESULT)
        
    }
    
    func test_attribute_comparable() {
        let HTML_RESULT = "<!DOCTYPE html>\n<html lang=\"en\">\n    <body><!-- test with bid -->\n        \n        <h1 data-id=\"10\">= 10</h1>\n        <h1>! 10</h1>\n        <h1>&lt; 10</h1>\n        <h1>&gt; 10</h1>\n        <h1 data-id=\"10\">&lt; 11</h1>\n        <h1 data-id=\"10\">&gt; 09</h1>\n<!-- with value sustitution -->\n        \n        <h1 class=\"red\">#ff0000 has class red</h1>\n        <h1>#00ff00 has no class</h1>\n\n\t\t<h1 class=\"customClass\">attribute class has customClass</h1>\n\t\t<h1>there is not class attribute</h1>\n<!-- test with tid -->\n        \n        <h2>= 10</h2>\n        <h2>! 10</h2>\n        <h2>&gt; 10</h2>\n        <h2>&lt; 10</h2>\n        <h2>&gt; 11</h2>\n        <h2>&lt; 09</h2>\n    </body>\n</html>"

        let template = BrilliantTemplate(file: "test_attribute_comparable.html", path: getPathTemplates())
        XCTAssertEqual(template.getHTML(data: ["active": true, "value": "10", "color": "#ff0000"]), HTML_RESULT)
    }
    


	func test_filters_boolean() {
		func isEqual(_ comp: (value: String, result: FilterAction), _ value:String, _ action:FilterAction) -> Bool {
			return value == comp.value && comp.result == action
		}

		// Replace value in attribute:  <span bid-class="var:true?warning"> => <span class="warning"> if var = true
		XCTAssertTrue(isEqual(filterBoolBid(value: true, filters: "var:true:?itistrue".components(separatedBy: ":")), "itistrue", .replace), "var:true:?itistrue")
		XCTAssertTrue(isEqual(filterBoolBid(value: true, filters: "var:false:?itistrue".components(separatedBy: ":")), "", .replace), "var:true:?itistrue")
		XCTAssertTrue(isEqual(filterBoolBid(value: true, filters: "var".components(separatedBy: ":")), "true", .replace), "var")
		XCTAssertTrue(isEqual(filterBoolBid(value: false, filters: "var".components(separatedBy: ":")), "false", .replace), "var")

		// Remove tag:  <span tid="var:true">  => <span> if true, removed if false
		XCTAssertTrue(isEqual(filterBoolTID(value: true, filters: "var:true".components(separatedBy: ":")), "", .remainNodes), "var:true")
		XCTAssertTrue(isEqual(filterBoolTID(value: false, filters: "var:false".components(separatedBy: ":")), "", .remainNodes), "var:true")

		XCTAssertTrue(isEqual(filterBoolTID(value: true, filters: "var:false".components(separatedBy: ":")), "", .removeNode), "var:false")
		XCTAssertTrue(isEqual(filterBoolTID(value: false, filters: "var:true".components(separatedBy: ":")), "", .removeNode), "var:true")
	}

	func test_filters_date() {
		func isEqual(_ comp: (value: String, result: FilterAction), _ value:String, _ action:FilterAction) -> Bool {
			//print("\t\t####### [\(comp.value)] == [\(value)]")
			return value == comp.value && comp.result == action
		}


		// Basic dates
		// 15/nov/2016 6:35am

		//let date = Date(timeIntervalSince1970: 1479184514)
		//var a = filterDate(value: "datetime", filters: "var:date".components(separatedBy: ":"))

		TEMPLATE_DEFAULT_LOCALE = Locale(identifier: "en_EN")
		/*
		// ISO and RFC dates
		XCTAssertTrue(isEqual(filterDate(value: date, filters: "var:ISO8601".components(separatedBy: ":")), "2016-11-15T04:35:14.000Z", .ok), "iso8601")
		XCTAssertTrue(isEqual(filterDate(value: date, filters: "var:RFC2616".components(separatedBy: ":")), "Tue, 15-Nov-2016 06:35:14 GMT+2", .ok), "RFC2616")

		// Date, Time, Datetime
		XCTAssertTrue(isEqual(filterDate(value: date, filters: "var:date".components(separatedBy: ":")), "11/15/16", .ok), "date")
		XCTAssertTrue(isEqual(filterDate(value: date, filters: "var:time".components(separatedBy: ":")), "6:35 AM", .ok), "time")
		XCTAssertTrue(isEqual(filterDate(value: date, filters: "var".components(separatedBy: ":")), "11/15/2016 06:35:14", .ok), "no filters")
		XCTAssertTrue(isEqual(filterDate(value: date, filters: "var:datetime".components(separatedBy: ":")), "11/15/16, 6:35 AM", .ok), "datetime")

		// Style formatter, full, long, medium and short
		XCTAssertTrue(isEqual(filterDate(value: date, filters: "var:full".components(separatedBy: ":")), "Tuesday, November 15, 2016 at 6:35:14 AM Eastern European Standard Time", .ok), "full")
		XCTAssertTrue(isEqual(filterDate(value: date, filters: "var:long".components(separatedBy: ":")), "November 15, 2016 at 6:35:14 AM GMT+2", .ok), "long")
		XCTAssertTrue(isEqual(filterDate(value: date, filters: "var:medium".components(separatedBy: ":")), "Nov 15, 2016, 6:35:14 AM", .ok), "medium")
		XCTAssertTrue(isEqual(filterDate(value: date, filters: "var:short".components(separatedBy: ":")), "11/15/16, 6:35 AM", .ok), "short")

		// International dates (US, UK, ES, EE, JP AND ZH)
		XCTAssertTrue(isEqual(filterDate(value: date, filters: "var:short:en_US".components(separatedBy: ":")), "11/15/16, 6:35 AM", .ok), "en_UK")
		XCTAssertTrue(isEqual(filterDate(value: date, filters: "var:short:en_UK".components(separatedBy: ":")), "15/11/2016, 06:35", .ok), "en_UK")
		XCTAssertTrue(isEqual(filterDate(value: date, filters: "var:short:es_ES".components(separatedBy: ":")), "15/11/16 6:35", .ok), "es_ES")
		XCTAssertTrue(isEqual(filterDate(value: date, filters: "var:short:et_EE".components(separatedBy: ":")), "15.11.16 6:35", .ok), "et_EE")
		XCTAssertTrue(isEqual(filterDate(value: date, filters: "var:short:ja_JP".components(separatedBy: ":")), "2016/11/15 6:35", .ok), "ja_JP")
		XCTAssertTrue(isEqual(filterDate(value: date, filters: "var:short:zh_ZH".components(separatedBy: ":")), "2016/11/15 &#x4E0A;&#x5348;6:35", .ok), "zh_ZH")

		// Custom format: the class will control escape \:, the original string was:  "var:format/MM/dd/yyyy hh\:mm\:ss" but was splitted for this test
		XCTAssertTrue(isEqual(filterDate(value: date, filters: ["var", "format/MM/dd/yyyy hh:mm:ss"]), "11/15/2016 06:35:14", .ok), "customFormat")
	*/

	}
    
    func test_dictionary() {
        let HTML_RESULT = "<!DOCTYPE html>\n<html lang=\"en\">\n    <body>\n        <h1>test dictionary</h1>\n        <div>\n            <span>100</span>\n            <span>test 100</span>\n            <span>11/15/2016 06:35:14</span>\n            <span>/* error key &quot;obj.name&quot; is not a dictionary */</span>\n            <span>/* \"obj.error\" not found! */</span>\n            \n            <span id=\"100\">id</span>\n            <span name=\"test 100\">name</span>\n            <span date=\"11/15/2016 06:35:14\">date</span>\n            <span name-error=\"/* error key &quot;obj.name&quot; is not a dictionary */\">name.error</span>\n            <span error=\"\">error</span>\n        </div>\n    </body>\n</html>\n"
        
        let data: [String: Any?] = [
            "testName":"test dictionary",
            "obj": [
                "id": 100,
                "name": "test 100",
                "date": Date(timeIntervalSince1970: 1479184514)
            ],
            "color": "#ff0000"
        ]
        
        let template = BrilliantTemplate(file: "test_dictionary.html", path: getPathTemplates())
        XCTAssertEqual(template.getHTML(data: data), HTML_RESULT)
    }
    
    func test_conditional() {
        let HTML_RESULT = "<!DOCTYPE html>\n<html lang=\"en\">\n    <body>\n        <h1>bool is not true</h1>\n        <h1>name is not empty</h1>\n        <h1>surname is empty</h1>\n        \n        <h4>There is not activities</h4>\n\n\n    </body>\n</html>\n"
        
        let data: [String: Any?] = [
            "bool": false,
            "name": "something",
            "surname": "",
            "activities": []
        ]
        
        let template = BrilliantTemplate(file: "test_conditional.html", path: getPathTemplates())
        XCTAssertEqual(template.getHTML(data: data), HTML_RESULT)
    }
    
    func test_support_uint32() {
        let HTML_RESULT = "<!DOCTYPE html>\n<html lang=\"en\">\n    <body>\n        <div data-id=\"4294967295\" class=\"previouClass\"></div>\n        <div>4294967295</div>\n    </body>\n</html>\n"
        
        let data: [String: Any?] = [
            "UInt32": UINT32_MAX
        ]
        
        let template = BrilliantTemplate(file: "test_support_uint32.html", path: getPathTemplates())
        XCTAssertEqual(template.getHTML(data: data), HTML_RESULT)
    }


	func test_filter_number() {
		let template = BrilliantTemplate(file: "test_filter_number.html", path: getPathTemplates())
		XCTAssertEqual(template.getHTML(data: ["value": "10"]), loadfile(file: "test_filter_number-result.html", in: getPathTemplates()))
		XCTAssertEqual(template.getHTML(data: ["value": 10]), loadfile(file: "test_filter_number-result.html", in: getPathTemplates()))
	}

	func test_stringNil() {
		let data: [String:Any?]? = ["test1": nil, "test2": "notnil", "test3": 100, "test4": Date()]
		let template = BrilliantTemplate(file: "test_isnil_notnil.html", path: getPathTemplates())
		XCTAssertEqual(template.getHTML(data: data), loadfile(file: "test_isnil_notnil-result.html", in: getPathTemplates()))
	}


}
