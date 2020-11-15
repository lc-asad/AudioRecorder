//
//  Result.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 09/11/2020.
//

import Foundation

enum Result<T, E: Error> {
    case success(T)
    case failure(E)
    case canceled
}


enum ErrorResult: Error {
    case failedToEncodeAudio
    case permissionDenied
    case otherError
    var errorDescription: String? {
        switch self {
        case .failedToEncodeAudio:
            return NSLocalizedString("Audio encode failed", comment: "")
        case .permissionDenied:
            return NSLocalizedString("Micro phone permission", comment: "")
         case .otherError:
            return NSLocalizedString("Other Error", comment: "")
        }
    }
}



//enum Error: LocalizedError {
//    case failedToEncodeAudio
//    case permissionDenied
//
//    var errorDescription: String? {
//        switch self {
//        case .failedToEncodeAudio:
//            return NSLocalizedString("Audio encode failed", comment: "")
//        case .permissionDenied:
//            return NSLocalizedString("Micro phone permission", comment: "")
//        }
//    }
//}
