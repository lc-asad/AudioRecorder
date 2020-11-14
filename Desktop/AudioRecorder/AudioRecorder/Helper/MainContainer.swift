//
//  MainContainer.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 07/11/2020.
//

import Foundation
import Swinject

class MainContainer {
    
    static let sharedContainer = MainContainer()
    
    let container = Container()
    
    private init() {
        setupDefaultContainers()
    }
    
    private func setupDefaultContainers() {
        
        container.register(AudioRecordModel.self) {_ in AudioRecordModel(name: "002_024.m4a")}
        container.register(AudioRecordViewModel.self, factory: { resolver in
            return AudioRecordViewModel()
        })
    }
}
