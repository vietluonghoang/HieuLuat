//
//  BBSearchTableController.swift
//  HieuLuat
//
//  Created by VietLH on 9/9/18.
//  Copyright © 2018 VietLH. All rights reserved.
//

import UIKit
import os.log
import GoogleMobileAds

class BBSearchTableController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UIGestureRecognizerDelegate {
    
    @IBOutlet var adsView: UIView!
    @IBOutlet var svResult: UIScrollView!
    @IBOutlet var viewSearch: UIView!
    @IBOutlet var tblView: UITableView!
    @IBOutlet var consHeightTblView: NSLayoutConstraint!
    @IBOutlet var plateShapeSelectView: UIView!
    @IBOutlet var viewScrollviewWrapper: UIView!
    @IBOutlet var svPlateShapeSelect: UIScrollView!
    @IBOutlet var viewScrollviewContent: UIView!
    @IBOutlet var plateShapeSelectFilterView: UIView!
    @IBOutlet var btnPlateShapeGroupFilter: UIButton!
    @IBOutlet var lblPlateShapeGroupFilter: UILabel!
    @IBOutlet var viewDetailsSelect: UIView!
    @IBOutlet var btnArrow: UIButton!
    @IBOutlet var btnAlphanumeric: UIButton!
    @IBOutlet var btnCreatures: UIButton!
    @IBOutlet var btnVehicles: UIButton!
    @IBOutlet var btnSigns: UIButton!
    @IBOutlet var btnStructures: UIButton!
    @IBOutlet var btnFigures: UIButton!
    @IBOutlet var btnExtras: UIButton!
    
    var dieukhoanList = [Dieukhoan]()
    var rowCount = 0
    var bannerView: GADBannerView!
    let btnFBBanner = UIButton()
    var plateShapeGroups = [String]()
    var plateShapeGroupFiltersSelected = [String:Bool]()
    var plateShapesFiltered = [String]()
    var plateShapesSelected = [String:Bool]()
    var plateDetailsGroupsSelected = [String:Bool]()
    let onColor = UIColor.blue
    let offColor = UIColor(red:0.39377 , green: 0.891997, blue: 0.793788, alpha: 1.0)
    let shapeGroupNamePair = ["Circle":"Hình tròn","Rectangle":"Hình chữ nhật","Arrow":"Hình mũi tên","Octagon":"Hình bát giác","Triangle":"Hình tam giác","Square":"Hình vuông","Rhombus":"Hình quả trám","Xshape":"Hình chữ X"]
    //    var offColor = UIColor.cyan
    
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
        initPlateShapeGroupsList()
        updateFilterLabel()
        updatePlateGroupsScrollView()
        if(dieukhoanList.count<1){
            updateSearchResults()
        }
        
        initAds()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnArrowAct(_ sender: Any) {
        updateButtonState(btnName: "Arrows", button: btnArrow)
    }
    
    @IBAction func btnAlphanumericAct(_ sender: Any) {
        updateButtonState(btnName: "Alphanumerics", button: btnAlphanumeric)
    }
    
    @IBAction func btnCreaturesAct(_ sender: Any) {
        updateButtonState(btnName: "Creatures", button: btnCreatures)
    }
    
    @IBAction func btnVehiclesAct(_ sender: Any) {
        updateButtonState(btnName: "Vehicles", button: btnVehicles)
    }
    
    @IBAction func btnSignsAct(_ sender: Any) {
        updateButtonState(btnName: "Signs", button: btnSigns)
    }
    
    @IBAction func btnStructuresAct(_ sender: Any) {
        updateButtonState(btnName: "Structures", button: btnStructures)
    }
    
    @IBAction func btnFiguresAct(_ sender: Any) {
        updateButtonState(btnName: "Figures", button: btnFigures)
    }
    
    @IBAction func btnExtrasAct(_ sender: Any) {
        //TO DO:
    }
    
    func updateButtonState(btnName: String,button: UIButton) {
        updatePlateDetailsGroupSelected(details: btnName)
        Utils.updateButtonState(button: button, state: isButtonOn(btnName: btnName), onColor: onColor, offColor: offColor)
        updateSearchResults()
    }
    
    func updatePlateDetailsGroupSelected(details: String){
        if plateDetailsGroupsSelected[details] == nil {
            plateDetailsGroupsSelected[details] = true
        } else {
            plateDetailsGroupsSelected[details] = !(plateDetailsGroupsSelected[details]!)
        }
    }
    
    func isButtonOn(btnName:String) -> Bool {
        if plateDetailsGroupsSelected[btnName] == nil {
            return false
        }
        return plateDetailsGroupsSelected[btnName]!
    }
    
