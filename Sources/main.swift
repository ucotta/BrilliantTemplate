//
//  main.swift
//  MasPruebasHTML
//
//  Created by Ubaldo Cotta on 1/11/16.
//  Copyright © 2016 Ubaldo Cotta. All rights reserved.
//

import Foundation

class BrilliantTemplate {
	let template: String
	let data: [String:Any?]
	let path: String

	public init(_ template: String, data:[String:Any?]? = nil, path: String = ".") {
		self.template = template
		self.data = data ?? [:]
		self.path = path
	}


	func loadfile(file:String) -> String {
		do {
			return try String(contentsOfFile: "\(path)/\(file)", encoding: String.Encoding.utf8)
		} catch let error {
			print(error)

		}
		return "<include>file \(file) not found</include>"
	}

	func loadIncludes(_ doc:HTMLDocument) {
		for var link in doc.xpath("//include") {
			if let file = link["file"] {
				if let tmp = HTML(html: loadfile(file: file), encoding: .utf8) {
					for div in tmp.xpath("body/*") {
						link.addPrevSibling(div)
					}
				}
				link.parent?.removeChild(link)
			}
		}
	}

	func processJSids(_ doc:HTMLDocument) {
		for var item in doc.xpath("//*[@jsid]") {
			if let jsid = item["jsid"] {

				if (jsid.isEmpty) {
					item.content = "/* Empty jsid cannot be used */"
				} else {

					switch data[jsid] {
					case let v as String:
						item.content = "\n\(v)\n"
					default:
						item.content = "/* \(jsid) not found! */"
					}
				}
				item["jsid"] = nil
			}
		}
	}

	func processAids(_ doc:HTMLDocument) {
		return processAids(doc, data: data)

	}
	func processAids(_ doc:SearchableNode, data: [String: Any?] ) {
		for var item in doc.xpath("//*[@aid]") {
			if let aid = item["aid"] {
				var parts: [String] = aid.components(separatedBy: ":")

				if (parts.count < 2) {
					item["aid"] = "incorrect syntax, aid needs 2 or more parameters"
				} else {
					let attribute = parts.remove(at: 0)

					if let variable = data[parts[0]] { 
						var attributeValue: String? = nil

						switch variable {
						case let v as String:
							attributeValue = filterString(value: v, filters: parts)

						case let v as NSNumber:
							attributeValue = filterNumber(value: v, filters: parts)

						default:
							item["aid"] = "\(variable) not supported"
							print("\(parts[0]) not supported")
						}

						if attributeValue != nil {
							item["aid"] = nil
							item[attribute] = attributeValue
						}

					} else {
						item["aid"] = nil
						item[attribute] = ""
					}
				}

			}
		}
	}



	func processTids(_ doc:HTMLDocument) {
		return processTids(doc, data: data)
	}

	func processTids(_ doc:SearchableNode, data: [String: Any?] ) {
		for var item in doc.xpath("//*[@tid]") {
			if let tid = item["tid"] {

				if (tid.isEmpty) {
					item.content = "Empty tid cannot be used!"
				} else {
					var parts = tid.components(separatedBy: ":")

					if let variable = data[parts[0]]! {

						switch variable {
						case let v as String:
							item.content = filterString(value: v, filters: parts)

						case let v as NSNumber:
							item.content = filterNumber(value: v, filters: parts)


						case let v as [[String: Any?]]:
							// Array of dictionaries
							item["tid"] = nil
							processArray(node: item as! libxmlHTMLNode, values: v)


						default:
							print("\(parts[0]) not supported")
						}

					} else {
						item.content = "tid: '\(tid)' not found!"
					}
				}
				item["tid"] = nil
			}
		}
	}

	func processArray(node: libxmlHTMLNode, values: [[String: Any?]]) {
		for value in values {
			if let newNode = node.cloneNode() {
				processTids(newNode, data: value)
				processAids(newNode, data: value)
				processTids(newNode, data: data)
				processAids(newNode, data: data)
			}

		}
		node.parent?.removeChild(node)
	}

	public func getHTML() -> String {
		let document = HTML(html: loadfile(file: template), encoding: .utf8)
		guard let doc = document else {
			print("can not load \(template)")
			return ""
		}

		loadIncludes(doc)
		processTids(doc)
		processAids(doc)
		processJSids(doc)

		if let html = doc.toHTML {
			return html
		}

		return "error generating html"
	}


}

