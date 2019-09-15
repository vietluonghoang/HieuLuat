//
//  VKDTableViewController.swift
//  HieuLuat
//
//  Created by VietLH on 9/25/18.
//  Copyright © 2018 VietLH. All rights reserved.
//

import UIKit
import os.log
import GoogleMobileAds

class VKDTableController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UIGestureRecognizerDelegate, SearchControllers {
    
    
    @IBOutlet var adsView: UIView!
    @IBOutlet var svResult: UIScrollView!
    @IBOutlet var viewSearch: UIView!
    @IBOutlet var tblView: UITableView!
    @IBOutlet var consHeightTblView: NSLayoutConstraint!
    @IBOutlet var vachShapeSelectView: UIView!
    @IBOutlet var viewScrollviewWrapper: UIView!
    @IBOutlet var svVachShapeSelect: UIScrollView!
    @IBOutlet var viewScrollviewContent: UIView!
    @IBOutlet var vachShapeSelectFilterView: UIView!
    @IBOutlet var btnVachShapeGroupFilter: UIButton!
    @IBOutlet var lblVachShapeGroupFilter: UILabel!
    @IBOutlet var viewDetailsSelect: UIView!
    @IBOutlet var btnOnroad: UIButton!
    @IBOutlet var btnCross: UIButton!
    @IBOutlet var btnSidewalk: UIButton!
    @IBOutlet var btnObstacle: UIButton!
    
    var dieukhoanList = [Dieukhoan]()
    var rowCount = 0
    var bannerView: GADBannerView!
    let btnFBBanner = UIButton()
    var vachShapeGroups = [String]()
    var vachShapeGroupFiltersSelected = [String:Bool]()
    var vachShapesFiltered = [String]()
    var vachShapesSelected = [String:Bool]()
    var vachDetailsGroupsSelected = [String:Bool]()
    let onColor = UIColor.blue
    let offColor = UIColor(red:0.39377 , green: 0.891997, blue: 0.793788, alpha: 1.0)
    var shapeGroupNamePair = [String:String]()
    //    var offColor = UIColor.cyan
    let redirectionHelper = RedirectionHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tblView.delegate = self
        tblView.dataSource = self
        
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        initVachShapeGroupsList()
        updateFilterLabel()
        updateGroupsScrollView()
        if(dieukhoanList.count<1){
            updateSearchResults()
        }
        
        initAds()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnOnroadAct(_ sender: Any) {
        updateButtonState(btnName: "on road", button: btnOnroad)
    }
    
    @IBAction func btnCrossAct(_ sender: Any) {
        updateButtonState(btnName: "cross", button: btnCross)
    }
    
    @IBAction func btnSidewalkAct(_ sender: Any) {
        updateButtonState(btnName: "sidewalk", button: btnSidewalk)
    }
    
    @IBAction func btnObstacleAct(_ sender: Any) {
        updateButtonState(btnName: "obstacle", button: btnObstacle)
    }
    
    func updateButtonState(btnName: String,button: UIButton) {
        updateVachDetailsGroupSelected(details: btnName)
        Utils.updateButtonState(button: button, state: isButtonOn(btnName: btnName), onColor: onColor, offColor: offColor)
        updateSearchResults()
    }
    
    func updateVachDetailsGroupSelected(details: String){
        if vachDetailsGroupsSelected[details] == nil {
            vachDetailsGroupsSelected[details] = true
        } else {
            vachDetailsGroupsSelected[details] = !(vachDetailsGroupsSelected[details]!)
        }
    }
    
    func isButtonOn(btnName:String) -> Bool {
        if vachDetailsGroupsSelected[btnName] == nil {
            return false
        }
        return vachDetailsGroupsSelected[btnName]!
    }
    
