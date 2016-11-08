//
//  main.swift
//  MasPruebasHTML
//
//  Created by Ubaldo Cotta on 1/11/16.
//  Copyright © 2016 Ubaldo Cotta. All rights reserved.
//

import Foundation
import BrilliantHTML5Parser

public class BrilliantTemplate {
	var html: String?
	let file: String?
	let data: [String:Any?]
	let path: String

	public init(file: String, data:[String:Any?]? = nil, path: String = ".") {
		self.file = file
		self.data = data ?? [:]
		self.path = path
	}

	public init(html: String, data:[String:Any?]? = nil, path: String = ".") {
		self.html = html
		self.data = data ?? [:]
		self.path = path
		self.file = nil
	}

	func loadfile(file:String) -> String {
		do {
			return try String(contentsOfFile: "\(path)/\(file)", encoding: String.Encoding.utf8)
		} catch let error {
			print(error)

		}
		return "<include>file \(file) not found</include>"
	}

	/*
	func loadIncludes(_ doc:HTMLDocument) {
		for var link in doc.xpath("//include") {
			if let file = link["file"] {
				if let tmp = HTML(html: loadfile(file: file), encoding: .utf8) {
					for div in tmp.xpath("body/ *") {
						link.addPrevSibling(div)
					}
				}
				link.parent?.removeChild(link)
			}
		}
	}
	*/

	func processJSids(doc: ParserHTML5, data: [String: Any?]) {
		while let node: HTMLNode = doc.root.getNextJSid() {
			if let jsid = node["jsid"] {
				node.removeNodes()
				if (jsid.isEmpty) {
					node.addNode(node: TextHTML(text: "/* Empty jsid cannot be used */"))
				} else if let script = data[jsid] {
					node.addNode(node: TextHTML(text: "\n\(script)\n"))
				} else {
					node.addNode(node: TextHTML(text: "/* \"\(jsid)\" not found! */"))
				}
			}
			node["jsid"] = nil
		}
	}


	func processTids(doc: ParserHTML5, data: [String: Any?]) {
		while let node: HTMLNode = doc.root.getNextTid() {
			processTids(node: node, data: data)
			node["tid"] = nil
		}
	}

	func processTids(node: HTMLNode, data: [String: Any?] ) {
		if let tid = node["tid"] {
			if (tid.isEmpty) {
				node.addNode(node: TextHTML(text: "/* Empty tid cannot be used */"))
			} else {
				var parts = tid.components(separatedBy: ":")

				if let variable = data[parts[0]] {

					switch variable {
					case let v as String:
						node.removeNodes()
						node.addNode(node: TextHTML(text: filterString(value: v, filters: parts)))

					case let v as NSNumber:
						node.removeNodes()
						node.addNode(node: TextHTML(text: filterNumber(value: v, filters: parts)))


					case let v as [[String: Any?]]:
						// Array of dictionaries
						node["tid"] = nil
						processArray(node: node, values: v)

					case let v as [HTMLNode]:
						node.removeNodes()
						node.content = v


					default:
						print("\(parts[0]) not supported")
					}

				} else {
					node.removeNodes()
					node.addNode(node: TextHTML(text: "/* \"\(tid)\" not found! */"))
				}
			}
		}
		node["tid"] = nil
	}


	func processArray(node: HTMLNode, values: [[String: Any?]]) {
		for p in 0..<values.count {
			let newNode = node.copyNode()
			var mergedData = data
			// Join data with new values
			for (key,val) in values[p] {
				mergedData.updateValue(val, forKey:key)
			}
			// Replace tid and aid elements.
			while let childNode: HTMLNode = newNode.getNextTid() {
				processTids(node: childNode, data: mergedData)
				childNode["tid"] = nil
			}
			while let childNode: HTMLNode = newNode.getNextNodeWithAtt(att: "aid") {
				processAid(node: childNode, data: mergedData)
				childNode["aid"] = nil
			}
			newNode.setBeforeNode(node: node)
		}
		// Remove current node
		node.parentNode = nil
	}

	func processAid(node: HTMLNode, data: [String: Any?]) {

		if let aid = node["aid"] {
			var parts: [String] = aid.components(separatedBy: ":")

			if (parts.count < 2) {
				node["aid"] = "incorrect syntax, aid needs 2 or more parameters"
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
						node["aid"] = "\(variable) not supported"
						print("\(parts[0]) not supported")
					}

					if attributeValue != nil {
						node["aid"] = nil
						node[attribute] = attributeValue
					}

				} else {
					node["aid"] = nil
					node[attribute] = ""
				}
			}

		}
	}

	func processAids(doc: ParserHTML5, data: [String: Any?] ) {
		while let node:HTMLNode = doc.root.getNextNodeWithAtt(att: "aid") {
			processAid(node: node, data: data)
		}
	}


	public func getHTML() -> String {
		if let t = file {
			html = loadfile(file: t)
		}
		let doc = ParserHTML5(html: html!);


		//loadIncludes(doc)
		processTids(doc: doc, data:data)
		processAids(doc: doc, data:data)
		processJSids(doc: doc, data:data)

		return doc.toHTML
	}


}


