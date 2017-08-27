//
//  QC41SeemoreTableviewCell.swift
//  HieuLuat
//
//  Created by VietLH on 8/27/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit

class QC41SeemoreTableviewCell: UITableViewCell{
    //MARK: Properties
    
    @IBOutlet weak var lblVanban: UILabel!
    @IBOutlet weak var lblDieukhoan: UILabel!
    @IBOutlet weak var lblNoidung: UILabel!
    @IBOutlet weak var sampleImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateDieukhoan(dieukhoan: Dieukhoan) {
        lblVanban.numberOfLines = 0
        lblVanban.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblDieukhoan.numberOfLines = 0
        lblDieukhoan.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblNoidung.numberOfLines = 0
        lblNoidung.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        lblVanban.text = dieukhoan.getVanban().getMa()
        lblDieukhoan.text = dieukhoan.getSo()
        var noidung = "\(dieukhoan.getTieude()) \n \(dieukhoan.getNoidung())"
        
        if(noidung.characters.count>150){
            noidung = noidung.substring(to: noidung.index(noidung.startIndex, offsetBy: 150))
            noidung.append("...")
        }
        lblNoidung.text = noidung
        sampleImageView.image = UIImage(named: (dieukhoan.getMinhhoa()[0].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ".png", with: "")).replacingOccurrences(of: "\n", with: ""))
    }
}
