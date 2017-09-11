//
//  TT01DetailsViewController.swift
//  HieuLuat
//
//  Created by VietLH on 9/2/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit
import os.log

class VBPLDetailsViewController: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var lblVanban: UILabel!
    @IBOutlet weak var lblDieukhoan: UILabel!
    @IBOutlet weak var lblNoidung: UILabel!
    @IBOutlet weak var scvDetails: UIScrollView!
    @IBOutlet weak var svStackview: UIStackView!
    @IBOutlet weak var lblSeeMore: UIButton!
    @IBOutlet var consSvStackviewHeightBig: NSLayoutConstraint!
    @IBOutlet var consSvStackviewHeightSmall: NSLayoutConstraint!
    
    var children = [Dieukhoan]()
    var relatedChildren = [Dieukhoan]()
    var dieukhoan: Dieukhoan? = nil
    var search = SearchFor()
    var specificVanbanId = [String]()
    var images = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //            scvDetails.autoresizingMask = UIViewAutoresizing.flexibleHeight
        lblVanban.numberOfLines = 0
        lblVanban.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblDieukhoan.numberOfLines = 0
        lblDieukhoan.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblNoidung.numberOfLines = 0
        lblNoidung.lineBreakMode = NSLineBreakMode.byWordWrapping
        // Do any additional setup after loading the view.
        
        if(relatedChildren.count>0){
            lblSeeMore.isEnabled = true
        }else{
            lblSeeMore.isEnabled = false
        }
        showDieukhoan()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func updateDetails(dieukhoan: Dieukhoan) {
        self.dieukhoan = dieukhoan
        specificVanbanId.append( String(describing:dieukhoan.getVanban().getId()))
        let noidung = "\(String(describing: dieukhoan.getTieude())) \n \(String(describing: dieukhoan.getNoidung()))"
        
        for child in getChildren(keyword: String(describing: dieukhoan.id)) {
            children.append(child)
        }
        
        var keywords: [String] = []
        
        for k in getRelatedDirectKeywords(content: noidung) {
            var key = k.lowercased()
            if key.characters.count>0 {
                if key.contains("điều")||key.contains("chương")||key.contains("phần")||key.contains("mục")||key.contains("phụ lục") {
                    keywords.append(key)
                }else{
                    keywords.append(key.components(separatedBy: " ")[1])
                }
            }
        }
        
        for key in keywords {
            for child in getRelatedChildren(keyword: key) {
                let pattern = "^\\s*\(key.replacingOccurrences(of: ".", with: "\\."))\\.*\\s*$"
                if search.regexSearch(pattern: pattern, searchIn: child.getSo().lowercased()).count>0{
                    appendRelatedChild(child: child)
                }
            }
        }
        
        //  TODO: need to make this simpler
        
        for k in getRelatedPlatKeywords(content: noidung) {
            var key = k.lowercased()
            if key.characters.count>0 {
                keywords.append(key)
                for child in getRelatedChildren(keyword: key)
                {
                    let noidung = child.getTieude() + " "+child.getNoidung()
                    if getParent(keyword: getAncesters(dieukhoan: child).components(separatedBy: "-")[0])[0].getSo().lowercased().contains("phụ lục")&&(search.regexSearch(pattern: "^\\s*\(key.replacingOccurrences(of: ".", with: "\\."))\\s+", searchIn: noidung).count>0 || search.regexSearch(pattern: "\\s+\(key.replacingOccurrences(of: ".", with: "\\."))\\.*\\s+", searchIn: noidung).count>0 || search.regexSearch(pattern: "\\s+\(key.replacingOccurrences(of: ".", with: "\\."))\\.*$", searchIn: noidung).count>0) {
                        appendRelatedChild(child: child)
                    }
                }
            }
        }
        
        for child in getParent(keyword: String(describing: dieukhoan.cha)) {
            appendRelatedChild(child: child)
        }
        
    }
    
    func appendRelatedChild(child: Dieukhoan) {
        if child.id != self.dieukhoan?.id {
            var isExisted = false
            for c in relatedChildren {
                if c.getId() == child.getId(){
                    isExisted = true
                }
            }
            if !isExisted {
                relatedChildren.append(child)
            }
        }
    }
    
    func getAncesters(dieukhoan:Dieukhoan) -> String {
        var ancesters = ""
        if dieukhoan.getCha() == 0 {
            ancesters = "\(dieukhoan.getId())"
        }else{
            ancesters = "\(dieukhoan.getCha())"
            var parents = getParent(keyword: "\(dieukhoan.getCha())")
            while parents[0].getCha() != 0 {
                ancesters = "\(parents[0].getCha())-"+ancesters
                parents = getParent(keyword: "\(parents[0].getCha())")
            }
            
        }
        return ancesters
    }
    
    func hideMinhhoaStackview(isHidden: Bool)  {
        consSvStackviewHeightBig.constant = 0
        consSvStackviewHeightSmall.constant = 0
        if(isHidden){
            svStackview.isHidden = true
            consSvStackviewHeightBig.isActive = false
            consSvStackviewHeightSmall.isActive = true
        }else{
            svStackview.isHidden = false
            consSvStackviewHeightBig.isActive = true
            consSvStackviewHeightSmall.isActive = false
        }
    }
    
    func imageViewScaleup(frameWidth: Float,imageView:UIImageView) {
        
        let ratio:Float = Float(imageView.frame.width)/Float(imageView.frame.height)
        let newWidth:Float = frameWidth - 10
        let newHeight:Float = newWidth/ratio
        
        print("\(newWidth):\(+newHeight)")
        imageView.frame = CGRect(x: imageView.frame.minX, y: imageView.frame.minY, width: CGFloat(newWidth), height: CGFloat(newHeight))
    }
    
    
    func scaleImage(image: UIImage, targetWidth: CGFloat) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetWidth / image.size.width
        
        let ratio:Float = Float(size.width)/Float(size.height)
        
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        newSize = CGSize(width: size.width * widthRatio, height: CGFloat(Float(size.height) * (Float(ratio) * Float(widthRatio))))
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func getChildren(keyword:String) -> [Dieukhoan] {
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        return Queries.searchChildren(keyword: "\(keyword)", vanbanid: specificVanbanId)
    }
    
    func getParent(keyword:String) -> [Dieukhoan] {
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        return Queries.searchDieukhoanByID(keyword: "\(keyword)", vanbanid: specificVanbanId)
    }
    
    func getRelatedChildren(keyword:String) -> [Dieukhoan] {
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        return Queries.searchDieukhoan(keyword: "\(keyword)", vanbanid: specificVanbanId)
    }
    
    
    func getRelatedDirectKeywords(content:String) -> [String] {
        let input = content.lowercased()
        
        let pattern = "((điều|chương|phần)\\s\\d{1,3})|((mục|phụ\\slục)\\s([A-Z]|[a-z]){1,3})|(khoản\\s\\d{1,3}\\.\\d{1,3})|((điểm)\\s\\d{1,3}\\.\\d{1,3}\\.\\d{1,3})"
        
        return search.regexSearch(pattern: pattern, searchIn: input)
    }
    
    func getRelatedPlatKeywords(content:String) -> [String] {
        let input = content.lowercased()
        
        let pattern = "(([A-Z]|[a-z]){1,2}\\.\\d{1,4})|(vạch)\\s(\\d)+(\\.\\d)*"
        return search.regexSearch(pattern: pattern, searchIn: input)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "seeRelated":
            guard let dieukhoanSeemore = segue.destination as? VBPLDetailsSearchTableController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            dieukhoanSeemore.updateDieukhoanList(arrDieukhoan: relatedChildren)
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    func showDieukhoan() {
        lblVanban.text = dieukhoan!.getVanban().getMa()
        lblDieukhoan.text = dieukhoan!.getSo()
        let noidung = "\(String(describing: dieukhoan!.getTieude())) \n \(String(describing: dieukhoan!.getNoidung()))"
        lblNoidung.text = noidung
        
        images = dieukhoan!.getMinhhoa()
        
        if(children.count > 0 || images.count > 0){
            
            hideMinhhoaStackview(isHidden: false)
            
            for img in images {
                if (img.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "")).trimmingCharacters(in: .whitespacesAndNewlines).characters.count < 1{
                    
                }else{
                    let image = scaleImage(image:UIImage(named: (img.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "")).trimmingCharacters(in: .whitespacesAndNewlines))!,targetWidth: svStackview.frame.width)
                    
                    let imgView = UIImageView(image: image)
                    imgView.clipsToBounds = true
                    imgView.contentMode = UIViewContentMode.scaleAspectFit
                    
                    imageViewScaleup(frameWidth: Float(svStackview.frame.width), imageView: imgView)
                    
                    svStackview.addArrangedSubview(imgView)
                }
                for child in children {
//                    let lineView = UIView(frame: CGRect(x: 0, y: 0, width: svStackview.frame.width, height: 1))
////                    lineView.layer.borderWidth = 1.0
////                    lineView.layer.borderColor = UIColor.black!
//                    lineView.backgroundColor = UIColor.black
                    
                    let lblDK = UILabel()
                    lblDK.numberOfLines = 0
                    lblDK.lineBreakMode = NSLineBreakMode.byWordWrapping
                    lblDK.text = child.getSo()
                    lblDK.font = UIFont.boldSystemFont(ofSize: 14)
                    
                    let lblND = UILabel()
                    lblND.numberOfLines = 0
                    lblND.lineBreakMode = NSLineBreakMode.byWordWrapping
                    lblND.text = child.getTieude() + "\n " + child.getNoidung()
                    lblND.font = UIFont.systemFont(ofSize: 16)
                    
                    let space = UILabel()
                    space.numberOfLines = 0
                    space.lineBreakMode = NSLineBreakMode.byWordWrapping
                    space.text = "   "
                    
                    svStackview.addArrangedSubview(space)
                    svStackview.addArrangedSubview(lblDK)
                    svStackview.addArrangedSubview(lblND)
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(seeMore))
                    lblND.isUserInteractionEnabled = true
                    lblND.addGestureRecognizer(tap)
                }
            }
        }else{
            hideMinhhoaStackview(isHidden: true)
        }
        
    }
    
    func seeMore(sender: UITapGestureRecognizer) {
        print("it works")
    }
}
