//
//  Phantich.swift
//  HieuLuat
//
//  Created by VietLH on 10/7/19.
//  Copyright © 2019 VietLH. All rights reserved.
//

import Foundation
import UIKit

class Phantich {
    private var idKey: String
    private var author: String
    private var title: String
    private var shortContent: String
    private var source: String
    private var sourceInapp: String
    private var revision: Int
    private var rawContentDetailed = [[String:String]]()
    
    init(idKey: String, author: String, title: String, shortContent: String, source: String, sourceInapp: String, revision: String, rawContentDetailed: [String:String]) {
        self.idKey = idKey
        self.author = author
        self.title = title
        self.shortContent = shortContent
        self.source = source
        self.sourceInapp = sourceInapp
        self.revision = Int(revision)!
        self.rawContentDetailed.append(rawContentDetailed)
    }
    
    //    init(idKey: String, author: String, title: String, shortContent: String, source: String, revision: String, rawContentDetailed: [String:String]) {
    //        self.idKey = idKey
    //        self.author = author
    //        self.title = title
    //        self.shortContent = shortContent
    //        self.source = source
    //        self.sourceInapp = ""
    //        self.revision = Int(revision)!
    //        self.rawContentDetailed.append(rawContentDetailed)
    //    }
    
    init(){
        self.idKey = ""
        self.author = ""
        self.title = ""
        self.shortContent = ""
        self.source = ""
        self.sourceInapp = ""
        self.revision = 0
    }
    
    func getIdKey() -> String {
        return idKey
    }
    func getAuthor() -> String {
        return author
    }
    func getTittle() -> String {
        return title
    }
    func getShortContent() -> String {
        return shortContent
    }
    func getSource() -> String {
        return source
    }
    func getSourceInapp() -> String {
        return sourceInapp
    }
    func getRevision() -> Int {
        return revision
    }
    func getContentDetails() -> [PhantichChitiet] {
        var contentDetailed = [PhantichChitiet]()
        for content in rawContentDetailed {
            let phantichChitiet = PhantichChitiet()
            if content["minhhoatype"] == "img" {
                phantichChitiet.initChitietWithImage(order: Int(content["contentorder"]!)!, noidung: content["content"]!, imgSrc: content["minhhoa"]!)
            }else{
                phantichChitiet.initChitietWithLink(order: Int(content["contentorder"]!)!, noidung: content["content"]!, linkUrl: content["minhhoa"]!)
            }
            contentDetailed.append(phantichChitiet)
        }
        return contentDetailed
    }
    func getRawContentDetailed() -> [[String:String]] {
        return rawContentDetailed
    }
    
    func updateRawContentDetailed(rawContentDetailed: [String:String]) {
        self.rawContentDetailed.append(rawContentDetailed)
    }
    
    class PhantichChitiet {
        var order = 0
        let wrapper : UIView
        var targetLink = URL(string: "")
        var imageLink = ""
        let redirectionHelper = RedirectionHelper()
        let lblNoidung = CustomizedLabel()
        
        init() {
            wrapper = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
            wrapper.translatesAutoresizingMaskIntoConstraints = false
            wrapper.clipsToBounds = true
            wrapper.autoresizesSubviews = true
            wrapper.isUserInteractionEnabled = true
            wrapper.contentMode = UIView.ContentMode.scaleAspectFit
            wrapper.autoresizesSubviews = true
            lblNoidung.numberOfLines = 0
            lblNoidung.lineBreakMode = NSLineBreakMode.byWordWrapping
            Utils.updateContentTextFont(label: lblNoidung)
        }
        
        func getOrder() -> Int {
            return order
        }
        
        func getWrapper() -> UIView {
            return wrapper
        }
        
        func initChitietWithImage(order: Int, noidung: String, imgSrc: String){
            self.order = order
            self.imageLink = imgSrc
            let minhhoaImg = WebImage()
            minhhoaImg.load(target: imgSrc)
            minhhoaImg.backgroundColor = UIColor.blue
            minhhoaImg.translatesAutoresizingMaskIntoConstraints = false
            minhhoaImg.clipsToBounds = true
            minhhoaImg.contentMode = UIView.ContentMode.scaleAspectFit
            minhhoaImg.autoresizesSubviews = true
            generateWrapper(noidung: noidung, minhhoa: minhhoaImg)
        }
        func initChitietWithLink(order: Int, noidung: String, linkUrl: String) {
            self.order = order
            let minhhoaLink = AutoScaleButton()
            minhhoaLink.titleLabel?.adjustsFontSizeToFitWidth = true
            minhhoaLink.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            minhhoaLink.titleLabel?.numberOfLines = 0
            minhhoaLink.setTitle(linkUrl, for: .normal)
            minhhoaLink.setTitleColor(UIColor.blue, for: .normal)
            minhhoaLink.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            minhhoaLink.addTarget(self, action: #selector(openLinkAction), for: .touchDown)
     
            targetLink = URL(string: linkUrl)
            minhhoaLink.layoutSubviews()
            if linkUrl.count > 0 {
                generateWrapper(noidung: noidung, minhhoa: minhhoaLink)
            }else{
                generateWrapper(noidung: noidung)
            }
            
        }
        
        @objc func openLinkAction() {
            redirectionHelper.openUrl(url: targetLink!)
        }
        
        private func generateWrapper(noidung: String)  {
            lblNoidung.text = noidung
            Utils.generateNewComponentConstraints(parent: wrapper, topComponent: wrapper, bottomComponent: wrapper, component: lblNoidung, top: 4, left: 4, right: 4, bottom: 0, isInside: true)
        }
        
        private func generateWrapper(noidung: String, minhhoa: UIView)  {
            lblNoidung.text = noidung
            Utils.generateNewComponentConstraints(parent: wrapper, topComponent: wrapper, component: lblNoidung, top: 4, left: 4, right: 4, isInside: true)
            Utils.generateNewComponentConstraints(parent: wrapper, topComponent: wrapper.subviews.last!, bottomComponent: wrapper, component: minhhoa, top: 2, left: 20, right: 20, bottom: 0, isInside: false)
        }
        
    }
    
}
