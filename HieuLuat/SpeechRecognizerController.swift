//
//  SpeechRecognizerController.swift
//  HieuLuat
//
//  Created by VietLH on 8/26/20.
//  Copyright © 2020 VietLH. All rights reserved.
// reference: https://www.appcoda.com/siri-speech-framework/

import Foundation
import Speech
import UIKit

@available(iOS 10.0, *)
class SpeechRecognizerController: UIViewController, SFSpeechRecognizerDelegate{
    
    @IBOutlet var btnDone: UIButton!
    private var localIdentifier = "vi-VN"
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var speechRecognizer: SFSpeechRecognizer?
    private var isButtonEnabled = false
    private var keyword = ""
    private var parentUI: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: localIdentifier))
        initSpeechRecognition()
        startRecording()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        closingPopup()
    }
    
    private func initSpeechRecognition (){
        print("------------ initializing SpeechRecognition ---------------")
        speechRecognizer!.delegate = self  //3
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            switch authStatus {  //5
            case .authorized:
                self.isButtonEnabled = true
            case .denied:
                self.isButtonEnabled = false
                print("=====SR: User denied access to speech recognition")
            case .restricted:
                self.isButtonEnabled = false
                print("=====SR: Speech recognition restricted on this device")
            case .notDetermined:
                self.isButtonEnabled = false
                print("=====SR: Speech recognition not yet authorized")
            default:
                self.isButtonEnabled = false
            }
            
            OperationQueue.main.addOperation() {
                //                    self.btnMicro.isEnabled = isButtonEnabled
            }
        }
        print("------------ Successfully initializing SpeechRecognition ---------------")
    }
    
    private func startRecording() {
        
        print("------------ Starting recording SpeechRecognition ---------------")
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
        } catch {
            print("=====SR: audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        //        {
        //            fatalError("Audio engine has no input node")
        //        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("=====SR: Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                self.keyword = result?.bestTranscription.formattedString as! String
                print("=====SR:  \(String(describing: result?.bestTranscription.formattedString))")
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("=====SR: audioEngine couldn't start because of an error.")
        }
        print("------------ Successfully recording SpeechRecognition ---------------")
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            print("=====SR:  microphoneButton.isEnabled = true")
        } else {
            print("=====SR:  microphoneButton.isEnabled = false")
        }
    }
    
    private func microphoneTapped() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        } else {
            startRecording()
        }
    }
    
    
    @IBAction func btnDoneAction(_ sender: Any) {
        closingPopup()
    }
    
    private func closingPopup(){
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
        updateKeywordToParent()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func updateKeywordToParent(){
        if let pa = parentUI as? VBPLSearchTableController {
            pa.updateSearchBarText(keyword: keyword)
        }
        else if let pa = parentUI as? MPSearchTableController{
            pa.updateSearchBarText(keyword: keyword)
        }
    }
    
    public func setParentUI(parentUI: UIViewController){
        self.parentUI = parentUI
    }
}
