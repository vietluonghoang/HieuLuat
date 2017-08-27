//
//  QC41SeemoreTableController.swift
//  HieuLuat
//
//  Created by VietLH on 8/27/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit
import os.log

class QC41SeemoreTableController: UITableViewController {
    
    @IBOutlet weak var tblView: UITableView!
    
    var dieukhoanList = [Dieukhoan]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tblView.delegate = self
        tblView.dataSource = self
        tblView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateDieukhoanList(arrDieukhoan: Array<Dieukhoan>)  {
        self.dieukhoanList=arrDieukhoan
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        
//        super.prepare(for: segue, sender: sender)
//        
//        switch(segue.identifier ?? "") {
//            
//            //        case "AddItem":
//            //            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
//            
//        case "showDieukhoan":
//            guard let dieukhoanDetails = segue.destination as? QC41DetailsViewController else {
//                fatalError("Unexpected destination: \(segue.destination)")
//            }
//            
//            guard let selectedDieukhoanCell = sender as? DieukhoanTableViewCell else {
//                fatalError("Unexpected sender: \(String(describing: sender))")
//            }
//            
//            guard let indexPath = tblView.indexPath(for: selectedDieukhoanCell) else {
//                fatalError("The selected cell is not being displayed by the table")
//            }
//            
//            let selectedDieukhoan = dieukhoanList[indexPath.row]
//            dieukhoanDetails.updateDetails(dieukhoan: selectedDieukhoan)
//            //        case "viewImages":
//            //            guard let imageViews = segue.destination as? ImageViewController else {
//            //                fatalError("Unexpected destination: \(segue.destination)")
//            //            }
//            //
//            //            guard let selectedDieukhoanCell = sender as? DieukhoanTableViewCell else {
//            //                fatalError("Unexpected sender: \(String(describing: sender))")
//            //            }
//            //
//            //            guard let indexPath = tblView.indexPath(for: selectedDieukhoanCell) else {
//            //                fatalError("The selected cell is not being displayed by the table")
//            //            }
//            //
//            //            let images:[String] = ["QC41-Hinh_33","QC41-Hinh_33","QC41-Hinh_33","QC41-Hinh_33","QC41-Hinh_33","QC41-Hinh_33"]
//            //
//            //            imageViews.updateImages(images: images)
//            
//        default:
//            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
//        }
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "tblSeemoreCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? QC41SeemoreTableviewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Configure the cell...
        
        var dieukhoan:Dieukhoan
        
            dieukhoan = dieukhoanList[indexPath.row]
        
        cell.updateDieukhoan(dieukhoan: dieukhoan)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dieukhoanList.count
    }
    
    override func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
