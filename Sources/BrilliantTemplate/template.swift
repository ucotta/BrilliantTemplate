//
//  main.swift
//  MasPruebasHTML
//
//  Created by Ubaldo Cotta on 1/11/16.
//  Copyright © 2016 Ubaldo Cotta. All rights reserved.
//

import Foundation
import BrilliantHTML5Parser


#if os(Linux)
    // realpath is not working in linux
    private func loadfile(file:String, in path:String) -> String {
        func containsTraversalCharacters(data:String) -> Bool {
            let dangerCharacters = ["%2e", "%2f", "%5c", "%25", "%c0%af", "%c1%9c", ":", ">", "<", "./", ".\\", "..", "\\\\", "//", "/.", "\\.", "|"]
            return (dangerCharacters.filter { data.contains($0) }.flatMap { $0 }).count > 0
        }
        
        var result = "cannot open file \(file)"
        
        let tmp = path + "/" + file
        do {
            if !containsTraversalCharacters(data:tmp) {
                result = try String(contentsOfFile: tmp, encoding: String.Encoding.utf8)
            }
        } catch {
        }
        return result
    }
#else
    private func loadfile(file:String, in path:String) -> String {
        func rp(path: String) -> String? {
            let p = realpath(path, nil)
            if p == nil {
                return nil
            }
            defer { free(p) }
            
            return String(validatingUTF8: p!)
        }
        
        let tmp = path + "/" + file
        var result = "cannot open file \(file)"
        do {
            if let file = rp(path: tmp) {
                if file.hasPrefix(path) {
                    result = try String(contentsOfFile: file, encoding: String.Encoding.utf8)
                } else {
                    print("Trying to acces file: \(file) outside path \(path)")
                }
            }
        } catch {}
        return result
    }
#endif


public class BrilliantTemplate {
	var html: String?
	let file: String?
	let data: [String:Any?]
	let path: String

	public init(file: String, data:[String:Any?]? = nil, path: String = ".") {
		self.file = file
		self.data = data ?? [:]
		self.path = path
        html = loadfile(file: file, in: path)
	}

	public init(html: String, data:[String:Any?]? = nil, path: String = ".") {
		self.html = html
		self.data = data ?? [:]
		self.path = path
		self.file = nil
	}
    
	func loadIncludes(doc:ParserHTML5) {
        for include in doc.getAllBy(tagName: "include") {
            if let file = include["file"] {
                doc.reparseNode(node: include, html: loadfile(file: file, in: path))
            }
        }
	}

    func cleanBrilliantTag(doc: ParserHTML5) {
        for brilliant in doc.getAllBy(tagName: "brilliant") {
            brilliant.replaceBy(string: brilliant.innerHTML)
        }

    }



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
    
    func untieVar(name:String, data: [String: Any?]) -> Any? {
        var item: Any = data
        var keys: [String] = name.components(separatedBy: ".")
        
        var path = ""
        while keys.count > 0 {
            let key = keys.remove(at: 0)
            
            if item is [String: Any] && keys.count > 0 {
                let tmp = item as! [String: Any]
                if tmp[key] == nil {
                    return nil
                }
                item = tmp[key]!
            } else if item is [String: Any] {
                let tmp = item as! [String: Any]
                return tmp[key]
            } else {
                return "/* error key \"\(path)\" is not a dictionary */"
            }
            path += (path.isEmpty ? "" : ".") + key
        }
        return item
    }

