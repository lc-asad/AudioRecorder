//
//  Recorder.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 04/11/2020.
//

import AVFoundation

class Recorder:NSObject {
    
    private lazy var recordingSession = AVAudioSession.sharedInstance()
    
    private var recordFileURL:URL
    private var audioRecorder: AVAudioRecorder?
    private var completion: ((Result<URL, ErrorResult>) -> Void)?

    private let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 44100,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]

    private var isCanceled = false

    init<T>(fileUrl: T) {
        
        recordFileURL = fileUrl as! URL
    }
    
    func startRecording(with completion: @escaping (Result<URL, ErrorResult>) -> Void) {
        self.completion = completion
        isCanceled = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.recordingSession.setCategory(.playAndRecord)
                try self.recordingSession.setActive(true, options: .notifyOthersOnDeactivation)
                self.audioRecorder = try AVAudioRecorder(url: self.recordFileURL, settings: self.settings)
                self.audioRecorder?.prepareToRecord()
                self.audioRecorder?.delegate = self
            } catch {
                completion(Result.failure(ErrorResult.otherError))
                return
            }

            self.recordingSession.requestRecordPermission { [weak self] granted in
                guard let self = self else { return }

                if granted {
                    self.audioRecorder?.record()
                } else {
                    self.completion!(Result.failure(ErrorResult.permissionDenied))
    
                }
            }
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
    }

    func cancel() {
        if audioRecorder?.isRecording == true {
            isCanceled = true
            audioRecorder?.stop()
            audioRecorder?.deleteRecording()
        }
    }

}


extension Recorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        guard !isCanceled else {
            completion?(Result.canceled)
            return
        }

        if flag {
            completion?(Result.success(recorder.url))
        } else {
            self.completion?(Result.failure(ErrorResult.failedToEncodeAudio))
            
        }
        
        handleFinish()
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Swift.Error?) {
        handleFinish()
        if error != nil {
            completion!(Result.failure(ErrorResult.otherError))
        } else {
            completion!(Result.failure(ErrorResult.failedToEncodeAudio))
        }
    }

    private func handleFinish() {
        try? recordingSession.setActive(false, options: .notifyOthersOnDeactivation)
        audioRecorder = nil
    }
}


