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
import AVFoundation

@available(iOS 9.0, *)
class VBPLDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, TJPlacementDelegate, AVSpeechSynthesizerDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var lblVanban: CustomizedLabel!
    @IBOutlet weak var lblDieukhoan: CustomizedLabel!
    @IBOutlet weak var lblNoidung: CustomizedLabel!
    
    @IBOutlet var btnParentBreadscrub: UIButton!
    @IBOutlet weak var scvDetails: UIScrollView!
    @IBOutlet weak var svStackview: UIStackView!
    @IBOutlet weak var btnSeeMore: UIButton!
    @IBOutlet var viewExtraInfo: UIView!
    @IBOutlet var lblMucphat: CustomizedLabel!
    @IBOutlet var lblPhuongtien: CustomizedLabel!
    @IBOutlet var lblLinhvuc: CustomizedLabel!
    @IBOutlet var lblDoituong: CustomizedLabel!
    @IBOutlet var viewBosungKhacphuc: UIView!
    @IBOutlet var viewHinhphatbosung: UIView!
    @IBOutlet var viewBienphapkhacphuc: UIView!
    @IBOutlet var viewTamgiuPhuongtien: UIView!
    @IBOutlet var viewThamquyen: UIView!
    @IBOutlet var lblHinhphatbosungTitle: CustomizedLabel!
    @IBOutlet var lblHinhphatbosungDetails: CustomizedLabel!
    @IBOutlet var lblBienphapkhacphucTitle: CustomizedLabel!
    @IBOutlet var lblBienphapkhacphucDetails: CustomizedLabel!
    @IBOutlet var lblTamgiuPhuongtienTitle: CustomizedLabel!
    @IBOutlet var lblTamgiuPhuongtienDetails: CustomizedLabel!
    @IBOutlet var lblThamquyenTitle: CustomizedLabel!
    @IBOutlet var lblThamquyenDetails: CustomizedLabel!
    
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
    @IBOutlet var viewBottomButtons: UIView!
    @IBOutlet var btnRead: UIButton!
    @IBOutlet var viewAds: UIView!
    
    @IBAction func actBtnRead(_ sender: Any) {
        if utterance.voice?.language != nil {
            speakContent(utterance: utterance)
        }else {
            
        }
    }
    
    
    var dkChild = [Dieukhoan]()
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
    let redirectionHelper = RedirectionHelper()
    var placement = TJPlacement()
    var contentString = ""
    let synthesizer = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance(string: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.delegate = self
        tblView.dataSource = self
        synthesizer.delegate = self
        lblVanban.setLightCaptionLabel()
        lblVanban.setRoot(root: self)
        lblDieukhoan.setBoldCaptionLabel()
        lblDieukhoan.setRoot(root: self)
        lblNoidung.setNormalCaptionLabel()
        lblNoidung.setRoot(root: self)
        // Do any additional setup after loading the view.
        
        showDieukhoan()
        
        tblView.reloadData()
        updateTableViewHeight()
        initAds()
        
        //check if speaker is availalbe for the text language
        setSpeakerLanguage()
        if utterance.voice?.language != nil {
            updateSpeakerButton(onNow: true)
        }else {
            btnRead.isHidden = true
        }
        if relatedChildren.count > 0{
            btnSeeMore.isHidden = false
        }else{
            btnSeeMore.isHidden = true
        }
        if(relatedChildren.count < 1 && utterance.voice?.language == nil){
            consLblSeeMoreHeight.constant = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        synthesizer.stopSpeaking(at: .immediate)
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
        //Initialize Tapjoy Ads
        placement = AdsHelper.initTJPlacement(name: "WeThoongPlacement", delegate: self)
        placement.requestContent()
        
        //Initialize Google Admob
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        btnFBBanner.addTarget(self, action: #selector(btnFouderFBAction), for: .touchDown)
        AdsHelper.initBannerAds(btnFBBanner: btnFBBanner, bannerView: bannerView, toView: viewAds, root: self)
    }
    
    @objc func btnFouderFBAction() {
        redirectionHelper.openUrl(urls: GeneralSettings.getFBLink)
    }
    
    func updateDetails(dieukhoan: Dieukhoan) {
        self.dieukhoan = dieukhoan
        specificVanbanId.append( String(describing:dieukhoan.getVanban().getId()))
        
        for child in getChildren(keyword: String(describing: dieukhoan.id)) {
            dkChild.append(child)
        }
        rowCount = dkChild.count
        
        for child in Queries.getAllDirectRelatedDieukhoan(dieukhoanId: dieukhoan.getId()) {
            relatedChildren.append(child)
        }
        
        for child in Queries.getAllRelativeRelatedDieukhoan(dieukhoanId: dieukhoan.getId()) {
            relatedChildren.append(child)
        }
        
        //filter out all duplicated dieukhoan in relatedChildren but still keep the original order of direct then relative
        var tempRelatedChildren = [Dieukhoan]()
        var referer = [String:Bool]()
        for dk in relatedChildren {
            if referer["\(dk.getId())"] == nil {
                tempRelatedChildren.append(dk)
            }
            referer["\(dk.getId())"] = true
        }
        relatedChildren = tempRelatedChildren
        
        hinhphatbosungList = Queries.getAllHinhphatbosung(dieukhoanId: dieukhoan.getId())
        bienphapkhacphucList = Queries.getAllBienphapkhacphuc(dieukhoanId: dieukhoan.getId())
        tamgiuphuongtienList = getTamgiuPhuongtienList()
        thamquyenList = getThamquyenList()
        
        for parent in getParent(keyword: String(describing: dieukhoan.cha)) {
            parentDieukhoan = parent
        }
        
    }
    
    func speakContent(utterance: AVSpeechUtterance) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        } else {
            synthesizer.speak(utterance)
        }
    }
    
    // will be called when speech did finish
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        updateSpeakerButton(onNow: true)
    }
    // will be called when speech did start
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        updateSpeakerButton(onNow: false)
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        updateSpeakerButton(onNow: true)
    }
    private func updateSpeakerButton(onNow: Bool){
        if onNow {
            btnRead.setImage(UIImage(named: "speaker_on"), for: .normal)
            btnRead.backgroundColor = UIColor.init(red: 56/255, green: 207/255, blue: 109/255, alpha: 1)
        }else{
            btnRead.setImage(UIImage(named: "speaker_off"), for: .normal)
            btnRead.backgroundColor = UIColor.init(red: 255/255, green: 64/255, blue: 129/255, alpha: 1)
        }
    }
    
    private func setSpeakerLanguage(){
        var language = "en"
        if #available(iOS 11.0, *) {
            language = NSLinguisticTagger.dominantLanguage(for: contentString)!
            if language != ""  {
                print("***** Language: \(language)")
            } else {
                print("***** Language: Unknown language")
            }
        } else {
            // Fallback on earlier versions
            language = "vi"
        }
        utterance = AVSpeechUtterance(string: contentString)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        print("+++++++=====++++++ Voice Language: \(utterance.voice?.language)")
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
            consViewHinhphatbosungHeight.isActive = true
            consViewBienphapkhacphucHeight.isActive = true
            consViewTamgiuPhuongtienHeight.isActive = true
            consViewThamquyenHeight.isActive = true
            consViewBosungKhacphucHeight.constant = 0
            consViewBosungKhacphucHeight.isActive = true
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
        //TO DO: Currently, dieukhoan owns Vanban but with limited vanban's data. To get tenRutgon of Vanban, we have to use vanbanInfo, which owns by GeneralSettings. To fix this problem completely, we have to change the rawQuery in Queries. We'll do it later
        lblVanban.text = "\(GeneralSettings.getVanbanInfo(id: dieukhoan!.getVanban().getId(), info: "shortname")) (\(dieukhoan!.getVanban().getMa()))"
        lblDieukhoan.text = dieukhoan!.getSo()
        let breadscrubText = search.getAncestersNumber(dieukhoan: dieukhoan!, vanbanId: [String(describing: dieukhoan!.getVanban().getId())])
        if breadscrubText.count > 0 {
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
        
        //reverse breadsrub text to the right order
        let aces = breadscrubText.split(separator: "/").reversed()
        //insert prefix for dieukhoan
        var pref = "";
        var edittedAces = [String]();
        for scrub in aces{
            edittedAces.append(pref + scrub)
            if scrub.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().hasPrefix("điều"){
                pref = "khoản ";
            }else if(pref == "khoản "){
                pref = "điểm ";
            } else {
                pref = "";
            }
        }
        
        //update content string
        let so = dieukhoan!.getSo().hasSuffix(".") ? dieukhoan!.getSo() : dieukhoan!.getSo() + "."
        contentString = "\(edittedAces.joined(separator: " "))\n\(pref)\(so) \(dieukhoan!.getTieude())\n\(dieukhoan!.getNoidung())"
        
        populateExtraInfoView()
        if hinhphatbosungList.count < 1 && bienphapkhacphucList.count < 1 && thamquyenList.count < 1 && tamgiuphuongtienList.count < 1{
            hideBosungKhacphucView(isHidden: true)
        } else {
            populateBosungKhacphucView()
        }
    }
    
    func populateBosungKhacphucView(){
        if hinhphatbosungList.count > 0 {
            hideHinhphatbosungView(isHidden: false)
            lblHinhphatbosungTitle.numberOfLines = 0
            lblHinhphatbosungTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            lblHinhphatbosungTitle.text = "Hình phạt bổ sung:"
            lblHinhphatbosungDetails.numberOfLines = 0
            lblHinhphatbosungDetails.lineBreakMode = NSLineBreakMode.byWordWrapping
            lblHinhphatbosungDetails.text = ""
            lblHinhphatbosungDetails.setRoot(root: self)
            lblHinhphatbosungTitle.setRoot(root: self)
            var hpbs = ""
            for bosung in hinhphatbosungList {
                hpbs += "- \(lblHinhphatbosungDetails.text!)\(Utils.removeLastCharacters(result: bosung.getNoidung(), length: (bosung.getNoidung().count - 1)).uppercased())\(Utils.removeFirstCharacters(result: bosung.getNoidung(), length: 1))\n"
            }
            lblHinhphatbosungDetails.text = hpbs
            contentString += "\nHình phạt bổ sung: \(hpbs)"
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
            lblBienphapkhacphucTitle.setRoot(root: self)
            lblBienphapkhacphucDetails.setRoot(root: self)
            var bpkp = ""
            for khacphuc in bienphapkhacphucList {
                bpkp += "- \(lblBienphapkhacphucDetails.text!)\(Utils.removeLastCharacters(result: khacphuc.getNoidung(), length: (khacphuc.getNoidung().count - 1)).uppercased())\(Utils.removeFirstCharacters(result: khacphuc.getNoidung(), length: 1))\n"
            }
            lblBienphapkhacphucDetails.text = bpkp
            contentString += "\nBiện pháp khắc phục: \(bpkp)"
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
            lblTamgiuPhuongtienTitle.setRoot(root: self)
            lblTamgiuPhuongtienDetails.setRoot(root: self)
            contentString += "\nTạm giữ phương tiện: 07 ngày"
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
            lblThamquyenTitle.setRoot(root: self)
            lblThamquyenDetails.setRoot(root: self)
            for thamquyen in thamquyenList {
                lblThamquyenDetails.text = "\(lblThamquyenDetails.text!)\(thamquyen.getNoidung())\n"
            }
        }else{
            hideThamquyenView(isHidden: true)
        }
    }
    
    func populateExtraInfoView(){
        var isExtraInfoAvailable = false
        let mpText = getMucphat(id: String(describing: dieukhoan!.getId()))
        let ptText = getPhuongtien(id: String(describing: dieukhoan!.getId()))
        let lvText = getLinhvuc(id: String(describing: dieukhoan!.getId()))
        let dtText = getDoituong(id: String(describing: dieukhoan!.getId()))
        
        if mpText.count > 0 {
            consLblMucphatHeight.isActive = false
            consLblMucphatDetailsHeight.isActive = false
            lblMucphat.text = mpText
            lblMucphat.setRoot(root: self)
            contentString += "\nMức phạt: \(mpText)"
            isExtraInfoAvailable = true
        }else{
            consLblMucphatHeight.isActive = true
            consLblMucphatDetailsHeight.isActive = true
            consLblMucphatHeight.constant =  0
            consLblMucphatDetailsHeight.constant =  0
        }
        if ptText.count > 0 {
            consLblPhuongtienHeight.isActive = false
            consLblPhuongtienDetailsHeight.isActive = false
            lblPhuongtien.text = ptText
            lblPhuongtien.setRoot(root: self)
            contentString += "\nPhương tiện: \(ptText)"
            isExtraInfoAvailable = true
        }else{
            consLblPhuongtienHeight.isActive = true
            consLblPhuongtienDetailsHeight.isActive = true
            consLblPhuongtienHeight.constant =  0
            consLblPhuongtienDetailsHeight.constant =  0
        }
        if lvText.count > 0 {
            consLblLinhvucHeight.isActive = false
            consLblLinhvucDetailsHeight.isActive = false
            lblLinhvuc.text = lvText
            lblLinhvuc.setRoot(root: self)
            contentString += "\nLĩnh vực: \(lvText)"
            isExtraInfoAvailable = true
        }else{
            consLblLinhvucHeight.isActive = true
            consLblLinhvucDetailsHeight.isActive = true
            consLblLinhvucHeight.constant =  0
            consLblLinhvucDetailsHeight.constant =  0
        }
        if dtText.count > 0 {
            consLblDoituongHeight.isActive = false
            consLblDoituongDetailsHeight.isActive = false
            lblDoituong.text = dtText
            lblDoituong.setRoot(root: self)
            contentString += "\nĐối tượng: \(dtText)"
            isExtraInfoAvailable = true
        }else{
            consLblDoituongHeight.isActive = true
            consLblDoituongDetailsHeight.isActive = true
            consLblDoituongHeight.constant =  0
            consLblDoituongDetailsHeight.constant =  0
        }
        
        //show or hide extra info view
        hideExtraInfoView(isHidden: !isExtraInfoAvailable)
    }
    
    func fillMinhhoaToViewMinhhoa(images: [String]) {
        hideMinhhoaView(isHidden: false)
        viewMinhhoa.translatesAutoresizingMaskIntoConstraints = false
        
        var order = 0
        for img in images {
            if (img.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "")).trimmingCharacters(in: .whitespacesAndNewlines).count < 1{
                
            }else{
                let image = UIImage(named: (img.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "")).trimmingCharacters(in: .whitespacesAndNewlines))!
                
                let imgView = UIImageView(image: Utils.scaleImage(image: image, targetWidth: Utils.getScreenWidth()))
                imgView.translatesAutoresizingMaskIntoConstraints = false
                imgView.clipsToBounds = true
                imgView.contentMode = UIView.ContentMode.scaleAspectFit
                imgView.autoresizesSubviews = true
                if order == 0 {
                    if images.count == 1 {
                        Utils.generateNewComponentConstraints(parent: viewMinhhoa, topComponent: viewMinhhoa, bottomComponent: viewMinhhoa, component: imgView, top: 0, left: 0, right: 0, bottom: 0, isInside: true)
                    }else{
                        Utils.generateNewComponentConstraints(parent: viewMinhhoa, topComponent: viewMinhhoa, component: imgView, top: 0, left: 0, right: 0, isInside: true)
                    }
                }else{
                    if order < (images.count - 1) {
                        Utils.generateNewComponentConstraints(parent: viewMinhhoa, topComponent: (viewMinhhoa.subviews.last)!, component: imgView, top: 0, left: 0, right: 0, isInside: false)
                    }else{
                        Utils.generateNewComponentConstraints(parent: viewMinhhoa, topComponent: (viewMinhhoa.subviews.last)!, bottomComponent: viewMinhhoa, component: imgView, top: 0, left: 0, right: 0, bottom: 0, isInside: false)
                    }
                }
                order += 1
                let tap = UITapGestureRecognizer(target: self, action: #selector(seeMore))
                imgView.isUserInteractionEnabled = true
                imgView.addGestureRecognizer(tap)
            }
        }
    }
    
    func getThamquyenList() -> [Dieukhoan] {
        var thamquyen = [Dieukhoan]()
        
        return thamquyen
    }
    
    func getTamgiuPhuongtienList() -> [Dieukhoan] {
        var tamgiu = [Dieukhoan]()
        //        let qry = "select distinct dk.id as dkId, dk.so as dkSo, tieude as dkTieude, dk.noidung as dkNoidung, minhhoa as dkMinhhoa, cha as dkCha, vb.loai as lvbID, lvb.ten as lvbTen, vb.so as vbSo, vanbanid as vbId, vb.ten as vbTen, nam as vbNam, ma as vbMa, vb.noidung as vbNoidung, coquanbanhanh as vbCoquanbanhanhId, cq.ten as cqTen, dk.forSearch as dkSearch from tblChitietvanban as dk join tblVanban as vb on dk.vanbanid=vb.id join tblLoaivanban as lvb on vb.loai=lvb.id join tblCoquanbanhanh as cq on vb.coquanbanhanh=cq.id join tblRelatedDieukhoan as rdk on dk.id = rdk.dieukhoanId where (dkCha = \(GeneralSettings.tamgiuPhuongtienParentID) or dkCha in (select id from tblchitietvanban where cha = \(GeneralSettings.tamgiuPhuongtienParentID)) or dkCha in (select id from tblchitietvanban where cha in (select id from tblchitietvanban where cha = \(GeneralSettings.tamgiuPhuongtienParentID)))) and (rdk.relatedDieukhoanID = \(dieukhoan!.getId()) or rdk.relatedDieukhoanID = \(dieukhoan!.getCha()) or rdk.relatedDieukhoanID = (select cha from tblchitietvanban where id = \(dieukhoan!.getCha())))"
        
        //check if there is any tamgiuPhuongtienParentId available
        if GeneralSettings.getTamgiuPhuongtienParentID(vanbanId: dieukhoan!.getVanban().getId()).count > 0 {
            
            let qry = "select distinct dk.id as dkId, dk.so as dkSo, tieude as dkTieude, dk.noidung as dkNoidung, minhhoa as dkMinhhoa, cha as dkCha, vb.loai as lvbID, lvb.ten as lvbTen, vb.so as vbSo, vanbanid as vbId, vb.ten as vbTen, nam as vbNam, ma as vbMa, vb.noidung as vbNoidung, coquanbanhanh as vbCoquanbanhanhId, cq.ten as cqTen, dk.forSearch as dkSearch from tblChitietvanban as dk join tblVanban as vb on dk.vanbanid=vb.id join tblLoaivanban as lvb on vb.loai=lvb.id join tblCoquanbanhanh as cq on vb.coquanbanhanh=cq.id join tblRelatedDieukhoan as rdk on dk.id = rdk.dieukhoanId where (dkCha = \(GeneralSettings.getTamgiuPhuongtienParentID(vanbanId: dieukhoan!.getVanban().getId())) or dkCha in (select id from tblchitietvanban where cha = \(GeneralSettings.getTamgiuPhuongtienParentID(vanbanId: dieukhoan!.getVanban().getId()))) or dkCha in (select id from tblchitietvanban where cha in (select id from tblchitietvanban where cha = \(GeneralSettings.getTamgiuPhuongtienParentID(vanbanId: dieukhoan!.getVanban().getId()))))) and (rdk.relatedDieukhoanID = \(dieukhoan!.getId()) or rdk.relatedDieukhoanID = \(dieukhoan!.getCha()) or rdk.relatedDieukhoanID = (select cha from tblchitietvanban where id = \(dieukhoan!.getCha())))"
            tamgiu = Queries.searchDieukhoanByQuery(query: qry, vanbanid: specificVanbanId)
        }
        return tamgiu
    }
    
    func getMucphat(id: String) -> String {
        return Queries.searchMucphatInfo(id: id)
    }
    
    func getPhuongtien(id: String) -> String {
        return Queries.searchPhuongtienInfo(id: id)
    }
    
    func getLinhvuc(id: String) -> String {
        return Queries.searchLinhvucInfo(id: id)
    }
    
    func getDoituong(id: String) -> String {
        return Queries.searchDoituongInfo(id: id)
    }
    
    func getChildren(keyword:String) -> [Dieukhoan] {
        return Queries.searchChildren(keyword: "\(keyword)", vanbanid: specificVanbanId)
    }
    
    func getParent(keyword:String) -> [Dieukhoan] {
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
            
            let selectedDieukhoan = dkChild[indexPath.row]
            dieukhoanDetails.updateDetails(dieukhoan: selectedDieukhoan)
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    @objc func seeMore(sender: UITapGestureRecognizer) {
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
            if dkChild.count>0 {
                dieukhoan = dkChild[indexPath.row]
            }else{
                dieukhoan = Dieukhoan(id: 0, cha: 0, vanban: Vanban(id: 0, ten: "", loai: Loaivanban(id: 0, ten: ""), so: "", nam: "", ma: "", coquanbanhanh: Coquanbanhanh(id: 0, ten: ""), noidung: ""))
                dieukhoan.setMinhhoa(minhhoa: [""])
            }
        } else {
            dieukhoan = dkChild[indexPath.row]
        }
        contentString += "\n\(dieukhoan.getSo()) \(dieukhoan.getTieude())\n\(dieukhoan.getNoidung())"
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
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        //        updateDieukhoanList(arrDieukhoan: search(keyword: searchText))
        rowCount = dkChild.count
        tblView.reloadData()
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: "All")
    }
    
    //Tapjoy Ads delegate
    // Called when the SDK has made contact with Tapjoy's servers. It does not necessarily mean that any content is available.
    func requestDidSucceed(_ placement: TJPlacement){
        print("Request to TJ server successfully made")
    }
    
    // Called when there was a problem during connecting Tapjoy servers.
    func requestDidFail(_ placement: TJPlacement!, error: Error!) {
        print("Request to TJ server failed to make")
    }
    
    // Called when the content is actually available to display.
    func contentIsReady(_ placement: TJPlacement!) {
        print("Tj ads content is ready")
        if AdsHelper.isValidToShowIntestitialAds() {
            //log the timestamp of showing Interstitial ads
            GeneralSettings.getLastInterstitialAdsOpenTimestamp = Int(NSDate().timeIntervalSince1970)
            //log the number of time the the ads was shown during the day
            GeneralSettings.getInterstitialAdsOpenTimes += 1
            
            //show the ad
            placement.showContent(with: self)
        }
        
    }
    
    // Called when the content is showed.
    func contentDidAppear(_ placement: TJPlacement!) {
        print("Tj ads content showing")
    }
    
    // Called when the content is dismissed.
    func contentDidDisappear(_ placement: TJPlacement!) {
        print("Tj ads content went away")
    }
    
    func getContentString() -> String {
        return contentString
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
