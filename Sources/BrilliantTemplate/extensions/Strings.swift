//
// Created by Ubaldo Cotta on 4/1/17.
//

import Foundation


// Extracted from
//  Utilities.swift
//  PerfectLib
//
//  Created by Kyle Jessup on 7/17/15.
//	Copyright (C) 2015 PerfectlySoft, Inc.

extension String {

    /// Replace all occurrences of `string` with `withString`.
    public func stringByReplacing(string strng: String, withString: String) -> String {

        guard !strng.isEmpty else {
            return self
        }
        guard !self.isEmpty else {
            return self
        }

        var ret = ""
        var idx = self.startIndex
        let endIdx = self.endIndex

        while idx != endIdx {
            if self[idx] == strng[strng.startIndex] {
                var newIdx = self.index(after: idx)
                var findIdx = strng.index(after: strng.startIndex)
                let findEndIdx = strng.endIndex

                while newIdx != endIndex && findIdx != findEndIdx && self[newIdx] == strng[findIdx] {
                    newIdx = self.index(after: newIdx)
                    findIdx = strng.index(after: findIdx)
                }

                if findIdx == findEndIdx { // match
                    ret.append(withString)
                    idx = newIdx
                    continue
                }
            }
            ret.append(self[idx])
            idx = self.index(after: idx)
        }

        return ret
    }

    // For compatibility due to shifting swift
    public func contains(string strng: String) -> Bool {
        return nil != self.range(ofString: strng)
    }
}

//
//  SwiftCompatibility.swift
//  PerfectLib
//
//  Created by Kyle Jessup on 2016-04-22.
//  Copyright © 2016 PerfectlySoft. All rights reserved.
//

extension String {
    func range(ofString string: String, ignoreCase: Bool = false) -> Range<String.Index>? {
        var idx = self.startIndex
        let endIdx = self.endIndex

        while idx != endIdx {
            if ignoreCase ? (String(self[idx]).lowercased() == String(string[string.startIndex]).lowercased()) : (self[idx] == string[string.startIndex]) {
                var newIdx = self.index(after: idx)
                var findIdx = string.index(after: string.startIndex)
                let findEndIdx = string.endIndex

                while newIdx != endIndex && findIdx != findEndIdx && (ignoreCase ? (String(self[newIdx]).lowercased() == String(string[findIdx]).lowercased()) : (self[newIdx] == string[findIdx])) {
                    newIdx = self.index(after: newIdx)
                    findIdx = string.index(after: findIdx)
                }

                if findIdx == findEndIdx { // match
                    return idx..<newIdx
                }
            }
            idx = self.index(after: idx)
        }
        return nil
    }
}

