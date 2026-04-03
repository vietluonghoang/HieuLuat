//
//  SplashScreenViewController.swift
//  HieuLuat
//
//  Created by VietLH on 9/9/22.
//  Copyright © 2022 VietLH. All rights reserved.
//

import FirebaseRemoteConfig
import Network
import UIKit

class SplashScreenViewController: UIViewController {
    var remoteConfig: RemoteConfig!
    var delayTimer: Timer?
    @IBOutlet var viewMainView: UIView!
    var homeOpened = false

    private var progressView: UIProgressView!
    private var progressLabel: UILabel!
    private var currentProgress: Float = 0.0
    private var progressTimer: Timer?

    // Track initialization conditions
    private var isRemoteConfigDone = false
    private var isDeviceIdDone = false

    private let maxTimeoutSeconds: TimeInterval = 10.0
    private let fetchTimeoutSeconds: TimeInterval = 6.0
    private var fetchTimedOut = false
    private var retryCount = 0
    private let maxRetries = 2

    // Network monitoring
    private let networkMonitor = NWPathMonitor()
    private var isNetworkAvailable = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressUI()
        startNetworkMonitor()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewMainView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, action: #selector(moveToHomeAgain)))
        _ = DataConnection.instance()
        updateRemoteConfig()
        print(
            "Delay to wait for initialization of Firebase and Device information....."
        )
        delayTimer = Timer.scheduledTimer(
            timeInterval: 0.5, target: self,
            selector: #selector(checkIfInitializationDone), userInfo: nil,
            repeats: true)
        AnalyticsHelper.sendAnalyticEventMixPanel(
            eventName: "app_open", params: [:])

        // Start progress animation
        startProgressAnimation()

