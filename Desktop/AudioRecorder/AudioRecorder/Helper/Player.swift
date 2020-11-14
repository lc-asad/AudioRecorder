//
//  Player.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 04/11/2020.
//

import AVFoundation

class Player:NSObject {
    
    private var audioPlayer: AVAudioPlayer?
    private var completion: ((Result) -> Void)?
    let backgroundQueue = DispatchQueue(label: "play_sound_queue", qos: .userInitiated)

    func play(filePath: URL, with completion: @escaping (Result) -> Void) {
        
        self.completion = completion
        if self.audioPlayer != nil {
            self.audioPlayer?.stop()
            self.cleanup()
        }
        
        backgroundQueue.async {
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                self.audioPlayer = try? AVAudioPlayer(contentsOf: filePath)
                self.audioPlayer?.delegate = self
                self.audioPlayer?.play()
            }
            catch {
                completion(.failure(error))
            }
        }
    }
    
    func stop() {
        backgroundQueue.async {
            self.audioPlayer?.stop()
            self.cleanup()
        }
    }
    
    func cleanup() {
        backgroundQueue.async {
            try? AVAudioSession.sharedInstance().setActive(false)
            self.audioPlayer = nil
            
        }
    }
}

extension Player: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        cleanup()
        
        if flag {
            completion?(.success(player.url!))
        } else {
            completion?(.failure(Error.failedToEncodeAudio))
        }
    }
    
    private func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        cleanup()
        
        if let error = error {
            completion?(.failure(error))
        } else {
            completion?(.failure(Error.failedToEncodeAudio))
        }
    }
    
}
