//
//  TT01SearchTableController.swift
//  HieuLuat
//
//  Created by VietLH on 9/2/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit
import os.log
import GoogleMobileAds

class VBPLDetailsSearchTableController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet var viewAds: UIView!
    
    var dieukhoanList = [Dieukhoan]()
    var specificVanbanId = [String]()
    let searchController = UISearchController(searchResultsController: nil)
    var rowCount = 0
    var bannerView: GADBannerView!
    let btnFBBanner = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tblView.delegate = self
        tblView.dataSource = self
        
//        initSearch()
        
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        if(dieukhoanList.count<1){
            updateDieukhoanList(arrDieukhoan: Queries.searchChildren(keyword: "", vanbanid: specificVanbanId))
        }
        rowCount = dieukhoanList.count
        tblView.reloadData()
        tblView.layoutIfNeeded()
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
        tblView.tableHeaderView = searchController.searchBar
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
    
    @objc func btnFouderFBAction() {
        let url = URL(string: GeneralSettings.getFBLink)
        if UIApplication.shared.canOpenURL(url!) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url!)
            }
        }
    }
    
    func updateDieukhoanList(arrDieukhoan: Array<Dieukhoan>)  {
        self.dieukhoanList=arrDieukhoan
    }
    func updateVanbanId(vanbanId: [String]) {
        self.specificVanbanId = vanbanId
    }
    
    func search(keyword:String) -> [Dieukhoan]{
        var rs:[Dieukhoan]
        rs=Queries.searchDieukhoan(keyword: "\(keyword)", vanbanid: specificVanbanId)
        return rs
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
            
            //        case "AddItem":
            //            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
            
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
            fatalError("The dequeued cell is not an instance of VBPLDetailsSearchTableViewCell.")
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
        
        cell.updateDieukhoan(dieukhoan: dieukhoan, fullDetails: true, showVanban: true)
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
        updateDieukhoanList(arrDieukhoan: search(keyword: searchText.trimmingCharacters(in: .whitespacesAndNewlines)))
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
