//
//  Player.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 04/11/2020.
//

import AVFoundation
import RxCocoa

class Player: NSObject {

    private var audioPlayer: AVAudioPlayer?
    var recordDirectory = Directories.documentsDirectory

    let isPlaying = BehaviorRelay(value: false)
    let backgroundQueue = DispatchQueue(label: "play_sound_queue", qos: .userInitiated)

    func play(fileName: String) {
        if self.audioPlayer != nil {
            self.audioPlayer?.stop()
            self.cleanup()
        }

        backgroundQueue.async {
            let url = self.recordDirectory.appendingPathComponent(fileName)
            try? AVAudioSession.sharedInstance().setActive(true)

            self.audioPlayer = try? AVAudioPlayer(contentsOf: url)
            self.audioPlayer?.delegate = self

            if self.audioPlayer?.play() == true {
                self.isPlaying.accept(true)
            }
        }
    }

    func stop() {
        backgroundQueue.async {
            self.audioPlayer?.stop()
            self.cleanup()
        }
    }
}

extension Player: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        cleanup()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        cleanup()
    }

    private func cleanup() {
        backgroundQueue.async {
            try? AVAudioSession.sharedInstance().setActive(false)
            
            self.isPlaying.accept(false)
            self.audioPlayer = nil
            
        }
    }
}