        // Fallback timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + maxTimeoutSeconds) { [weak self] in
            self?.finishProgress()
        }
    }

    deinit {
        networkMonitor.cancel()
    }

    // MARK: - Network Monitoring

    private func startNetworkMonitor() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let wasAvailable = self.isNetworkAvailable
            self.isNetworkAvailable = path.status == .satisfied

            DispatchQueue.main.async {
                if self.isNetworkAvailable && !wasAvailable && !self.isRemoteConfigDone {
                    // Network restored while still waiting → retry fetch
                    self.progressLabel.text = "Mạng đã khôi phục, đang thử lại..."
                    self.retryFetchRemoteConfig()
                }
            }
        }
        networkMonitor.start(queue: DispatchQueue.global(qos: .utility))
    }

    // MARK: - Progress UI

    private func setupProgressUI() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = AppColors.primary
        progressView.trackTintColor = AppColors.outline
        progressView.progress = 0.0
        progressView.layer.cornerRadius = AppRadius.xs
        progressView.clipsToBounds = true
        view.addSubview(progressView)

        progressLabel = UILabel()
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.text = "Đang tải dữ liệu..."
        progressLabel.textColor = AppColors.onSurface
        progressLabel.font = AppTypography.bodySmall
        progressLabel.textAlignment = .center
        view.addSubview(progressLabel)

        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            progressView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            progressView.heightAnchor.constraint(equalToConstant: 4),

            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -8)
        ])
    }

    private func startProgressAnimation() {
        // Animate progress slowly up to 80% while waiting
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let target: Float = self.allConditionsMet() ? 1.0 : 0.8
            if self.currentProgress < target {
                // Slow down as approaching target
                let remaining = target - self.currentProgress
                let increment = remaining * 0.05
                self.currentProgress += max(increment, 0.005)
                self.currentProgress = min(self.currentProgress, target)
                self.progressView.setProgress(self.currentProgress, animated: true)
            }

            if self.allConditionsMet() && self.currentProgress >= 0.95 {
                self.completeInitialization()
            }
        }
    }

    private func finishProgress() {
        guard !homeOpened else { return }
        // Force complete
        progressTimer?.invalidate()
        progressTimer = nil
        currentProgress = 1.0
        progressView.setProgress(1.0, animated: true)
        progressLabel.text = "Hoàn tất!"

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.moveToHome()
        }
    }

    private func allConditionsMet() -> Bool {
        return isRemoteConfigDone && isDeviceIdDone
    }

    private func completeInitialization() {
        guard !homeOpened else { return }
        progressTimer?.invalidate()
        progressTimer = nil
        delayTimer?.invalidate()
        delayTimer = nil

        currentProgress = 1.0
        progressView.setProgress(1.0, animated: true)
        progressLabel.text = "Hoàn tất!"

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.moveToHome()
        }
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

    func updateRemoteConfig() {
        print("--- Getting RemoteConfig from Firebase")

        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        settings.fetchTimeout = fetchTimeoutSeconds
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "remote_config_defaults")

        if !isNetworkAvailable {
            print("--- No network, using defaults")
            DispatchQueue.main.async { [weak self] in
                self?.progressLabel.text = "Không có mạng, dùng cấu hình mặc định"
                self?.useDefaultConfigAndContinue()
            }
            return
        }

        performFetch()
    }

    private func performFetch() {
        guard !isRemoteConfigDone else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.retryCount > 0 {
                self.progressLabel.text = "Đang thử lại lần \(self.retryCount)..."
            } else {
                self.progressLabel.text = "Đang tải cấu hình..."
            }
        }

        remoteConfig.fetch { [weak self] (status, error) -> Void in
            guard let self = self, !self.isRemoteConfigDone else { return }
            if status == .success {
                print("RemoteConfig fetched!")
                self.remoteConfig.activate { changed, error in
                    DispatchQueue.main.async {
                        self.fetchRemoteConfig()
                        self.isRemoteConfigDone = true
                        self.progressLabel.text = "Đã tải cấu hình"
                    }
                }
                let params = [
                    "defaultActiveNDXPId": String(
                        GeneralSettings.getActiveNDXPId),
                    "defaultActiveQC41Id": String(
                        GeneralSettings.getActiveQC41Id),
                    "defaultConnectionTries": String(GeneralSettings.remainingConnectionTries),
                    "defaultMixPanelEventSendTimeout": String(GeneralSettings.getDefaultMixPanelEventSendTimeout),
                    "developementMode": String(GeneralSettings.isDevMode),
                    "enableBannerAds": String(
                        GeneralSettings.isEnableBannerAds),
                    "enableInappNotif": String(
                        GeneralSettings.isEnableInappNotif),
                    "enableInterstitialAds": String(
                        GeneralSettings.isEnableInterstitialAds),
                    "minimumAdsInterval": String(
                        GeneralSettings.minimumAdsIntervalInSeconds),
                    "minimumAppVersion": String(
                        GeneralSettings.minimumAppVersionRequired),
                    "mixPanelEnabled": String(GeneralSettings.isMixPanelEnabled),
                    "requiredDBVersion": String(
                        GeneralSettings.getRequiredDatabaseVersion),
                    "tamgiuPhuongtienDieukhoanID": String(GeneralSettings.getTamgiuPhuongtienParentID()),
                    "trackAutomaticEvents": String(GeneralSettings.isTrackAutomaticEvents)
                ]
                AnalyticsHelper.sendAnalyticEventMixPanel(
                    eventName: "app_config", params: params)
            } else {
                print("RemoteConfig not fetched")
                print(
                    "Error: \(error?.localizedDescription ?? "No error available.")"
                )
                DispatchQueue.main.async {
                    self.handleFetchFailure()
                }
            }
        }
    }

    private func handleFetchFailure() {
        guard !isRemoteConfigDone else { return }

        if retryCount < maxRetries && isNetworkAvailable {
            retryCount += 1
            print("--- Retrying remote config fetch (attempt \(retryCount)/\(maxRetries))")
            progressLabel.text = "Tải thất bại, thử lại lần \(retryCount)..."
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.performFetch()
            }
        } else {
            print("--- Max retries reached or no network, using defaults")
            if !isNetworkAvailable {
                progressLabel.text = "Mất kết nối mạng, dùng cấu hình mặc định"
            } else {
                progressLabel.text = "Không tải được, dùng cấu hình mặc định"
            }
            useDefaultConfigAndContinue()
        }
    }

    private func retryFetchRemoteConfig() {
        guard !isRemoteConfigDone else { return }
        retryCount = 0
        performFetch()
    }

    private func useDefaultConfigAndContinue() {
        fetchRemoteConfig()
        isRemoteConfigDone = true
    }

    func fetchRemoteConfig() {

        GeneralSettings.getActiveNDXPId =
            remoteConfig.configValue(forKey: "defaultActiveNDXPId").numberValue
            .int64Value
        print("--- defaultActiveNDXPId: \(GeneralSettings.getActiveNDXPId)")
        GeneralSettings.getActiveQC41Id =
            remoteConfig.configValue(forKey: "defaultActiveQC41Id").numberValue
            .int64Value
        print("--- defaultActiveQC41Id: \(GeneralSettings.getActiveQC41Id)")
        GeneralSettings.remainingConnectionTries =
            remoteConfig.configValue(forKey: "defaultConnectionTries").numberValue
            .intValue
        print("--- defaultConnectionTries: \(GeneralSettings.remainingConnectionTries)")
        GeneralSettings.getDefaultMixPanelEventSendTimeout =
            remoteConfig.configValue(forKey: "defaultMixPanelEventSendTimeout").numberValue
            .intValue
        print("--- defaultMixPanelEventSendTimeout: \(GeneralSettings.getDefaultMixPanelEventSendTimeout)")
        GeneralSettings.isDevMode =
            remoteConfig.configValue(forKey: "developementMode").boolValue
        print("--- developementMode: \(GeneralSettings.isDevMode)")
        GeneralSettings.isEnableBannerAds =
            remoteConfig.configValue(forKey: "enableBannerAds").boolValue
        print("--- enableBannerAds: \(GeneralSettings.isEnableBannerAds)")
        GeneralSettings.isEnableInappNotif =
            remoteConfig.configValue(forKey: "enableInappNotif").boolValue
        print("--- enableInappNotif: \(GeneralSettings.isEnableInappNotif)")
        GeneralSettings.isEnableInterstitialAds =
            remoteConfig.configValue(forKey: "enableInterstitialAds").boolValue
        print(
            "--- enableInterstitialAds: \(GeneralSettings.isEnableInterstitialAds)"
        )
        GeneralSettings.minimumAdsIntervalInSeconds =
            remoteConfig.configValue(forKey: "minimumAdsInterval").numberValue
            .intValue
        print(
            "--- minimumAdsInterval: \(GeneralSettings.minimumAdsIntervalInSeconds)"
        )
        GeneralSettings.minimumAppVersionRequired = remoteConfig.configValue(
            forKey: "minimumAppVersion"
        ).stringValue!
        print(
            "--- minimumAppVersion: \(GeneralSettings.minimumAppVersionRequired)"
        )
        GeneralSettings.isMixPanelEnabled =
            remoteConfig.configValue(forKey: "mixPanelEnabled").boolValue
        print("--- mixPanelEnabled: \(GeneralSettings.isMixPanelEnabled)")
        GeneralSettings.getRequiredDatabaseVersion =
            remoteConfig.configValue(forKey: "requiredDBVersion").numberValue
            .intValue
        print(
            "--- requiredDBVersion: \(GeneralSettings.getRequiredDatabaseVersion)"
        )
        print("--- tamgiuPhuongtienDieukhoanID: ")
        GeneralSettings.setTamgiuPhuongtienParentID(
            tamgiuphuongtienArr: remoteConfig.configValue(
                forKey: "tamgiuPhuongtienDieukhoanID"
            ).jsonValue!)
        GeneralSettings.isTrackAutomaticEvents =
            remoteConfig.configValue(forKey: "trackAutomaticEvents").boolValue
        print("--- trackAutomaticEvents: \(GeneralSettings.isTrackAutomaticEvents)")
        
    print("RemoteConfig fetched successfully")
        
        GeneralSettings.isRemoteConfigFetched = true
    }

    @objc func checkIfInitializationDone() {
        print("Checking the initialization conditions....")
        if !AnalyticsHelper.getIdForVendor().isEmpty
            && !AnalyticsHelper.getAdsId().isEmpty
            && !AnalyticsHelper.getAdsId().contains("undefined")
        {
            isDeviceIdDone = true
            delayTimer?.invalidate()
            print(".... Device IDs ready")
        }
    }

    func moveToHome() {
        guard !homeOpened else { return }
        print("forwarding to Home")
        homeOpened = true
        progressTimer?.invalidate()
        progressTimer = nil
        delayTimer?.invalidate()
        delayTimer = nil
        networkMonitor.cancel()
        performSegue(withIdentifier: "showHome", sender: nil)
    }

    @objc func moveToHomeAgain() {
        if homeOpened {
            moveToHome()
        }
    }
}
