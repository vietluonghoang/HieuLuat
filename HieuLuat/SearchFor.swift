//
//  SearchFor.swift
//  HieuLuat
//
//  Created by VietLH on 8/26/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import Foundation

class SearchFor {
    func regexSearch(pattern:String, searchIn:String) -> [String] {
        do {
            let input = searchIn.lowercased()
            
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
            let nsString = input as NSString
            
            return matches.map{ nsString.substring(with: $0.range)}
        } catch {
            print("Error with RegEx")
            return [""]
        }
    }
}
