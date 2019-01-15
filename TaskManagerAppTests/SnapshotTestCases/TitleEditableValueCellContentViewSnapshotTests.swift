//
//  TitleEditableValueCellContentViewSnapshotTests.swift
//  TaskManagerAppTests
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
import FBSnapshotTestCase
@testable import TaskManagerApp

class TitleEditableValueCellContentViewSnapshotTests: FBSnapshotTestCase {
    func test() {
        //Arrange
        let testee = TitleEditableValueCellContentView(frame: CGRect(x: 0, y: 0, width: 640, height: 140))
        testee.title.text = "Name"
        testee.valueText.placeholder = "e.g. Clean garage"
        
        //Act//Assert
        FBSnapshotVerifyView(testee)
    }
}
