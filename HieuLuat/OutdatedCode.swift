//
//  OutdatedCode.swift
//  HieuLuat
//
//  Created by VietLH on 12/21/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import Foundation
import UIKit

class OutdatedCode {
    
// From: VBPLDetailsViewController.swift
//==========================================
    func imageViewScaleup(frameWidth: Float,imageView:UIImageView) {
        
        //        let ratio:Float = Float(imageView.frame.width)/Float(imageView.frame.height)
        let newWidth:Float = frameWidth - 10
        let newHeight:Float = (newWidth / Float(imageView.frame.width))*Float(imageView.frame.height)
        
        print("\(newWidth):\(+newHeight)")
        imageView.frame = CGRect(x: imageView.frame.minX, y: imageView.frame.minY, width: CGFloat(newWidth), height: CGFloat(newHeight))
    }
    
    
    func getScreenWidth() -> CGFloat {
        if UIDevice.current.orientation == UIDeviceOrientation.portrait || UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown {
            return UIScreen.main.bounds.width
        }
        return UIScreen.main.bounds.height
    }
    
    func scaleImage(image: UIImage, targetWidth: CGFloat) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetWidth / image.size.width
        
        //        let ratio:Float = Float(size.width)/Float(size.height)
        
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        newSize = CGSize(width: size.width * widthRatio, height: CGFloat(Float(size.height) * Float(widthRatio)))
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    //this function is not good-implemented since the performance is quite bad. should take a look on this again to find a better solution
    func parseRelatedDieukhoanKeywords(keyword:String) -> [Dieukhoan] {
//        let key = keyword.lowercased()
//        var relatedDieukhoan = [Dieukhoan]()
//        let sortIt = SortUtil()
//        
//        
//        var pattern = "^((điều)|(khoản)|(điểm)|(chương)|(mục)|(phần)|(phụ lục))(\\s)+(((\\d)|(\\w))+(\\.)*)+$"
//        if search.regexSearch(pattern: pattern, searchIn: key).count > 0 {
//            for d in Queries.searchDieukhoanBySo(keyword: key, vanbanid: specificVanbanId) {
//                relatedDieukhoan.append(d)
//            }
//        }else{
//            var dieu: Dieukhoan? = nil
//            
//            pattern = "(điều)(\\s)+(((\\d)|(\\w))+(\\.)*)+$"
//            for d in search.regexSearch(pattern: pattern, searchIn: key){
//                if d == "điều này" {
//                    dieu = search.getDieunay(currentDieukhoan: dieukhoan!, vanbanId: specificVanbanId)
//                }else{
//                    var rs = Queries.searchDieukhoanBySo(keyword: d, vanbanid: specificVanbanId)
//                    if rs.count > 0 {
//                        dieu = rs[0]
//                    }else{
//                        return sortIt.sortByBestMatch(listDieukhoan: relatedDieukhoan, keyword: key)
//                    }
//                }
//            }
//            pattern = "(((điểm)\\s((\\w)+(\\.)*)+(,)*(\\s)*)*((khoản)\\s((\\d)+(\\.)*)+)+)"
//            for kd in search.regexSearch(pattern: pattern, searchIn: key) {
//                pattern = "(khoản)(\\s)+(((\\d)|(\\w))+(\\.)*)+$"
//                for k in search.regexSearch(pattern: pattern, searchIn: kd) {
//                    var khoan = [Dieukhoan]()
//                    for childKhoan in getChildren(keyword: "\(String(describing: dieu!.getId()))") {
//                        if search.regexSearch(pattern: "^(\(k.components(separatedBy: " ")[1]))(\\.)*$", searchIn: childKhoan.getSo().lowercased()).count > 0 {
//                            khoan.append(childKhoan)
//                            break
//                        }
//                    }
//                    pattern = "(điểm)(\\s)+((\\w)+(\\.)*)+"
//                    let diem = search.regexSearch(pattern: pattern, searchIn: kd)
//                    if diem.count > 0 {
//                        for d in diem {
//                            for k in khoan {
//                                for dm in getChildren(keyword: "\(String(describing: k.getId()))") {
//                                    if search.regexSearch(pattern: "^(\(d.components(separatedBy: " ")[1]))(\\.)*$", searchIn: dm.getSo().lowercased()).count > 0 {
//                                        relatedDieukhoan.append(dm)
//                                        break
//                                    }
//                                }
//                            }
//                        }
//                    }else{
//                        for k in khoan {
//                            relatedDieukhoan.append(k)
//                        }
//                    }
//                }
//            }
//        }
//        return sortIt.sortByBestMatch(listDieukhoan: relatedDieukhoan, keyword: key)
        return [Dieukhoan]()
    }
    
