//
//  ViewController.swift
//  HieuLuat
//
//  Created by VietLH on 8/26/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit

class ViewController: UIViewController,TJPlacementDelegate {
    @IBOutlet var lblVersion: UILabel!
    @IBOutlet var btnCamera: UIBarButtonItem!
    
    let network = NetworkHandler()
    let networkCall = NetworkHandler()
    var appConfiguration = [String:String]()
    
    var networkCallTimer = Timer()
    let networkCallInterval = 10.0
    var retries = GeneralSettings.remainingConnectionTries
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        sendAnalytics() //send analytics for tracking user usage
        getAppConfiguration()
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        checkAdsOptout() //check ads optout state
        RunLoop.current.run(until: Date(timeIntervalSinceNow : 2.0)) //delay 2 seconds to view splash screen longer
        lblVersion.text = getVersion()
        GeneralSettings.getLastAppOpenTimestamp = Int(NSDate().timeIntervalSince1970)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateConfig()
        
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
    
    @IBAction func btnCameraAct(_ sender: Any) {
        let weQuayAppStoreLink = "https://apps.apple.com/us/app/wequay/id1470215783"
        RedirectionHelper().openUrl(url: URL(string: weQuayAppStoreLink)!)
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
                        GeneralSettings.minimumAppVersionRequired = cf["configvalue"]!
                    case AppConfiguration.Configuration.enableappnotification.rawValue:
                        GeneralSettings.isEnableInappNotif = (cf["configvalue"]! == "1")
                    case AppConfiguration.Configuration.enablebannerads.rawValue:
                        GeneralSettings.isEnableBannerAds = (cf["configvalue"]! == "1")
                    case AppConfiguration.Configuration.enableinterstitialads.rawValue:
                        GeneralSettings.isEnableInterstitialAds = (cf["configvalue"]! == "1")
                    case AppConfiguration.Configuration.minimumadsinterval.rawValue:
                        GeneralSettings.minimumAdsIntervalInSeconds = Int(cf["configvalue"]!)!
                        
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
        if (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String).compare((GeneralSettings.minimumAppVersionRequired)) == .orderedAscending {
            return true
        }
        return false
    }
    
    func checkAdsOptout() {
        let valueInDatabase = Queries.getAppConfigsFromDatabaseByKey(key: "adsOptout")
        switch valueInDatabase {
        case "1":
            print("adsoptout state set in database")
            GeneralSettings.isAdsOptout = true
        case "0":
            print("adsoptout state set in database")
            GeneralSettings.isAdsOptout = false
        default:
            print("send request to check adsoptout state")
            let target = "https://wethoong-server.herokuapp.com/hasoptout"
            let rawData = DeviceInfoCollector().getDeviceInfo()
            let data = try! JSONSerialization.data(withJSONObject: rawData, options: [])
            networkCall.sendData(url: target, method: NetworkHandler.HttpMethod.post.rawValue, contentType: NetworkHandler.HttpContentType.applicationjson.rawValue,data: data)
            networkCallTimer = Timer.scheduledTimer(timeInterval: TimeInterval(networkCallInterval), target: self, selector: #selector(checkCodeState), userInfo: nil, repeats: true)
        }
        
    }
    
    @objc func checkCodeState(){
        print("checking adsoptout state")
        let result = networkCall.getMessage()
        
        if let message = result.getValue(key: MessagingContainer.MessageKey.data.rawValue) as? Dictionary<String,String> {
            print("message: \(message)")
            networkCallTimer.invalidate()
            if message["status"] == "Success" {
                GeneralSettings.isAdsOptout = Queries.updateAppConfigsToDatabase(configList: ["adsOptout":"1"])
            }else{
                Queries.updateAppConfigsToDatabase(configList: ["adsOptout":"0"])
            }
        }
        if retries < 1 {
            networkCallTimer.invalidate()
        }else{
            retries -= 1
        }
    }
}

