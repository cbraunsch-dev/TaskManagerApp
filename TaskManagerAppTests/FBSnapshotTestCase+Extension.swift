//
//  FBSnapshotTestCase+Extension.swift
//  TaskManagerAppTests
//
//  Created by Chris Braunschweiler on 14.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import FBSnapshotTestCase

extension FBSnapshotTestCase {
    func setupSnapshotTest() {
        self.agnosticOptions = [FBSnapshotTestCaseAgnosticOption.device, FBSnapshotTestCaseAgnosticOption.screenSize]
        self.removeAllViewsFromWindow()
    }
    
    private func removeAllViewsFromWindow() {
        guard let appWindow = self.getAppWindow() else {
            print("Unable to access app window")
            return
        }
        appWindow.subviews.forEach { view in view.removeFromSuperview() }
    }
    
    func verifyViewController(viewController: UIViewController) {
        guard let innerWindow = self.getAppWindow() else {
            print("Failed to access window")
            return
        }
        innerWindow.rootViewController = viewController
        FBSnapshotVerifyLayer(innerWindow.layer)
    }
    
    //Use this method together with verifyWindow() if you want to snapshot test content that is added to the window rather than the view controller's view.
    func addToWindow(viewController: UIViewController) {
        guard let innerWindow = self.getAppWindow() else {
            print("Failed to access window")
            return
        }
        innerWindow.rootViewController = viewController
    }
    
    func verifyWindow() {
        guard let innerWindow = self.getAppWindow() else {
            print("Failed to access window")
            return
        }
        FBSnapshotVerifyLayer(innerWindow.layer)
    }
    
    private func getAppWindow() -> UIWindow? {
        guard let appDelegate = UIApplication.shared.delegate else {
            print("Failed to access app delegate")
            return nil
        }
        guard let appWindow = appDelegate.window else {
            print("Failed to access window optional")
            return nil
        }
        return appWindow
    }
    
    // Test and Load the View at the Same Time. Loading the view by accessing the ViewController's view property is required so that viewDidLoad is called before our tests start
    func loadView(of viewController: UIViewController) {
        XCTAssertNotNil(viewController.view)
    }
}
