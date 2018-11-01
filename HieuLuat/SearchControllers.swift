//
//  SearchControllers.swift
//  HieuLuat
//
//  Created by VietLH on 10/30/18.
//  Copyright © 2018 VietLH. All rights reserved.
//

import Foundation

protocol SearchControllers : NSObjectProtocol{
    func updateFilter(key: String, value: Bool)
    func updateFilterLabel()
    func updateGroupsScrollView()
    func updateSearchResults()
    func isFilterSelected(key: String) -> Bool
}
