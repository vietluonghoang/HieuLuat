//
//  ViewController.swift
//  HieuLuat
//
//  Created by VietLH on 8/26/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var lblVersion: UILabel!
    @IBOutlet var lblData: UILabel!
    
    let network = NetworkHandler()
    var appConfiguration = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        sendAnalytics() //send analytics for tracking user usage
        getAppConfiguration()
        RunLoop.current.run(until: Date(timeIntervalSinceNow : 2.0)) //delay 2 seconds to view splash screen longer
        lblVersion.text = getVersion()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateConfig()
        var text = ""
        
        for key in appConfiguration.keys {
            text += "\(appConfiguration[key]!) \n"
        }
        lblData.text = text
        
        if checkIfNeedToUpdate() {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let updatePopup = storyBoard.instantiateViewController(withIdentifier: "updatePopup") as! UpdatePopupViewController
            self.present(updatePopup, animated: true, completion: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getVersion() -> String {
        let bundleCode: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
        let bundleVersion: AnyObject? = Bundle.main.infoDictionary!["CFBundleVersion"] as AnyObject
        let versionInfo = "v.\(bundleCode as! String)(\(bundleVersion as! String)) - db.\(GeneralSettings.getDatabaseVersion)"
        return versionInfo
    }
    
    func sendAnalytics() {
        let target = "https://wethoong-server.herokuapp.com/analytics"
        var rawData = DeviceInfoCollector().getDeviceInfo()
        rawData["action"] = "app_open"
        rawData["actiontype"] = ""
        rawData["actionvalue"] = ""
        
        let data = try! JSONSerialization.data(withJSONObject: rawData, options: [])
        network.sendData(url: target, method: NetworkHandler.HttpMethod.post.rawValue, contentType: NetworkHandler.HttpContentType.applicationjson.rawValue,data: data)
    }
    
    func getAppConfiguration() {
        let target = "https://wethoong-server.herokuapp.com/getconfig"
        let mimeType = "application/json"
        network.requestData(url: target, mimeType: mimeType)
    }
    
    func updateConfig() {
        let result = network.getMessage()
        if result.getValue(key: MessagingContainer.MessageKey.data.rawValue) is String   {
            print("Error getting data: \(result.getValue(key: MessagingContainer.MessageKey.message.rawValue) as! String)")
        }else{
            let rawData = result.getValue(key: MessagingContainer.MessageKey.data.rawValue)
            //                let configs = try JSONSerialization.data(withJSONObject: rawData, options: [])
            if let config = rawData as? [AnyObject]   {
                print("configs: \(config)")
                for conf in config{
                    let cf = conf as! Dictionary<String, String>
                    
                    switch cf["configname"]{
                    case AppConfiguration.Configuration.minimumappversion.rawValue:
                        appConfiguration[AppConfiguration.Configuration.minimumappversion.rawValue] = cf["configvalue"]
                    case AppConfiguration.Configuration.enableappnotification.rawValue:
                        appConfiguration[AppConfiguration.Configuration.enableappnotification.rawValue] = cf["configvalue"]
                    default:
                        print("not any defined config!")
                    }
                }
            }else{
                print("Actual type of raw data: \(type(of: rawData))")
            }
        }
    }
    
    func checkIfNeedToUpdate() -> Bool {
        if appConfiguration[AppConfiguration.Configuration.minimumappversion.rawValue] == nil {
            return false
        }
        if (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String).compare((appConfiguration[AppConfiguration.Configuration.minimumappversion.rawValue]!)) == .orderedAscending {
            return true
        }
        return false
    }
}

