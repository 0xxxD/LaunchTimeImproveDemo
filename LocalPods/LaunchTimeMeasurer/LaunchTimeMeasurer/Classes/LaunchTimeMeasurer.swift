//
//  LaunchTimeMeasurer.swift
//  LaunchTimeMeasurer
//
//  Created by 0xxxD on 2023/4/18.
//

import Foundation
import QuartzCore
public protocol LaunchTimeMeasurerDelegate: NSObjectProtocol {
    func resultMeasureFinished(_ result: [LaunchTimeMeasurer.WallTimeType: Double])
}

public extension LaunchTimeMeasurer {
    enum WallTimeType: CaseIterable {
        case forkStart
        case loadStart
//        case constructorStart
//        case constructorEnd
        case mainStart
        case appDelegateDidFinishedStart
        case appDelegateDidFinishedEnd
        case firstFrameStart
    }
}

public class LaunchTimeMeasurer: NSObject {
    public static weak var delegate: LaunchTimeMeasurerDelegate? = nil
    private static var store = [WallTimeType: Double]()
    
    public static func record(type: WallTimeType) {
        guard store[type] == nil else {
            assertionFailure()
            return
        }
        
        switch type {
        case .loadStart, .forkStart:
            assertionFailure("please use objc method")
        case .mainStart, .appDelegateDidFinishedStart, .appDelegateDidFinishedEnd:
            store[type] = CACurrentMediaTime()
        case .firstFrameStart:
            let mainRunloop = CFRunLoopGetMain()
            if #available(iOS 13.0, *) {
                let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.allActivities.rawValue, true, 0) { observer, activity in
                    if activity == CFRunLoopActivity.beforeTimers {
                        store[.firstFrameStart] = CACurrentMediaTime()
                        checkFinish()
                        CFRunLoopRemoveObserver(mainRunloop, observer, CFRunLoopMode.commonModes)
                    }
                }
                CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, .commonModes)

            } else {
                CFRunLoopPerformBlock(mainRunloop, CFRunLoopMode.defaultMode.rawValue) {
                    store[.firstFrameStart] = CACurrentMediaTime()
                    checkFinish()
                }
            }
        }
        store[type] = CACurrentMediaTime()
    }
    
    static func checkFinish() {
        guard store.count == WallTimeType.allCases.count else {
            assertionFailure()
            return
        }
        delegate?.resultMeasureFinished(store)
    }
    
    @objc public static func recordLoadStart(_ time: Double) {
        guard store[.loadStart] == nil else {
            assertionFailure()
            return
        }
        store[.loadStart] = time
    }
    
    @objc public static func recordForkStart(_ time: Double) {
        guard store[.forkStart] == nil else {
            assertionFailure()
            return
        }
        store[.forkStart] = time
    }

    
    @objc public static func recordMainStart() {
        record(type: .mainStart)
    }
    
}


