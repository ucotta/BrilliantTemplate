//
// Created by Ubaldo Cotta on 4/1/17.
//

import Foundation
import BrilliantHTML5Parser

extension BrilliantTemplate {
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
                        case .replace:
                            if let data: String = node[attribute], let sequence = r.extra {
                                attributeValue = data.stringByReplacing(string: sequence, withString: r.value)
                            } else {
                                attributeValue = ""
                            }
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
                        let r = filterBoolAID(value: v, filters: parts)
                        switch r.result {
                        case .ok:
                            attributeValue = r.value
                        case .plus:
                            attributeValue = (node[attribute] ?? "") + r.value
                                //case .replace:
                                //    if let data: String = node[attribute], let sequence = r.extra {
                                //        attributeValue = data.stringByReplacing(string: sequence, withString: r.value)
                                //    } else {
                                //        attributeValue = ""
                                //    }

                        default:
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
                        case .replace:
                            if let data: String = node[attribute], let sequence = r.extra {
                                attributeValue = data.stringByReplacing(string: sequence, withString: r.value)
                            } else {
                                attributeValue = ""
                            }

                        case .remainNodes:
                            break
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
                        case .replace:
                            if let data: String = node[attribute], let sequence = r.extra {
                                attributeValue = data.stringByReplacing(string: sequence, withString: r.value)
                            } else {
                                attributeValue = ""
                            }

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
        while let node:HTMLNode = doc.root.getNextBid() {
            processAid(node: node, data: data)
        }
    }
}