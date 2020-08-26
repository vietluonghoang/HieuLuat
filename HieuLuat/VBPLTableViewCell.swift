//
//  VBPLTableViewCell.swift
//  HieuLuat
//
//  Created by VietLH on 9/5/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit

class VBPLTableViewCell: UITableViewCell{
    //MARK: Properties
    
    @IBOutlet weak var lblVanban: CustomizedLabel!
    @IBOutlet weak var lblDieukhoan: CustomizedLabel!
    @IBOutlet weak var lblNoidung: CustomizedLabel!
    @IBOutlet var lblParentBreadscrub: CustomizedLabel!
    
    @IBOutlet var consHeightLblVanban: NSLayoutConstraint!
    @IBOutlet var consWidthImageView: NSLayoutConstraint!
    
    @IBOutlet var consHeightImageView: NSLayoutConstraint!
    
    @IBOutlet var consWidthImageViewEmpty: NSLayoutConstraint!
    @IBOutlet weak var imgView: UIImageView!
    
    private var search = SearchFor()
    private var keyword = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateDieukhoan(dieukhoan: Dieukhoan,fullDetails: Bool,showVanban: Bool, maxText: Int = 250, defaultImage: Int = 0) {
        polulateContent(dieukhoan: dieukhoan, fullDetails: fullDetails, showVanban: showVanban, maxText: maxText, defaultImage: defaultImage)
    }
    
    func updateDieukhoan(dieukhoan: Dieukhoan,fullDetails: Bool,showVanban: Bool, maxText: Int = 250, defaultImage: Int = 0, keywork: String) {
        self.keyword = keywork
        polulateContent(dieukhoan: dieukhoan, fullDetails: fullDetails, showVanban: showVanban, maxText: maxText, defaultImage: defaultImage)
    }
    
    private func polulateContent(dieukhoan: Dieukhoan,fullDetails: Bool,showVanban: Bool, maxText: Int, defaultImage: Int){
        if(!showVanban){
            lblVanban.isHidden = true
            lblParentBreadscrub.isHidden = true
            consHeightLblVanban.constant = 0
        }else{
            lblVanban.isHidden = false
            consHeightLblVanban.constant = 15
            lblParentBreadscrub.isHidden = false
            lblVanban.setLightCaptionLabel()
            lblParentBreadscrub.setRegularCaptionLabelRightAligned()
        }
        lblDieukhoan.setBoldCaptionLabel()
        lblNoidung.setNormalCaptionLabel()
        
        //TO DO: Currently, dieukhoan owns Vanban but with limited vanban's data. To get tenRutgon of Vanban, we have to use vanbanInfo, which owns by GeneralSettings. To fix this problem completely, we have to change the rawQuery in Queries. We'll do it later
        lblVanban.text = "\(GeneralSettings.getVanbanInfo(id: dieukhoan.getVanban().getId(), info: "shortname"))"
        lblDieukhoan.text = dieukhoan.getSo()
        
        let breadscrub = search.getAncestersNumber(dieukhoan: dieukhoan, vanbanId: [String(dieukhoan.getVanban().getId())])
        lblParentBreadscrub.text = breadscrub
        var noidung = dieukhoan.getTieude().count > 0 ?"\(dieukhoan.getTieude()) \n \(dieukhoan.getNoidung())":"\(dieukhoan.getNoidung())"
        
        if(!fullDetails){
            if(noidung.count > maxText){
                let matchingNoidung = populateMatchingKeyword(noidung: noidung)
                if matchingNoidung.count > maxText {
                    noidung = Utils.removeLastCharacters(result: matchingNoidung, length: matchingNoidung.count - maxText)
                    noidung.append("...")
                }else{
                    noidung = matchingNoidung
                }
            }
        }
        lblNoidung.text = noidung
        
        if(dieukhoan.getMinhhoa().count > 0){
            
            //check if dieukhoan gets default minhhoa set internally. By default, minhhoa will be shown with the default value set internally (through .getDefaultMinhhoa). In the case if defaultImage is set (not equal to 0), then the value of defaultImage will overwrites the internal default minhhoa value (defaultImage will be the one to show).
            var dftImg = dieukhoan.getDefaultMinhhoa()
            if dieukhoan.getDefaultMinhhoa() != dftImg && defaultImage != 0 {
                dftImg = defaultImage
            }
            let image = UIImage(named: (dieukhoan.getMinhhoa()[dftImg].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ".png", with: "")).replacingOccurrences(of: "\n", with: ""))!
            imgView.image = image
            consWidthImageViewEmpty.isActive = false
            consWidthImageView.isActive = true
        }else{
            consWidthImageView.isActive = false
            consWidthImageViewEmpty.isActive = true
        }
    }
    
    private func populateMatchingKeyword(noidung: String) -> String{
        if keyword.count > 0 {
            let slicedKeyword = keyword.split(separator: " ")
            var matchingLength = slicedKeyword.count
            
            while matchingLength > 0 {
                let chunks = stride(from: 0, to: slicedKeyword.count, by: matchingLength).map {
                    Array(slicedKeyword[$0..<min($0 + matchingLength, slicedKeyword.count)])
                }
                let matchingKeyword = chunks[0].joined(separator: " ")
                
                if noidung.lowercased().contains(matchingKeyword.lowercased()) {
                    let slicedNoidung = noidung.lowercased().replacingOccurrences(of: matchingKeyword.lowercased(), with: "|").split(separator: "|")
                    if slicedNoidung.count > 1 {
                        let truncatedNoidung = Utils.removeFirstCharacters(result: noidung, length: slicedNoidung[0].count)
                        return "...\(truncatedNoidung)"
                    }else {
                        return noidung
                    }
                }
                matchingLength -= 1
            }
        }
        return noidung
    }
}
