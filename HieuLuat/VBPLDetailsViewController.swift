//
//  TT01DetailsViewController.swift
//  HieuLuat
//
//  Created by VietLH on 9/2/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit
import os.log
import GoogleMobileAds

class VBPLDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    //MARK: Properties
    
    @IBOutlet weak var lblVanban: UILabel!
    @IBOutlet weak var lblDieukhoan: UILabel!
    @IBOutlet weak var lblNoidung: UILabel!
    
    @IBOutlet var btnParentBreadscrub: UIButton!
    @IBOutlet weak var scvDetails: UIScrollView!
    @IBOutlet weak var svStackview: UIStackView!
    @IBOutlet weak var lblSeeMore: UIButton!
    @IBOutlet var viewExtraInfo: UIView!
    @IBOutlet var lblMucphat: UILabel!
    @IBOutlet var lblPhuongtien: UILabel!
    @IBOutlet var lblLinhvuc: UILabel!
    @IBOutlet var lblDoituong: UILabel!
    @IBOutlet var consSvStackviewHeightBig: NSLayoutConstraint!
    @IBOutlet var consSvStackviewHeightSmall: NSLayoutConstraint!
    @IBOutlet var consExtraViewHeight: NSLayoutConstraint!
    @IBOutlet var consLblMucphatHeight: NSLayoutConstraint!
    @IBOutlet var consLblPhuongtienHeight: NSLayoutConstraint!
    @IBOutlet var consLblLinhvucHeight: NSLayoutConstraint!
    @IBOutlet var consLblDoituongHeight: NSLayoutConstraint!
    @IBOutlet var consLblMucphatDetailsHeight: NSLayoutConstraint!
    @IBOutlet var consLblPhuongtienDetailsHeight: NSLayoutConstraint!
    @IBOutlet var consLblLinhvucDetailsHeight: NSLayoutConstraint!
    @IBOutlet var consLblDoituongDetailsHeight: NSLayoutConstraint!
    @IBOutlet var consLblSeeMoreHeight: NSLayoutConstraint!
    @IBOutlet var consViewMinhhoaHeight: NSLayoutConstraint!
    
    @IBOutlet var viewMinhhoa: UIView!
    @IBOutlet var tblView: UITableView!
    @IBOutlet var consHeightTblView: NSLayoutConstraint!
    @IBOutlet var viewAds: UIView!
    
    var children = [Dieukhoan]()
    var parentDieukhoan: Dieukhoan? = nil
    var relatedChildren = [Dieukhoan]()
    var dieukhoan: Dieukhoan? = nil
    var search = SearchFor()
    var specificVanbanId = [String]()
    var images = [String]()
    let searchController = UISearchController(searchResultsController: nil)
    var rowCount = 0
    var settings = GeneralSettings()
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //            scvDetails.autoresizingMask = UIViewAutoresizing.flexibleHeight
        
        tblView.delegate = self
        tblView.dataSource = self
        lblVanban.numberOfLines = 0
        lblVanban.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblDieukhoan.numberOfLines = 0
        lblDieukhoan.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblNoidung.numberOfLines = 0
        lblNoidung.lineBreakMode = NSLineBreakMode.byWordWrapping
        // Do any additional setup after loading the view.
        
        if(relatedChildren.count>0){
            lblSeeMore.isEnabled = true
            consLblSeeMoreHeight.constant = 50
        }else{
            lblSeeMore.isEnabled = false
            consLblSeeMoreHeight.constant = 0
        }
        showDieukhoan()
        
        tblView.reloadData()
        updateTableViewHeight()
        initAds()
        
        //        svStackview.contentMode = UIViewContentMode.scaleAspectFit
        //        print(svStackview.frame.size)
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
    func updateTableViewHeight() {
        consHeightTblView.constant = 50000
        tblView.reloadData()
        tblView.layoutIfNeeded()
        
        var tableHeight:CGFloat = 0
        for obj in tblView.visibleCells {
            if let cell = obj as? UITableViewCell {
                tableHeight += cell.bounds.height
            }
        }
        consHeightTblView.constant = tableHeight
        tblView.sizeToFit()
        tblView.layoutIfNeeded()
    }
    
    func initAds() {
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        AdsHelper.addBannerViewToView(bannerView: bannerView,toView: viewAds, root: self)
    }
    
    func updateDetails(dieukhoan: Dieukhoan) {
        self.dieukhoan = dieukhoan
        specificVanbanId.append( String(describing:dieukhoan.getVanban().getId()))
        let noidung = "\(String(describing: dieukhoan.getTieude())) \n \(String(describing: dieukhoan.getNoidung()))"
        
        for child in getChildren(keyword: String(describing: dieukhoan.id)) {
            children.append(child)
        }
        rowCount = children.count
        
        for child in getRelatedDieukhoan(noidung: noidung) {
            relatedChildren.append(child)
        }
        let relatedPlateKeywords = getRelatedPlatKeywords(content: noidung)
        var sortedRelatedPlat = [Dieukhoan]()
        let sortIt = SortUtil()
        
        for k in relatedPlateKeywords {
            var key = k.lowercased()
            var finalQuery = ""
            if key.characters.count > 0 {
                finalQuery = Queries.rawSqlQuery + " (dkCha in (select id from tblChitietvanban where forsearch like 'phụ lục%') or dkCha in (select id from tblchitietvanban where cha in (select id from tblChitietvanban where forsearch like 'phụ lục%')) or dkCha in (select id from tblchitietvanban where cha in (select id from tblchitietvanban where cha in (select id from tblChitietvanban where forsearch like 'phụ lục%')))) and forsearch like '% \(key) %'"
                let relatedChild = Queries.searchDieukhoanByQuery(query: finalQuery, vanbanid: ["\(settings.getQC41ID())"])
                sortedRelatedPlat.append(contentsOf: sortIt.sortByBestMatch(listDieukhoan: relatedChild, keyword: key))
            }
        }
        
        for relatedPlateItem in sortIt.sortBySortPoint(listDieukhoan: sortedRelatedPlat,isAscending: true) {
            appendRelatedChild(child: relatedPlateItem)
        }
        
        for parent in getParent(keyword: String(describing: dieukhoan.cha)) {
            parentDieukhoan = parent
        }
        
    }
    
    func appendRelatedChild(child: Dieukhoan) {
        if child.id != self.dieukhoan?.id {
            var isExisted = false
            for c in relatedChildren {
                if c.getId() == child.getId(){
                    isExisted = true
                    break
                }
            }
            if !isExisted {
                relatedChildren.append(child)
            }
        }
    }
    
    func hideMinhhoaStackview(isHidden: Bool)  {
        consSvStackviewHeightSmall.constant = 0
        if(isHidden){
            svStackview.isHidden = true
            consSvStackviewHeightSmall.isActive = true
        }else{
            svStackview.isHidden = false
            //            consSvStackviewHeightBig.isActive = true
            consSvStackviewHeightSmall.isActive = false
        }
    }
    
    func hideMinhhoaView(isHidden: Bool) {
        consViewMinhhoaHeight.constant = 0
        if isHidden {
            consViewMinhhoaHeight.isActive = true
        }else {
            consViewMinhhoaHeight.isActive = false
        }
    }
    
    func hideExtraInfoView(isHidden: Bool)  {
        if(isHidden){
            consExtraViewHeight.constant = 0
            consExtraViewHeight.isActive = true
            viewExtraInfo.isHidden = true
        }else{
            consExtraViewHeight.isActive = false
            viewExtraInfo.isHidden = false
        }
    }
    
    func getRelatedChildren(keyword:String) -> [Dieukhoan] {
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        return Queries.searchDieukhoan(keyword: "\(keyword)", vanbanid: specificVanbanId)
    }
    
    func getRelatedDieukhoan(noidung:String) -> [Dieukhoan] {
        var nd = noidung.lowercased()
        
        var relatedDieukhoan = [Dieukhoan]()
        
        var pattern = "((điểm\\s+(((\\p{L}{1})|(\\d\\.*)+)(,|;)*\\s+(và)*\\s*)+)*(khoản\\s+(((này)|(\\d\\.*)+)(,|;)*\\s*(và)*\\s*)+)+)*((điều\\s+(((này)|(\\d\\.*)+)(,|;)*\\s*(và)*\\s*)+)+)+(((của)|(tại)|(theo))*\\s*((luật)|(nghị định)|(quy chuẩn)|(thông tư))\\s*((này)|(giao thông đường bộ)|(xử lý vi phạm hành chính)))"
        let vanbanPattern = "(((của)|(tại)|(theo))*\\s*((luật)|(nghị định)|(quy chuẩn)|(thông tư))\\s*((này)|(giao thông đường bộ)|(xử lý vi phạm hành chính)))"
        
        let fullMatches = search.regexSearch(pattern: pattern, searchIn: nd)
        
        for fmatch in fullMatches {
            var keywords = [String]()
            for vbMatch in search.regexSearch(pattern: vanbanPattern, searchIn: fmatch) {
                if vbMatch.contains("này") {
                    specificVanbanId = [String(describing: dieukhoan!.getVanban().getId())]
                }
                if vbMatch.contains("luật giao thông") {
                    specificVanbanId = [settings.getLGTID()]
                }
                if vbMatch.contains("luật xử lý vi phạm hành chính") {
                    specificVanbanId = [settings.getLXLVPHCID()]
                }
                if vbMatch.contains("nghị định 46") {
                    specificVanbanId = [settings.getND46ID()]
                }
                if vbMatch.contains("thông tư 01") {
                    specificVanbanId = [settings.getTT01ID()]
                }
                if vbMatch.contains("quy chuẩn 41") {
                    specificVanbanId = [settings.getQC41ID()]
                }
            }
            
            nd = nd.replacingOccurrences(of: fmatch, with: "")
            
            pattern = "((điểm\\s+(((\\p{L}{1})|(\\d\\.*)+)(,|;)*\\s+(và)*\\s*)+)*(khoản\\s+(((này)|(\\d\\.*)+)(,|;)*\\s*(và)*\\s*)+)+)*((điều\\s+(((này)|(\\d\\.*)+)(,|;)*\\s*(và)*\\s*)+)+)+"
            
            let longMatches = search.regexSearch(pattern: pattern, searchIn: fmatch)
            
            for match in longMatches{
                if(!search.isStringExisted(str: match, strArr: keywords)){
                    keywords.append(match.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
            
            for key in keywords {
                let dk = parseRelatedDieukhoan(keyword: key)
                if dk.count > 0{
                    for dkh in dk {
                        relatedDieukhoan.append(dkh)
                    }
                }
            }
        }
        
        specificVanbanId = [String(describing: dieukhoan!.getVanban().getId())]
        
        pattern = "((điểm\\s+(((\\p{L}{1})|(\\d\\.*)+)(,|;)*\\s+(và)*\\s*)+)*(khoản\\s+(((này)|(\\d\\.*)+)(,|;)*\\s*(và)*\\s*)+)+)+((điều\\s+(((này)|(\\d\\.*)+)(,|;)*\\s*(và)*\\s*)+)+)+"
        
        let longMatches = search.regexSearch(pattern: pattern, searchIn: nd)
        
        for lmatch in longMatches{
            var keywords = [String]()
            nd = nd.replacingOccurrences(of: lmatch, with: "")
            
            if(!search.isStringExisted(str: lmatch, strArr: keywords)){
                if lmatch.contains("điều này") {
                    keywords.append(lmatch.replacingOccurrences(of: "điều này", with: search.getDieunay(currentDieukhoan: dieukhoan!, vanbanId: specificVanbanId).getSo()).trimmingCharacters(in: .whitespacesAndNewlines))
                }else{
                    keywords.append(lmatch.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
            for key in keywords {
                let dk = parseRelatedDieukhoan(keyword: key)
                if dk.count > 0{
                    for dkh in dk {
                        relatedDieukhoan.append(dkh)
                    }
                }
            }
        }
        
        pattern = "(điểm\\s+(((\\p{L}{1})|(\\d\\.*)+)(,|;)*\\s+(và)*\\s*)+)*(khoản\\s+(((này)|(\\d\\.*)+)(,|;)*\\s*(và)*\\s*)+)+"
        
        let shortMatches = search.regexSearch(pattern: pattern, searchIn: nd)
        
        for smatch in shortMatches{
            var keywords = [String]()
            nd = nd.replacingOccurrences(of: smatch, with: "")
            var key = smatch
            
            if(!search.isStringExisted(str: smatch, strArr: keywords)){
                if smatch.contains("điều này") {
                    key = key.replacingOccurrences(of: "điều này", with: search.getDieunay(currentDieukhoan: dieukhoan!, vanbanId: specificVanbanId).getSo()).trimmingCharacters(in: .whitespacesAndNewlines)
                }else{
                    key = key + " " + search.getDieunay(currentDieukhoan: dieukhoan!, vanbanId: specificVanbanId).getSo().trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                if smatch.contains("khoản này") {
                    key = key.replacingOccurrences(of: "khoản này", with: search.getKhoannay(currentDieukhoan: dieukhoan!, vanbanId: specificVanbanId).getSo()).trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                keywords.append(key.trimmingCharacters(in: .whitespacesAndNewlines))
                
            }
            for key in keywords {
                let dk = parseRelatedDieukhoan(keyword: key.lowercased())
                if dk.count > 0{
                    for dkh in dk {
                        relatedDieukhoan.append(dkh)
                    }
                }
            }
        }
        
        return relatedDieukhoan
    }
    
    func parseRelatedDieukhoan(keyword: String) -> [Dieukhoan] {
        let key = keyword.lowercased()
        var relatedDieukhoan = [Dieukhoan]()
        var finalQuery = ""
        
        var pattern = "(điều\\s+(((này)|(\\d\\.*)+)(,|;)*\\s*(và)*\\s*)+)+"
        
        let dieuMatches = search.regexSearch(pattern: pattern, searchIn: key)
        
        for dm in dieuMatches{
            var convertedDieu = dm.replacingOccurrences(of: " và", with: ",")
            convertedDieu = convertedDieu.replacingOccurrences(of: ";", with: ",")
            var dieu = [String]()
            var dieuQuery = ""
            var tempQuery = ""
            if search.regexSearch(pattern: "(\\d+,\\s*\\d+)+", searchIn: convertedDieu).count > 0 {
                convertedDieu = convertedDieu.replacingOccurrences(of: "điều", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                for eachDm in convertedDieu.components(separatedBy: ","){
                    if(!search.isStringExisted(str: eachDm, strArr: dieu) && eachDm.characters.count > 0){
                        dieu.append("điều "+eachDm.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
            }else{
                if(!search.isStringExisted(str: convertedDieu, strArr: dieu)){
                    convertedDieu = convertedDieu.replacingOccurrences(of: ",", with: "")
                    dieu.append(convertedDieu.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
            
            for d  in dieu {
                tempQuery += "forsearch like \"\(d) %\" or forsearch like \"\(d). %\" or "
            }
            
            dieuQuery = "select distinct id from tblChitietvanban where (\(tempQuery.substring(to: tempQuery.index(tempQuery.endIndex, offsetBy: -4)))) and vanbanid = \(specificVanbanId[0])"
            
            pattern = "(điểm\\s+(((\\p{L}{1})|(\\d\\.*)+)(,|;)*\\s+(và)*\\s*)+)*(khoản\\s+(((này)|(\\d\\.*)+)(,|;)*\\s*(và)*\\s*)+)+"
            
            let khoanMatches = search.regexSearch(pattern: pattern, searchIn: key)
            
            for km in khoanMatches{
                var query = ""
                var khoan = [String]()
                var convertedKhoan = km.replacingOccurrences(of: " và", with: ",")
                convertedKhoan = convertedKhoan.replacingOccurrences(of: ";", with: ",")
                pattern = "khoản\\s+((\\d+\\.*(,|;)*\\s*)+)"
                for matchKhoan in search.regexSearch(pattern: pattern, searchIn: convertedKhoan){
                    var mk = matchKhoan
                    if search.regexSearch(pattern: "(\\d+,\\s*\\d+)+", searchIn: mk).count > 0 {
                        mk = mk.replacingOccurrences(of: "khoản", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                        for eachKm in mk.components(separatedBy: ","){
                            if(!search.isStringExisted(str: eachKm, strArr: khoan) && eachKm.characters.count > 0){
                                khoan.append(eachKm.trimmingCharacters(in: .whitespacesAndNewlines))
                            }
                        }
                    }else{
                        if(!search.isStringExisted(str: matchKhoan, strArr: khoan)){
                            mk = mk.replacingOccurrences(of: ",", with: "")
                            khoan.append(mk.replacingOccurrences(of: "khoản", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                    }
                }
                tempQuery = ""
                for d in khoan {
                    tempQuery += "forsearch like \"\(d) %\" or forsearch like \"\(d). %\" or "
                }
                if khoan.count > 0 {
                    query = "select distinct id from tblChitietvanban where (\(tempQuery.substring(to: tempQuery.index(tempQuery.endIndex, offsetBy: -4)))) and cha in (\(dieuQuery))"
                }
                
                pattern = "điểm\\s+(((\\p{L}{1})|(\\d\\.*)+)(,|;)*\\s+(và)*\\s*)+"
                
                let diemMatches = search.regexSearch(pattern: pattern, searchIn: convertedKhoan)
                
                var diem = [String]()
                for d in diemMatches{
                    var convertedDiem = d.replacingOccurrences(of: " và", with: ",")
                    convertedDiem = convertedDiem.replacingOccurrences(of: ";", with: ",")
                    pattern = "điểm\\s+(((\\p{L}{1})|(\\d\\.*)+)(,|;)*\\s+(và)*\\s*)+"
                    for matchDiem in search.regexSearch(pattern: pattern, searchIn: convertedDiem) {
                        var md = matchDiem
                        md = md.replacingOccurrences(of: "điểm", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                        if search.regexSearch(pattern: "((((\\p{L}{1})|(\\d\\.*)+)(,\\s+)((\\p{L}{1})|(\\d\\.*)+))+", searchIn: md).count > 0 {
                            for eachD in md.components(separatedBy: ","){
                                if(!search.isStringExisted(str: eachD, strArr: diem) && eachD.characters.count > 0){
                                    diem.append(eachD.trimmingCharacters(in: .whitespacesAndNewlines))
                                }
                            }
                        }else{
                            if(!search.isStringExisted(str: md, strArr: diem)){
                                md = md.replacingOccurrences(of: ",", with: "")
                                diem.append(md.replacingOccurrences(of: "điểm", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
                            }
                        }
                    }
                    tempQuery = ""
                    for d in diem {
                        tempQuery += "forsearch like \"\(d) %\" or forsearch like \"\(d). %\" or "
                    }
                }
                if diem.count > 0{
                    query = "select distinct id from tblChitietvanban where (\(tempQuery.substring(to: tempQuery.index(tempQuery.endIndex, offsetBy: -4)))) and cha in (\(query))"
                }
                finalQuery += "dkid in (\(query)) or "
            }
            
            if finalQuery.characters.count < 1 {
                //in case no 'khoan' and 'diem' available, the query should be initialized (' or ' is added because it will be removed when initializing final query
                finalQuery = "dkid in (\(dieuQuery)) or "
            }
        }
        finalQuery = Queries.rawSqlQuery + " \(finalQuery.substring(to: finalQuery.index(finalQuery.endIndex, offsetBy: -4)))"
        
        relatedDieukhoan.append(contentsOf: Queries.searchDieukhoanByQuery(query: finalQuery, vanbanid: specificVanbanId))
        return relatedDieukhoan
    }
    
    func showDieukhoan() {
        lblVanban.text = dieukhoan!.getVanban().getMa()
        lblDieukhoan.text = dieukhoan!.getSo()
        let breadscrubText = search.getAncestersNumber(dieukhoan: dieukhoan!, vanbanId: [String(describing: dieukhoan!.getVanban().getId())])
        if breadscrubText.characters.count > 0 {
            btnParentBreadscrub.setTitle(breadscrubText, for: .normal)
            btnParentBreadscrub.isEnabled = true
        }else {
            btnParentBreadscrub.setTitle("", for: .normal)
            btnParentBreadscrub.isEnabled = false
        }
        
        let noidung = "\(String(describing: dieukhoan!.getTieude())) \n \(String(describing: dieukhoan!.getNoidung()))"
        lblNoidung.text = noidung
        
        images = dieukhoan!.getMinhhoa()
        
        if(images.count > 0){
            //            fillMinhhoaToStackview(images: images)
            //            viewMinhhoa.translatesAutoresizingMaskIntoConstraints = false
            //            viewMinhhoa.sizeToFit()
            //            viewMinhhoa.layoutSubviews()
            //            print("view Minh hoa: \(viewMinhhoa.frame.size.height)")
            fillMinhhoaToViewMinhhoa(images: images)
        }else{
            hideMinhhoaView(isHidden: true)
            //            hideMinhhoaStackview(isHidden: true)
        }
        
        // Enable extra section for details of ND46
        if String(describing:dieukhoan!.vanban.getId()) == settings.getND46ID() {
            hideExtraInfoView(isHidden: false)
            let mpText = getMucphat(id: String(describing: dieukhoan!.getId()))
            let ptText = getPhuongtien(id: String(describing: dieukhoan!.getId()))
            let lvText = getLinhvuc(id: String(describing: dieukhoan!.getId()))
            let dtText = getDoituong(id: String(describing: dieukhoan!.getId()))
            
            if mpText.characters.count > 0 {
                consLblMucphatHeight.isActive = false
                consLblMucphatDetailsHeight.isActive = false
                lblMucphat.text = mpText
            }else{
                consLblMucphatHeight.isActive = true
                consLblMucphatDetailsHeight.isActive = true
                consLblMucphatHeight.constant =  0
                consLblMucphatDetailsHeight.constant =  0
            }
            if ptText.characters.count > 0 {
                consLblPhuongtienHeight.isActive = false
                consLblPhuongtienDetailsHeight.isActive = false
                lblPhuongtien.text = ptText
            }else{
                consLblPhuongtienHeight.isActive = true
                consLblPhuongtienDetailsHeight.isActive = true
                consLblPhuongtienHeight.constant =  0
                consLblPhuongtienDetailsHeight.constant =  0
            }
            if lvText.characters.count > 0 {
                consLblLinhvucHeight.isActive = false
                consLblLinhvucDetailsHeight.isActive = false
                lblLinhvuc.text = lvText
            }else{
                consLblLinhvucHeight.isActive = true
                consLblLinhvucDetailsHeight.isActive = true
                consLblLinhvucHeight.constant =  0
                consLblLinhvucDetailsHeight.constant =  0
            }
            if dtText.characters.count > 0 {
                consLblDoituongHeight.isActive = false
                consLblDoituongDetailsHeight.isActive = false
                lblDoituong.text = dtText
            }else{
                consLblDoituongHeight.isActive = true
                consLblDoituongDetailsHeight.isActive = true
                consLblDoituongHeight.constant =  0
                consLblDoituongDetailsHeight.constant =  0
            }
        }else{
            hideExtraInfoView(isHidden: true)
        }
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
    
    func getRelatedPlatKeywords(content:String) -> [String] {
        let input = content.lowercased()
        
        let pattern = "(\\b(([a-zA-Z]{1,2})(\\.|,)+)+(\\d)+(\\.\\d)*([a-zA-Z])*\\b)|(\\b(vạch)(\\ssố)*\\s(\\d)+(\\.\\d)*(\\.)*\\b)"
        return search.regexSearch(pattern: pattern, searchIn: input)
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
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func getScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    func fillMinhhoaToViewMinhhoa(images: [String]) {
        hideMinhhoaView(isHidden: false)
        
        var order = 0
        var previousImageView = UIImageView()
        
        for img in images {
            if (img.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "")).trimmingCharacters(in: .whitespacesAndNewlines).characters.count < 1{
                
            }else{
                let image = UIImage(named: (img.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "")).trimmingCharacters(in: .whitespacesAndNewlines))!
                
                let imgView = UIImageView(image: scaleImage(image: image, targetWidth: getScreenWidth()))
                imgView.translatesAutoresizingMaskIntoConstraints = false
                imgView.clipsToBounds = true
                imgView.contentMode = UIViewContentMode.scaleAspectFit
                imgView.autoresizesSubviews = true
                viewMinhhoa.addSubview(imgView)
                if order == 0 {
                    if images.count == 1 {
                        viewMinhhoa.addConstraints(
                            [
                                NSLayoutConstraint(item: imgView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: viewMinhhoa,
                                                   attribute: .leading,
                                                   multiplier: 1,
                                                   constant: 0),
                                NSLayoutConstraint(item: imgView,
                                                   attribute: .trailing,
                                                   relatedBy: .equal,
                                                   toItem: viewMinhhoa,
                                                   attribute: .trailing,
                                                   multiplier: 1,
                                                   constant: 0),
                                NSLayoutConstraint(item: imgView,
                                                   attribute: .top,
                                                   relatedBy: .equal,
                                                   toItem: viewMinhhoa,
                                                   attribute: .top,
                                                   multiplier: 1,
                                                   constant: 0),
                                NSLayoutConstraint(item: imgView,
                                                   attribute: .bottom,
                                                   relatedBy: .equal,
                                                   toItem: viewMinhhoa,
                                                   attribute: .bottom,
                                                   multiplier: 1,
                                                   constant: 0)
                            ])
                    }else{
                        viewMinhhoa.addConstraints(
                            [
                                NSLayoutConstraint(item: imgView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: viewMinhhoa,
                                                   attribute: .leading,
                                                   multiplier: 1,
                                                   constant: 0),
                                NSLayoutConstraint(item: imgView,
                                                   attribute: .trailing,
                                                   relatedBy: .equal,
                                                   toItem: viewMinhhoa,
                                                   attribute: .trailing,
                                                   multiplier: 1,
                                                   constant: 0),
                                NSLayoutConstraint(item: imgView,
                                                   attribute: .top,
                                                   relatedBy: .equal,
                                                   toItem: viewMinhhoa,
                                                   attribute: .top,
                                                   multiplier: 1,
                                                   constant: 0)
                            ])
                    }
                }else{
                    if order < (images.count - 1) {
                        viewMinhhoa.addConstraints(
                            [
                                NSLayoutConstraint(item: imgView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: viewMinhhoa,
                                                   attribute: .leading,
                                                   multiplier: 1,
                                                   constant: 0),
                                NSLayoutConstraint(item: imgView,
                                                   attribute: .trailing,
                                                   relatedBy: .equal,
                                                   toItem: viewMinhhoa,
                                                   attribute: .trailing,
                                                   multiplier: 1,
                                                   constant: 0),
                                NSLayoutConstraint(item: imgView,
                                                   attribute: .top,
                                                   relatedBy: .equal,
                                                   toItem:previousImageView,
                                                   attribute: .bottom,
                                                   multiplier: 1,
                                                   constant: 0)
                            ])
                    }else{
                        viewMinhhoa.addConstraints(
                            [
                                NSLayoutConstraint(item: imgView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: viewMinhhoa,
                                                   attribute: .leading,
                                                   multiplier: 1,
                                                   constant: 0),
                                NSLayoutConstraint(item: imgView,
                                                   attribute: .trailing,
                                                   relatedBy: .equal,
                                                   toItem: viewMinhhoa,
                                                   attribute: .trailing,
                                                   multiplier: 1,
                                                   constant: 0),
                                NSLayoutConstraint(item: imgView,
                                                   attribute: .top,
                                                   relatedBy: .equal,
                                                   toItem: previousImageView,
                                                   attribute: .bottom,
                                                   multiplier: 1,
                                                   constant: 0),
                                NSLayoutConstraint(item: imgView,
                                                   attribute: .bottom,
                                                   relatedBy: .equal,
                                                   toItem: viewMinhhoa,
                                                   attribute: .bottom,
                                                   multiplier: 1,
                                                   constant: 0)
                            ])
                    }
                }
                previousImageView = imgView
                order += 1
                let tap = UITapGestureRecognizer(target: self, action: #selector(seeMore))
                imgView.isUserInteractionEnabled = true
                imgView.addGestureRecognizer(tap)
            }
        }
        print("image view: \(previousImageView.frame.size.height)")
    }
    //    func fillMinhhoaToStackview(images: [String]) {
    //        hideMinhhoaStackview(isHidden: false)
    //        for img in images {
    //            if (img.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "")).trimmingCharacters(in: .whitespacesAndNewlines).characters.count < 1{
    //
    //            }else{
    //                let image = UIImage(named: (img.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "")).trimmingCharacters(in: .whitespacesAndNewlines))!
    //
    //                let imgView = UIImageView(image: image)
    //
    //
    //                imgView.clipsToBounds = true
    //                imgView.contentMode = UIViewContentMode.scaleAspectFit
    //                imgView.autoresizesSubviews = true
    //                imgView.translatesAutoresizingMaskIntoConstraints = false
    //                svStackview.addArrangedSubview(imgView)
    //                svStackview.addConstraints(
    //                    [
    //                        NSLayoutConstraint(item: imgView,
    //                                           attribute: .leading,
    //                                           relatedBy: .equal,
    //                                           toItem: svStackview,
    //                                           attribute: .leading,
    //                                           multiplier: 1,
    //                                           constant: 0),
    //                        NSLayoutConstraint(item: imgView,
    //                                           attribute: .trailing,
    //                                           relatedBy: .equal,
    //                                           toItem: svStackview,
    //                                           attribute: .trailing,
    //                                           multiplier: 1,
    //                                           constant: 0)
    //                    ])
    //
    //                let tap = UITapGestureRecognizer(target: self, action: #selector(seeMore))
    //                imgView.isUserInteractionEnabled = true
    //                imgView.addGestureRecognizer(tap)
    //            }
    //        }
    //    }
    
    func getMucphat(id: String) -> String {
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        return Queries.searchMucphatInfo(id: id)
    }
    
    func getPhuongtien(id: String) -> String {
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        return Queries.searchPhuongtienInfo(id: id)
    }
    
    func getLinhvuc(id: String) -> String {
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        return Queries.searchLinhvucInfo(id: id)
    }
    
    func getDoituong(id: String) -> String {
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        return Queries.searchDoituongInfo(id: id)
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
        case "seeParent":
            guard let dieukhoanParent = segue.destination as? VBPLDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            dieukhoanParent.updateDetails(dieukhoan: parentDieukhoan!)
            
        case "showDieukhoan":
            guard let dieukhoanDetails = segue.destination as? VBPLDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedDieukhoanCell = sender as? VBPLTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tblView.indexPath(for: selectedDieukhoanCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedDieukhoan = children[indexPath.row]
            dieukhoanDetails.updateDetails(dieukhoan: selectedDieukhoan)
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    func seeMore(sender: UITapGestureRecognizer) {
        print("----------------------------\nI want to show image in zoom view but it could take more time to implement this while the benefit from this is not really high, then i'll let it like this until i have more time or i change my mind.\n----------------------------")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "tblDieukhoanCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? VBPLTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Configure the cell...
        
        var dieukhoan:Dieukhoan
        
        if searchController.isActive && searchController.searchBar.text != "" {
            if children.count>0 {
                dieukhoan = children[indexPath.row]
            }else{
                dieukhoan = Dieukhoan(id: 0, cha: 0, vanban: Vanban(id: 0, ten: "", loai: Loaivanban(id: 0, ten: ""), so: "", nam: "", ma: "", coquanbanhanh: Coquanbanhanh(id: 0, ten: ""), noidung: ""))
                dieukhoan.setMinhhoa(minhhoa: [""])
            }
        } else {
            dieukhoan = children[indexPath.row]
        }
        
        cell.updateDieukhoan(dieukhoan: dieukhoan, fullDetails: true, showVanban: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rowCount
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        //        updateDieukhoanList(arrDieukhoan: search(keyword: searchText))
        rowCount = children.count
        tblView.reloadData()
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: "All")
    }
}
