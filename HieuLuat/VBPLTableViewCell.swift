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
    
    @IBOutlet var consWidthImageView: NSLayoutConstraint!
    
    @IBOutlet var consHeightImageView: NSLayoutConstraint!
    
    @IBOutlet var consWidthImageViewEmpty: NSLayoutConstraint!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateDieukhoan(dieukhoan: Dieukhoan,fullDetails: Bool,showVanban: Bool) {
        if(!showVanban){
            lblVanban.isHidden = true
        }else{
            lblVanban.isHidden = false
            lblVanban.numberOfLines = 0
            lblVanban.lineBreakMode = NSLineBreakMode.byWordWrapping
            lblVanban.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
        }
        lblDieukhoan.numberOfLines = 0
        lblDieukhoan.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblDieukhoan.font = UIFont.boldSystemFont(ofSize: 14)
        lblNoidung.numberOfLines = 0
        lblNoidung.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblNoidung.font = UIFont.systemFont(ofSize: 16)
        
        lblVanban.text = dieukhoan.getVanban().getMa()
        lblDieukhoan.text = dieukhoan.getSo()
        var noidung = "\(dieukhoan.getTieude()) \n \(dieukhoan.getNoidung())"
        
        let maxText = 250
        if(!fullDetails){
            if(noidung.characters.count > maxText){
                noidung = noidung.substring(to: noidung.index(noidung.startIndex, offsetBy: maxText))
                noidung.append("...")
            }
        }
        lblNoidung.text = noidung
        
        if(dieukhoan.getMinhhoa()[0].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "").characters.count>0){
            let image = UIImage(named: (dieukhoan.getMinhhoa()[0].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ".png", with: "")).replacingOccurrences(of: "\n", with: ""))!
            imgView.image = image
            consWidthImageViewEmpty.isActive = false
            consWidthImageView.isActive = true
        }else{
            consWidthImageView.isActive = false
            consWidthImageViewEmpty.isActive = true
        }
        
        
    }
}
