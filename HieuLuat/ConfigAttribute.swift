//
//  ConfigAttribute.swift
//  HieuLuat
//
//  Created by VietLH on 9/6/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit

class ConfigAttribute {
    var name:String = ""
    var value:String = ""
    
    init(name: String, value: String) {
        self.setName(name: name)
        self.setValue(value: value)
    }
    
    func getName() -> String {
        return name
    }
    func getValue() -> String {
        return name
    }
    
    func setName(name:String) {
        self.name = String(describing: name.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func setValue(value:String) {
        self.value = String(describing: value.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
