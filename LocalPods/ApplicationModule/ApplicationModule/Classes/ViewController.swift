//
//  ViewController.swift
//  LaunchTimeImproveDemo
//
//  Created by 0xxxD on 2023/4/18.
//

import UIKit
import A
import SnapKit
import LaunchTimeMeasurer
//import AppOrderFiles
import LaunchManager
class ViewController: UIViewController {
    var label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        label.textColor = .black
        LaunchTimeMeasurer.delegate = self

        // Do any additional setup after loading the view.
        label.numberOfLines = 0
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LaunchManager.shared().addIdleObserver()
    }
}

extension ViewController: LaunchTimeMeasurerDelegate {
    func resultMeasureFinished(_ result: [LaunchTimeMeasurer.WallTimeType : Double]) {
        let total = result[.firstFrameStart]! - result[.forkStart]!
        let first = result[.loadStart]! - result[.forkStart]!
        let second = result[.mainStart]! - result[.loadStart]!
        let third = result[.appDelegateDidFinishedStart]! - result[.mainStart]!
        let fourth = result[.appDelegateDidFinishedEnd]! - result[.appDelegateDidFinishedStart]!
        let fifth = result[.firstFrameStart]! - result[.appDelegateDidFinishedEnd]!
        let text = "Process Start: \(first) \nPremain: \(second) \nMain: \(third) \nLifeCycle: \(fourth) \nFirstFrame: \(fifth)\nTotoal: \(total)"
        label.text = text
        label.sizeToFit()
    }
}
