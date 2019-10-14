//
//  InstructionTableViewCell.swift
//  HieuLuat
//
//  Created by VietLH on 10/9/19.
//  Copyright © 2019 VietLH. All rights reserved.
//

import UIKit

class InstructionTableViewCell: UITableViewCell {
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var constImageViewWidth: NSLayoutConstraint!
    @IBOutlet var lblAuthor: UILabel!
    @IBOutlet var lblTittle: UILabel!
    @IBOutlet var lblBreadscrubs: UILabel!
    @IBOutlet var lblNoidung: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updatePhantich(phantich: Phantich) {
        lblAuthor.text = phantich.getAuthor()
        lblTittle.text = phantich.getTittle()
        lblNoidung.text = phantich.getShortContent()
        lblBreadscrubs.text = ""
    }

}