	func processTids(node: HTMLNode, data: [String: Any?] ) {
		if let tid = node["tid"] {
			if (tid.isEmpty) {
				node.addNode(node: TextHTML(text: "/* Empty tid cannot be used */"))
			} else {
				let escaped = tid.stringByReplacing(string: "\\:", withString: "$DDOTESC$")
				var parts = escaped.components(separatedBy: ":")

                if let variable = untieVar(name: parts[0], data: data) {

					switch variable {
					case let v as String:
                        let r = filterString(value: v, filters: parts)
                        switch r.result {
                        case .ok:
                            node.removeNodes()
                            node.addNode(node: TextHTML(text: r.value))
                        case .removeNode:
                            node.removeNodes()
                            node.parentNode = nil
                        default: break
                        }

					case let v as Date:
						node.removeNodes()
                        let r = filterDate(value: v, filters: parts)
                        switch r.result {
                        case .ok:
                            node.addNode(node: TextHTML(text: r.value))
                        case .removeNode:
                            node.removeNodes()
                            node.parentNode = nil
                        default: break
                        }

					case let v as Bool:
						if filterBoolTID(value: v, filters: parts).result == .removeNode {
                            node.removeNodes()
							node.parentNode = nil
						}

					case let v as NSNumber:
                        node.removeNodes()
                        let r = filterNumber(value: v, filters: parts)
                        switch r.result {
                        case .ok:
                            node.addNode(node: TextHTML(text: r.value))
                        case .removeNode:
                            node.removeNodes()
                            node.parentNode = nil
                        default: break
                        }
                    case let v as UInt32:
                        let v2 = NSNumber(value: v)
                        node.removeNodes()
                        let r = filterNumber(value: v2, filters: parts)
                        switch r.result {
                        case .ok:
                            node.addNode(node: TextHTML(text: r.value))
                        case .removeNode:
                            node.removeNodes()
                            node.parentNode = nil
                        default: break
                        }
                        

					case let v as [[String: Any?]]:
						// Array of dictionaries
                        // Bool dont populate arrays, just show or remove a tag.
                        if parts.contains("empty") {
                            if v.count > 0 {
                                node.removeNodes()
                                node.parentNode = nil
                            }
                        } else if parts.contains("noempty") {
                            if v.count == 0 {
                                node.removeNodes()
                                node.parentNode = nil
                            }
                        } else {
                            processArray(node: node, values: v)
                        }
                        node["tid"] = nil

					case let v as [HTMLNode]:
						node.removeNodes()
						node.content = v


					default:
						print("\(parts[0]) not supported")
						//rint(variable)
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
			while let childNode: HTMLNode = newNode.getNextAid() {
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

                if let variable = untieVar(name: parts[0], data: data) {
				//if let variable = data[parts[0]] {
					var attributeValue: String? = nil

					switch variable {
					case let v as String:
                        let r = filterString(value: v, filters: parts)
                        switch r.result {
                        case .ok:
                            attributeValue = r.value
                        case .plus:
                            attributeValue = (node[attribute] ?? "") + r.value
                        default:
                            node.removeNodes()
                            node.parentNode = nil
                        }

					case let v as Date:
                        let r = filterDate(value: v, filters: parts)
                        switch r.result {
                        case .ok:
                            attributeValue = r.value
                        default:
                            node.removeNodes()
                            node.parentNode = nil
                        }

                    case let v as Bool:
                        if filterBoolAID(value: v, filters: parts).result == .removeNode {
                            node.removeNodes()
                            node.parentNode = nil
                        }

					case let v as NSNumber:
						let r = filterNumber(value: v, filters: parts)
                        switch r.result {
                        case .ok:
                            attributeValue = r.value
                        case .plus:
                            attributeValue = (node[attribute] ?? "") + r.value
                        default:
                            node.removeNodes()
                            node.parentNode = nil
                        }
                    case let v as UInt32:
                        let v2 = NSNumber(value: v)
                        let r = filterNumber(value: v2, filters: parts)
                        switch r.result {
                        case .ok:
                            attributeValue = r.value
                        case .plus:
                            attributeValue = (node[attribute] ?? "") + r.value
                        default:
                            node.removeNodes()
                            node.parentNode = nil
                        }
					default:
						node["aid"] = "\(variable) not supported"
						print("\(parts[0]) not supported")
					}

					if attributeValue != nil && !attributeValue!.isEmpty {
                        //if node[attribute] == nil {
                        node[attribute] = attributeValue
                        //} else {
                        //    node[attribute] = node[attribute]! + " " + attributeValue!
                        //}
					}
                    node["aid"] = nil

				} else {
					node["aid"] = nil
                    if node[attribute] == nil {
                        node[attribute] = ""
                    }
				}
			}

		}
	}

	func processAids(doc: ParserHTML5, data: [String: Any?] ) {
		while let node:HTMLNode = doc.root.getNextAid() {
			processAid(node: node, data: data)
		}
	}

	public func getHTML() -> String {
		let doc = ParserHTML5(html: html!);

        loadIncludes(doc: doc)
		processTids(doc: doc, data:data)
		processAids(doc: doc, data:data)
		processJSids(doc: doc, data:data)
        cleanBrilliantTag(doc: doc)

		return doc.toHTML
	}


}