    func showDieukhoan() {
//        lblVanban.text = dieukhoan!.getVanban().getMa()
//        lblDieukhoan.text = dieukhoan!.getSo()
//        let breadscrubText = search.getAncestersNumber(dieukhoan: dieukhoan!, vanbanId: [String(describing: dieukhoan!.getVanban().getId())])
//        if breadscrubText.characters.count > 0 {
//            btnParentBreadscrub.setTitle(breadscrubText, for: .normal)
//            btnParentBreadscrub.isEnabled = true
//        }else {
//            btnParentBreadscrub.setTitle("", for: .normal)
//            btnParentBreadscrub.isEnabled = false
//        }
//        
//        let noidung = "\(String(describing: dieukhoan!.getTieude())) \n \(String(describing: dieukhoan!.getNoidung()))"
//        lblNoidung.text = noidung
//        
//        images = dieukhoan!.getMinhhoa()
//        
//        if(images.count > 0){
//            
//            hideMinhhoaStackview(isHidden: false)
//            
//            for img in images {
//                if (img.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "")).trimmingCharacters(in: .whitespacesAndNewlines).characters.count < 1{
//                    
//                }else{
//                    //                    let image = scaleImage(image:UIImage(named: (img.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "")).trimmingCharacters(in: .whitespacesAndNewlines))!,targetWidth: svStackview.frame.width)
//                    let image = UIImage(named: (img.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "")).trimmingCharacters(in: .whitespacesAndNewlines))!
//                    
//                    let imgView = UIImageView(image: image)
//                    imgView.clipsToBounds = true
//                    imgView.contentMode = UIViewContentMode.scaleAspectFit
//                    
//                    //                    imageViewScaleup(frameWidth: Float(svStackview.frame.width), imageView: imgView)
//                    
//                    imgView.translatesAutoresizingMaskIntoConstraints = false
//                    svStackview.addArrangedSubview(imgView)
//                    svStackview.addConstraints(
//                        [
//                            NSLayoutConstraint(item: imgView,
//                                               attribute: .leading,
//                                               relatedBy: .equal,
//                                               toItem: svStackview,
//                                               attribute: .leading,
//                                               multiplier: 1,
//                                               constant: 0),
//                            NSLayoutConstraint(item: imgView,
//                                               attribute: .trailing,
//                                               relatedBy: .equal,
//                                               toItem: svStackview,
//                                               attribute: .trailing,
//                                               multiplier: 1,
//                                               constant: 0),
//                            //                            NSLayoutConstraint(item: imgView,
//                            //                                               attribute: .centerX,
//                            //                                               relatedBy: .equal,
//                            //                                               toItem: svStackview,
//                            //                                               attribute: .centerX,
//                            //                                               multiplier: 1,
//                            //                                               constant: 0)
//                        ])
//                    let tap = UITapGestureRecognizer(target: self, action: #selector(seeMore))
//                    imgView.isUserInteractionEnabled = true
//                    imgView.addGestureRecognizer(tap)
//                }
//                //                for child in children {
//                //                    let lineView = UIView(frame: CGRect(x: 0, y: 0, width: svStackview.frame.width, height: 1))
//                ////                    lineView.layer.borderWidth = 1.0
//                ////                    lineView.layer.borderColor = UIColor.black!
//                //                    lineView.backgroundColor = UIColor.black
//                
//                //                    let lblDK = UILabel()
//                //                    lblDK.numberOfLines = 0
//                //                    lblDK.lineBreakMode = NSLineBreakMode.byWordWrapping
//                //                    lblDK.text = child.getSo()
//                //                    lblDK.font = UIFont.boldSystemFont(ofSize: 14)
//                //
//                //                    let lblND = UILabel()
//                //                    lblND.numberOfLines = 0
//                //                    lblND.lineBreakMode = NSLineBreakMode.byWordWrapping
//                //                    lblND.text = child.getTieude() + "\n " + child.getNoidung()
//                //                    lblND.font = UIFont.systemFont(ofSize: 16)
//                //
//                //                    let space = UILabel()
//                //                    space.numberOfLines = 0
//                //                    space.lineBreakMode = NSLineBreakMode.byWordWrapping
//                //                    space.text = "   "
//                //
//                //                    svStackview.addArrangedSubview(space)
//                //                    svStackview.addArrangedSubview(lblDK)
//                //                    svStackview.addArrangedSubview(lblND)
//                //
//                //                                    let tap = UITapGestureRecognizer(target: self, action: #selector(seeMore))
//                //                                    lblND.isUserInteractionEnabled = true
//                //                                    lblND.addGestureRecognizer(tap)
//                //                }
//                
//                // Enable extra section for details of ND46
//                if String(describing:dieukhoan!.vanban.getId()) == settings.getND46ID() {
//                    hideExtraInfoView(isHidden: false)
//                    let mpText = getMucphat(id: String(describing: dieukhoan!.getId()))
//                    let ptText = getPhuongtien(id: String(describing: dieukhoan!.getId()))
//                    let lvText = getLinhvuc(id: String(describing: dieukhoan!.getId()))
//                    let dtText = getDoituong(id: String(describing: dieukhoan!.getId()))
//                    
//                    if mpText.characters.count > 0 {
//                        consLblMucphatHeight.isActive = false
//                        consLblMucphatDetailsHeight.isActive = false
//                        lblMucphat.text = mpText
//                    }else{
//                        consLblMucphatHeight.isActive = true
//                        consLblMucphatDetailsHeight.isActive = true
//                        consLblMucphatHeight.constant =  0
//                        consLblMucphatDetailsHeight.constant =  0
//                    }
//                    if ptText.characters.count > 0 {
//                        consLblPhuongtienHeight.isActive = false
//                        consLblPhuongtienDetailsHeight.isActive = false
//                        lblPhuongtien.text = ptText
//                    }else{
//                        consLblPhuongtienHeight.isActive = true
//                        consLblPhuongtienDetailsHeight.isActive = true
//                        consLblPhuongtienHeight.constant =  0
//                        consLblPhuongtienDetailsHeight.constant =  0
//                    }
//                    if lvText.characters.count > 0 {
//                        consLblLinhvucHeight.isActive = false
//                        consLblLinhvucDetailsHeight.isActive = false
//                        lblLinhvuc.text = lvText
//                    }else{
//                        consLblLinhvucHeight.isActive = true
//                        consLblLinhvucDetailsHeight.isActive = true
//                        consLblLinhvucHeight.constant =  0
//                        consLblLinhvucDetailsHeight.constant =  0
//                    }
//                    if dtText.characters.count > 0 {
//                        consLblDoituongHeight.isActive = false
//                        consLblDoituongDetailsHeight.isActive = false
//                        lblDoituong.text = dtText
//                    }else{
//                        consLblDoituongHeight.isActive = true
//                        consLblDoituongDetailsHeight.isActive = true
//                        consLblDoituongHeight.constant =  0
//                        consLblDoituongDetailsHeight.constant =  0
//                    }
//                }else{
//                    hideExtraInfoView(isHidden: true)
//                }
//            }
//        }else{
//            hideMinhhoaStackview(isHidden: true)
//        }
        
    }
    
