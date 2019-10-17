//
//  InstructionDetailsViewController.swift
//  HieuLuat
//
//  Created by VietLH on 10/9/19.
//  Copyright © 2019 VietLH. All rights reserved.
//

import UIKit
import GoogleMobileAds

class InstructionDetailsViewController: UIViewController, TJPlacementDelegate {
    @IBOutlet var viewBottom: UIView!
    @IBOutlet var scrViewContent: UIScrollView!
    @IBOutlet var viewTop: UIView!
    @IBOutlet var viewSource: UIView!
    @IBOutlet var btnSource: UIButton!
    @IBOutlet var lblSource: UILabel!
    @IBOutlet var viewTitle: UIView!
    @IBOutlet var lblTittle: UILabel!
    @IBOutlet var viewAuthor: UIView!
    @IBOutlet var lblAuthor: UILabel!
    @IBOutlet var lblAuthorName: UILabel!
    @IBOutlet var viewContent: UIView!
    
    var phantich = Phantich()
    var redirectionHelper = RedirectionHelper()
    var bannerView: GADBannerView!
    let btnFBBanner = UIButton()
    var placement = TJPlacement()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if !AdsHelper.isConnectedToNetwork() {
            viewSource.isHidden = true
            viewAuthor.isHidden = true
            lblTittle.text = "Lỗi kết nối mạng!\nHãy kiểm tra lại kết nối và thử mở lại màn hình này!"
        }else{
            initAds()
            showPhantich()
        }
    }
    
    func updateDetails(phantich: Phantich) {
        self.phantich = phantich
    }
    
    func initAds() {
        placement = AdsHelper.initTJPlacement(name: "WeThoongPlacement", delegate: self)
        placement.requestContent()
        
        //Initialize Google Admob
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        btnFBBanner.addTarget(self, action: #selector(btnFouderFBAction), for: .touchDown)
        AdsHelper.initBannerAds(btnFBBanner: btnFBBanner, bannerView: bannerView, toView: viewBottom, root: self)
    }
    
    @objc func btnFouderFBAction() {
        redirectionHelper.openUrl(urls: GeneralSettings.getFBLink)
    }
    
    @IBAction func btnSourceAct(_ sender: Any) {
        /*
         wethoong: fb://profile/224587561051762
         Congdonghieuluat: fb://profile/2262780957320858
         post:1299801006863740
         */
        if phantich.getSourceInapp().count > 0 {
            redirectionHelper.openUrl(urls: [URL(string: phantich.getSourceInapp())!,URL(string: phantich.getSource())!])
        }else{
        redirectionHelper.openUrl(url: URL(string: phantich.getSource())!)
        }
//        redirectionHelper.openUrl(url: URL(string: "fb://story?id=2368088400123446")!)
    }
    
    func addViewToContainer(parent: UIView, orderedList: [Int:UIView]) {
        //TODO: need a mechanic to reorder view in case the counter does not start from 0
        var order = 0
        while order < orderedList.count {
            let wrapper = orderedList[order]
            ////            Utils.generateNewComponentWidthConstraint(component: wrapper!, width: parent.frame.width)
            //            for subView in wrapper!.subviews {
            ////                Utils.generateNewComponentWidthConstraint(component: subView, width: parent.frame.width)
            //            }
            let topPadding = CGFloat(3)
            if order == 0 {
                if orderedList.count == 1 {
                    Utils.generateNewComponentConstraints(parent: parent, topComponent: parent, bottomComponent: parent, component: wrapper!, top: topPadding, left: 0, right: 0, bottom: 0, isInside: true)
                }else{
                    Utils.generateNewComponentConstraints(parent: parent, topComponent: parent, component: wrapper!, top: topPadding, left: 0, right: 0, isInside: true)
                }
            }else{
                if order < (orderedList.count - 1) {
                    Utils.generateNewComponentConstraints(parent: parent, topComponent: (parent.subviews.last)!, component: wrapper!, top: topPadding, left: 0, right: 0, isInside: false)
                }else{
                    Utils.generateNewComponentConstraints(parent: parent, topComponent: (parent.subviews.last)!, bottomComponent: parent, component: wrapper!, top: topPadding, left: 0, right: 0, bottom: 0, isInside: false)
                }
            }
            order += 1
        }
    }
    
    func showPhantich(){
        btnSource.setTitle(phantich.getSource(), for: .normal)
        lblTittle.text = phantich.getTittle()
        lblAuthorName.text = phantich.getAuthor()
        var orderedContent = [String:Phantich.PhantichChitiet]()
        for content in phantich.getContentDetails() {
            orderedContent["\(content.getOrder())"] = content
        }
        var order = 0
        var counter = 0
        var orderList = [Int:UIView]()
        while order < orderedContent.count {
            if let chitiet = orderedContent["\(counter)"] {
                let wrapper = chitiet.getWrapper()
                orderList[order] = wrapper
                order += 1
            }
            counter += 1
        }
        viewContent.translatesAutoresizingMaskIntoConstraints = false
        addViewToContainer(parent: viewContent, orderedList: orderList)
    }
    //TODO: implement content
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    //Tapjoy Ads delegate
    // Called when the SDK has made contact with Tapjoy's servers. It does not necessarily mean that any content is available.
    func requestDidSucceed(_ placement: TJPlacement){
        print("Request to TJ server successfully made")
    }
    
    // Called when there was a problem during connecting Tapjoy servers.
    func requestDidFail(_ placement: TJPlacement!, error: Error!) {
        print("Request to TJ server failed to make")
    }
    
    // Called when the content is actually available to display.
    func contentIsReady(_ placement: TJPlacement!) {
        print("Tj ads content is ready")
        if AdsHelper.isValidToShowIntestitialAds() {
            //log the timestamp of showing Interstitial ads
            GeneralSettings.getLastInterstitialAdsOpenTimestamp = Int(NSDate().timeIntervalSince1970)
            //log the number of time the the ads was shown during the day
            GeneralSettings.getInterstitialAdsOpenTimes += 1
            
            //show the ad
            placement.showContent(with: self)
        }
    }
    
    // Called when the content is showed.
    func contentDidAppear(_ placement: TJPlacement!) {
        print("Tj ads content showing")
    }
    
    // Called when the content is dismissed.
    func contentDidDisappear(_ placement: TJPlacement!) {
        print("Tj ads content went away")
    }
}
