//
//  StoryboardContainer.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 07/11/2020.
//

import Foundation
import Swinject
import SwinjectStoryboard


extension SwinjectStoryboard {
    @objc class func setup() {
        let mainContainer = MainContainer.sharedContainer.container
        
        defaultContainer.storyboardInitCompleted(AudioRecordViewController.self) { _, controller in
            controller.viewModel = mainContainer.resolve(AudioRecordViewModel.self)
        }
    }
}
