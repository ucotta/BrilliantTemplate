//
// Created by Ubaldo Cotta on 4/1/17.
//

import Foundation


func filterDate(value _val: Date, filters _filters: [String]) -> (value: String, result: FilterAction, extra: String?) {
    var filters = _filters
    let value: Date = _val
    var result: FilterAction = .replace
    var stringResult: String = ""
    var escapeMethod = "htmlencode"
    let extra: String? = nil

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

        case "isnil":
            result = .removeNode

        case "notnil":
            result = .remainNodes
        
        
        default:
            if filter.contains("_") {
                formatter.locale = Locale(identifier: filter)
            } else if filter.hasPrefix("format/") {
                formatter.dateFormat = removePrefix(string: filter, prefix: "format/").replacingOccurrences(of: "$DDOTESC$", with: ":")
            } else {
                return (value: "filter: \(filter) not supported", result: .replace, extra: extra)
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
    return (value: stringResult, result: result, extra: extra)
}


func getDate(from string:String) -> Date {
    // formats: yyyy-MM-dd hh:mm:ss, yyyy-MM-dd or hh:mm:ss
    let hasDate = string.contains("-")
    let hasTime = string.contains(":")
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    if hasDate && hasTime {
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    } else if hasDate {
        formatter.dateFormat = "yyyy-MM-dd"
    }

    return formatter.date(from: string) ?? Date()
}
