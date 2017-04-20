//
// Created by Ubaldo Cotta on 4/1/17.
//

import Foundation
import BrilliantHTML5Parser

extension BrilliantTemplate {

	func toInteger(value: Any) -> Any {
		if value is UInt8 {return Int(value as! UInt8)}
		if value is Int8 {return Int(value as! Int8)}
		if value is UInt16 {return UInt(value as! UInt16)}
		if value is Int16 {return Int(value as! Int16)}
		if value is UInt32 {return UInt(value as! UInt32)}
		if value is Int32 {return Int(value as! Int32)}

		return value
	}

    func processBid(node: HTMLNode, data: [String: Any?]) {
        let attPrefix = node.prefixClass ?? "aid"
        if let aid = node[attPrefix] {
            var parts: [String] = aid.components(separatedBy: ":")

            if (parts.count < 1) {
                node[attPrefix] = "incorrect syntax, bid needs 2 or more parameters"
            } else {
                let attribute = node.prefixAttribute // parts.remove(at: 0)
    
    
                if var variable = untieVar(name: parts[0], data: data) {
					variable = toInteger(value: variable)

                    var attributeValue: String? = nil

                    switch variable {
                    case let v as String:
                        let r = filterString(value: v, filters: parts)
                        switch r.result {
                        case .replace, .remainNodes:
                            attributeValue = r.value
                        case .plus:
                            attributeValue = (node[attribute] ?? "") + r.value
                        case .replaceVariable:
                            if let data: String = node[attribute], let sequence = r.extra {
                                attributeValue = data.stringByReplacing(string: sequence, withString: r.value)
                            } else {
                                attributeValue = ""
                            }
                        default:
							attributeValue = ""
                        }

                    case let v as Date:
                        let r = filterDate(value: v, filters: parts)
                        switch r.result {
                        case .replace:
                            attributeValue = r.value
                        default:
                            node.removeNodes()
                            node.parentNode = nil
                        }

					case let v as Bool:
                        let r = filterBoolBid(value: v, filters: parts)
                        switch r.result {
                        case .replace:
                            attributeValue = r.value
                        case .plus:
                            attributeValue = (node[attribute] ?? "") + r.value
                                //case .replace:
                                //    if let data: String = node[attribute], let sequence = r.extra {
                                //        attributeValue = data.stringByReplacing(string: sequence, withString: r.value)
                                //    } else {
                                //        attributeValue = ""
                                //    }
                        case .removeAttribute:
                            attributeValue = nil
                        
                        default:
							attributeValue = ""
                        }

                    default:
						if variable is UInt {
							variable = NSNumber(value: variable as! UInt)
						} else if variable is Int {
							variable = NSNumber(value: variable as! Int)
						}

						if let v = variable as? NSNumber {
							let r = filterNumber(value: v, filters: parts)
							switch r.result {
							case .replace, .remainNodes:
								attributeValue = r.value
							case .plus:
								attributeValue = (node[attribute] ?? "") + r.value
							case .replaceVariable:
								if let data: String = node[attribute], let sequence = r.extra {
									attributeValue = data.stringByReplacing(string: sequence, withString: r.value)
								} else {
									attributeValue = ""
								}
							default:
								attributeValue = ""
							}

						} else {
							node[attPrefix] = "\(variable) not supported"
							print("bidprocessor: \(parts[0]) not supported")
						}
                    }

                    if attributeValue != nil && !attributeValue!.isEmpty {
                        //if node[attribute] == nil {
                        node[attribute] = attributeValue
                        //} else {
                        //    node[attribute] = node[attribute]! + " " + attributeValue!
                        //}
                    }
                    node[attPrefix] = nil

                } else {
                    node[attPrefix] = nil
                    if node[attribute] == nil {
                        node[attribute] = ""
                    }
                }
            }

        }
    }

    func processBids(doc: ParserHTML5, data: [String: Any?] ) {
        while let node:HTMLNode = doc.root.getNextBid() {
            processBid(node: node, data: data)
        }
    }
}
