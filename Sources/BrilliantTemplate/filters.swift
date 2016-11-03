//
//  filters.swift
//  MasPruebasHTML
//
//  Created by Ubaldo Cotta on 2/11/16.
//  Copyright © 2016 Ubaldo Cotta. All rights reserved.
//

import Foundation



func filterString(value _val: String, filters _filters: [String]) -> String {
	var filters = _filters
	var value:String = _val

	filters.remove(at: 0)
	while filters.count > 0 {
		let filter = filters.remove(at: 0)

		switch filter {
		case "cap":
			value = value.capitalized

		case "upper":
			value = value.uppercased()

		case "lower":
			value = value.lowercased()

		default:
			return "filter: \(filter) not supported"
		}
	}
	return value
}


func filterNumber(value: NSNumber, filters: [String]) -> String {
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
			return formatter.string(from: value) ?? "currency error in \(value)"

		} else if filter == "decimal" {
			let formatter = NumberFormatter()
			formatter.numberStyle = .decimal
			formatter.locale = option1 == "" ? Locale.current : Locale(identifier: option1)
			if !option2.isEmpty {
				formatter.minimumFractionDigits = Int(option2) ?? 2
				formatter.maximumFractionDigits = Int(option2) ?? 2
			}
			return formatter.string(from: value) ?? "decimal error in \(value)"

		}
	}
	return "\(value)"
}

