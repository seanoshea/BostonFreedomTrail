/*
 Copyright (c) 2014 - present Upwards Northwards Software Limited
 All rights reserved.
 */

import Testing
import UIKit
@testable import BostonFreedomTrail

@Suite("AppDelegate", .serialized)
@MainActor
struct AppDelegateTests {

  @Test("Application did finish launching")
  func applicationDidFinishLaunching() async {
    let appDelegate = AppDelegate()
    let application = UIApplication.shared

    let didFinishLaunching = appDelegate.application(application, didFinishLaunchingWithOptions: nil)

    #expect(didFinishLaunching == true)
  }

  @Test("Application did become active executes")
  func applicationDidBecomeActiveExecutes() async {
    let appDelegate = AppDelegate()
    let application = UIApplication.shared

    appDelegate.applicationDidBecomeActive(application)

    #expect(true)
  }

  @Test("Initialize methods execute without error")
  func initializeMethodsExecuteWithoutError() async {
    let appDelegate = AppDelegate()

    appDelegate.initializeGoogleMapsApi()
    appDelegate.initializeAnalytics()
    appDelegate.initializeLocalization()

    #expect(true)
  }
}
