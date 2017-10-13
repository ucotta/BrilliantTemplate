//
// Created by Ubaldo Cotta on 4/1/17.
//

import Foundation
import BrilliantHTML5Parser

extension BrilliantTemplate {

    func processJSids(doc: ParserHTML5, data: [String: Any?]) {
        while let node: HTMLNode = doc.root.getNextJSid() {
            if let jsid = node["jsid"] {
                node.removeNodes()
                if (jsid.isEmpty) {
                    node.addNode(node: TextHTML(text: "/* Empty jsid cannot be used */"))
                } else if let script = data[jsid] as? String {
                    node.addNode(node: TextHTML(text: "\n\(script)\n"))
                } else {
                    node.addNode(node: TextHTML(text: "/* \"\(jsid)\" not found! */"))
                }
            }
            node["jsid"] = nil
        }
    }

}
