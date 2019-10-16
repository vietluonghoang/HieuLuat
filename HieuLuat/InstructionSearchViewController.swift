//
//  InstructionSearchViewController.swift
//  HieuLuat
//
//  Created by VietLH on 10/7/19.
//  Copyright © 2019 VietLH. All rights reserved.
//

import UIKit
import os.log
import GoogleMobileAds

class InstructionSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    var bannerView: GADBannerView!
    let btnFBBanner = UIButton()
    let redirectionHelper = RedirectionHelper()
    let searchController = UISearchController(searchResultsController: nil)
    var rowCount = 0
    let network = NetworkHandler()
    var isPhantichListReady = false
    var updatePhantichListTimer = Timer()
    var checkPhantichListInterval = 1 //in seconds
    var checkPhantichListTimeout = 90 //in seconds
    var rawPhantichList = [String:Phantich]()
    var phantichList = [String:Phantich]()
    var phantichListKeys = [String]()
    
    @IBOutlet var viewTop: UIView!
    @IBOutlet var searchbarView: UIView!
    @IBOutlet var viewFilter: UIView!
    @IBOutlet var viewBottom: UIView!
    @IBOutlet var tblView: UITableView!
    @IBOutlet var searchBarViewHeight: NSLayoutConstraint!
    @IBOutlet var viewCover: UIView!
    @IBOutlet var viewGrayLayer: UIView!
    @IBOutlet var viewLoadingIndicator: UIView!
    @IBOutlet var viewLoading: LoadingView!
    @IBOutlet var lblLoadingText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.delegate = self
        tblView.dataSource = self
        // Do any additional setup after loading the view.
        showCoverLayer(show: true)
        if AdsHelper.isConnectedToNetwork() {
            getPhantichList()
            if DataConnection.database == nil {
                DataConnection.databaseSetup()
            }
            
            initSearch()
            initAds()
            getPhantichListFromDatabase()
        }
        //TO DO: viết logic xử lý dữ liệu từ server và chuẩn bị dữ liệu cho phần hiển thị. Cần xử lý thời gian chờ load
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func showCoverLayer(show: Bool) {
        if show {
            viewLoadingIndicator.layer.cornerRadius = 20
            viewLoading.showSpinner()
            viewCover.alpha = 1
            viewCover.isHidden = false
            if !AdsHelper.isConnectedToNetwork(){
                lblLoadingText.text = "Lỗi kết nối mạng!\nHãy kiểm tra kết nối và mở lại sau..."
            }else{
                lblLoadingText.text = "Đang xử lý dữ liệu..."
            }
        }else {
            viewCover.alpha = 0
            viewCover.isHidden = true
        }
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
        searchBarViewHeight.constant = sBar.frame.height
    }
    
    @objc func btnFouderFBAction() {
        redirectionHelper.openUrl(urls: GeneralSettings.getFBLink)
    }
    
    @objc func checkPhantichList(){
        print("Checking data....")
        if rawPhantichList.count < 1 {
            print("Waiting for response....")
            if !isPhantichListReady && phantichList.count > 0 {
                print("Found local data!")
                showCoverLayer(show: false)
                isPhantichListReady = true
            }
            initPhantichList()
        }else {
            print("Received response....")
            updatePhantichListTimer.invalidate()
            showCoverLayer(show: true)
            isPhantichListReady = false
            print("Checking data revison....")
            if (phantichList.count > 0 && (phantichList.first!.value.getRevision() < rawPhantichList.first!.value.getRevision()) || (phantichList.count < 1)){
                print("Updating local data....")
                var isSuccess = Queries.insertPhantichToDatabase(phantichList: rawPhantichList) //TO DO: should have a fallback solution for this, in case if it failed to insert data
                getPhantichListFromDatabase()
            }else{
                print("No newer data!")
            }
            
            //finish updating data
            showCoverLayer(show: false)
            isPhantichListReady = true
            print("Done updating data!")
        }
    }
    
    func getPhantichList() {
        let target = "https://wethoong-server.herokuapp.com/phantich/getphantich/"
        let mimeType = "application/json"
        network.requestData(url: target, mimeType: mimeType)
        if !isPhantichListReady {
            updatePhantichListTimer = Timer.scheduledTimer(timeInterval: TimeInterval(checkPhantichListInterval), target: self, selector: #selector(checkPhantichList), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func btnAction(_ sender: Any) {
        Queries.executeUpdateQuery(query: "delete from phantich")
        Queries.executeUpdateQuery(query: "delete from phantich_details")
    }
    
    //TO DO: phần này cần triển khai đoạn tìm kiếm dựa trên tiêu đề và thông tin vắn tắt
    
    func initPhantichList(){
        print("Initializing raw data")
        let result = network.getMessage()
        if result.getValue(key: MessagingContainer.MessageKey.data.rawValue) is String   {
            print("Error getting data: \(result.getValue(key: MessagingContainer.MessageKey.message.rawValue) as! String)")
        }else{
            let rawData = result.getValue(key: MessagingContainer.MessageKey.data.rawValue)
            //                let configs = try JSONSerialization.data(withJSONObject: rawData, options: [])
            if let phantich = rawData as? [AnyObject]   {
//                print("configs: \(phantich)")
                for ptich in phantich{
                    if let pt = ptich as? Dictionary<String, String> {
                        if rawPhantichList[pt["id_key"]!] == nil {
                            let phantichRaw = Phantich(idKey: pt["id_key"]!, author: pt["author"]!,title: pt["title"]!,shortContent: pt["shortdescription"]!, source: pt["source"]!, revision: pt["revision"]!,rawContentDetailed: pt )
                            rawPhantichList[pt["id_key"]!] = phantichRaw
                        } else {
                            rawPhantichList[pt["id_key"]!]!.updateRawContentDetailed(rawContentDetailed: pt)
                        }
                    }else{
                        
                        //cast to dictionary of String:String
                        let pt = ptich as? Dictionary<String, AnyObject>
                        var newPt = [String:String]()
                        newPt["id_key"] = pt!["id_key"] as! String
                        newPt["author"] = pt!["author"] as! String
                        newPt["title"] = pt!["title"] as! String
                        newPt["shortdescription"] = pt!["shortdescription"] as! String
                        newPt["source"] = pt!["source"] as! String
                        newPt["minhhoa"] = pt!["minhhoa"] as! String
                        newPt["content"] = pt!["content"] as! String
                        newPt["minhhoatype"] = pt!["minhhoatype"] as! String
                        newPt["contentorder"] = "\(pt!["contentorder"] as! Int)"
                        newPt["revision"] = "\(pt!["revision"] as! Int)"
                        
                        if rawPhantichList[newPt["id_key"]!] == nil {
                            let phantichRaw = Phantich(idKey: newPt["id_key"]!, author: newPt["author"]!,title: newPt["title"]!,shortContent: newPt["shortdescription"]!, source: newPt["source"]!, revision: newPt["revision"]!,rawContentDetailed: newPt )
                            rawPhantichList[newPt["id_key"]!] = phantichRaw
                        } else {
                            rawPhantichList[newPt["id_key"]!]!.updateRawContentDetailed(rawContentDetailed: newPt)
                        }
                    }
                }
            }else{
                print("Actual type of raw data: \(type(of: rawData))")
            }
        }
    }
    
    func getPhantichListFromDatabase() {
        print("Get data from local")
        updatePhantichList(arrPhantich: Queries.getAllPhantich())
    }
    
    func updatePhantichList(arrPhantich: [String:Phantich])  {
        self.phantichList = arrPhantich
        self.phantichListKeys = Array(phantichList.keys) //need keys in order to generate table view
        rowCount = phantichList.count
        tblView.reloadData()
    }
    
    func search( keyword: String) -> [String:Phantich] {
        if isPhantichListReady {
            var rs = [String:Phantich]()
                    let kw = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
                    if(kw.count > 0){
                        rs = Queries.getPhantichByKeyword(keyword: kw)
                    }else{
                        rs = Queries.getAllPhantich()
                    }
            return rs
        }
        return phantichList
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        updatePhantichList(arrPhantich: search(keyword: searchText))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCount
    }
    
    //TO DO: đoạn này xử lý để hiển thị dữ liệu vắn tắt cho danh sách các hướng dẫn
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "lawInstructionCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? InstructionTableViewCell else {
            fatalError("The dequeued cell is not an instance of InstructionTableViewCell.")
        }
        
        // Configure the cell...
        
        var phantich:Phantich
        
//        if searchController.isActive && searchController.searchBar.text != "" && phantichList.count > 0 {
            phantich = phantichList[phantichListKeys[indexPath.row]]!
//        }else{
//            phantich = Phantich(idKey: "", author: "", title: "Đang cập nhật dữ liệu...", shortContent: "", source: "", revision: "0", rawContentDetailed: [String:String]())
//        }
        
        cell.updatePhantich(phantich: phantich)
        return cell
    }
    
    
    //TO DO: đoạn này xử lý dữ liệu khi chuyển tiếp xem chi tiết bài hướng dẫn
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "showPhantich":
            guard let phantichDetails = segue.destination as? InstructionDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedPhantichCell = sender as? InstructionTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tblView.indexPath(for: selectedPhantichCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedPhantich = phantichList[phantichListKeys[indexPath.row]]!
            phantichDetails.updateDetails(phantich: selectedPhantich)
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: "All")
    }
}
