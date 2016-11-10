//
//  filters.swift
//  MasPruebasHTML
//
//  Created by Ubaldo Cotta on 2/11/16.
//  Copyright © 2016 Ubaldo Cotta. All rights reserved.
//

import Foundation

private let COMPARABLE = "<>=!".characters

enum FilterAction { case ok, removeNode }

func filterString(value _val: String, filters _filters: [String]) -> (value: String, result: FilterAction) {
	var filters = _filters
	var value:String = _val
    var result: FilterAction = .ok

	filters.remove(at: 0)
	while filters.count > 0 {
        var filter:String = filters.remove(at: 0)
        
        if filter.isEmpty {
            continue
        }

		switch filter {
        case "notempty":
            if value == "" {
                result = .removeNode
            }
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
                
            default:
                return (value: "filter: \(c)\(filter) not supported", result: .ok)
            }
		}
	}
    return (value: value, result: result)
}


func filterNumber(value: NSNumber, filters: [String]) -> (value: String, result: FilterAction)  {
    let result: FilterAction = .ok

    if filters.count > 1 {
		var filter = filters[1], option1 = "", option2 = ""
		if filter.contains("/") {
			var tmp = filters[1].components(separatedBy: "/")
			filter = tmp[0]
			option1 = tmp[1]
			option2 = tmp.count > 2 ? tmp[2] : ""
		}

		if filter.contains("currency") {
			let formatter = NumberFormatter()
			formatter.numberStyle = .currency
			formatter.locale = option1 == "" ? Locale.current : Locale(identifier: option1)
            return (value: formatter.string(from: value) ?? "currency error in \(value)", result: .ok)

		} else if filter == "decimal" {
			let formatter = NumberFormatter()
			formatter.numberStyle = .decimal
			formatter.locale = option1 == "" ? Locale.current : Locale(identifier: option1)
			if !option2.isEmpty {
				formatter.minimumFractionDigits = Int(option2) ?? 2
				formatter.maximumFractionDigits = Int(option2) ?? 2
			}
            return (value: formatter.string(from: value) ?? "decimal error in \(value)", result: .ok)

		}
	}
    return (value: "\(value)", result: result)
}

