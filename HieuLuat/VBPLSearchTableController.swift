//
//  VBPLSearchTableController.swift
//  HieuLuat
//
//  Created by VietLH on 9/4/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import GoogleMobileAds
import UIKit
import os.log

class VBPLSearchTableController: UIViewController, UITableViewDelegate,
    UITableViewDataSource, UISearchBarDelegate
{

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
    let searchBar = UISearchBar()
    private var searchKeyword = ""
    private var rowCount = 0
    var filterSettings = [String: String]()
    private var bannerView: BannerView!
    private let btnFBBanner = UIButton()
    private let redirectionHelper = RedirectionHelper()
    
    
    private var delayTimer: Timer?
    private var lastInputUpdatedTimestamp: Int = 0
    private var delayedEventname = ""
    private var delayedEventParams = ["": ""]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        tblView.delegate = self
        tblView.dataSource = self

        // Modern UI styling
        view.backgroundColor = AppColors.surfaceVariant
        tblView.backgroundColor = .clear
        tblView.separatorStyle = .none
        tblView.contentInset = UIEdgeInsets(top: AppSpacing.sm, left: 0, bottom: AppSpacing.sm, right: 0)
        viewTop?.backgroundColor = AppColors.surface
        viewBottom?.backgroundColor = AppColors.surface

        initSearch()
        initFilterConfig()
        updateFilterLabel()

        if dieukhoanList.count < 1 {
            updateDieukhoanList(
                arrDieukhoan: search(keyword: searchBar.text ?? ""))
        }

        rowCount = dieukhoanList.count
        tblView.reloadData()
        initAds()
        AnalyticsHelper.sendAnalyticEvent(
            eventName: "open_screen",
            params: ["screen_name": AnalyticsHelper.SCREEN_NAME_TRACUUVANBAN])
        AnalyticsHelper.sendAnalyticEventMixPanel(
            eventName: "screen_open",
            params: ["screen_name": AnalyticsHelper.SCREEN_NAME_TRACUUVANBAN])
    }

    func initSearch() {
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchTextView.clipsToBounds = true
        searchTextView.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: searchTextView.topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: searchTextView.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: searchTextView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: searchTextView.trailingAnchor),
        ])
        // Modern search bar styling
        searchBar.searchBarStyle = .minimal
        searchBar.barTintColor = AppColors.surface
        searchBar.tintColor = AppColors.primary
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = AppColors.surfaceVariant
            textField.textColor = AppColors.onSurface
            textField.font = AppTypography.bodyMedium
            textField.layer.cornerRadius = AppRadius.md
            textField.clipsToBounds = true
            let placeholderText = NSAttributedString(
                string: "Tìm kiếm văn bản pháp luật...",
                attributes: [
                    .foregroundColor: AppColors.onSurfaceVariant,
                    .font: AppTypography.bodyMedium
                ]
            )
            textField.attributedPlaceholder = placeholderText
        }
        if #available(iOS 10.0, *) {
        } else {
            btnMicro.isHidden = true
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText: searchText)
    }

    func initAds() {
        bannerView = BannerView(adSize: kGADAdSizeSmartBannerPortrait)
        btnFBBanner.addTarget(
            self, action: #selector(btnFouderFBAction), for: .touchDown)
        AdsHelper.initBannerAds(
            btnFBBanner: btnFBBanner, bannerView: bannerView,
            toView: viewBottom, root: self)
    }

    @IBAction func btnMicroAction(_ sender: Any) {
    }

    @objc func btnFouderFBAction() {
        redirectionHelper.openUrl(urls: GeneralSettings.getFBLink)
    }

    func initFilterConfig() {
        if filterSettings.count < 1 {
            //iterate all Vanban to get active ones.
            print("++++++ Setting up filter settings")
            for id in 0...GeneralSettings.getVanbanIdMax {
                let valid = GeneralSettings.getVanbanInfo(
                    id: Int64(id), info: "valid")
                if valid.count > 0 {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"  //Your date format
                    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+7:00")  //Current time zone
                    //according to date format your date string
                    guard let date = dateFormatter.date(from: valid) else {
                        fatalError()
                    }

                    if Date() > date {
                        filterSettings[String(id)] = "on"
                        print("vanban \(id) is valid => ON")
                    } else {
                        filterSettings[String(id)] = "off"
                        print("vanban \(id) is valid => ON")
                    }
                }
            }
            //iterate active Vanban to deactivate replaced ones
            //TO DO: multiple replacement
            for id in filterSettings.keys {
                if filterSettings[id] == "on" {  //only check if the filter is on, which means either it's valid or not being replaced
                    print("Checking vanban \(id) for replacement")
                    var toReplaceVanbanId = GeneralSettings.getVanbanInfo(
                        id: Int64(id)!, info: "replace")
                    print("vanban \(id) to replace vanban \(toReplaceVanbanId)")
                    while toReplaceVanbanId != "0" {  //turn off all vanban until the last one in the hierarchy
                        filterSettings[toReplaceVanbanId] = "off"
                        print("vanban \(toReplaceVanbanId) is turning off")
                        print(
                            "vanban \(toReplaceVanbanId) to replace vanban....")
                        toReplaceVanbanId = GeneralSettings.getVanbanInfo(
                            id: Int64(toReplaceVanbanId)!, info: "replace")
                        print("...... \(toReplaceVanbanId)")
                    }
                }
            }
        }
    }

    func updateFilterLabel() {
        var newLabel = ""
        for filter in filterSettings {
            if filter.value.lowercased() == "on" {
                newLabel +=
                    GeneralSettings.getVanbanInfo(
                        id: Int64(filter.key)!, info: "shortname") + ", "
            }
        }
        if newLabel.count > 2 {
            //            newLabel = newLabel.substring(to: newLabel.index(newLabel.endIndex, offsetBy: -2))
            newLabel = Utils.removeLastCharacters(result: newLabel, length: 2)
        }
        lblLoctheo.text = newLabel
        lblLoctheo.setRegularCaptionLabel()
        lblLoctheo.textColor = AppColors.primary
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

    func updateDieukhoanList(arrDieukhoan: [Dieukhoan]) {
        self.dieukhoanList = arrDieukhoan
    }

    func search(keyword: String) -> [Dieukhoan] {
        var rs = [Dieukhoan]()
        let kw = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //print(getActiveFilter())
        if kw.count > 0 {
            rs = Queries.searchDieukhoan(
                keyword: "\(kw)", vanbanid: getActiveFilter())
            
            //send analytics event
            print("+++++ MixPanel trigger delayed event")
            triggerDelayedAnalyticEventSendTimer(
                timestamp: Int(NSDate().timeIntervalSince1970), timeout: 0,
                eventName: "Search", params: ["keyword": kw])
        } else {
            rs = Queries.searchChildren(
                keyword: "\(kw)", vanbanid: getActiveFilter())
        }
        let sortIt = SortUtil()
        return sortIt.sortByBestMatch(listDieukhoan: rs, keyword: kw)
    }

    public func updateSearchBarText(keyword: String) {
        searchBar.text = keyword
        filterContentForSearchText(searchText: keyword)
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

        switch segue.identifier ?? "" {

        //        case "vanbanHome":
        //            guard segue.destination is VBPLHomeDetailsViewController else {
        //                fatalError("Unexpected destination: \(segue.destination)")
        //            }

        case "filterPopup":
            guard
                let filterPopup = segue.destination
                    as? FilterPopupViewController
            else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            filterPopup.updateActiveFilterList(root: self)

        case "showDieukhoan":
            guard
                let dieukhoanDetails = segue.destination
                    as? VBPLDetailsViewController
            else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let selectedDieukhoanCell = sender as? VBPLTableViewCell
            else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }

            guard let indexPath = tblView.indexPath(for: selectedDieukhoanCell)
            else {
                fatalError(
                    "The selected cell is not being displayed by the table")
            }

            let selectedDieukhoan = dieukhoanList[indexPath.row]
            dieukhoanDetails.updateDetails(dieukhoan: selectedDieukhoan)

        case "speechRecognizer":
            if #available(iOS 10.0, *) {
                guard
                    let target = segue.destination
                        as? SpeechRecognizerController
                else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                target.setParentUI(parentUI: self)
            } else {
                // Fallback on earlier versions
            }
        default:
            fatalError(
                "Unexpected Segue Identifier; \(String(describing: segue.identifier))"
            )
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cellIdentifier = "tblDieukhoanCell"

        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier, for: indexPath)
                as? VBPLTableViewCell
        else {
            fatalError(
                "The dequeued cell is not an instance of MealTableViewCell.")
        }

        // Configure the cell...

        var dieukhoan: Dieukhoan

        if dieukhoanList.count > 0 {
            dieukhoan = dieukhoanList[indexPath.row]
        } else {
            dieukhoan = Dieukhoan(
                id: 0, cha: 0,
                vanban: Vanban(
                    id: 0, ten: "", loai: Loaivanban(id: 0, ten: ""),
                    so: "", nam: "", ma: "",
                    coquanbanhanh: Coquanbanhanh(id: 0, ten: ""),
                    noidung: ""))
            dieukhoan.setMinhhoa(minhhoa: [""])
        }

        cell.updateDieukhoan(
            dieukhoan: dieukhoan, fullDetails: false, showVanban: true,
            keywork: searchKeyword)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return rowCount
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return UITableView.automaticDimension
    }

    func tableView(
        _ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return UITableView.automaticDimension
    }

    func filterContentForSearchText(searchText: String, scope: String = "All") {
        self.searchKeyword = searchText
        updateDieukhoanList(arrDieukhoan: search(keyword: searchText))
        rowCount = dieukhoanList.count
        tblView.reloadData()
    }

    func updateSearchResults() {
        filterContentForSearchText(searchText: searchBar.text ?? "")
    }

    func triggerDelayedAnalyticEventSendTimer(
        timestamp: Int, timeout: Int, eventName: String,
        params: [String: String]
    ) {
        lastInputUpdatedTimestamp = timestamp
        if timeout > 0 {
            GeneralSettings.getDefaultMixPanelEventSendTimeout = timeout
        }
        delayedEventname = eventName
        delayedEventParams = params
        if !(delayTimer?.isValid ?? false) {  //by default, the check returns false the same as the timer was invalidated
            print("+++++ MixPanel timer starting...")
            delayTimer = Timer.scheduledTimer(
                timeInterval: TimeInterval(
                    GeneralSettings.getDefaultMixPanelEventSendTimeout / 1000),
                target: self, selector: #selector(checkDelayedAnalyticEvent),
                userInfo: nil, repeats: true)
        } else {
            print(
                "+++++ MixPanel timer: \(String(describing: delayTimer?.isValid))"
            )
        }
    }
    
    func sendDelayedAnalyticEvent() {
        if Int(NSDate().timeIntervalSince1970)
            - lastInputUpdatedTimestamp
            > GeneralSettings.getDefaultMixPanelEventSendTimeout/1000 //need to devide by 1000 here because the timestamp is in seconds, while the timeout is is miliseconds
        {
            //invalidate the timer
            delayTimer?.invalidate()
            //send analytics event
            print(
                "+++++ MixPanel sending delayed event\n \(delayedEventname)\n \(delayedEventParams)"
            )
            AnalyticsHelper.sendAnalyticEventMixPanel(
                eventName: delayedEventname,
                params: delayedEventParams)
        }else{
            print(
                "+++++ checking timestamp \n \(Int(NSDate().timeIntervalSince1970) - lastInputUpdatedTimestamp > GeneralSettings.getDefaultMixPanelEventSendTimeout) \n \(Int(NSDate().timeIntervalSince1970)) \n \(lastInputUpdatedTimestamp) \n \(GeneralSettings.getDefaultMixPanelEventSendTimeout)"
            )
        }
    }
    @objc func checkDelayedAnalyticEvent() {
        sendDelayedAnalyticEvent()
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(
    _ input: [String: Any]
) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(
        uniqueKeysWithValues: input.map { key, value in
            (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)
        })
}
