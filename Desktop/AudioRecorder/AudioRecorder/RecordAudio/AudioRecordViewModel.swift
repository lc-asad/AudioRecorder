//
//  AudioRecordViewModel.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 04/11/2020.
//

import AVFoundation
import RxSwift
import RxCocoa

struct AudioRecordViewModel {
    
    private var service: AudioService!
    let model = AudioRecordModel(name: "002_024.m4a")
    
    let disposeBag = DisposeBag()
    let isRecording: BehaviorRelay<Bool>
    let isFileExists = BehaviorRelay<String>(value: "")
    let isPlaying: BehaviorRelay<Bool>
    
    init(service: AudioService = AudioService.shared) {
        
        self.service = service
        isRecording  = service.isRecording
        isPlaying    = service.isPlaying
       
        service.isFileExists.map{$0.description}.bind(to: isFileExists).disposed(by: disposeBag)

    }
    
    //ToggleRecording
    func toggleRecord() {
        
        if service.isRecording.value {
            service.stopRecording()
        } else {
            service.startRecording(with: model.fileURL!)
        }
    }
    
    
    // Play audio file
    func startPlaying() {
        
        service.playItem(with: model.fileURL!)
        
    }
    
    // Cancel recording
    private func cancel() {
        
        service.cancelRecording()
    }
    
    // Delete audio file
    func deleteAudioFile(){
        if(service.isPlaying.value){
            service.stopPlayer()
        }
        service.deleteFile(at: model)
    }
    
    // Share file
    func shareFile(viewcontroller: AudioRecordViewController)  {
        
        service.sharePersistFile(viewcontroller: viewcontroller, filePath: model.fileURL!)
    }
}





