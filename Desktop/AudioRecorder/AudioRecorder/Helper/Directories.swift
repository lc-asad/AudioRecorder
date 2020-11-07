//
//  Directories.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 04/11/2020.
//

import Foundation

enum Directories {
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}
