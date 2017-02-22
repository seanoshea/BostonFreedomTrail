//
//  BostonFreedomTrailUITests.swift
//  BostonFreedomTrailUITests
//
//  Created by Sean O'Shea on 2/12/17.
//  Copyright © 2017 UpwardsNorthwards. All rights reserved.
//

import XCTest

class BostonFreedomTrailUITests: XCTestCase {
  
  var app:XCUIApplication!
  
  override func setUp() {
    super.setUp()
    app = XCUIApplication()
    setupSnapshot(app)
    app.launchArguments.append("SnapshotIdentifier")
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
  
  func testTwo() {
    app.tabBars.buttons["Map"].tap()
    snapshot("two")
  }
}
