//
//  Recorder.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 04/11/2020.
//

import AVFoundation

class Recorder: NSObject {
    
    private lazy var recordingSession = AVAudioSession.sharedInstance()
    
    private let recordFileURL = Directories.documentsDirectory.appendingPathComponent("002_024.m4a")
    private var audioRecorder: AVAudioRecorder?
    private var completion: ((Result) -> Void)?

    private let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 44100,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]

    private var isCanceled = false

    func startRecording(with completion: @escaping (Result) -> Void) {
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
                completion(.failure(error))
                return
            }

            self.recordingSession.requestRecordPermission { [weak self] granted in
                guard let self = self else { return }

                if granted {
                    self.audioRecorder?.record()
                } else {
                    self.completion?(.failure(Error.permissionDenied))
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
        handleFinish()
        guard !isCanceled else {
            completion?(.canceled)
            return
        }

        if flag {
            completion?(.success(recordFileURL))
        } else {
            completion?(.failure(Error.failedToEncodeAudio))
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Swift.Error?) {
        handleFinish()
        if let error = error {
            completion?(.failure(error))
        } else {
            completion?(.failure(Error.failedToEncodeAudio))
        }
    }

    private func handleFinish() {
        try? recordingSession.setActive(false, options: .notifyOthersOnDeactivation)
        audioRecorder = nil
    }
}

extension Recorder {
    enum Result {
        case success(URL)
        case failure(Swift.Error)
        case canceled
    }

    enum Error: LocalizedError {
        case failedToEncodeAudio
        case permissionDenied

        var errorDescription: String? {
            switch self {
            case .failedToEncodeAudio:
                return NSLocalizedString("Failed to encode audio", comment: "")
            case .permissionDenied:
                return NSLocalizedString("Permission denied. Please, allow access to micro in settings", comment: "")
            }
        }
    }
}
