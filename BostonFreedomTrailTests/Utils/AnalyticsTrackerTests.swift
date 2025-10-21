/*
 Copyright (c) 2014 - present Upwards Northwards Software Limited
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 3. All advertising materials mentioning features or use of this software
 must display the following acknowledgement:
 This product includes software developed by Upwards Northwards Software Limited.
 4. Neither the name of Upwards Northwards Software Limited nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY UPWARDS NORTHWARDS SOFTWARE LIMITED ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL UPWARDS NORTHWARDS SOFTWARE LIMITED BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Testing
import UIKit
import CoreLocation
@testable import BostonFreedomTrail

@Suite("AnalyticsTracker")
@MainActor
struct AnalyticsTrackerTests {

  // MARK: - Test Helper Class

  class TestViewController: UIViewController, AnalyticsTracker {
    var screenName: String = ""

    func getScreenTrackingName() -> String {
      screenName
    }
  }

  // MARK: - Screen Tracking Tests

  @Test("Track screen name with valid name")
  func trackScreenNameWithValidName() async {
    let controller = TestViewController()
    controller.screenName = "test_screen"

    // Should not crash when tracking screen
    controller.trackScreenName()

    #expect(true) // Test passes if no crash occurs
  }

  @Test("Track screen name with empty name")
  func trackScreenNameWithEmptyName() async {
    let controller = TestViewController()
    controller.screenName = ""

    // Should handle empty screen name gracefully
    controller.trackScreenName()

    #expect(true) // Test passes if no crash occurs
  }

  // MARK: - Tab Bar Tracking Tests

  @Test("Track tab bar button press with valid index")
  func trackTabBarButtonPressWithValidIndex() async {
    let controller = TestViewController()

    // Should not crash when tracking tab bar press
    controller.trackTabBarButtonPress(index: 0)
    controller.trackTabBarButtonPress(index: 1)
    controller.trackTabBarButtonPress(index: 2)

    #expect(true) // Test passes if no crash occurs
  }

  @Test("Track tab bar button press with negative index")
  func trackTabBarButtonPressWithNegativeIndex() async {
    let controller = TestViewController()

    // Should handle negative index gracefully
    controller.trackTabBarButtonPress(index: -1)

    #expect(true) // Test passes if no crash occurs
  }

  // MARK: - Placemark Tracking Tests

  @Test("Track button press for placemark with valid data")
  func trackButtonPressForPlacemarkWithValidData() async {
    let controller = TestViewController()
    let placemark = Placemark(identifier: "1", name: "Test Placemark", location: CLLocation(), coordinates: [], placemarkDescription: "Test Description", lookAt: nil)

    // Should not crash when tracking placemark press
    controller.trackButtonPressForPlacemark(placemark, label: "info_window")

    #expect(true) // Test passes if no crash occurs
  }

  @Test("Track button press for placemark with nil identifier")
  func trackButtonPressForPlacemarkWithNilIdentifier() async {
    let controller = TestViewController()
    let placemark = Placemark(identifier: "", name: "Test Placemark", location: CLLocation(), coordinates: [], placemarkDescription: "Test Description", lookAt: nil)

    // Should handle empty identifier gracefully
    controller.trackButtonPressForPlacemark(placemark, label: "info_window")

    #expect(true) // Test passes if no crash occurs
  }

  @Test("Track button press for placemark with empty label")
  func trackButtonPressForPlacemarkWithEmptyLabel() async {
    let controller = TestViewController()
    let placemark = Placemark(identifier: "1", name: "Test Placemark", location: CLLocation(), coordinates: [], placemarkDescription: "Test Description", lookAt: nil)

    // Should handle empty label gracefully
    controller.trackButtonPressForPlacemark(placemark, label: "")

    #expect(true) // Test passes if no crash occurs
  }

  // MARK: - Error Tracking Tests

  @Test("Track non-fatal error with valid message")
  func trackNonFatalErrorWithValidMessage() async {
    let controller = TestViewController()
    controller.screenName = "test_screen"

    // Should not crash when tracking error
    controller.trackNonFatalErrorMessage("Test error occurred")

    #expect(true) // Test passes if no crash occurs
  }

  @Test("Track non-fatal error with empty message")
  func trackNonFatalErrorWithEmptyMessage() async {
    let controller = TestViewController()
    controller.screenName = "test_screen"

    // Should handle empty error message gracefully
    controller.trackNonFatalErrorMessage("")

    #expect(true) // Test passes if no crash occurs
  }

  @Test("Track non-fatal error with long message")
  func trackNonFatalErrorWithLongMessage() async {
    let controller = TestViewController()
    controller.screenName = "test_screen"
    let longMessage = String(repeating: "A", count: 1000)

    // Should handle long error message gracefully
    controller.trackNonFatalErrorMessage(longMessage)

    #expect(true) // Test passes if no crash occurs
  }

  // MARK: - Analytics Constants Tests

  @Test("Analytics screen names have correct values")
  func analyticsScreenNamesHaveCorrectValues() async {
    #expect(AnalyticsScreenNames.aboutScreen.rawValue == "aboutScreen")
    #expect(AnalyticsScreenNames.mapScreen.rawValue == "mapScreen")
    #expect(AnalyticsScreenNames.placemarkScreen.rawValue == "placemarkScreen")
    #expect(AnalyticsScreenNames.virtualTourScreen.rawValue == "virtualTourScreen")
  }

  @Test("Analytics event categories have correct values")
  func analyticsEventCategoriesHaveCorrectValues() async {
    #expect(AnalyticsEventCategories.action.rawValue == "ui_action")
  }

  @Test("Analytics actions have correct values")
  func analyticsActionsHaveCorrectValues() async {
    #expect(AnalyticsActions.buttonPress.rawValue == "button_press")
  }

  @Test("Analytics labels have correct values")
  func analyticsLabelsHaveCorrectValues() async {
    #expect(AnalyticsLabels.tabBarPress.rawValue == "tab_bar_press")
    #expect(AnalyticsLabels.markerPress.rawValue == "marker_press")
    #expect(AnalyticsLabels.infoWindowPress.rawValue == "info_window_press")
    #expect(AnalyticsLabels.streetViewPress.rawValue == "street_view_press")
  }
}
