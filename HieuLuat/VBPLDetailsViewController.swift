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

@available(iOS 9.0, *)
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
    @IBOutlet var viewBosungKhacphuc: UIView!
    @IBOutlet var viewHinhphatbosung: UIView!
    @IBOutlet var viewBienphapkhacphuc: UIView!
    @IBOutlet var viewTamgiuPhuongtien: UIView!
    @IBOutlet var viewThamquyen: UIView!
    @IBOutlet var lblHinhphatbosungTitle: UILabel!
    @IBOutlet var lblHinhphatbosungDetails: UILabel!
    @IBOutlet var lblBienphapkhacphucTitle: UILabel!
    @IBOutlet var lblBienphapkhacphucDetails: UILabel!
    @IBOutlet var lblTamgiuPhuongtienTitle: UILabel!
    @IBOutlet var lblTamgiuPhuongtienDetails: UILabel!
    @IBOutlet var lblThamquyenTitle: UILabel!
    @IBOutlet var lblThamquyenDetails: UILabel!
    
    @IBOutlet var consViewThamquyenHeight: NSLayoutConstraint!
    @IBOutlet var consViewTamgiuPhuongtienHeight: NSLayoutConstraint!
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
    @IBOutlet var consViewHinhphatbosungHeight: NSLayoutConstraint!
    
    @IBOutlet var consViewBienphapkhacphucHeight: NSLayoutConstraint!
    @IBOutlet var consViewBosungKhacphucHeight: NSLayoutConstraint!
    @IBOutlet var viewMinhhoa: UIView!
    @IBOutlet var tblView: UITableView!
    @IBOutlet var consHeightTblView: NSLayoutConstraint!
    @IBOutlet var viewAds: UIView!
    
    var children = [Dieukhoan]()
    var parentDieukhoan: Dieukhoan? = nil
    var relatedChildren = [Dieukhoan]()
    var hinhphatbosungList = [BosungKhacphuc]()
    var bienphapkhacphucList = [BosungKhacphuc]()
    var thamquyenList = [Dieukhoan]()
    var tamgiuphuongtienList = [Dieukhoan]()
    var dieukhoan: Dieukhoan? = nil
    var search = SearchFor()
    var specificVanbanId = [String]()
    var images = [String]()
    let searchController = UISearchController(searchResultsController: nil)
    var rowCount = 0
    var settings = GeneralSettings()
    var bannerView: GADBannerView!
    let btnFBBanner = UIButton()
    
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
        if GeneralSettings.isAdEnabled && AdsHelper.isConnectedToNetwork() {
            bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            AdsHelper.addBannerViewToView(bannerView: bannerView,toView: viewAds, root: self)
        }else{
            btnFBBanner.addTarget(self, action: #selector(btnFouderFBAction), for: .touchDown)
            AdsHelper.addButtonToView(btnFBBanner: btnFBBanner, toView: viewAds)
        }
    }
    
    func btnFouderFBAction() {
        let url = URL(string: GeneralSettings.getFBLink)
        if UIApplication.shared.canOpenURL(url!) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url!)
            }
        }
    }
    
    func updateDetails(dieukhoan: Dieukhoan) {
        self.dieukhoan = dieukhoan
        specificVanbanId.append( String(describing:dieukhoan.getVanban().getId()))
        
        for child in getChildren(keyword: String(describing: dieukhoan.id)) {
            children.append(child)
        }
        rowCount = children.count
        
        for child in Queries.getAllDirectRelatedDieukhoan(dieukhoanId: dieukhoan.getId()) {
            relatedChildren.append(child)
        }
        
        for child in Queries.getAllRelativeRelatedDieukhoan(dieukhoanId: dieukhoan.getId()) {
            relatedChildren.append(child)
        }
        
        hinhphatbosungList = Queries.getAllHinhphatbosung(dieukhoanId: dieukhoan.getId())
        bienphapkhacphucList = Queries.getAllBienphapkhacphuc(dieukhoanId: dieukhoan.getId())
        tamgiuphuongtienList = getTamgiuPhuongtienList()
        thamquyenList = getThamquyenList()
        
        for parent in getParent(keyword: String(describing: dieukhoan.cha)) {
            parentDieukhoan = parent
        }
        
    }
    
    
    func hideMinhhoaStackview(isHidden: Bool)  {
        consSvStackviewHeightSmall.constant = 0
        if(isHidden){
            svStackview.isHidden = true
            consSvStackviewHeightSmall.isActive = true
        }else{
            svStackview.isHidden = false
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
    
    func hideBosungKhacphucView(isHidden: Bool)  {
        if(isHidden){
            consViewBosungKhacphucHeight.constant = 0
            consViewBosungKhacphucHeight.isActive = true
            consViewHinhphatbosungHeight.isActive = true
            consViewBienphapkhacphucHeight.isActive = true
            consViewTamgiuPhuongtienHeight.isActive = true
            consViewThamquyenHeight.isActive = true
            viewBosungKhacphuc.isHidden = true
        }else{
            consViewBosungKhacphucHeight.isActive = false
            consViewHinhphatbosungHeight.isActive = false
            consViewBienphapkhacphucHeight.isActive = false
            consViewTamgiuPhuongtienHeight.isActive = false
            consViewThamquyenHeight.isActive = false
            viewBosungKhacphuc.isHidden = false
        }
    }
    
    func hideHinhphatbosungView(isHidden: Bool)  {
        if(isHidden){
            consViewHinhphatbosungHeight.constant = 0
            consViewHinhphatbosungHeight.isActive = true
        }else{
            consViewBosungKhacphucHeight.isActive = false
            consViewHinhphatbosungHeight.isActive = false
            viewBosungKhacphuc.isHidden = false
        }
    }
    
    func hideBienphapkhacphucView(isHidden: Bool)  {
        if(isHidden){
            consViewBienphapkhacphucHeight.constant = 0
            consViewBienphapkhacphucHeight.isActive = true
        }else{
            consViewBosungKhacphucHeight.isActive = false
            consViewBienphapkhacphucHeight.isActive = false
            viewBosungKhacphuc.isHidden = false
        }
    }
    
    func hideTamgiuPhuongtienView(isHidden: Bool)  {
        if(isHidden){
            consViewTamgiuPhuongtienHeight.constant = 0
            consViewTamgiuPhuongtienHeight.isActive = true
        }else{
            consViewBosungKhacphucHeight.isActive = false
            consViewTamgiuPhuongtienHeight.isActive = false
            viewBosungKhacphuc.isHidden = false
        }
    }
    
    func hideThamquyenView(isHidden: Bool)  {
        if(isHidden){
            consViewThamquyenHeight.constant = 0
            consViewThamquyenHeight.isActive = true
        }else{
            consViewBosungKhacphucHeight.isActive = false
            consViewThamquyenHeight.isActive = false
            viewBosungKhacphuc.isHidden = false
        }
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
            fillMinhhoaToViewMinhhoa(images: images)
        }else{
            hideMinhhoaView(isHidden: true)
        }
        
        // Enable extra section for details of ND46
        if String(describing:dieukhoan!.vanban.getId()) == GeneralSettings.getVanbanInfo(name: "ND46", info: "id") {
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
        if hinhphatbosungList.count < 1 && bienphapkhacphucList.count < 1 && thamquyenList.count < 1 && tamgiuphuongtienList.count < 1{
            hideBosungKhacphucView(isHidden: true)
        } else {
            if hinhphatbosungList.count > 0 {
                hideHinhphatbosungView(isHidden: false)
                lblHinhphatbosungTitle.numberOfLines = 0
                lblHinhphatbosungTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                lblHinhphatbosungTitle.text = "Hình phạt bổ sung:"
                lblHinhphatbosungDetails.numberOfLines = 0
                lblHinhphatbosungDetails.lineBreakMode = NSLineBreakMode.byWordWrapping
                lblHinhphatbosungDetails.text = ""
                for bosung in hinhphatbosungList {
                    lblHinhphatbosungDetails.text = "\(lblHinhphatbosungDetails.text!)\(bosung.getNoidung())\n"
                }
            } else {
                hideHinhphatbosungView(isHidden: true)
            }
            
            if bienphapkhacphucList.count > 0 {
                hideBienphapkhacphucView(isHidden: false)
                lblBienphapkhacphucTitle.numberOfLines = 0
                lblBienphapkhacphucTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                lblBienphapkhacphucTitle.text = "Biện pháp khắc phục:"
                lblBienphapkhacphucDetails.numberOfLines = 0
                lblBienphapkhacphucDetails.lineBreakMode = NSLineBreakMode.byWordWrapping
                lblBienphapkhacphucDetails.text = ""
                for khacphuc in bienphapkhacphucList {
                    lblBienphapkhacphucDetails.text = "\(lblBienphapkhacphucDetails.text!)\(khacphuc.getNoidung())\n"
                }
            }else{
                hideBienphapkhacphucView(isHidden: true)
            }
            
            if tamgiuphuongtienList.count > 0 {
                hideTamgiuPhuongtienView(isHidden: false)
                lblTamgiuPhuongtienTitle.numberOfLines = 0
                lblTamgiuPhuongtienTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                lblTamgiuPhuongtienTitle.text = "Tạm giữ phương tiện:"
                lblTamgiuPhuongtienDetails.numberOfLines = 0
                lblTamgiuPhuongtienDetails.lineBreakMode = NSLineBreakMode.byWordWrapping
                lblTamgiuPhuongtienDetails.text = "07 ngày"
            }else{
                hideTamgiuPhuongtienView(isHidden: true)
            }
            
            if thamquyenList.count > 0 {
                hideThamquyenView(isHidden: false)
                lblThamquyenTitle.numberOfLines = 0
                lblThamquyenTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                lblThamquyenTitle.text = "Biện pháp khắc phục:"
                lblThamquyenDetails.numberOfLines = 0
                lblThamquyenDetails.lineBreakMode = NSLineBreakMode.byWordWrapping
                lblThamquyenDetails.text = ""
                for thamquyen in thamquyenList {
                    lblThamquyenDetails.text = "\(lblThamquyenDetails.text!)\(thamquyen.getNoidung())\n"
                }
            }else{
                hideThamquyenView(isHidden: true)
            }
        }
    }
    
    func generateNewComponentConstraints(parent: UIView, topComponent: UIView, component: UIView, top: CGFloat, left: CGFloat, right: CGFloat) {
        parent.addSubview(component)
        parent.addConstraints(
            [
                NSLayoutConstraint(item: component,
                                   attribute: .leading,
                                   relatedBy: .equal,
                                   toItem: parent,
                                   attribute: .leading,
                                   multiplier: 1,
                                   constant: left),
                NSLayoutConstraint(item: component,
                                   attribute: .trailing,
                                   relatedBy: .equal,
                                   toItem: parent,
                                   attribute: .trailing,
                                   multiplier: 1,
                                   constant: right),
                NSLayoutConstraint(item: component,
                                   attribute: .top,
                                   relatedBy: .equal,
                                   toItem: topComponent,
                                   attribute: .top,
                                   multiplier: 1,
                                   constant: top)
            ])
    }
    
    func generateNewComponentConstraints(parent: UIView, topComponent: UIView, bottomComponent: UIView, component: UIView, top: CGFloat, left: CGFloat, right: CGFloat, bottom: CGFloat) {
        parent.addSubview(component)
        parent.addConstraints(
            [
                NSLayoutConstraint(item: component,
                                   attribute: .leading,
                                   relatedBy: .equal,
                                   toItem: parent,
                                   attribute: .leading,
                                   multiplier: 1,
                                   constant: left),
                NSLayoutConstraint(item: component,
                                   attribute: .trailing,
                                   relatedBy: .equal,
                                   toItem: parent,
                                   attribute: .trailing,
                                   multiplier: 1,
                                   constant: right),
                NSLayoutConstraint(item: component,
                                   attribute: .top,
                                   relatedBy: .equal,
                                   toItem: topComponent,
                                   attribute: .top,
                                   multiplier: 1,
                                   constant: top),
                NSLayoutConstraint(item: component,
                                   attribute: .bottom,
                                   relatedBy: .equal,
                                   toItem: bottomComponent,
                                   attribute: .bottom,
                                   multiplier: 1,
                                   constant: bottom)
            ])
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
                        generateNewComponentConstraints(parent: viewMinhhoa, topComponent: viewMinhhoa, bottomComponent: viewMinhhoa, component: imgView, top: 0, left: 0, right: 0, bottom: 0)
                    }else{
                        generateNewComponentConstraints(parent: viewMinhhoa, topComponent: viewMinhhoa, component: imgView, top: 0, left: 0, right: 0)
                    }
                }else{
                    if order < (images.count - 1) {
                        generateNewComponentConstraints(parent: viewMinhhoa, topComponent: previousImageView, component: imgView, top: 0, left: 0, right: 0)
                    }else{
                        generateNewComponentConstraints(parent: viewMinhhoa, topComponent: previousImageView, bottomComponent: viewMinhhoa, component: imgView, top: 0, left: 0, right: 0, bottom: 0)
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
    
    func getThamquyenList() -> [Dieukhoan] {
        var thamquyen = [Dieukhoan]()
        
        return thamquyen
    }
    
    func getTamgiuPhuongtienList() -> [Dieukhoan] {
        var tamgiu = [Dieukhoan]()
        let qry = "select distinct dk.id as dkId, dk.so as dkSo, tieude as dkTieude, dk.noidung as dkNoidung, minhhoa as dkMinhhoa, cha as dkCha, vb.loai as lvbID, lvb.ten as lvbTen, vb.so as vbSo, vanbanid as vbId, vb.ten as vbTen, nam as vbNam, ma as vbMa, vb.noidung as vbNoidung, coquanbanhanh as vbCoquanbanhanhId, cq.ten as cqTen, dk.forSearch as dkSearch from tblChitietvanban as dk join tblVanban as vb on dk.vanbanid=vb.id join tblLoaivanban as lvb on vb.loai=lvb.id join tblCoquanbanhanh as cq on vb.coquanbanhanh=cq.id join tblRelatedDieukhoan as rdk on dk.id = rdk.dieukhoanId where (dkCha = \(GeneralSettings.tamgiuPhuongtienParentID) or dkCha in (select id from tblchitietvanban where cha = \(GeneralSettings.tamgiuPhuongtienParentID)) or dkCha in (select id from tblchitietvanban where cha in (select id from tblchitietvanban where cha = \(GeneralSettings.tamgiuPhuongtienParentID)))) and rdk.relatedDieukhoanID = \(dieukhoan!.getId())"
        tamgiu = Queries.searchDieukhoanByQuery(query: qry, vanbanid: specificVanbanId)
        return tamgiu
    }
    
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
