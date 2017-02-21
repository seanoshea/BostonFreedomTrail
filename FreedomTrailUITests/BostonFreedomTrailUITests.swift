//
//  BostonFreedomTrailUITests.swift
//  BostonFreedomTrailUITests
//
//  Created by Sean O'Shea on 2/12/17.
//  Copyright © 2017 UpwardsNorthwards. All rights reserved.
//

import XCTest

class BostonFreedomTrailUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        addUIInterruptionMonitor(withDescription: "Alert Dialog") { (alert) -> Bool in
            alert.buttons["Allow"].tap()
            return true
        }
        app.tap()
    }
    
    func testOne() {
        snapshot("one")
    }
}
