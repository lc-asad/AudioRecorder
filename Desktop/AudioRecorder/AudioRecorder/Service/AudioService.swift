//
//  AudioService.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 11/11/2020.
//

import Foundation
import RxSwift
import RxCocoa


final class AudioService {
    
    static let shared = AudioService()
    
    private var recorder: Recorder!
    private lazy var recordPlayer =  Player()
    
    let isRecording  = BehaviorRelay(value: false)
    let isPlaying    = BehaviorRelay(value: false)
    let isFileExists = BehaviorRelay<String>(value: "")
    
    func startRecording(with fileUrl: URL) {
        
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
    func sharePersistFile(viewcontroller: AudioRecordViewController, filePath: URL) {
        
        let activityItems: [Any] = [filePath, "Share file!"]
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityController.popoverPresentationController?.sourceView = viewcontroller.view
        activityController.popoverPresentationController?.sourceRect = viewcontroller.view.frame
        viewcontroller.present(activityController, animated: true, completion: nil)
    }
}


