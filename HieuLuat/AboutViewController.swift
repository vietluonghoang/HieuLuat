//
//  AboutViewController.swift
//  HieuLuat
//
//  Created by VietLH on 4/2/18.
//  Copyright © 2018 VietLH. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    let redirectionHelper = RedirectionHelper()
    
    @IBOutlet var btnFounderFB: UIButton!
    @IBOutlet var btnFounderE: UIButton!
    @IBOutlet var btnAdsOptout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Modern styling
        view.backgroundColor = AppColors.surfaceVariant
        btnFounderFB.setTitle((GeneralSettings.getFBLink[1]).absoluteString, for: .normal)
        btnFounderE.setTitle(GeneralSettings.getEmailAddress, for: .normal)
        // Style as plain link buttons (no border, no background)
        btnFounderFB.applyModernStyle(.link)
        btnFounderFB.contentHorizontalAlignment = .left
        btnFounderE.applyModernStyle(.link)
        btnFounderE.contentHorizontalAlignment = .left
        
        // Always hide ads opt-out button
        btnAdsOptout.isHidden = true
        
        AnalyticsHelper.sendAnalyticEvent(eventName: "open_screen", params: ["screen_name" : AnalyticsHelper.SCREEN_NAME_CHUNGTOI])
        AnalyticsHelper.sendAnalyticEventMixPanel(eventName: "screen_open", params: ["screen_name" : AnalyticsHelper.SCREEN_NAME_CHUNGTOI])
        
        setupAIAttributionLabel()
    }
    
    private func setupAIAttributionLabel() {
        let label = UILabel()
        label.text = "Tính năng AI sử dụng kiến trúc mô hình Gemma® của Google và được chuyển đổi bởi công cụ của ANEMLL (MIT License)."
        label.font = AppTypography.caption
        label.textColor = AppColors.onSurfaceVariant
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = AppColors.surfaceVariant
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        view.bringSubviewToFront(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppSpacing.md),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppSpacing.md),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -AppSpacing.sm)
        ])
    }
    
    @IBAction func btnFouderFBAction(_ sender: Any) {
        redirectionHelper.openUrl(urls: GeneralSettings.getFBLink)
    }
    
    
    @IBAction func btnFounderEAction(_ sender: Any) {
        let url = URL(string: "mailto:\(btnFounderE.titleLabel!.text!)")!
        redirectionHelper.openUrl(url: url)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
