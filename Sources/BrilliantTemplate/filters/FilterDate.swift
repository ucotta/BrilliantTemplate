//
// Created by Ubaldo Cotta on 4/1/17.
//

import Foundation


func filterDate(value _val: Date, filters _filters: [String]) -> (value: String, result: FilterAction, extra: String?) {
    var filters = _filters
    let value: Date = _val
    let result: FilterAction = .ok
    var stringResult: String = ""
    var escapeMethod = "htmlencode"
    var extra: String? = nil

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
                return (value: "filter: \(filter) not supported", result: .ok, extra: extra)
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
    let hasDate = string.contains(string: "-")
    let hasTime = string.contains(string: ":")
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm:ss"
    if hasDate && hasTime {
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
    } else if hasDate {
        formatter.dateFormat = "yyyy-MM-dd"
    }

    return formatter.date(from: string) ?? Date()
}
