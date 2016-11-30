//
//  filters.swift
//  MasPruebasHTML
//
//  Created by Ubaldo Cotta on 2/11/16.
//  Copyright © 2016 Ubaldo Cotta. All rights reserved.
//

import Foundation
//import PerfectLib
import HTMLEntities
import BrilliantHTML5Parser

private let COMPARABLE = "<>=!".characters

public var TEMPLATE_DEFAULT_LOCALE = Locale.current

enum FilterAction {
    case ok, removeNode, returnNone, remainNodes, plus
}


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
    var result: FilterAction = .ok

    filters.remove(at: 0)
    while filters.count > 0 {
        let filter: String = filters.remove(at: 0)

        if filter.isEmpty {
            continue
        }

        switch filter.lowercased() {
        case "true":
            result = value ? .ok : .removeNode

        case "false":
            result = !value ? .ok : .removeNode

        default:
            return (value: "filter: \(filter) not supported", result: .ok)
        }

    }

    return (value: "", result: result)
}

func filterBoolAID(value _val: Bool, filters _filters: [String]) -> (value: String, result: FilterAction) {
	var filters = _filters
	let value:Bool = _val
	var result: FilterAction = .ok
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
			if result == .ok {
				result = .plus
			}

        case "true":
            result = value ? .ok : .returnNone

        case "false":
            result = !value ? .ok : .returnNone

        default:
            if filter.hasPrefix("?") {
                stringResult = removePrefix(string: filter, prefix: "?")
            } else {
                return (value: "filter: \(filter) not supported", result: .ok)
            }
        }

	}

    if result == .returnNone {
        return (value: "", result: .ok)
    }

    return (value: stringResult, result: result)
}

func filterDate(value _val: Date, filters _filters: [String]) -> (value: String, result: FilterAction) {
    var filters = _filters
    let value: Date = _val
    let result: FilterAction = .ok
    var stringResult: String = ""
    var escapeMethod = "htmlencode"

    let formatter = DateFormatter()
	formatter.locale = TEMPLATE_DEFAULT_LOCALE
	formatter.timeStyle = .short
	formatter.dateStyle = .short
    formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"


    filters.remove(at: 0)
    while filters.count > 0 {
        let filter: String = filters.remove(at: 0)

        if filter.isEmpty {
            continue
        }

        switch filter.lowercased() {
        case "raw":
            escapeMethod = "raw"
        case "urlencode":
            escapeMethod = "urlencode"

        case "htmlencode":
            escapeMethod = "htmlencode"

        case "iso8601":
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"

        case "rfc2616":
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "E, dd-MMM-YYY HH:mm:ss z"

        case "date":
            formatter.timeStyle = .none
            formatter.dateStyle = .short

        case "time":
            formatter.dateStyle = .none
            formatter.timeStyle = .short

        case "datetime":
            formatter.dateStyle = .short
            formatter.timeStyle = .short

        case "short":
            formatter.dateStyle = formatter.dateStyle != .none ? .short : .none
            formatter.timeStyle = formatter.timeStyle != .none ? .short : .none

        case "medium":
            formatter.dateStyle = formatter.dateStyle != .none ? .medium : .none
            formatter.timeStyle = formatter.timeStyle != .none ? .medium : .none

        case "long":
            formatter.dateStyle = formatter.dateStyle != .none ? .long : .none
            formatter.timeStyle = formatter.timeStyle != .none ? .long : .none

        case "full":
            formatter.dateStyle = formatter.dateStyle != .none ? .full : .none
            formatter.timeStyle = formatter.timeStyle != .none ? .full : .none
        default:
            if filter.contains(string: "_") {
                formatter.locale = Locale(identifier: filter)
            } else if filter.hasPrefix("format/") {
                formatter.dateFormat = removePrefix(string: filter, prefix: "format/").stringByReplacing(string: "$DDOTESC$", withString: ":")
            } else {
                return (value: "filter: \(filter) not supported", result: .ok)
            }
        }

    }


    stringResult = formatter.string(from: value)

    if escapeMethod == "htmlencode" {
        stringResult = stringResult.htmlEscape()
    } else if escapeMethod == "urlencode" {
		// import a library.
        //stringResult = stringResult.stringByEncodingURL
    }
    return (value: stringResult, result: result)
}


func getDate(from string:String) -> Date {
	// formats: yyyy-MM-dd hh:mm:ss, yyyy-MM-dd or hh:mm:ss
	let hasDate = string.contains(string: "-")
	let hasTime = string.contains(string: ":")
	var formatter = DateFormatter()
	formatter.dateFormat = "hh:mm:ss"
	if hasDate && hasTime {
		formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
	} else if hasDate {
		formatter.dateFormat = "yyyy-MM-dd"
	}
	
	return formatter.date(from: string) ?? Date()
}

