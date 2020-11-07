//
//  AudioRecordViewModel.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 04/11/2020.
//

import AVFoundation
import RxSwift
import RxCocoa

class AudioRecordViewModel {
    
    private let model: AudioRecordModel
    //private let coordinator: CreateAudioCoordinatorType
    let disposeBag = DisposeBag()
    
    let isRecording: BehaviorRelay<Bool>
    let isFileExists = BehaviorRelay<String>(value: "")
    let isPlaying: BehaviorRelay<Bool>
    
    init(model: AudioRecordModel) {
        
        self.model = model
        //self.coordinator = coordinator
        
        //Record
        self.isRecording = model.isRecording
        
        //Play
        isPlaying = model.isPlaying
        
        
        model.isFileExists.map{$0.description}.bind(to: isFileExists).disposed(by: disposeBag)
        model.recordResult.observeOn(MainScheduler.instance).subscribe(onNext: { record in
            debugPrint("saved record \(record)")
        }, onError: { [weak self] (error) in
           
            debugPrint("recording canceled \(error)")

        },
        onCompleted: {
            debugPrint("recording canceled")
        }).disposed(by: disposeBag)
    }
    
    func toggleRecord() {
        
        if model.isRecording.value {
            model.stopRecording()
        } else {
            model.startRecording()
        }
    }
    
    
    func startPlaying() {
        
        if(model.isPlaying.value){
            model.stopPlayer()
            isPlaying.accept(model.isPlaying.value)
        }
        else {
            model.playItem(with: "002_024.m4a")
            isPlaying.accept(model.isPlaying.value)
        }
    }
    
    func cancel() {
        
        model.cancelRecording()
    }
    
    func deleteAudioFile(){
        if(model.isPlaying.value){
            model.stopPlayer()
        }
        model.deleteFile()
    }
    
    //MARK: Share file
    
    func sharePersistFile(viewcontroller: AudioRecordViewController) {
        let filePath = Directories.documentsDirectory.appendingPathComponent("002_024.m4a")
        
        let activityItems: [Any] = [filePath, "Share file!"]
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityController.popoverPresentationController?.sourceView = viewcontroller.view
        activityController.popoverPresentationController?.sourceRect = viewcontroller.view.frame
        viewcontroller.present(activityController, animated: true, completion: nil)
    }
    
}