    func initAds() {
        if GeneralSettings.isEnableBannerAds && AdsHelper.isConnectedToNetwork() {
            bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            AdsHelper.addBannerViewToView(bannerView: bannerView,toView: adsView, root: self)
        }else{
            btnFBBanner.addTarget(self, action: #selector(btnFouderFBAction), for: .touchDown)
            AdsHelper.addButtonToView(btnFBBanner: btnFBBanner, toView: adsView)
        }
    }
    
    func initVachShapeGroupsList() {
        
        for shapeGroup in Queries.getVachGroups() {
            vachShapeGroups.append(shapeGroup.key)
            shapeGroupNamePair[shapeGroup.key] = shapeGroup.value
            vachShapeGroupFiltersSelected[shapeGroup.key] = true
        }
    }
    
    func updateGroupsScrollView() {
        viewScrollviewWrapper.translatesAutoresizingMaskIntoConstraints = false
        svVachShapeSelect.translatesAutoresizingMaskIntoConstraints = false
        
        //remove all old content
        for content in viewScrollviewContent.subviews {
            content.removeFromSuperview()
        }
        
        //remove all filtered shapes
        vachShapesFiltered.removeAll()
        var order = 0
        var selectedVachGroups = [String]()
        for g in vachShapeGroupFiltersSelected {
            if g.value {
                selectedVachGroups.append(g.key)
            }
        }
        
        //get current selected shapes. Only selected shapes will be added to the list and get marked as false. If it appears in the as a shape in the filtered shape group, it will be turned to true. After updating filterd shapes, the shapes that is not in the list (still false) will be removed from vachShapesSelected (turn to false)
        var currentSelectedShapes = [String:Bool]()
        for s in vachShapesSelected {
            if s.value {
                currentSelectedShapes[s.key] = false
            }
        }
        
        let allShapes = Queries.getVachShapeByGroup(groups: selectedVachGroups)
        for shape in allShapes {
            let imgName = shape.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            
            //add shape name to a list for referencing when user selects a shape. Order of this list must be the same as image view to make sure that the correct shape will be refered properly.
            vachShapesFiltered.append(imgName)
            let vachShapeImage = UIImage(named: imgName)!
            
            if currentSelectedShapes[imgName] != nil {
                currentSelectedShapes[imgName] = true
            }
            
            let imgView = UIImageView(image: Utils.scaleImageSideward(image: vachShapeImage, targetHeight: 70))
            let imgViewWrapper = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            
            
            imgViewWrapper.translatesAutoresizingMaskIntoConstraints = false
            imgViewWrapper.clipsToBounds = true
            imgViewWrapper.contentMode = UIView.ContentMode.scaleAspectFit
            imgViewWrapper.autoresizesSubviews = true
            
            imgView.translatesAutoresizingMaskIntoConstraints = false
            imgView.clipsToBounds = true
            imgView.contentMode = UIView.ContentMode.scaleAspectFit
            imgView.autoresizesSubviews = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(selectVachShapeActionListener))
            imgView.isUserInteractionEnabled = true
            imgView.addGestureRecognizer(tap)
            imgView.tag = order
            
            
            Utils.updateViewState(view: imgViewWrapper, state: isVachShapeSelected(vachShapeName: imgName), onColor: onColor, offColor: offColor)
            Utils.generateNewComponentConstraints(parent: imgViewWrapper, topComponent: imgViewWrapper, bottomComponent: imgViewWrapper, component: imgView, top: 5, left: 5, right: 5, bottom: 5, isInside: true)
            
            if order == 0 {
                if allShapes.count == 1 {
                    Utils.generateNewComponentConstraintsSideward(parent: viewScrollviewContent, leftComponent: viewScrollviewContent, rightComponent: viewScrollviewContent, component: imgViewWrapper, top: 0, left: 0, right: 0, bottom: 0, isInside: true)
                }else{
                    Utils.generateNewComponentConstraintsSideward(parent: viewScrollviewContent, leftComponent: viewScrollviewContent, component: imgViewWrapper, top: 0, left: 0, bottom: 0, isInside: true)
                }
            }else{
                if order < (allShapes.count - 1) {
                    Utils.generateNewComponentConstraintsSideward(parent: viewScrollviewContent, leftComponent: (viewScrollviewContent.subviews.last)!, component: imgViewWrapper, top: 0, left: 5, bottom: 0, isInside: false)
                }else{
                    Utils.generateNewComponentConstraintsSideward(parent: viewScrollviewContent, leftComponent: (viewScrollviewContent.subviews.last)!, rightComponent: viewScrollviewContent, component: imgViewWrapper, top: 0, left: 5, right: 0, bottom: 0, isInside: false)
                }
            }
            order += 1
        }
        
        //remove already selected shapes but the shape is not available due to new shape groups filtered
        for s in vachShapesSelected {
            if s.value && currentSelectedShapes[s.key] == false {
                vachShapesSelected[s.key] = false
            }
        }
    }
    
    @objc func btnFouderFBAction() {
        redirectionHelper.openUrl(urls: GeneralSettings.getFBLink)
    }
    
    func updateDieukhoanList(arrDieukhoan: Array<Dieukhoan>)  {
        self.dieukhoanList=arrDieukhoan
    }
    
    func search() -> [Dieukhoan]{
        let kw = populateVachParams()
        var groups = [String]()
        
        for group in vachShapeGroupFiltersSelected {
            if group.value {
                groups.append(group.key)
            }
        }
        let rs = Queries.getVachByParams(params: kw, groups: groups)
        rowCount = rs.count
        
        return rs
    }
    
