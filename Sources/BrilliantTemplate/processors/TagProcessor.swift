//
// Created by Ubaldo Cotta on 4/1/17.
//

import Foundation
import BrilliantHTML5Parser

extension BrilliantTemplate {

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
                let escaped = tid.stringByReplacing(string: "\\:", withString: "$DDOTESC$")
                var parts = escaped.components(separatedBy: ":")

                if var variable = untieVar(name: parts[0], data: data) {
                    variable = toInteger(value: variable)

                    switch variable {
                    case let v as String:
                        let r = filterString(value: v, filters: parts)
                        switch r.result {
                        case .replace:
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
                        case .replace:
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
                        if variable is UInt {
                            variable = NSNumber(value: variable as! UInt)
                        } else if variable is Int {
                            variable = NSNumber(value: variable as! Int)
                        }
    
                        if let v = variable as? NSNumber {
                            let r = filterNumber(value: v, filters: parts)
                            switch r.result {
                            case .replace:
                                node.removeNodes()
                                node.addNode(node: TextHTML(text: r.value))
                            case .removeNode:
                                node.removeNodes()
                                node.parentNode = nil
                            default: break
                            }
						} else if String(describing: variable) == "nil" {
							// Strings with "nil" text value was procesed in case let v as String. This is a real nil value...
							if parts.contains("notnil") {
								node.removeNodes()
								node.parentNode = nil
							}
                        } else {
                            print("\(parts[0]) not supported")
                        }
                    }

                } else {
                    node.removeNodes()
                    node.addNode(node: TextHTML(text: "/* \"\(tid)\" not found! */"))
                }
            }
        }
        node["tid"] = nil
    }

}
