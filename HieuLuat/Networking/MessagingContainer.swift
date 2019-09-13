//
//  MessagingContainer.swift
//  HieuLuat
//
//  Created by VietLH on 9/12/19.
//  Copyright © 2019 VietLH. All rights reserved.
//

import Foundation

class MessagingContainer {
    enum MessageKey: String {
        case message = "message"
        case error = "error"
        case data = "data"
    }
    
    private var messages = [String:AnyObject]()
    
    func getAllKey() -> [String] {
        var keys = [String]()
        for k in messages.keys {
            keys.append(k)
        }
        return keys
    }
    
    func getValue(key:String) -> AnyObject {
        return messages[key] ?? "" as AnyObject
    }
    
    func setValue(key: String, value: AnyObject) {
        messages[key] = value
    }
    
    func appendValue(key: String, value: AnyObject) {
        if var string = messages[key] as? String   {
            string = "\(string) \n \(value)"
            messages[key] = string as AnyObject
            return
        }
        
        if var array = messages[key] as? [AnyObject]   {
            array.append(value)
            messages[key] = array as AnyObject
            return
        }
        
        setValue(key: key, value: value)
    }
    
}
