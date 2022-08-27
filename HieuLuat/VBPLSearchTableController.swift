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
    @IBOutlet var lblLoctheo: CustomizedLabel!
    @IBOutlet weak var searchbarView: UIView!
    @IBOutlet var searchTextView: UIView!
    @IBOutlet var microView: UIView!
    @IBOutlet var btnMicro: UIButton!
    @IBOutlet weak var consHeightTableView: NSLayoutConstraint!
    @IBOutlet var consSearchViewHeight: NSLayoutConstraint!
    @IBOutlet var viewBottom: UIView!
    
    private var dieukhoanList = [Dieukhoan]()
    let searchController = UISearchController(searchResultsController: nil)
    private var searchKeyword = ""
    private var rowCount = 0
    var filterSettings = [String:String]()
    private var bannerView: GADBannerView!
    private let btnFBBanner = UIButton()
    private let redirectionHelper = RedirectionHelper()
    
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
        AnalyticsHelper.sendAnalyticEvent(eventName: "open_screen", params: ["screen_name" : AnalyticsHelper.SCREEN_NAME_TRACUUVANBAN])
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
        searchTextView.addSubview(sBar)
        searchTextView.addConstraints(
            [NSLayoutConstraint(item: sBar,
                                attribute: .top,
                                relatedBy: .equal,
                                toItem: searchTextView,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: sBar,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: searchTextView,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: sBar,
                                attribute: .leading,
                                relatedBy: .equal,
                                toItem: searchTextView,
                                attribute: .leading,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: sBar,
                                attribute: .trailing,
                                relatedBy: .equal,
                                toItem: searchTextView,
                                attribute: .trailing,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: sBar,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: searchTextView,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
        ])
        consSearchViewHeight.constant = sBar.frame.height
        if #available(iOS 10.0, *) {
        }else{
            btnMicro.isHidden = true
        }
    }
    
    func setupSearchBarSize(){
        self.searchController.searchBar.frame.size.width = self.view.frame.size.width - microView.frame.size.width
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
    
    @IBAction func btnMicroAction(_ sender: Any) {
    }
    
    @objc func btnFouderFBAction() {
        redirectionHelper.openUrl(urls: GeneralSettings.getFBLink)
    }
    
    
    func initFilterConfig() {
        if(filterSettings.count < 1){
            //iterate all Vanban to get active ones
            for id in 0...GeneralSettings.getVanbanIdMax {
                let valid = GeneralSettings.getVanbanInfo(id: Int64(id), info: "valid")
                if valid.count > 0 {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy" //Your date format
                    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+7:00") //Current time zone
                    //according to date format your date string
                    guard let date = dateFormatter.date(from: valid) else {
                        fatalError()
                    }
                    
                    if Date() > date {
                        filterSettings[String(id)] = "on"
                    } else {
                        filterSettings[String(id)] = "off"
                    }
                }
            }
            //iterate active Vanban to deactivate replaced ones
            //TO DO: multiple replacement
            for id in filterSettings.keys {
                if filterSettings[id] == "on" && filterSettings[GeneralSettings.getVanbanInfo(id: Int64(id)!, info: "replace")] == "on" {
                    filterSettings[GeneralSettings.getVanbanInfo(id: Int64(id)!, info: "replace")] = "off"
                }
            }
        }
    }
    
    func updateFilterLabel() {
        var newLabel = ""
        for filter in filterSettings {
            if filter.value.lowercased() == "on" {
                newLabel += GeneralSettings.getVanbanInfo(id: Int64(filter.key)!, info: "shortname") + ", "
            }
        }
        if newLabel.count > 2 {
            //            newLabel = newLabel.substring(to: newLabel.index(newLabel.endIndex, offsetBy: -2))
            newLabel = Utils.removeLastCharacters(result: newLabel, length: 2)
        }
        lblLoctheo.text = newLabel
        lblLoctheo.setRegularCaptionLabel()
        viewTop.layoutIfNeeded()
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
        if(kw.count > 0){
            rs = Queries.searchDieukhoan(keyword: "\(kw)", vanbanid: getActiveFilter())
        }else{
            rs = Queries.searchChildren(keyword: "\(kw)", vanbanid: getActiveFilter())
        }
        let sortIt = SortUtil()
        return sortIt.sortByBestMatch(listDieukhoan: rs, keyword: kw)
    }
    
    public func updateSearchBarText(keyword: String){
        searchController.searchBar.text = keyword
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
            
        case "speechRecognizer":
            if #available(iOS 10.0, *) {
                guard let target = segue.destination as? SpeechRecognizerController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                target.setParentUI(parentUI: self)
            } else {
                // Fallback on earlier versions
            }
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
        
        cell.updateDieukhoan(dieukhoan: dieukhoan, fullDetails: false, showVanban: true,keywork: searchKeyword)
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
        self.searchKeyword = searchText
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
