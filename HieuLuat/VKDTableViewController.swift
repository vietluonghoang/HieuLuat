//
//  VKDTableViewController.swift
//  HieuLuat
//
//  Created by VietLH on 9/25/18.
//  Copyright © 2018 VietLH. All rights reserved.
//

import UIKit

class VKDTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UIGestureRecognizerDelegate {
    
    @IBOutlet var viewSearch: UIView!
    @IBOutlet var viewScrollviewWrapper: UIView!
    @IBOutlet var svPlateShapeSelect: UIScrollView!
    @IBOutlet var svResults: UIScrollView!
    @IBOutlet var tblView: UITableView!
    @IBOutlet var viewAds: UIView!
    var rowCount = 0
    var dieukhoanList = [Dieukhoan]()
    var plateShapeGroups = [String]()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rowCount
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
        
        cell.updateDieukhoan(dieukhoan: dieukhoan, fullDetails: false, showVanban: true)
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
            //        if searchController.searchBar.text!.characters.count > 1 {
//            filterContentForSearchText(searchText: searchController.searchBar.text!, scope: "All")
            //        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblView.delegate = self
        tblView.dataSource = self
        
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        initPlateShapeGroupsList()
//        updateFilterLabel()
        updatePlateGroupsScrollView()
//        if(dieukhoanList.count<1){
//            updateDieukhoanList(arrDieukhoan: search())
//        }
        
//        Utils.updateTableViewHeight(consHeightTblView: consHeightTblView, tblView: tblView, minimumHeight: 170)
//        tblView.reloadData()
//        tblView.layoutIfNeeded()
//        initAds()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initPlateShapeGroupsList() {
        for shapeGroup in Queries.getPlateGroups() {
            plateShapeGroups.append(shapeGroup)
//            plateShapeGroupFiltersSelected[shapeGroup] = true
        }
    }
    
    func updatePlateGroupsScrollView() {
        viewScrollviewWrapper.translatesAutoresizingMaskIntoConstraints = false
        svPlateShapeSelect.translatesAutoresizingMaskIntoConstraints = false
        var order = 0
        var selectedPlateGroups = [String]()
//        for g in plateShapeGroups {
           selectedPlateGroups.append(plateShapeGroups[0])
//        }
        
        print("=====sv:\(svPlateShapeSelect.frame.height)")
        print("== sub: \(svPlateShapeSelect.subviews)")
        
        let allGroups = [String]()
        for group in allGroups {
            let imgName = group.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            let plateShapeImage = UIImage(named: imgName)!
            
            let imgView = UIImageView(image: Utils.scaleImageSideward(image: plateShapeImage, targetHeight: 40))
            let imgViewWrapper = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            imgViewWrapper.translatesAutoresizingMaskIntoConstraints = false
            imgViewWrapper.clipsToBounds = true
            imgViewWrapper.contentMode = UIViewContentMode.scaleAspectFit
            imgViewWrapper.autoresizesSubviews = true
            imgViewWrapper.backgroundColor = UIColor.brown
            
            imgView.translatesAutoresizingMaskIntoConstraints = false
            imgView.clipsToBounds = true
            imgView.contentMode = UIViewContentMode.scaleAspectFit
            imgView.autoresizesSubviews = true
            imgView.isUserInteractionEnabled = true
//           let tap = UITapGestureRecognizer(target: self, action: #selector(selectPlateShapeActionListener)) imgView.addGestureRecognizer(tap)
            
            imgView.tag = order
            Utils.generateNewComponentConstraints(parent: imgViewWrapper, topComponent: imgViewWrapper, bottomComponent: imgViewWrapper, component: imgView, top: 5, left: 5, right: 5, bottom: 5, isInside: true)
            
            if order == 0 {
                if allGroups.count == 1 {
                    Utils.generateNewComponentConstraintsSideward(parent: svPlateShapeSelect, leftComponent: svPlateShapeSelect, rightComponent: svPlateShapeSelect, component: imgViewWrapper, top: 0, left: 0, right: 0, bottom: 0, isInside: true)
                }else{
                    Utils.generateNewComponentConstraintsSideward(parent: svPlateShapeSelect, leftComponent: svPlateShapeSelect, component: imgViewWrapper, top: 0, left: 0, bottom: 0, isInside: true)
                }
            }else{
                if order < (allGroups.count - 1) {
                    Utils.generateNewComponentConstraintsSideward(parent: svPlateShapeSelect, leftComponent: (svPlateShapeSelect.subviews.last)!, component: imgViewWrapper, top: 0, left: 5, bottom: 0, isInside: false)
                }else{
                    Utils.generateNewComponentConstraintsSideward(parent: svPlateShapeSelect, leftComponent: (svPlateShapeSelect.subviews.last)!, rightComponent: svPlateShapeSelect, component: imgViewWrapper, top: 0, left: 5, right: 0, bottom: 0, isInside: false)
                }
            }
            order += 1
            
        }
        
        var contentRect = CGRect.zero
        //
        for view in svPlateShapeSelect.subviews {
            contentRect = contentRect.union(view.frame)
        }
        print("======== \(contentRect)")
        
        print("=====sv:\(svPlateShapeSelect.frame.height)")
        print("== sub: \(svPlateShapeSelect.subviews)")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
