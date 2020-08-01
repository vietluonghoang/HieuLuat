//
//  MPSearchTableController.swift
//  HieuLuat
//
//  Created by VietLH on 10/27/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit
import os.log
import GoogleMobileAds

class MPSearchTableController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet var lblLoctheo: UILabel!
    @IBOutlet weak var searchbarView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var consSearchViewHeight: NSLayoutConstraint!
    @IBOutlet weak var consHeightTableView: NSLayoutConstraint!
    var dieukhoanList = [Dieukhoan]()
    let searchController = UISearchController(searchResultsController: nil)
    var rowCount = 0
    var filterSettings = [String:String]()
    var searchFilters = [String:[String:[String:String]]]()
    var builtQuery = ""
    var settings = GeneralSettings()
    var bannerView: GADBannerView!
    let btnFBBanner = UIButton()
    let redirectionHelper = RedirectionHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tblView.delegate = self
        tblView.dataSource = self
        
        initSearch()
        initFilterConfig()
        initSearchFilters()
        updateFilterLabel()
        if(dieukhoanList.count<1){
            updateDieukhoanList(arrDieukhoan: search(keyword: searchController.searchBar.text!))
        }
        
        rowCount = dieukhoanList.count
        tblView.reloadData()
        initAds()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initSearch() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        let sBar = searchController.searchBar
        searchbarView.addSubview(sBar)
        searchbarView.addConstraints(
            [NSLayoutConstraint(item: sBar,
                                attribute: .top,
                                relatedBy: .equal,
                                toItem: searchbarView,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: sBar,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: searchbarView,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: sBar,
                                attribute: .leading,
                                relatedBy: .equal,
                                toItem: searchbarView,
                                attribute: .leading,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: sBar,
                                attribute: .trailing,
                                relatedBy: .equal,
                                toItem: searchbarView,
                                attribute: .trailing,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: sBar,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: searchbarView,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        consSearchViewHeight.constant = sBar.frame.height
    }
    
    func initAds() {
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        btnFBBanner.addTarget(self, action: #selector(btnFouderFBAction), for: .touchDown)
        AdsHelper.initBannerAds(btnFBBanner: btnFBBanner, bannerView: bannerView, toView: bottomView, root: self)
    }
    
    @objc func btnFouderFBAction() {
        redirectionHelper.openUrl(urls: GeneralSettings.getFBLink)
    }
    
    func setupSearchBarSize(){
        self.searchController.searchBar.frame.size.width = self.view.frame.size.width
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        setupSearchBarSize()
    }
    
    override func viewDidLayoutSubviews() {
        setupSearchBarSize()
    }
    
    func initFilterConfig() {
        if(filterSettings.count < 1){
            filterSettings[String(GeneralSettings.getActiveNDXPId)] = "on" //Use default default NDXP id for searching
        }
    }
    
    func initSearchFilters() {
        if searchFilters.count < 1 {
            searchFilters["Mucphat"] = ["tu":["chon":"0"],"den":["chon":"0"]]
            searchFilters["Phuongtien"] = ["Oto":["chon":"0"],"Xemay":["chon":"0"],"Xechuyendung":["chon":"0"],"Tauhoa":["chon":"0"],"Xedap":["chon":"0"],"Dibo":["chon":"0"]]
            searchFilters["Doituong"] = ["Canhan":["Chuphuongtien":"0","NDK":"0","NDX":"0","GVDLX":"0","KDVT":"0"], "Tochuc":["KDVT":"0","KDDS":"0","TPDB":"0","TTKDVTDS":"0","QLKTPTDS":"0","QLKTBTHTDB":"0","QLKTBTHTDS":"0"], "Doanhnghiep":["KDKB":"0","KDSXLR":"0","KDVTDS":"0","KDXDHH":"0","KDKCHTDS":"0"], "Nhanvien":["DKV":"0","NVTTDK":"0","GC":"0","KX":"0","TH":"0","PV":"0","DDCT":"0","DS":"0","GN":"0","LT":"0","PLT":"0","TD":"0","TT":"0","DKMD":"0","TBCTG":"0"], "Trungtam":["SHLX":"0","DK":"0"], "Cosodaotaolaixe":["chon":"0"], "Ga":["chon":"0"]]
        }
        //        searchFilters["Mucphat"]!["tu"]!["chon"] = "0"
        //        searchFilters["Mucphat"]!["den"]!["chon"] = "0"
        //        searchFilters["Phuongtien"]!["Oto"]!["chon"] = "0"
        //        searchFilters["Phuongtien"]!["Xemay"]!["chon"] = "0"
        //        searchFilters["Phuongtien"]!["Xechuyendung"]!["chon"] = "0"
        //        searchFilters["Phuongtien"]!["Tauhoa"]!["chon"] = "0"
        //        searchFilters["Phuongtien"]!["Xedap"]!["chon"] = "0"
        //        searchFilters["Phuongtien"]!["Dibo"]!["chon"] = "0"
        //        searchFilters["Doituong"]!["Canhan"]!["Chuphuongtien"] = "0"
        //        searchFilters["Doituong"]!["Canhan"]!["NDK"] = "0"
        //        searchFilters["Doituong"]!["Canhan"]!["NDX"] = "0"
        //        searchFilters["Doituong"]!["Canhan"]!["GVDLX"] = "0"
        //        searchFilters["Doituong"]!["Canhan"]!["KDVT"] = "0"
        //        searchFilters["Doituong"]!["Tochuc"]!["KDVT"] = "0"
        //        searchFilters["Doituong"]!["Tochuc"]!["KDDS"] = "0"
        //        searchFilters["Doituong"]!["Tochuc"]!["TPDB"] = "0"
        //        searchFilters["Doituong"]!["Tochuc"]!["TTKDVTDS"] = "0"
        //        searchFilters["Doituong"]!["Tochuc"]!["QLKTPTDS"] = "0"
        //        searchFilters["Doituong"]!["Tochuc"]!["QLKTBTHTDB"] = "0"
        //        searchFilters["Doituong"]!["Tochuc"]!["QLKTBTHTDS"] = "0"
        //        searchFilters["Doituong"]!["Doanhnghiep"]!["KDKB"] = "0"
        //        searchFilters["Doituong"]!["Doanhnghiep"]!["KDSXLR"] = "0"
        //        searchFilters["Doituong"]!["Doanhnghiep"]!["KDVTDS"] = "0"
        //        searchFilters["Doituong"]!["Doanhnghiep"]!["KDXDHH"] = "0"
        //        searchFilters["Doituong"]!["Doanhnghiep"]!["KDKCHTDS"] = "0"
        //        searchFilters["Doituong"]!["Nhanvien"]!["DKV"] = "0"
        //        searchFilters["Doituong"]!["Nhanvien"]!["NVTTDK"] = "0"
        //        searchFilters["Doituong"]!["Nhanvien"]!["GC"] = "0"
        //        searchFilters["Doituong"]!["Nhanvien"]!["KX"] = "0"
        //        searchFilters["Doituong"]!["Nhanvien"]!["TH"] = "0"
        //        searchFilters["Doituong"]!["Nhanvien"]!["PV"] = "0"
        //        searchFilters["Doituong"]!["Nhanvien"]!["DDCT"] = "0"
        //        searchFilters["Doituong"]!["Nhanvien"]!["DS"] = "0"
        //        searchFilters["Doituong"]!["Nhanvien"]!["GN"] = "0"
        //        searchFilters["Doituong"]!["Nhanvien"]!["LT"] = "0"
        //        searchFilters["Doituong"]!["Nhanvien"]!["PLT"] = "0"
        //        searchFilters["Doituong"]!["Nhanvien"]!["TD"] = "0"
        //        searchFilters["Doituong"]!["Nhanvien"]!["TT"] = "0"
        //        searchFilters["Doituong"]!["Nhanvien"]!["DKMD"] = "0"
        //        searchFilters["Doituong"]!["Nhanvien"]!["TBCTG"] = "0"
        //        searchFilters["Doituong"]!["Trungtam"]!["SHLX"] = "0"
        //        searchFilters["Doituong"]!["Trungtam"]!["DK"] = "0"
        //        searchFilters["Doituong"]!["Cosodaotaolaixe"]!["chon"] = "0"
        //        searchFilters["Doituong"]!["Ga"]!["chon"] = "0"
    }
    
    func updateFilterLabel() {
        var newLabel = ""
        if searchFilters["Mucphat"]!["tu"]!["chon"] != "0" || searchFilters["Mucphat"]!["den"]!["chon"] != "0" {
            if searchFilters["Mucphat"]!["tu"]!["chon"] != "0" && searchFilters["Mucphat"]!["den"]!["chon"] == "0" {
                searchFilters["Mucphat"]!["den"]!["chon"] = GeneralSettings.getMucphatRange(vanbanId: GeneralSettings.getActiveNDXPId)[GeneralSettings.getMucphatRange(vanbanId: GeneralSettings.getActiveNDXPId).count - 1]
                newLabel += "Mức phạt (từ \(String(describing: searchFilters["Mucphat"]!["tu"]!["chon"]!)))" + ", "
            }else if searchFilters["Mucphat"]!["tu"]!["chon"] == "0" && searchFilters["Mucphat"]!["den"]!["chon"] != "0"{
                searchFilters["Mucphat"]!["tu"]!["chon"] = GeneralSettings.getMucphatRange(vanbanId: GeneralSettings.getActiveNDXPId)[0]
                newLabel += "Mức phạt (đến \(String(describing: searchFilters["Mucphat"]!["den"]!["chon"]!)))" + ", "
            }else{
                newLabel += "Mức phạt (\(String(describing: searchFilters["Mucphat"]!["tu"]!["chon"]!))-\(String(describing: searchFilters["Mucphat"]!["den"]!["chon"]!)))" + ", "
            }
        }
        
        if searchFilters["Phuongtien"]!["Oto"]!["chon"] != "0" {
            newLabel += "Ô tô" + ", "
        }
        
        if searchFilters["Phuongtien"]!["Xemay"]!["chon"] != "0"
        {
            newLabel += "Xe máy" + ", "
        }
        
        if searchFilters["Phuongtien"]!["Xechuyendung"]!["chon"] != "0"
        {
            newLabel += "Xe chuyên dùng" + ", "
        }
        
        if searchFilters["Phuongtien"]!["Tauhoa"]!["chon"] != "0"
        {
            newLabel += "Tầu hoả" + ", "
        }
        
        if searchFilters["Phuongtien"]!["Xedap"]!["chon"] != "0"
        {
            newLabel += "Xe đạp" + ", "
        }
        
        if searchFilters["Phuongtien"]!["Dibo"]!["chon"] != "0" {
            newLabel += "Đi bộ" + ", "
        }
        
        if ((searchFilters["Doituong"]!["Canhan"]!["Chuphuongtien"] != "0") || (searchFilters["Doituong"]!["Canhan"]!["NDK"] != "0") || (searchFilters["Doituong"]!["Canhan"]!["NDX"] != "0") || (searchFilters["Doituong"]!["Canhan"]!["GVDLX"] != "0") || (searchFilters["Doituong"]!["Canhan"]!["KDVT"] != "0")) {
            newLabel += "Cá nhân" + ", "
        }
        
        if searchFilters["Doituong"]!["Tochuc"]!["KDVT"] != "0" || searchFilters["Doituong"]!["Tochuc"]!["KDDS"] != "0" || searchFilters["Doituong"]!["Tochuc"]!["TPDB"] != "0" || searchFilters["Doituong"]!["Tochuc"]!["TTKDVTDS"] != "0" || searchFilters["Doituong"]!["Tochuc"]!["QLKTPTDS"] != "0" || searchFilters["Doituong"]!["Tochuc"]!["QLKTBTHTDB"] != "0" || searchFilters["Doituong"]!["Tochuc"]!["QLKTBTHTDS"] != "0" {
            newLabel += "Tổ chức" + ", "
        }
        
        if searchFilters["Doituong"]!["Doanhnghiep"]!["KDKB"] != "0" || searchFilters["Doituong"]!["Doanhnghiep"]!["KDSXLR"] != "0" || searchFilters["Doituong"]!["Doanhnghiep"]!["KDVTDS"] != "0" || searchFilters["Doituong"]!["Doanhnghiep"]!["KDXDHH"] != "0" || searchFilters["Doituong"]!["Doanhnghiep"]!["KDKCHTDS"] != "0" {
            newLabel += "Doanh nghiệp" + ", "
        }
        
        if searchFilters["Doituong"]!["Nhanvien"]!["DKV"] != "0" || searchFilters["Doituong"]!["Nhanvien"]!["NVTTDK"] != "0" || searchFilters["Doituong"]!["Nhanvien"]!["GC"] != "0" || searchFilters["Doituong"]!["Nhanvien"]!["KX"] != "0" || searchFilters["Doituong"]!["Nhanvien"]!["TH"] != "0" || searchFilters["Doituong"]!["Nhanvien"]!["PV"] != "0" || searchFilters["Doituong"]!["Nhanvien"]!["DDCT"] != "0" || searchFilters["Doituong"]!["Nhanvien"]!["DS"] != "0" || searchFilters["Doituong"]!["Nhanvien"]!["GN"] != "0" || searchFilters["Doituong"]!["Nhanvien"]!["LT"] != "0" || searchFilters["Doituong"]!["Nhanvien"]!["PLT"] != "0" || searchFilters["Doituong"]!["Nhanvien"]!["TD"] != "0" || searchFilters["Doituong"]!["Nhanvien"]!["TT"] != "0" || searchFilters["Doituong"]!["Nhanvien"]!["DKMD"] != "0" || searchFilters["Doituong"]!["Nhanvien"]!["TBCTG"] != "0" {
            newLabel += "Nhân viên" + ", "
        }
        
        if searchFilters["Doituong"]!["Trungtam"]!["SHLX"] != "0" || searchFilters["Doituong"]!["Trungtam"]!["DK"] != "0" {
            newLabel += "Trung tâm" + ", "
        }
        
        if searchFilters["Doituong"]!["Cosodaotaolaixe"]!["chon"] != "0" {
            newLabel += "Cơ sở đào tạo lái xe" + ", "
        }
        
        if searchFilters["Doituong"]!["Ga"]!["chon"] != "0" {
            newLabel += "Ga" + ", "
        }
        
        if newLabel.count > 2 {
//            newLabel = newLabel.substring(to: newLabel.index(newLabel.endIndex, offsetBy: -2))
            newLabel = Utils.removeLastCharacters(result: newLabel, length: 2)
        }
        lblLoctheo.text = newLabel
    }
    
    func getActiveFilter() -> [String] {
        var activeFilterList = [String]()
        for id in filterSettings.keys {
            if filterSettings[id] == "on" {
                activeFilterList.append(id)
            }
        }
        return activeFilterList
    }
    
    func updateDieukhoanList(arrDieukhoan: Array<Dieukhoan>)  {
        self.dieukhoanList=arrDieukhoan
    }
    
    func search(keyword:String) -> [Dieukhoan]{
        var rs = [Dieukhoan]()
        let kw = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        //print(getActiveFilter())
        if(kw.count > 0 || (lblLoctheo.text?.count)! > 0){
            rs = Queries.searchDieukhoanByQuery(query: "\(builtQuery)", vanbanid: getActiveFilter())
        }else{
            rs = Queries.searchChildren(keyword: "\(kw)", vanbanid: getActiveFilter())
        }
        let sortIt = SortUtil()
        return sortIt.sortByBestMatch(listDieukhoan: rs, keyword: kw)
    }
    
    func getBuiltQuery(keyword: String) -> String {
        let query = Queries.rawSqlQuery
        
        var appendString = ""
        for k in Queries.convertKeywordsForDifferentAccentType(keyword: keyword.lowercased()) {
            var str = ""
            for key in k.components(separatedBy: " ") {
                str += "dkSearch like '%\(key)%' and "
            }
//            str = str.substring(to: str.index(str.endIndex, offsetBy: -5))
            str = Utils.removeLastCharacters(result: str, length: 5)
            appendString += "(\(str)) or "
        }
//        appendString = "(\(appendString.substring(to: appendString.index(appendString.endIndex, offsetBy: -4))))"
        appendString = "(\(Utils.removeLastCharacters(result: appendString, length: 4)))"
        
        if searchFilters["Mucphat"]!["tu"]!["chon"] != "0" && searchFilters["Mucphat"]!["den"]!["chon"] != "0" {
            appendString += getWhereClauseForMucphat(tu: searchFilters["Mucphat"]!["tu"]!["chon"]!, den: searchFilters["Mucphat"]!["den"]!["chon"]!)
        }
        
        if searchFilters["Phuongtien"]!["Oto"]!["chon"] != "0" || searchFilters["Phuongtien"]!["Xemay"]!["chon"] != "0" || searchFilters["Phuongtien"]!["Xechuyendung"]!["chon"] != "0" || searchFilters["Phuongtien"]!["Tauhoa"]!["chon"] != "0" || searchFilters["Phuongtien"]!["Xedap"]!["chon"] != "0" || searchFilters["Phuongtien"]!["Dibo"]!["chon"] != "0" {
            appendString += getWhereClauseForPhuongtien()
        }
        return query + appendString
    }
    
    func getWhereClauseForMucphat(tu: String, den: String) -> String {
        let tuInt = Int32(tu.replacingOccurrences(of: ".", with: ""))
        let denInt = Int32(den.replacingOccurrences(of: ".", with: ""))
        var inClause = ""
        for item in GeneralSettings.getMucphatRange(vanbanId: GeneralSettings.getActiveNDXPId) {
            let itemInt = Int32(item.replacingOccurrences(of: ".", with: ""))
            if itemInt! >= tuInt! && itemInt! <= denInt! {
                inClause += "\"\(item)\","
            }
        }
//        inClause = inClause.substring(to: inClause.index(inClause.endIndex, offsetBy: -1))
        inClause = Utils.removeLastCharacters(result: inClause, length: 1)
        
        return " and dkId in (select distinct dieukhoanID from tblMucphat where canhanTu in (\(inClause)) or canhanDen in (\(inClause)) or tochucTu in (\(inClause)) or tochucDen in (\(inClause)))"
    }
    
    func getWhereClauseForPhuongtien() -> String {
        var inClause = ""
        if searchFilters["Phuongtien"]!["Oto"]!["chon"] != "0" {
            inClause += "oto = 1 or otoTai = 1 or "
        }
        
        if searchFilters["Phuongtien"]!["Xemay"]!["chon"] != "0"
        {
            inClause += "moto = 1 or xemaydien = 1 or xeganmay = 1 or "
        }
        
        if searchFilters["Phuongtien"]!["Xechuyendung"]!["chon"] != "0"
        {
            inClause += "maykeo = 1 or xechuyendung = 1 or "
        }
        
        if searchFilters["Phuongtien"]!["Tauhoa"]!["chon"] != "0"
        {
            inClause += "tau = 1 or "
        }
        
        if searchFilters["Phuongtien"]!["Xedap"]!["chon"] != "0"
        {
            inClause += "xedapmay = 1 or xedapdien = 1 or xethoso = 1 or sucvat = 1 or xichlo = 1 or "
        }
        
        if searchFilters["Phuongtien"]!["Dibo"]!["chon"] != "0" {
            inClause += "dibo = 1 or "
        }
        
//        inClause = inClause.substring(to: inClause.index(inClause.endIndex, offsetBy: -4))
        inClause = Utils.removeLastCharacters(result: inClause, length: 4)
        
        return " and dkID in (select distinct dieukhoanID from tblPhuongtien where \(inClause))"
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "filterPopup":
            guard let filterPopup = segue.destination as? MPSearchFilterPopupController else {
                fatalError("Unexpected destination: \(segue.destination)")
                
            }
            
            filterPopup.updateActiveFilterList(root: self)
            
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
            
            let selectedDieukhoan = dieukhoanList[indexPath.row]
            dieukhoanDetails.updateDetails(dieukhoan: selectedDieukhoan)
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "tblDieukhoanCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? VBPLTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Configure the cell...
        
        var dieukhoan:Dieukhoan
        
        if searchController.isActive && searchController.searchBar.text != "" {
            if dieukhoanList.count>0 {
                dieukhoan = dieukhoanList[indexPath.row]
            }else{
                dieukhoan = Dieukhoan(id: 0, cha: 0, vanban: Vanban(id: 0, ten: "", loai: Loaivanban(id: 0, ten: ""), so: "", nam: "", ma: "", coquanbanhanh: Coquanbanhanh(id: 0, ten: ""), noidung: ""))
                dieukhoan.setMinhhoa(minhhoa: [""])
            }
        } else {
            dieukhoan = dieukhoanList[indexPath.row]
        }
        
        cell.updateDieukhoan(dieukhoan: dieukhoan, fullDetails: false, showVanban: true)
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
        updateDieukhoanList(arrDieukhoan: search(keyword: searchText))
        rowCount = dieukhoanList.count
        tblView.reloadData()
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        //        if searchController.searchBar.text!.characters.count > 1 {
        builtQuery = getBuiltQuery(keyword: searchController.searchBar.text!)
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: "All")
        //        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
