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
    @IBOutlet weak var viewTracuu: UIView!
    @IBOutlet var btnCamera: UIBarButtonItem!
    
    private var isDataLoaded = false
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AnalyticsHelper.sendAnalyticEvent(eventName: "app_open", params: [String:String]())
        GeneralSettings.getLastAppOpenTimestamp = Int(NSDate().timeIntervalSince1970)
        
        view.backgroundColor = AppColors.surfaceVariant
        
        lblVersion.font = AppTypography.caption
        lblVersion.textColor = AppColors.onSurfaceVariant
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !isDataLoaded {
            GeneralSettings.setVanbanInfo(vanbans: Queries.selectAllVanban())
            isDataLoaded = true
        }
        
        if checkIfNeedToUpdate() {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let updatePopup = storyBoard.instantiateViewController(withIdentifier: "updatePopup") as! UpdatePopupViewController
            self.present(updatePopup, animated: true, completion: nil)
        }
        if DataConnection.instance().lastErrorMessage().contains("no such table") {
            DataConnection.forceInitializeDatabase()
        }
        lblVersion.text = getVersion()
        
        // Modern card styling for viewTracuu
        viewTracuu.backgroundColor = AppColors.surface
        viewTracuu.layer.cornerRadius = AppRadius.lg
        AppShadow.light(for: viewTracuu.layer)
        viewTracuu.layer.borderWidth = 0
        
        // Style all buttons within the view hierarchy
        styleButtons(in: view)
        
        // Check and prompt for AI model download
        AIModelCoordinator.shared.checkAndPromptIfNeeded(from: self)
    }
    
    @IBAction func btnCameraAct(_ sender: Any) {
        let weQuayAppStoreLink = "https://apps.apple.com/us/app/wequay/id1470215783"
        RedirectionHelper().openUrl(url: URL(string: weQuayAppStoreLink)!)
    }
    
    func getVersion() -> String {
        let bundleCode: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
        let bundleVersion: AnyObject? = Bundle.main.infoDictionary!["CFBundleVersion"] as AnyObject
        let versionInfo = "v.\(bundleCode as! String)(\(bundleVersion as! String)) - db.\(DataConnection.getCurrentDBVersion())"
        return versionInfo
    }
    
    private func styleButtons(in parentView: UIView) {
        for subview in parentView.subviews {
            if let button = subview as? UIButton, let title = button.title(for: .normal) {
                if title == "Chúng tôi là ai?" {
                    button.applyModernStyle(.link)
                } else {
                    button.applyModernStyle(.primary)
                }
            }
            styleButtons(in: subview)
        }
    }
    
    func checkIfNeedToUpdate() -> Bool {
        if (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String).compare((GeneralSettings.minimumAppVersionRequired)) == .orderedAscending {
            return true
        }
        return false
    }
    
}

