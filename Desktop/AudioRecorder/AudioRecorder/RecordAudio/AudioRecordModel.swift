//
//  AudioRecordModel.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 04/11/2020.
//

import AVFoundation
import RxSwift
import RxCocoa


class AudioRecordModel {
    
    var name: String
    var fileName: String
    
    private lazy var recorder     =  Recorder()
    private lazy var recordPlayer =  Player()
    
    let isRecording  = BehaviorRelay(value: false)
    let isPlaying    = BehaviorRelay(value: false)
    let isFileExists = BehaviorRelay<String>(value: "")
    let recordResult = PublishSubject<Recorder>()
    
    init(name: String, filename:String) {
        //TODO:
        self.name = name
        self.fileName = filename
    }
    
    // MARK: - Recording
    func startRecording() {
        isRecording.accept(true)
        recorder.startRecording(with: { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let url):
                print(url)
                self.isFileExists.accept(url.absoluteString)
                self.isRecording.accept(false)
            case .failure(let error):
                print(error)
                self.isFileExists.accept("")
                self.isRecording.accept(false)
                self.recordResult.onError(error)
            case .canceled:
                print("cancaled")
                self.isFileExists.accept("")
                self.isRecording.accept(false)
            }
        })
    }

    func stopRecording() {
        recorder.stopRecording()
    }

    func cancelRecording() {
        recorder.cancel()
    }
    
    //MARK:  Play Audio
    func playItem(with name: String) {
        
        if self.isRecording.value {
            stopRecording()
        }
        
        if  recordPlayer.isPlaying.value == true {
            isPlaying.accept(false)
            recordPlayer.stop()
        } else {
            let fileName = name
            recordPlayer.play(fileName: fileName)
            isPlaying.accept(true)
        }
    }
    
    //MARK: Play audio
    func stopPlayer() {
        
        recordPlayer.stop()
        isPlaying.accept(false)

    }
    
    //MARK: Delete audio file
    func deleteFile() {
        
        if isPlaying.value == true {
            
            recordPlayer.stop()
        }
            
        try? FileManager.default
            .removeItem(at:Directories.documentsDirectory.appendingPathComponent("002_024.m4a"))
    
    }
    
}