func filterString(value _val: String, filters _filters: [String]) -> (value: String, result: FilterAction) {
    var filters = _filters
    var value: String = _val
    var result: FilterAction = .ok

    var escapeMethod = "htmlencode"

    filters.remove(at: 0)
    while filters.count > 0 {
        var filter: String = filters.remove(at: 0)

        if filter.isEmpty {
            continue
        }

        switch filter {
        case "date":
	        // reset and send it to filterDate
	        filters.insert("date", at: 0)
            return filterDate(value: getDate(from: value),  filters: filters)
        case "+":
			if result == .ok {
				result = .plus
			}
        case "raw":
            escapeMethod = "raw"
        case "urlencode":
            escapeMethod = "urlencode"

        case "htmlencode":
            escapeMethod = "htmlencode"

        case "notempty", "true":
            result = value.isEmpty ? .removeNode : .remainNodes
        case "empty", "false":
            result = value.isEmpty ? .remainNodes : .removeNode

        case "cap":
            value = value.capitalized

        case "upper":
            value = value.uppercased()

        case "lower":
            value = value.lowercased()

        default:
            // Comparable filter has two parts, first character is operator, the rest are value to by compared.
            let c: Character = filter.characters.popFirst()!

            switch c {
            case "=":
                value = value == filter ? value : ""

            case "<":
                value = value < filter ? value : ""

            case ">":
                value = value > filter ? value : ""

            case "!":
                value = value < filter ? value : ""

            case "?" where !value.isEmpty:
                value = filter

            case "?":
                continue

            default:
                return (value: "filter: \(c)\(filter) not supported", result: .ok)
            }
        }
    }

    if escapeMethod == "htmlencode" {
        value = value.htmlEscape()
    } else if escapeMethod == "urlencode" {
        //value = value.stringByEncodingURL
    }

    return (value: value.htmlEscape(), result: result)
}



func filterNumber(value: NSNumber, filters _filters: [String]) -> (value: String, result: FilterAction) {
	var filters = _filters
	var result: FilterAction = .ok
	var stringResult = "\(value)"

	filters.remove(at: 0)
	while filters.count > 0 {
		let filterRaw = filters.remove(at: 0)
		var filterSep: [String] = filterRaw.components(separatedBy: "/")
		var filter = filterSep.remove(at: 0)

		if filter.isEmpty {
			continue
		}

		switch filter {
		case "currency":
			let formatter = NumberFormatter()
			formatter.numberStyle = .currency
			while filterSep.count > 0 {
				let option: String = filterSep.remove(at: 0)
				if option.isEmpty {
					continue
				}
				if option.contains("_") {
					formatter.locale = Locale(identifier: option)
				} else {
					print("filterNumber: unknown option [\(option)] in \(filterRaw)")
				}
			}
			stringResult = formatter.string(from: value) ?? "currency error in \(value)"

		case "decimal":
			let formatter = NumberFormatter()
			formatter.numberStyle = .decimal
			while filterSep.count > 0 {
				let option: String = filterSep.remove(at: 0)
				if option.isEmpty {
					continue
				}
				if option.contains("_") {
					formatter.locale = Locale(identifier: option)
				} else if Int(option) != nil {
					formatter.minimumFractionDigits = Int(option)!
					formatter.maximumFractionDigits = Int(option)!
				} else {
					print("filterNumber: unknown option [\(option)] in \(filterRaw)")
				}
			}
			stringResult = formatter.string(from: value) ?? "decimal error in \(value)"
		case "empty", "false":
			result = value.isEqual(NSNumber(value: 0)) ? .remainNodes : .removeNode
		case "notempty", "true":
			result = !value.isEqual(NSNumber(value: 0)) ? .remainNodes : .removeNode


		case "+":
			if result == .ok {
				result = .plus
			}

		default:
			let c: Character = filter.characters.popFirst()!
			let dblValue:Double = value.doubleValue, dblComp:Double = Double(filter) ?? 0.0

			switch c {
			case "=":
				result = dblValue.isEqual(to: dblComp) ? .remainNodes : .removeNode

			case "<":
				result = dblValue.isLess(than: dblComp) ? .remainNodes : .removeNode

			case ">":
				result = dblComp.isLess(than: dblValue) ? .remainNodes : .removeNode

			case "!":
				result = !dblValue.isEqual(to: dblComp) ? .remainNodes : .removeNode

			case "?" where !filter.isEmpty:
				stringResult = filter

			case "?":
				continue

			default:
				return (value: "filter: \(c)\(filter) not supported", result: .ok)
			}
		}
	}

	return (value: stringResult, result: result)
}
