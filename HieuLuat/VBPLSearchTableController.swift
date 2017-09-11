//
//  VBPLSearchTableController.swift
//  HieuLuat
//
//  Created by VietLH on 9/4/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit
import os.log

class VBPLSearchTableController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var searchbarView: UIView!
    
    @IBOutlet weak var consHeightTableView: NSLayoutConstraint!
    var dieukhoanList = [Dieukhoan]()
    let searchController = UISearchController(searchResultsController: nil)
    var rowCount = 0
    var filterSettings = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tblView.delegate = self
        tblView.dataSource = self
        
        initSearch()
        initFilterConfig()
        searchController.searchBar.becomeFirstResponder()
        print("\(searchController.searchBar.isFirstResponder)")
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        if(dieukhoanList.count<1){
            updateDieukhoanList(arrDieukhoan: search(keyword: searchController.searchBar.text!))
        }
        
        rowCount = dieukhoanList.count
        tblView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initSearch() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchbarView.addSubview(searchController.searchBar)
    }
    
    func initFilterConfig() {
        if(filterSettings.count < 1){
            filterSettings["QC41"] = "on"
            filterSettings["TT01"] = "on"
            filterSettings["ND46"] = "on"
            filterSettings["LGTDB"] = "on"
        }
    }
    
    func getActiveFilter() -> [String] {
        var activeFilterList = [String]()
        
        if(filterSettings["QC41"] == "on"){
            activeFilterList.append("1")
        }
        if(filterSettings["ND46"] == "on"){
            activeFilterList.append("2")
        }
        if(filterSettings["TT01"] == "on"){
            activeFilterList.append("3")
        }
        if(filterSettings["LGTDB"] == "on"){
            activeFilterList.append("4")
        }
        
        return activeFilterList
    }
    
    func updateDieukhoanList(arrDieukhoan: Array<Dieukhoan>)  {
        self.dieukhoanList=arrDieukhoan
    }
    
    func search(keyword:String) -> [Dieukhoan]{
        var rs = [Dieukhoan]()
        //print(getActiveFilter())
        if(keyword.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0){
            rs = Queries.searchDieukhoan(keyword: "\(keyword.trimmingCharacters(in: .whitespacesAndNewlines))", vanbanid: getActiveFilter())
        }else{
            rs = Queries.searchChildren(keyword: "\(keyword.trimmingCharacters(in: .whitespacesAndNewlines))", vanbanid: getActiveFilter())
        }
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
            
        case "vanbanHome":
            guard segue.destination is VBPLHomeDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
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
        
        cell.updateDieukhoan(dieukhoan: dieukhoan)
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
        updateDieukhoanList(arrDieukhoan: search(keyword: searchText))
        rowCount = dieukhoanList.count
        tblView.reloadData()
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: "All")
    }
    
}
