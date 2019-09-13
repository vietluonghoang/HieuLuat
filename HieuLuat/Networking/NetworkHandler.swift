//
//  NetworkHandler.swift
//  HieuLuat
//
//  Created by VietLH on 9/12/19.
//  Copyright © 2019 VietLH. All rights reserved.
//

import Foundation

class NetworkHandler {
    var msg = MessagingContainer()
    
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    enum HttpContentType: String {
        case applicationjson = "application/json"
        case xwwwformurlencoded = "application/x-www-form-urlencoded"
    }
    
    enum HttpMimeType: String {
        case applicationjson = "application/json"
    }
    
    let session = URLSession.shared
    
    func getMessage() -> MessagingContainer {
        return msg
    }
    func targetURL(url:String) -> URL {
        return URL(string: url)!
    }
    
    func requestURL(url:String) -> URLRequest {
        return URLRequest(url: targetURL(url: url))
    }
    
    func configureRequestURL( request: inout URLRequest,method:String,contentType:String) -> URLRequest {
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpMethod = method
        return request
    }
    func configureRequestURL( url:  String,method:String,contentType:String, data: Data) -> URLRequest {
        var request = URLRequest(url: targetURL(url: url))
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpMethod = method
        request.httpBody = data
        return request
    }
    
    func requestData(url:String,mimeType:String) {
        
        let task = session.dataTask(with: targetURL(url: url)) { data, response, error in
            if error != nil || data == nil {
                self.msg.setValue(key: MessagingContainer.MessageKey.error.rawValue, value:  error as AnyObject)
                self.msg.setValue(key: MessagingContainer.MessageKey.message.rawValue, value: "Error or nil data" as AnyObject)
                return
            }
            
            guard let res = response as? HTTPURLResponse, (200...299).contains(res.statusCode) else {
                self.msg.setValue(key: MessagingContainer.MessageKey.error.rawValue, value:  response as AnyObject)
                self.msg.setValue(key: MessagingContainer.MessageKey.message.rawValue, value: "Response error" as AnyObject)
                return
            }
            
            guard let mime = res.mimeType, mime == mimeType else {
                self.msg.setValue(key: MessagingContainer.MessageKey.error.rawValue, value:  response as AnyObject)
                self.msg.setValue(key: MessagingContainer.MessageKey.message.rawValue, value: "Wrong MIME type!" as AnyObject)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                print("json: \(json)")
                self.msg.setValue(key: MessagingContainer.MessageKey.message.rawValue, value: "Success" as AnyObject)
                self.msg.setValue(key: MessagingContainer.MessageKey.data.rawValue, value: json as AnyObject)
            } catch {
                self.msg.setValue(key: MessagingContainer.MessageKey.error.rawValue, value:  error as AnyObject)
                self.msg.setValue(key: MessagingContainer.MessageKey.message.rawValue, value: "JSON error" as AnyObject)
            }
        }
        task.resume()
    }
    
    func sendData(url:String, method:String,contentType:String,data:Data) {
        let task = session.dataTask(with: configureRequestURL(url: url, method: method, contentType: contentType, data: data)) { data, response, error in
            
            if error != nil || data == nil {
                self.msg.setValue(key: MessagingContainer.MessageKey.error.rawValue, value:  error as AnyObject)
                self.msg.setValue(key: MessagingContainer.MessageKey.message.rawValue, value: "Error or nil data" as AnyObject)
                return
            }
            
            guard let res = response as? HTTPURLResponse, (200...299).contains(res.statusCode) else {
                self.msg.setValue(key: MessagingContainer.MessageKey.error.rawValue, value:  response as AnyObject)
                self.msg.setValue(key: MessagingContainer.MessageKey.message.rawValue, value: "Response error" as AnyObject)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                self.msg.setValue(key: MessagingContainer.MessageKey.message.rawValue, value: "Success" as AnyObject)
                self.msg.setValue(key: MessagingContainer.MessageKey.data.rawValue, value: json as AnyObject)
            } catch {
                self.msg.setValue(key: MessagingContainer.MessageKey.error.rawValue, value:  error as AnyObject)
                self.msg.setValue(key: MessagingContainer.MessageKey.message.rawValue, value: "JSON error" as AnyObject)
            }
        }
        
        task.resume()
    }
}