    func populateVachParams() -> [String] {
        var params = [String]()
        for shape in vachShapesSelected {
            if shape.value {
                params.append("tblVachShapes:\(shape.key)".trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        //this check is for the case where user changes the filter of shape groups but does not select any shape
        //since it shows empty result then comment it out for now
        //        if params.count < 1 {
        //            for shape in plateShapesFiltered {
        //                updatePlateShapeSelected(plateShapeName: shape)
        //            }
        //            for selectedShape in plateShapesSelected {
        //                if selectedShape.value {
        //                    params.append("tblPlateShapes:\(selectedShape.key)".trimmingCharacters(in: .whitespacesAndNewlines))
        //                }
        //            }
        //        }
        for detailsGroup in vachDetailsGroupsSelected {
            //TO DO: in future, if we support advance search which allows user to select a (or many) figures/signs in each group, the value that appends to 'params' should has the same form of 'plateShape' above (with colon in the midlle of group and figure/sign name)
            if detailsGroup.value {
                params.append("positions:\(detailsGroup.key)".trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        return params
    }
    
    func updateFilter(key: String, value: Bool) {
        vachShapeGroupFiltersSelected[key] = value
    }
    
    func isFilterSelected(key: String) -> Bool {
        return vachShapeGroupFiltersSelected[key]!
    }
    
    func updateFilterLabel() {
        var label = ""
        for group in vachShapeGroupFiltersSelected {
            if group.value {
                label += "\(shapeGroupNamePair[group.key]!), "
            }
        }
        
        if label.count > 0 {
            lblVachShapeGroupFilter.text = Utils.removeLastCharacters(result: label, length: 2)
        }else{
            lblVachShapeGroupFilter.text = label
        }
        
    }
    @objc func selectVachShapeActionListener(sender: UITapGestureRecognizer) {
        for view in viewScrollviewContent.subviews {
            for iv in view.subviews {
                if iv.tag == sender.view?.tag {
                    updateVachShapeSelected(vachShapeName: vachShapesFiltered[iv.tag])
                    Utils.updateViewState(view: view, state: isVachShapeSelected(vachShapeName: vachShapesFiltered[iv.tag]), onColor: onColor, offColor: offColor)
                } else {
                    if !GeneralSettings.isAllowMultipleShapePlateSelect && isVachShapeSelected(vachShapeName: vachShapesFiltered[iv.tag]){
                        updateVachShapeSelected(vachShapeName: vachShapesFiltered[iv.tag])
                        Utils.updateViewState(view: view, state: isVachShapeSelected(vachShapeName: vachShapesFiltered[iv.tag]), onColor: onColor, offColor: offColor)
                    }
                }
            }
        }
        updateSearchResults()
    }
    
    func isVachShapeSelected(vachShapeName: String) -> Bool {
        if vachShapesSelected[vachShapeName] == nil {
            return false
        }
        return vachShapesSelected[vachShapeName]!
    }
    
    func updateVachShapeSelected(vachShapeName: String) {
        if vachShapesSelected[vachShapeName] == nil {
            vachShapesSelected[vachShapeName] = true
        } else {
            vachShapesSelected[vachShapeName] = !(vachShapesSelected[vachShapeName]!)
        }
    }
    
    // MARK: - Table view data source
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
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
            guard let filterPopup = segue.destination as? BBFilterPopupViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            let headerText = "Lọc theo đặc điểm vạch kẻ đường"
            
            filterPopup.updateFilterPopup(root: self, options: vachShapeGroups,optionsText: shapeGroupNamePair, headerText: headerText)
            
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
            fatalError("The dequeued cell is not an instance of \(cellIdentifier).")
        }
        
        // Configure the cell...
        
        var dieukhoan:Dieukhoan
        
        if dieukhoanList.count>0 {
            dieukhoan = dieukhoanList[indexPath.row]
        }else{
            dieukhoan = Dieukhoan(id: 0, cha: 0, vanban: Vanban(id: 0, ten: "", loai: Loaivanban(id: 0, ten: ""), so: "", nam: "", ma: "", coquanbanhanh: Coquanbanhanh(id: 0, ten: ""), noidung: ""))
            dieukhoan.setMinhhoa(minhhoa: [""])
        }
        
        cell.updateDieukhoan(dieukhoan: dieukhoan, fullDetails: false, showVanban: true, maxText: 50)
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
        updateDieukhoanList(arrDieukhoan: search())
        rowCount = dieukhoanList.count
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: "All")
    }
    
    func updateSearchResults() {
        updateDieukhoanList(arrDieukhoan: search())
        //not sure why by when commenting out this line, the result table appears properly when there are no results.
        //        Utils.updateTableViewHeight(consHeightTblView: consHeightTblView, tblView: tblView, minimumHeight: 170)
        tblView.reloadData()
        tblView.layoutIfNeeded()
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
