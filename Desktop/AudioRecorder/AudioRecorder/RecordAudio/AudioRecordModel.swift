//
//  AudioRecordModel.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 04/11/2020.
//

import AVFoundation

protocol AudioRecordProtocol {

    var name:  String { get }
    func deleteAudioFile()
}


struct AudioRecordModel:AudioRecordProtocol {
    
    var name: String
    let store: Store?
    
    
    init() {
        self.name = "002_024.m4a"
        self.store = Store(fileName: self.name)
    }
    
    var fileURL: URL? {
        return store?.fileURL(for: self)
    }
    
    func deleteAudioFile() {
        store?.removeFile(for: self)

    }
    
}

