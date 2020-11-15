//
//  AudioService.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 11/11/2020.
//

import Foundation
import RxSwift
import RxCocoa

protocol AudioServiceProtocol {

    // MARK: Variables
    var recordPlayer: Player {get}
    var isRecording :BehaviorRelay<Bool>{get}
    var isPlaying   :BehaviorRelay<Bool>{get}
    var isFileExists:BehaviorRelay<String>{get}
    
    // MARK: Methods
    func startRecording<T>(with fileUrl: T)
    func stopRecording()
    func cancelRecording()
    
    func playItem(with fileUrl: URL)
    func stopPlayer()
    func deleteFile(at model: AudioRecordModel)
    
}

final class AudioService:AudioServiceProtocol {
    
    static let shared = AudioService()
    
    private  var recorder: Recorder!
    internal var recordPlayer =  Player()
    
    var isRecording  = BehaviorRelay(value: false)
    var isPlaying    = BehaviorRelay(value: false)
    var isFileExists = BehaviorRelay<String>(value: "")
    
    func startRecording<T>(with fileUrl: T) {
        
        recorder = Recorder(fileUrl: fileUrl)
        isRecording.accept(true)
        recorder.startRecording(with: { [weak self] result in
            guard self != nil else { return }
        
            switch result {
            case .success(let url):
                self?.isFileExists.accept(url.absoluteString)
                
            case .failure(_):
                self?.isFileExists.accept("")
                
            case .canceled:
                self?.isFileExists.accept("")
    
            }
            self?.isRecording.accept(false)
        })
    }
    
    func stopRecording() {
        recorder.stopRecording()
    }

    func cancelRecording() {
        recorder.cancel()
    }
    
    //MARK:  Play Audio
    func playItem(with fileUrl: URL) {
        
        isPlaying.accept(true)
        recordPlayer.play(filePath: fileUrl, with: { [weak self] result in
            guard self != nil else { return }
            
            self?.isPlaying.accept(false)
        })
        
    }
    
    //MARK: Stop player
    func stopPlayer() {
        
        recordPlayer.stop()

    }
    
    //MARK: Delete audio file
    func deleteFile(at model: AudioRecordModel) {
        
        if isPlaying.value == true {
            
            recordPlayer.stop()
        }
        
        model.deleteAudioFile()
    
    }
    
    
    //MARK: Share file
    func sharePersistFile<T:UIViewController >(viewcontroller: T, filePath: URL) {
        
        let activityItems: [Any] = [filePath, "Share file!"]
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityController.popoverPresentationController?.sourceView = viewcontroller.view
        activityController.popoverPresentationController?.sourceRect = viewcontroller.view.frame
        viewcontroller.present(activityController, animated: true, completion: nil)
    }
    
}


