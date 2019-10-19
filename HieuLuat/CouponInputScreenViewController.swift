//
//  CouponInputScreenViewController.swift
//  HieuLuat
//
//  Created by VietLH on 10/16/19.
//  Copyright © 2019 VietLH. All rights reserved.
//

import UIKit

class CouponInputScreenViewController: UIViewController {
    @IBOutlet var txtCode: UITextField!
    @IBOutlet var btnConfirm: UIButton!
    @IBOutlet var lblMessage: UILabel!
    
    let network = NetworkHandler()
    var updateCheckStatusTimer = Timer()
    var checkStatusInterval = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnConfirmAction(_ sender: Any) {
        submitCode()
        updateCheckStatusTimer = Timer.scheduledTimer(timeInterval: TimeInterval(checkStatusInterval), target: self, selector: #selector(checkCodeState), userInfo: nil, repeats: true)
        updateStatusMessage(state: 0)
        enableConfirmButton(enable: false)
    }
    
    @IBAction func txtCodeAct(_ sender: Any) {
        updateStatusMessage(state: 2)
    }
    
    func enableConfirmButton(enable: Bool){
        if enable {
            btnConfirm.isEnabled = true
        }else {
            btnConfirm.isEnabled = false
        }
    }
    
    func updateStatusMessage(state: Int) {
        switch state {
        case 0:
            lblMessage.text = "Đang xử lý...."
            lblMessage.textColor = UIColor.black
        case 1:
            lblMessage.text = "Mã được xác nhận thành công!"
            lblMessage.textColor = UIColor.blue
        case -1:
            lblMessage.text = "Mã không đúng. Hãy kiểm tra và thử lại sau!"
            lblMessage.textColor = UIColor.red
        default:
            lblMessage.text = ""
        }
    }
    
    func submitCode() {
        let target = "https://wethoong-server.herokuapp.com/redeemcoupon"
        var rawData = DeviceInfoCollector().getDeviceInfo()
        rawData["couponCode"] = txtCode.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let data = try! JSONSerialization.data(withJSONObject: rawData, options: [])
        network.sendData(url: target, method: NetworkHandler.HttpMethod.post.rawValue, contentType: NetworkHandler.HttpContentType.applicationjson.rawValue,data: data)
    }
    
    @objc func checkCodeState(){
        let result = network.getMessage()
        
        if let message = result.getValue(key: MessagingContainer.MessageKey.data.rawValue) as? Dictionary<String,String> {
            print("check code message: \(message)")
            updateCheckStatusTimer.invalidate()
            if message["status"] == "Success" {
                updateStatusMessage(state: 1)
                GeneralSettings.isAdsOptout = Queries.updateAppConfigsToDatabase(configList: ["adsOptout":"1"])
            }else{
                updateStatusMessage(state: -1)
            }
            enableConfirmButton(enable: true)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
