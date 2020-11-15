//
//  Player.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 04/11/2020.
//

import AVFoundation

class Player:NSObject {
    
    private var audioPlayer: AVAudioPlayer?
    private var completion: ((Result<URL, ErrorResult>) -> Void)?
    let backgroundQueue = DispatchQueue(label: "play_sound_queue", qos: .userInitiated)

    func play(filePath: URL, with completion: @escaping (Result<URL, ErrorResult>) -> Void) {
        
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
                //completion( .failure(error))
                //completion(Result.failure(error))
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
            completion?(Result.success(player.url!))
        } else {
            completion!(Result.failure(ErrorResult.otherError))
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        cleanup()
        
        if error != nil {
            completion!(Result.failure(ErrorResult.otherError))
        } else {
            completion!(Result.failure(ErrorResult.failedToEncodeAudio))
        }
    }
    
}
