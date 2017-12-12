//
//  TT01DetailsViewController.swift
//  HieuLuat
//
//  Created by VietLH on 9/2/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit
import os.log

class VBPLDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    //MARK: Properties
    
    @IBOutlet weak var lblVanban: UILabel!
    @IBOutlet weak var lblDieukhoan: UILabel!
    @IBOutlet weak var lblNoidung: UILabel!
    @IBOutlet var lblParentBreadscrub: UILabel!
    @IBOutlet weak var scvDetails: UIScrollView!
    @IBOutlet weak var svStackview: UIStackView!
    @IBOutlet weak var lblSeeMore: UIButton!
    @IBOutlet var consSvStackviewHeightBig: NSLayoutConstraint!
    @IBOutlet var consSvStackviewHeightSmall: NSLayoutConstraint!
    
    @IBOutlet var tblView: UITableView!
    @IBOutlet var consHeightTblView: NSLayoutConstraint!
    
    var children = [Dieukhoan]()
    var relatedChildren = [Dieukhoan]()
    var dieukhoan: Dieukhoan? = nil
    var search = SearchFor()
    var specificVanbanId = [String]()
    var images = [String]()
    let searchController = UISearchController(searchResultsController: nil)
    var rowCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //            scvDetails.autoresizingMask = UIViewAutoresizing.flexibleHeight
        
        tblView.delegate = self
        tblView.dataSource = self
        lblVanban.numberOfLines = 0
        lblVanban.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblDieukhoan.numberOfLines = 0
        lblDieukhoan.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblNoidung.numberOfLines = 0
        lblNoidung.lineBreakMode = NSLineBreakMode.byWordWrapping
        // Do any additional setup after loading the view.
        
        if(relatedChildren.count>0){
            lblSeeMore.isEnabled = true
        }else{
            lblSeeMore.isEnabled = false
        }
        showDieukhoan()
        
        tblView.reloadData()
        updateTableViewHeight()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func updateTableViewHeight() {
        consHeightTblView.constant = 50000
        tblView.reloadData()
        tblView.layoutIfNeeded()
        
        var tableHeight:CGFloat = 0
        for obj in tblView.visibleCells {
            if let cell = obj as? UITableViewCell {
                tableHeight += cell.bounds.height
            }
        }
        consHeightTblView.constant = tableHeight
        tblView.sizeToFit()
        tblView.layoutIfNeeded()
    }
    
    func updateDetails(dieukhoan: Dieukhoan) {
        self.dieukhoan = dieukhoan
        specificVanbanId.append( String(describing:dieukhoan.getVanban().getId()))
        let noidung = "\(String(describing: dieukhoan.getTieude())) \n \(String(describing: dieukhoan.getNoidung()))"
        
        for child in getChildren(keyword: String(describing: dieukhoan.id)) {
            children.append(child)
        }
        rowCount = children.count
        
        for child in getRelatedDieukhoan(noidung: noidung) {
            relatedChildren.append(child)
        }
        let relatedPlate = getRelatedPlatKeywords(content: noidung)
        
        //this is a stupid way to take related ones out, but simpler to get it worked with less code
        
        var sortedRelatedPlat = [Dieukhoan]()
        let sortIt = SortUtil()
        for k in relatedPlate {
            var key = k.lowercased()
            if key.characters.count>0 {
                let relatedChild = getRelatedChildren(keyword: key)
                var order = 0
                for child in sortIt.sortByBestMatch(listDieukhoan: relatedChild, keyword: key)
                {
                    if  getParent(keyword: search.getAncestersID(dieukhoan: child, vanbanId: specificVanbanId).components(separatedBy: "-")[0])[0].getSo().lowercased().contains("phụ lục"){
//                        let noidungChild = child.getTieude() + " "+child.getNoidung()
//                        let childContains = search.regexSearch(pattern: "((^|\\W)(\(key.replacingOccurrences(of: ".", with: "\\.")))(\\.)*($|\\W))|((^|\\W)(\(key.replacingOccurrences(of: ".", with: "\\.")))(\\.)*($|\\W))", searchIn: noidungChild).count>0
//                        
//                        if (childContains) {
//                            appendRelatedChild(child: child)
//                        }
                        child.setSortPoint(sortPoint: Int16(order))
                        sortedRelatedPlat.append(child)
                        order += 1
                    }
                }
            }
        }
        
        for relatedPlateItem in sortIt.sortBySortPoint(listDieukhoan: sortedRelatedPlat,isAscending: true) {
            appendRelatedChild(child: relatedPlateItem)
        }
        
        for child in getParent(keyword: String(describing: dieukhoan.cha)) {
            appendRelatedChild(child: child)
        }
        
    }
    
    func appendRelatedChild(child: Dieukhoan) {
        if child.id != self.dieukhoan?.id {
            var isExisted = false
            for c in relatedChildren {
                if c.getId() == child.getId(){
                    isExisted = true
                    break
                }
            }
            if !isExisted {
                relatedChildren.append(child)
            }
        }
    }
    
    func hideMinhhoaStackview(isHidden: Bool)  {
        consSvStackviewHeightBig.constant = 0
        consSvStackviewHeightSmall.constant = 0
        if(isHidden){
            svStackview.isHidden = true
            consSvStackviewHeightBig.isActive = false
            consSvStackviewHeightSmall.isActive = true
        }else{
            svStackview.isHidden = false
            consSvStackviewHeightBig.isActive = true
            consSvStackviewHeightSmall.isActive = false
        }
    }
    
    func imageViewScaleup(frameWidth: Float,imageView:UIImageView) {
        
        //        let ratio:Float = Float(imageView.frame.width)/Float(imageView.frame.height)
        let newWidth:Float = frameWidth - 10
        let newHeight:Float = (newWidth / Float(imageView.frame.width))*Float(imageView.frame.height)
        
        print("\(newWidth):\(+newHeight)")
        imageView.frame = CGRect(x: imageView.frame.minX, y: imageView.frame.minY, width: CGFloat(newWidth), height: CGFloat(newHeight))
    }
    
    
    func scaleImage(image: UIImage, targetWidth: CGFloat) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetWidth / image.size.width
        
        //        let ratio:Float = Float(size.width)/Float(size.height)
        
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        newSize = CGSize(width: size.width * widthRatio, height: CGFloat(Float(size.height) * Float(widthRatio)))
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func getChildren(keyword:String) -> [Dieukhoan] {
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        return Queries.searchChildren(keyword: "\(keyword)", vanbanid: specificVanbanId)
    }
    
    func getParent(keyword:String) -> [Dieukhoan] {
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        return Queries.searchDieukhoanByID(keyword: "\(keyword)", vanbanid: specificVanbanId)
    }
    
    func getRelatedChildren(keyword:String) -> [Dieukhoan] {
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        return Queries.searchDieukhoan(keyword: "\(keyword)", vanbanid: specificVanbanId)
    }
    
    func getRelatedDieukhoan(noidung:String) -> [Dieukhoan] {
        var nd = noidung.lowercased()
        var keywords = [String]()
        
        var pattern = "((((điểm)\\s((\\w)+(\\.)*)+(,)*(\\s)*)*((khoản)\\s((\\d)+(\\.)*)+(;|,)*(\\s)*)+)+((điều\\s((này)|((\\d)+)))*))"
        
        let longMatches = search.regexSearch(pattern: pattern, searchIn: noidung)
        
        for match in longMatches{
            nd = nd.replacingOccurrences(of: match, with: "")
            if(!search.isStringExisted(str: match, strArr: keywords)){
                keywords.append(match.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        
        pattern = "((điều)|(khoản)|(điểm)|(chương)|(mục)|(phần)|(phụ lục))(\\s)+(((\\d)|(\\w))+(\\.)*)+"
        
        let shortMatches = search.regexSearch(pattern: pattern, searchIn: nd)
        
        for match in shortMatches{
            nd = nd.replacingOccurrences(of: match, with: "")
            if(!search.isStringExisted(str: match, strArr: keywords)){
                keywords.append(match.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        
        var relatedDieukhoan = [Dieukhoan]()
        
        for key in keywords {
            let dk = parseRelatedDieukhoanKeywords(keyword: key)
            if dk.count > 0{
                for dkh in dk {
                    relatedDieukhoan.append(dkh)
                }
            }
        }
        return relatedDieukhoan
    }
    
    //this function is not good-implemented since the performance is quite bad. should take a look on this again to find a better solution
    func parseRelatedDieukhoanKeywords(keyword:String) -> [Dieukhoan] {
        let key = keyword.lowercased()
        var relatedDieukhoan = [Dieukhoan]()
        let sortIt = SortUtil()
        
        
        var pattern = "^((điều)|(khoản)|(điểm)|(chương)|(mục)|(phần)|(phụ lục))(\\s)+(((\\d)|(\\w))+(\\.)*)+$"
        if search.regexSearch(pattern: pattern, searchIn: key).count > 0 {
            for d in Queries.searchDieukhoanBySo(keyword: key, vanbanid: specificVanbanId) {
                relatedDieukhoan.append(d)
            }
        }else{
            var dieu: Dieukhoan? = nil
            
            pattern = "(điều)(\\s)+(((\\d)|(\\w))+(\\.)*)+$"
            for d in search.regexSearch(pattern: pattern, searchIn: key){
                if d == "điều này" {
                    dieu = search.getDieunay(currentDieukhoan: dieukhoan!, vanbanId: specificVanbanId)
                }else{
                    var rs = Queries.searchDieukhoanBySo(keyword: d, vanbanid: specificVanbanId)
                    if rs.count > 0 {
                        dieu = rs[0]
                    }else{
                        return sortIt.sortByBestMatch(listDieukhoan: relatedDieukhoan, keyword: key)
                    }
                }
            }
            pattern = "(((điểm)\\s((\\w)+(\\.)*)+(,)*(\\s)*)*((khoản)\\s((\\d)+(\\.)*)+)+)"
            for kd in search.regexSearch(pattern: pattern, searchIn: key) {
                pattern = "(khoản)(\\s)+(((\\d)|(\\w))+(\\.)*)+$"
                for k in search.regexSearch(pattern: pattern, searchIn: kd) {
                    var khoan = [Dieukhoan]()
                    for childKhoan in getChildren(keyword: "\(String(describing: dieu!.getId()))") {
                        if search.regexSearch(pattern: "^(\(k.components(separatedBy: " ")[1]))(\\.)*$", searchIn: childKhoan.getSo().lowercased()).count > 0 {
                            khoan.append(childKhoan)
                            break
                        }
                    }
                    pattern = "(điểm)(\\s)+((\\w)+(\\.)*)+"
                    let diem = search.regexSearch(pattern: pattern, searchIn: kd)
                    if diem.count > 0 {
                        for d in diem {
                            for k in khoan {
                                for dm in getChildren(keyword: "\(String(describing: k.getId()))") {
                                    if search.regexSearch(pattern: "^(\(d.components(separatedBy: " ")[1]))(\\.)*$", searchIn: dm.getSo().lowercased()).count > 0 {
                                        relatedDieukhoan.append(dm)
                                        break
                                    }
                                }
                            }
                        }
                    }else{
                        for k in khoan {
                            relatedDieukhoan.append(k)
                        }
                    }
                }
            }
        }
        return sortIt.sortByBestMatch(listDieukhoan: relatedDieukhoan, keyword: key)
    }
    
    func getRelatedPlatKeywords(content:String) -> [String] {
        let input = content.lowercased()
        
        let pattern = "(\\b(([a-zA-Z]{1,2})(\\.|,)+)+(\\d)+(\\.\\d)*([a-zA-Z])*\\b)|(\\b(vạch)(\\ssố)*\\s(\\d)+(\\.\\d)*(\\.)*\\b)"
        return search.regexSearch(pattern: pattern, searchIn: input)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "seeRelated":
            guard let dieukhoanSeemore = segue.destination as? VBPLDetailsSearchTableController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            dieukhoanSeemore.updateDieukhoanList(arrDieukhoan: relatedChildren)
            
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
            
            let selectedDieukhoan = children[indexPath.row]
            dieukhoanDetails.updateDetails(dieukhoan: selectedDieukhoan)
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    func showDieukhoan() {
        lblVanban.text = dieukhoan!.getVanban().getMa()
        lblDieukhoan.text = dieukhoan!.getSo()
        lblParentBreadscrub.text = search.getAncestersNumber(dieukhoan: dieukhoan!, vanbanId: [String(describing: dieukhoan!.getVanban().getId())])
        let noidung = "\(String(describing: dieukhoan!.getTieude())) \n \(String(describing: dieukhoan!.getNoidung()))"
        lblNoidung.text = noidung
        
        images = dieukhoan!.getMinhhoa()
        
        if(images.count > 0){
            
            hideMinhhoaStackview(isHidden: false)
            
            for img in images {
                if (img.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "")).trimmingCharacters(in: .whitespacesAndNewlines).characters.count < 1{
                    
                }else{
                    let image = scaleImage(image:UIImage(named: (img.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: "\n", with: "")).trimmingCharacters(in: .whitespacesAndNewlines))!,targetWidth: svStackview.frame.width)
                    
                    let imgView = UIImageView(image: image)
                    imgView.clipsToBounds = true
                    imgView.contentMode = UIViewContentMode.scaleAspectFit
                    
                    imageViewScaleup(frameWidth: Float(svStackview.frame.width), imageView: imgView)
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(seeMore))
                    imgView.isUserInteractionEnabled = true
                    imgView.addGestureRecognizer(tap)
                    imgView.translatesAutoresizingMaskIntoConstraints = false
                    svStackview.addArrangedSubview(imgView)
                    svStackview.addConstraints(
                        [
                            NSLayoutConstraint(item: imgView,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: svStackview,
                                            attribute: .leading,
                                            multiplier: 1,
                                            constant: 0),
                            NSLayoutConstraint(item: imgView,
                                            attribute: .trailing,
                                            relatedBy: .equal,
                                            toItem: svStackview,
                                            attribute: .trailing,
                                            multiplier: 1,
                                            constant: 0),
                            NSLayoutConstraint(item: imgView,
                                            attribute: .centerX,
                                            relatedBy: .equal,
                                            toItem: svStackview,
                                            attribute: .centerX,
                                            multiplier: 1,
                                            constant: 0)
                        ])
                }
                //                for child in children {
                //                    let lineView = UIView(frame: CGRect(x: 0, y: 0, width: svStackview.frame.width, height: 1))
                ////                    lineView.layer.borderWidth = 1.0
                ////                    lineView.layer.borderColor = UIColor.black!
                //                    lineView.backgroundColor = UIColor.black
                
                //                    let lblDK = UILabel()
                //                    lblDK.numberOfLines = 0
                //                    lblDK.lineBreakMode = NSLineBreakMode.byWordWrapping
                //                    lblDK.text = child.getSo()
                //                    lblDK.font = UIFont.boldSystemFont(ofSize: 14)
                //
                //                    let lblND = UILabel()
                //                    lblND.numberOfLines = 0
                //                    lblND.lineBreakMode = NSLineBreakMode.byWordWrapping
                //                    lblND.text = child.getTieude() + "\n " + child.getNoidung()
                //                    lblND.font = UIFont.systemFont(ofSize: 16)
                //
                //                    let space = UILabel()
                //                    space.numberOfLines = 0
                //                    space.lineBreakMode = NSLineBreakMode.byWordWrapping
                //                    space.text = "   "
                //
                //                    svStackview.addArrangedSubview(space)
                //                    svStackview.addArrangedSubview(lblDK)
                //                    svStackview.addArrangedSubview(lblND)
                //
//                                    let tap = UITapGestureRecognizer(target: self, action: #selector(seeMore))
//                                    lblND.isUserInteractionEnabled = true
//                                    lblND.addGestureRecognizer(tap)
                //                }
            }
        }else{
            hideMinhhoaStackview(isHidden: true)
        }
        
    }
    
    func seeMore(sender: UITapGestureRecognizer) {
        print("----------------------------\nI want to show image in zoom view but it could take more time to implement this while the benefit from this is not really high, then i'll let it like this until i have more time or i change my mind.\n----------------------------")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "tblDieukhoanCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? VBPLTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Configure the cell...
        
        var dieukhoan:Dieukhoan
        
        if searchController.isActive && searchController.searchBar.text != "" {
            if children.count>0 {
                dieukhoan = children[indexPath.row]
            }else{
                dieukhoan = Dieukhoan(id: 0, cha: 0, vanban: Vanban(id: 0, ten: "", loai: Loaivanban(id: 0, ten: ""), so: "", nam: "", ma: "", coquanbanhanh: Coquanbanhanh(id: 0, ten: ""), noidung: ""))
                dieukhoan.setMinhhoa(minhhoa: [""])
            }
        } else {
            dieukhoan = children[indexPath.row]
        }
        
        cell.updateDieukhoan(dieukhoan: dieukhoan, fullDetails: true, showVanban: false)
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
        //        updateDieukhoanList(arrDieukhoan: search(keyword: searchText))
        rowCount = children.count
        tblView.reloadData()
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: "All")
    }
}
