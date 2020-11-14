//
//  Result.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 09/11/2020.
//

import Foundation

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
