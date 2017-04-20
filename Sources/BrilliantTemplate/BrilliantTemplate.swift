//
//  main.swift
//  MasPruebasHTML
//
//  Created by Ubaldo Cotta on 4/1/17.
//  Copyright © 2017 Ubaldo Cotta. All rights reserved.
//

import Foundation
import BrilliantHTML5Parser

public class BrilliantTemplate {
    var html: String?
    let file: String?
    var data: [String:Any?] = [:]
    let path: String

    public init(file: String, path: String = ".") {
        self.file = file
        self.path = path
        html = loadfile(file: file, in: path)
    }

    public init(html: String, path: String = ".") {
        self.html = html
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

    func processArray(node: HTMLNode, values: [[String: Any?]]) {
        for p in 0..<values.count {
            let newNode = node.copyNode()
            newNode["tid"] = nil
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
            while let childNode: HTMLNode = newNode.getNextBid() {
                processBid(node: childNode, data: mergedData)
                childNode["aid"] = nil
            }
            newNode.setBeforeNode(node: node)
        }
        // Remove current node
        node.parentNode = nil
    }

    public func getHTML() -> String {
        return getHTML(data: nil)
    }
    public func getHTML(data:[String:Any?]?) -> String {
        self.data = data ?? [:]

        let doc = ParserHTML5(html: html!);

        loadIncludes(doc: doc)
        processTids(doc: doc, data: self.data)
        processBids(doc: doc, data: self.data)
        processJSids(doc: doc, data: self.data)
        cleanBrilliantTag(doc: doc)

        return doc.toHTML
    }


}


