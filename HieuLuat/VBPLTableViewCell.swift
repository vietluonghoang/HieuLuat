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
    private let matchingPrefixThreshold = 10
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Card appearance
        backgroundColor = .clear
        contentView.backgroundColor = AppColors.surface
        contentView.layer.cornerRadius = AppRadius.md
        contentView.clipsToBounds = true
        
        // Lower image height priority so it doesn't conflict with cell sizing
        consHeightImageView?.priority = .defaultHigh
        
        // Add inner padding so text doesn't sit flush against rounded corners.
        // Storyboard constraints use tiny constants (0-2pt) to pin subviews to
        // contentView edges. We bump them to AppSpacing.sm (8pt) for breathing room.
        let pad = AppSpacing.sm  // 8pt
        for constraint in contentView.constraints {
            guard let first = constraint.firstItem as? UIView,
                  let second = constraint.secondItem as? UIView else { continue }
            
            let involvesContentView = (first === contentView || second === contentView)
            guard involvesContentView else { continue }
            
            let attr1 = constraint.firstAttribute
            let attr2 = constraint.secondAttribute
            let edges: Set<NSLayoutConstraint.Attribute> = [.top, .bottom, .leading, .trailing, .left, .right]
            guard edges.contains(attr1) && edges.contains(attr2) else { continue }
            
            // Only widen small gaps (0-4pt); leave already-large ones alone
            if abs(constraint.constant) <= 4 {
                if constraint.constant >= 0 {
                    constraint.constant = pad
                } else {
                    constraint.constant = -pad
                }
            }
        }
        
        // Image styling
        imgView?.layer.cornerRadius = AppRadius.sm
        imgView?.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        contentView.backgroundColor = selected ? AppColors.primaryContainer : AppColors.surface
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.contentView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.contentView.backgroundColor = highlighted ? AppColors.primaryContainer : AppColors.surface
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Outer margin between cells for card spacing
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(
            top: AppSpacing.xs,
            left: AppSpacing.md,
            bottom: AppSpacing.xs,
            right: AppSpacing.md
        ))
        // Shadow on the cell layer (outside clipsToBounds of contentView)
        let shadowPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: AppRadius.md)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.masksToBounds = false
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
                        var truncatedNoidung = ""
                        if slicedNoidung[0].count > matchingPrefixThreshold {
                            truncatedNoidung = "...\(Utils.removeFirstCharacters(result: noidung, length: slicedNoidung[0].count - matchingPrefixThreshold))"
                        } else {
                            truncatedNoidung = Utils.removeFirstCharacters(result: noidung, length: slicedNoidung[0].count)
                        }
                        return truncatedNoidung
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
