//
//  AppDelegate.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 04/11/2020.
//

import UIKit
import Swinject

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        _ = MainContainer.sharedContainer
        
        return true
    }


}

