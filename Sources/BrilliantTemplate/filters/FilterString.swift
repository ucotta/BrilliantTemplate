//
// Created by Ubaldo Cotta on 4/1/17.
//

import Foundation


func filterString(value _val: String, filters _filters: [String]) -> (value: String, result: FilterAction, extra: String?) {
    var filters = _filters
    var value: String = _val
    var result: FilterAction = .ok
    var extra: String? = nil

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

            case "~":
                extra = filter
                result = .replace

            case "?" where !value.isEmpty:
                value = filter

            case "?":
                continue

            default:
                return (value: "filter: \(c)\(filter) not supported", result: .ok, extra: extra)
            }
        }
    }

    if escapeMethod == "htmlencode" {
        value = value.htmlEscape()
    } else if escapeMethod == "urlencode" {
        //value = value.stringByEncodingURL
    }

    return (value: value, result: result, extra: extra)
}

