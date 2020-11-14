//
//  Store.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 11/11/2020.
//

import Foundation

struct Store {
    
    let baseURL:URL? = Directories.documentsDirectory
    var placeholder: URL?
    let fileName: String!
    
    init(fileName: String) {
        self.fileName = fileName
    }
    
    func fileURL(for recording: AudioRecordModel) -> URL? {
        
        return baseURL?.appendingPathComponent(self.fileName)
    }
    
    func removeFile(for recording: AudioRecordModel) {
        if let url = fileURL(for: recording), url != placeholder {
            _ = try? FileManager.default.removeItem(at: url)
        }
    }
}
