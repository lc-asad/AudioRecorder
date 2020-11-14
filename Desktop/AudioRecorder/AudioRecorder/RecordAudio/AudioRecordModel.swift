//
//  AudioRecordModel.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 04/11/2020.
//

import AVFoundation

struct AudioRecordModel {
    
    var name: String
    let store: Store?
    
    init(name: String) {
        
        self.name = name
        self.store = Store(fileName: self.name)
    }
    
    var fileURL: URL? {
        return store?.fileURL(for: self)
    }
    
    func deleteAudioFile() {
        store?.removeFile(for: self)

    }
}

