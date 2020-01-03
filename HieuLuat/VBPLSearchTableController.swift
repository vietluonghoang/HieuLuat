//
//  VBPLSearchTableController.swift
//  HieuLuat
//
//  Created by VietLH on 9/4/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit
import os.log
import GoogleMobileAds

class VBPLSearchTableController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet var viewTop: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet var lblLoctheo: UILabel!
    @IBOutlet weak var searchbarView: UIView!
    @IBOutlet weak var consHeightTableView: NSLayoutConstraint!
    @IBOutlet var consSearchViewHeight: NSLayoutConstraint!
    @IBOutlet var viewBottom: UIView!
    
    var dieukhoanList = [Dieukhoan]()
    let searchController = UISearchController(searchResultsController: nil)
    var rowCount = 0
    var filterSettings = [String:String]()
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
    
    func setupSearchBarSize(){
        self.searchController.searchBar.frame.size.width = self.view.frame.size.width
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        setupSearchBarSize()
    }
    
    override func viewDidLayoutSubviews() {
        setupSearchBarSize()
    }
    
    func initAds() {
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        btnFBBanner.addTarget(self, action: #selector(btnFouderFBAction), for: .touchDown)
        AdsHelper.initBannerAds(btnFBBanner: btnFBBanner, bannerView: bannerView, toView: viewBottom, root: self)
    }
    
    @objc func btnFouderFBAction() {
        redirectionHelper.openUrl(urls: GeneralSettings.getFBLink)
    }

    
    func initFilterConfig() {
        if(filterSettings.count < 1){
            filterSettings["QC41"] = "on"
            filterSettings["TT01"] = "on"
            filterSettings["ND46"] = "on"
            filterSettings["LGTDB"] = "on"
            filterSettings["LXLVPHC"] = "on"
        }
    }
    
    func updateFilterLabel() {
        var newLabel = ""
        for filter in filterSettings {
            if filter.value.lowercased() == "on" {
                newLabel += GeneralSettings.getVanbanInfo(name: filter.key, info: "fullName") + ", "
            }
        }
        if newLabel.count > 2 {
            newLabel = newLabel.substring(to: newLabel.index(newLabel.endIndex, offsetBy: -2))
        }
        lblLoctheo.text = newLabel
        viewTop.layoutIfNeeded()
    }
    
    func getActiveFilter() -> [String] {
        var activeFilterList = [String]()
        
        if(filterSettings["QC41"] == "on"){
            activeFilterList.append("1")
        }
        //TO DO: temporarily change to ND100/2019
        if(filterSettings["ND46"] == "on"){
            activeFilterList.append("6")
        }
        if(filterSettings["TT01"] == "on"){
            activeFilterList.append("3")
        }
        if(filterSettings["LGTDB"] == "on"){
            activeFilterList.append("4")
        }
        if(filterSettings["LXLVPHC"] == "on"){
            activeFilterList.append("5")
        }
        return activeFilterList
    }
    
    func updateDieukhoanList(arrDieukhoan: Array<Dieukhoan>)  {
        self.dieukhoanList=arrDieukhoan
    }
    
    func search(keyword:String) -> [Dieukhoan]{
        var rs = [Dieukhoan]()
        var kw = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        //print(getActiveFilter())
        if(kw.count > 0){
            rs = Queries.searchDieukhoan(keyword: "\(kw)", vanbanid: getActiveFilter())
        }else{
            rs = Queries.searchChildren(keyword: "\(kw)", vanbanid: getActiveFilter())
        }
        let sortIt = SortUtil()
        return sortIt.sortByBestMatch(listDieukhoan: rs, keyword: kw)
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
            
//        case "vanbanHome":
//            guard segue.destination is VBPLHomeDetailsViewController else {
//                fatalError("Unexpected destination: \(segue.destination)")
//            }
            
        case "filterPopup":
            guard let filterPopup = segue.destination as? FilterPopupViewController else {
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
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: "All")
        //        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