    func updateDetails(dieukhoan: Dieukhoan) {
//        self.dieukhoan = dieukhoan
//        specificVanbanId.append( String(describing:dieukhoan.getVanban().getId()))
//        let noidung = "\(String(describing: dieukhoan.getTieude())) \n \(String(describing: dieukhoan.getNoidung()))"
//        
//        for child in getChildren(keyword: String(describing: dieukhoan.id)) {
//            children.append(child)
//        }
//        rowCount = children.count
//        
//        for child in getRelatedDieukhoan(noidung: noidung) {
//            relatedChildren.append(child)
//        }
//        let relatedPlate = getRelatedPlatKeywords(content: noidung)
//        
//        //this is a stupid way to take related ones out, but simpler to get it worked with less code
//        
//        var sortedRelatedPlat = [Dieukhoan]()
//        let sortIt = SortUtil()
//        for k in relatedPlate {
//            var key = k.lowercased()
//            if key.characters.count>0 {
//                let relatedChild = getRelatedChildren(keyword: key)
//                var order = 0
//                for child in sortIt.sortByBestMatch(listDieukhoan: relatedChild, keyword: key)
//                {
//                    if  getParent(keyword: search.getAncestersID(dieukhoan: child, vanbanId: specificVanbanId).components(separatedBy: "-")[0])[0].getSo().lowercased().contains("phụ lục"){
//                        //                        let noidungChild = child.getTieude() + " "+child.getNoidung()
//                        //                        let childContains = search.regexSearch(pattern: "((^|\\W)(\(key.replacingOccurrences(of: ".", with: "\\.")))(\\.)*($|\\W))|((^|\\W)(\(key.replacingOccurrences(of: ".", with: "\\.")))(\\.)*($|\\W))", searchIn: noidungChild).count>0
//                        //
//                        //                        if (childContains) {
//                        //                            appendRelatedChild(child: child)
//                        //                        }
//                        child.setSortPoint(sortPoint: Int16(order))
//                        sortedRelatedPlat.append(child)
//                        order += 1
//                    }
//                }
//            }
//        }
//        
//        for relatedPlateItem in sortIt.sortBySortPoint(listDieukhoan: sortedRelatedPlat,isAscending: true) {
//            appendRelatedChild(child: relatedPlateItem)
//        }
//        
//        for parent in getParent(keyword: String(describing: dieukhoan.cha)) {
//            parentDieukhoan = parent
//        }
        
    }
//=========================================
}
