//
//  AppDelegate.swift
//  LaunchTimeImproveDemo
//
//  Created by 0xxxD on 2023/4/18.
//

import UIKit
import LaunchTimeMeasurer
public class AppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?


    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        LaunchTimeMeasurer.record(type: .appDelegateDidFinishedStart)
        // mimic luanch itmes
        for _ in 0..<1000*1000 {
            
        }
        LaunchTimeMeasurer.record(type: .appDelegateDidFinishedEnd)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else {
            assertionFailure("window must exsit")
            return true
        }
        
        window.rootViewController = ViewController(nibName: nil, bundle: nil)

        window.isHidden = false
        window.backgroundColor = .black
        window.makeKeyAndVisible()
        
        LaunchTimeMeasurer.record(type: .firstFrameStart)
        return true
    }
}

