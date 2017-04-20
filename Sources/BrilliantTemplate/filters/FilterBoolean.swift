//
//  FilterBoolean.swift
//  MasPruebasHTML
//
//  Created by Ubaldo Cotta on 2/11/16.
//  Copyright © 2016 Ubaldo Cotta. All rights reserved.
//

import Foundation
import HTMLEntities
import BrilliantHTML5Parser



func removePrefix(string s: String, prefix: String) -> String {
    var string = s
    if string == prefix {
        return ""
    }
    string.removeSubrange(string.startIndex ... string.index(string.startIndex, offsetBy: prefix.characters.count - 1))
    return string
}

func filterBoolTID(value _val: Bool, filters _filters: [String]) -> (value: String, result: FilterAction) {
    var filters = _filters
    let value: Bool = _val
    var result: FilterAction = .remainNodes

    filters.remove(at: 0)
    while filters.count > 0 {
        let filter: String = filters.remove(at: 0)

        if filter.isEmpty {
            continue
        }

        switch filter.lowercased() {
        case "true":
            result = value ? .remainNodes : .removeNode

        case "false":
            result = !value ? .remainNodes : .removeNode

        default:
            return (value: "filter: \(filter) not supported", result: .remainNodes)
        }

    }

    return (value: "", result: result)
}

func filterBoolBid(value _val: Bool, filters _filters: [String]) -> (value: String, result: FilterAction) {
	var filters = _filters
	let value:Bool = _val
	var result: FilterAction = .replace
    var stringResult = ""

    if value {
        stringResult = "true"
    } else {
        stringResult = "false"
    }

	filters.remove(at: 0)
	while filters.count > 0 {
		let filter:String = filters.remove(at: 0)

		if filter.isEmpty {
			continue
		}

        switch filter.lowercased() {
		case "+":
			if result == .replace {
				result = .plus
			}

        case "true":
            result = value ? .replace : .returnNone

        case "false":
            result = !value ? .replace : .returnNone
        
        case "checkbox":
	        result = value ? result : .removeAttribute
        
        default:
            if filter.hasPrefix("?") {
                stringResult = removePrefix(string: filter, prefix: "?")
            } else {
                return (value: "filter: \(filter) not supported", result: .replace)
            }
        }

	}

    if result == .returnNone {
        return (value: "", result: .replace)
    }

    return (value: stringResult, result: result)
}