    func initAds() {
        if GeneralSettings.isAdEnabled && AdsHelper.isConnectedToNetwork() {
            bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            AdsHelper.addBannerViewToView(bannerView: bannerView,toView: adsView, root: self)
        }else{
            btnFBBanner.addTarget(self, action: #selector(btnFouderFBAction), for: .touchDown)
            AdsHelper.addButtonToView(btnFBBanner: btnFBBanner, toView: adsView)
        }
    }
    
    func initPlateShapeGroupsList() {
        
        for shapeGroup in Queries.getPlateGroups() {
            plateShapeGroups.append(shapeGroup)
            plateShapeGroupFiltersSelected[shapeGroup] = true
        }
    }
    
    func updatePlateGroupsScrollView() {
        viewScrollviewWrapper.translatesAutoresizingMaskIntoConstraints = false
        svPlateShapeSelect.translatesAutoresizingMaskIntoConstraints = false
        
        //remove all old content
        for content in viewScrollviewContent.subviews {
            content.removeFromSuperview()
        }
        
        //remove all filtered plate shapes
        plateShapesFiltered.removeAll()
        var order = 0
        var selectedPlateGroups = [String]()
        for g in plateShapeGroupFiltersSelected {
            if g.value {
                selectedPlateGroups.append(g.key)
            }
        }
        
        //get current selected shapes. Only selected shapes will be added to the list and get marked as false. If it appears in the as a shape in the filtered shape group, it will be turned to true. After updating filterd shapes, the shapes that is not in the list (still false) will be removed from plateShapesSelected (turn to false)
        var currentSelectedShapes = [String:Bool]()
        for s in plateShapesSelected {
            if s.value {
                currentSelectedShapes[s.key] = false
            }
        }
        
        let allShapes = Queries.getPlateShapeByGroup(groups: selectedPlateGroups)
        for shape in allShapes {
            let imgName = shape.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            
            //add plate shape name to a list for referencing when user selects a shape. Order of this list must be the same as image view to make sure that the correct plate shape will be refered properly.
            plateShapesFiltered.append(imgName)
            let plateShapeImage = UIImage(named: imgName)!
            
            if currentSelectedShapes[imgName] != nil {
                currentSelectedShapes[imgName] = true
            }
            
            let imgView = UIImageView(image: Utils.scaleImageSideward(image: plateShapeImage, targetHeight: 40))
            let imgViewWrapper = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            
            
            imgViewWrapper.translatesAutoresizingMaskIntoConstraints = false
            imgViewWrapper.clipsToBounds = true
            imgViewWrapper.contentMode = UIViewContentMode.scaleAspectFit
            imgViewWrapper.autoresizesSubviews = true
            
            imgView.translatesAutoresizingMaskIntoConstraints = false
            imgView.clipsToBounds = true
            imgView.contentMode = UIViewContentMode.scaleAspectFit
            imgView.autoresizesSubviews = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(selectPlateShapeActionListener))
            imgView.isUserInteractionEnabled = true
            imgView.addGestureRecognizer(tap)
            imgView.tag = order
            
            
            Utils.updateViewState(view: imgViewWrapper, state: isPlateShapeSelected(plateShapeName: imgName), onColor: onColor, offColor: offColor)
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
        for s in plateShapesSelected {
            if s.value && currentSelectedShapes[s.key] == false {
                plateShapesSelected[s.key] = false
            }
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
    
    func updateDieukhoanList(arrDieukhoan: Array<Dieukhoan>)  {
        self.dieukhoanList=arrDieukhoan
    }
    
    func search() -> [Dieukhoan]{
        let kw = populatePlateParams()
        var groups = [String]()
        
        for group in plateShapeGroupFiltersSelected {
            if group.value {
                groups.append(group.key)
            }
        }
        let rs = Queries.getPlateByParams(params: kw, groups: groups)
        rowCount = rs.count
        
        return rs
    }
    
    func populatePlateParams() -> [String] {
        var params = [String]()
        for shape in plateShapesSelected {
            if shape.value {
                params.append("tblPlateShapes:\(shape.key)".trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        //this check is for the case where user changes the filter of shape groups but does not select any plate shape
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
        for detailsGroup in plateDetailsGroupsSelected {
            //TO DO: in future, if we support advance search which allows user to select a (or many) figures/signs in each group, the value that appends to 'params' should has the same form of 'plateShape' above (with colon in the midlle of group and figure/sign name)
            if detailsGroup.value {
                params.append("\(detailsGroup.key)".trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        return params
    }
    
    func updateFilter(key: String, value: Bool) {
        plateShapeGroupFiltersSelected[key] = value
    }
    
    func updateFilterLabel() {
        var label = ""
        for group in plateShapeGroupFiltersSelected {
            if group.value {
                label += "\(shapeGroupNamePair[group.key]!), "
            }
        }
        
        if label.count > 0 {
            lblPlateShapeGroupFilter.text = Utils.removeLastCharacters(result: label, length: 2)
        }else{
            lblPlateShapeGroupFilter.text = label
        }
        
    }
    func selectPlateShapeActionListener(sender: UITapGestureRecognizer) {
        for view in viewScrollviewContent.subviews {
            for iv in view.subviews {
                if iv.tag == sender.view?.tag {
                    updatePlateShapeSelected(plateShapeName: plateShapesFiltered[iv.tag])
                    Utils.updateViewState(view: view, state: isPlateShapeSelected(plateShapeName: plateShapesFiltered[iv.tag]), onColor: onColor, offColor: offColor)
                } else {
                    if !GeneralSettings.isAllowMultipleShapePlateSelect && isPlateShapeSelected(plateShapeName: plateShapesFiltered[iv.tag]){
                        updatePlateShapeSelected(plateShapeName: plateShapesFiltered[iv.tag])
                        Utils.updateViewState(view: view, state: isPlateShapeSelected(plateShapeName: plateShapesFiltered[iv.tag]), onColor: onColor, offColor: offColor)
                    }
                }
            }
        }
        updateSearchResults()
    }
    
    func isPlateShapeSelected(plateShapeName: String) -> Bool {
        if plateShapesSelected[plateShapeName] == nil {
            return false
        }
        return plateShapesSelected[plateShapeName]!
    }
    
    func updatePlateShapeSelected(plateShapeName: String) {
        if plateShapesSelected[plateShapeName] == nil {
            plateShapesSelected[plateShapeName] = true
        } else {
            plateShapesSelected[plateShapeName] = !(plateShapesSelected[plateShapeName]!)
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
            
            let headerText = "Lọc theo hình dạng biển báo"
            
            filterPopup.updateFilterPopup(root: self, options: plateShapeGroups,optionsText: shapeGroupNamePair, headerText: headerText)
            
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
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
