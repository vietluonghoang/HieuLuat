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
    
    @IBOutlet weak var lblVanban: UILabel!
    @IBOutlet weak var lblDieukhoan: UILabel!
    @IBOutlet weak var lblNoidung: UILabel!
    @IBOutlet var lblParentBreadscrub: UILabel!
    
    @IBOutlet var consHeightLblVanban: NSLayoutConstraint!
    @IBOutlet var consWidthImageView: NSLayoutConstraint!
    
    @IBOutlet var consHeightImageView: NSLayoutConstraint!
    
    @IBOutlet var consWidthImageViewEmpty: NSLayoutConstraint!
    @IBOutlet weak var imgView: UIImageView!
    
    var search = SearchFor()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
   
    func updateDieukhoan(dieukhoan: Dieukhoan,fullDetails: Bool,showVanban: Bool, maxText: Int = 250, defaultImage: Int = 0) {
        if(!showVanban){
            lblVanban.isHidden = true
            lblParentBreadscrub.isHidden = true
            consHeightLblVanban.constant = 0
        }else{
            lblVanban.isHidden = false
            consHeightLblVanban.constant = 15
            lblParentBreadscrub.isHidden = false
            lblVanban.numberOfLines = 0
            lblVanban.lineBreakMode = NSLineBreakMode.byWordWrapping
            if #available(iOS 8.2, *) {
                lblVanban.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
            } else {
                // Fallback on earlier versions
            }
            lblVanban.textAlignment = NSTextAlignment.left
            lblParentBreadscrub.numberOfLines = 0
            lblParentBreadscrub.lineBreakMode = NSLineBreakMode.byWordWrapping
            if #available(iOS 8.2, *) {
                lblParentBreadscrub.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
            } else {
                // Fallback on earlier versions
            }
            lblParentBreadscrub.textAlignment = NSTextAlignment.right
        }
        lblDieukhoan.numberOfLines = 0
        lblDieukhoan.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblDieukhoan.font = UIFont.boldSystemFont(ofSize: 14)
        lblDieukhoan.textAlignment = NSTextAlignment.left
        lblNoidung.numberOfLines = 0
        lblNoidung.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblNoidung.font = UIFont.systemFont(ofSize: 16)
        lblNoidung.textAlignment = NSTextAlignment.left
        
        lblVanban.text = dieukhoan.getVanban().getMa()
        lblDieukhoan.text = dieukhoan.getSo()
        
        let breadscrub = search.getAncestersNumber(dieukhoan: dieukhoan, vanbanId: [String(dieukhoan.getVanban().getId())])
        lblParentBreadscrub.text = breadscrub
        var noidung = "\(dieukhoan.getTieude()) \n \(dieukhoan.getNoidung())"
        
        if(!fullDetails){
            if(noidung.count > maxText){
                noidung = noidung.substring(to: noidung.index(noidung.startIndex, offsetBy: maxText))
                noidung.append("...")
            }
        }
        lblNoidung.text = noidung
        
        if(dieukhoan.getMinhhoa()[0].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "").count>0){
            
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
}
