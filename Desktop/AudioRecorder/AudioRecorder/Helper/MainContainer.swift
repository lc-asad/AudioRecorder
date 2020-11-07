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
        
        container.register(AudioRecordModel.self) {_ in AudioRecordModel(name: "", filename: "")}
        container.register(AudioRecordViewModel.self, factory: { resolver in
            return AudioRecordViewModel(model: resolver.resolve(AudioRecordModel.self)!)
        })
    }
}
