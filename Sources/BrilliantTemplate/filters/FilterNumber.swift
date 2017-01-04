//
// Created by Ubaldo Cotta on 4/1/17.
//

import Foundation


func filterNumber(value: NSNumber, filters _filters: [String]) -> (value: String, result: FilterAction, extra: String?) {
    var filters = _filters
    var result: FilterAction = .ok
    var stringResult = "\(value)"
    var extra: String? = nil

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

            case "~":
                extra = filter
                result = .replace

            case "?" where !filter.isEmpty:
                stringResult = filter

            case "?":
                continue

            default:
                return (value: "filter: \(c)\(filter) not supported", result: .ok, extra: extra)
            }
        }
    }

    return (value: stringResult, result: result, extra: extra)
}
