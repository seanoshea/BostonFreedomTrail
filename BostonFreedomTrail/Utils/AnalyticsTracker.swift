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

import Foundation
import FirebaseAnalytics

/**
 * Screen name identifiers for Firebase Analytics tracking.
 * 
 * These constants ensure consistent screen naming across the app
 * for analytics and user behavior tracking.
 */
enum AnalyticsScreenNames: String {
  /// About screen showing app information and credits
  case aboutScreen
  /// Main map screen displaying the Freedom Trail
  case mapScreen
  /// Placemark detail screen with historical information
  case placemarkScreen
  /// Virtual tour screen with street view functionality
  case virtualTourScreen
}

/// Category constants for analytics
enum AnalyticsEventCategories: String {
  /// Analytics constant for identifying a user interaction in the app
  case action = "ui_action"
}

/// Action constants for analytics
enum AnalyticsActions: String {
  /// Analytics constant for identifying a user button press in the app
  case buttonPress = "button_press"
}

/// Label constants for analytics
enum AnalyticsLabels: String {
  /// Analytics constant used when the user taps on a tab bar
  case tabBarPress = "tab_bar_press"
  /// Analytics constant used when the user taps on a marker
  case markerPress = "marker_press"
  /// Analytics constant used when the user taps on an info window
  case infoWindowPress = "info_window_press"
  /// Analytics constant used when the user taps on the street view button
  case streetViewPress = "street_view_press"
}

/**
 * Protocol for implementing Firebase Analytics tracking in view controllers.
 * 
 * This protocol provides a standardized interface for tracking user interactions,
 * screen views, and events throughout the Boston Freedom Trail app.
 * 
 * ## Implementation
 * View controllers should conform to this protocol and implement the required methods:
 * ```swift
 * class MyViewController: BaseViewController, AnalyticsTracker {
 *   func getScreenTrackingName() -> String {
 *     return AnalyticsScreenNames.myScreen.rawValue
 *   }
 * }
 * ```
 * 
 * - Note: All methods are marked @MainActor for thread safety
 */
@MainActor
protocol AnalyticsTracker: AnyObject {
  /**
   * Provides the unique screen identifier for analytics tracking.
   * 
   * - Returns: String identifier used for screen view tracking in Firebase Analytics
   */
  func getScreenTrackingName() -> String

  /**
   * Tracks user interaction with Freedom Trail placemarks.
   * 
   * - Parameter placemark: The placemark the user interacted with
   * - Parameter label: Context label describing the interaction type (e.g., "marker_press")
   */
  func trackButtonPressForPlacemark(_ placemark: Placemark, label: String)
}

/**
 * Default implementation of AnalyticsTracker for UIViewController subclasses.
 * 
 * This extension provides ready-to-use analytics functionality for all view controllers
 * that conform to the AnalyticsTracker protocol.
 */
extension AnalyticsTracker where Self: UIViewController {

  /**
   * Tracks screen view events in Firebase Analytics.
   * 
   * This method automatically logs screen views with both the screen name
   * and the view controller class name for comprehensive tracking.
   * 
   * ## Usage
   * Call this method in viewDidAppear or similar lifecycle methods:
   * ```swift
   * override func viewDidAppear(_ animated: Bool) {
   *   super.viewDidAppear(animated)
   *   trackScreenName()
   * }
   * ```
   */
  func trackScreenName() {
    let trackingName = getScreenTrackingName()
    guard !trackingName.isEmpty else { return }

    // Log screen view to Firebase Analytics
    Analytics.logEvent(AnalyticsEventScreenView, parameters: [
      AnalyticsParameterScreenName: trackingName,
      AnalyticsParameterScreenClass: String(describing: type(of: self))
    ])
  }

  /**
   * Tracks tab bar navigation events.
   * 
   * This method logs when users switch between the main app tabs,
   * helping understand navigation patterns and feature usage.
   * 
   * - Parameter index: Zero-based index of the selected tab (0=Map, 1=Virtual Tour, 2=About)
   */
  func trackTabBarButtonPress(index: Int) {
    Analytics.logEvent("tab_bar_press", parameters: [
      "category": AnalyticsEventCategories.action.rawValue,
      "action": AnalyticsActions.buttonPress.rawValue,
      "label": AnalyticsLabels.tabBarPress.rawValue,
      "value": index
    ])
  }

  /**
   Tracks a button press when the user requests information on a placemark.

   - parameter placemark: the placemark about which the user is requesting information.
   - parameter label: additional label information about the placemark & where the user is requesting the info from.
   */
  func trackButtonPressForPlacemark(_ placemark: Placemark, label: String) {
    Analytics.logEvent("placemark_info_press", parameters: [
      "category": AnalyticsEventCategories.action.rawValue,
      "action": AnalyticsActions.buttonPress.rawValue,
      "label": AnalyticsLabels.infoWindowPress.rawValue,
      "placemark_id": Int(placemark.identifier) ?? 0,
      "placemark_label": label
    ])
  }

  /**
   * Tracks non-fatal errors for debugging and monitoring.
   * 
   * This method logs recoverable errors that don't crash the app but may
   * indicate issues that need attention. Useful for monitoring app health
   * and identifying potential problems.
   * 
   * - Parameter errorMessage: Descriptive message about the error that occurred
   * 
   * ## Note
   * For production apps, consider using Firebase Crashlytics for more
   * comprehensive error tracking and reporting.
   */
  func trackNonFatalErrorMessage(_ errorMessage: String) {
    // Log non-fatal error to Firebase Analytics (Crashlytics would be better for this)
    Analytics.logEvent("non_fatal_error", parameters: [
      "error_message": errorMessage,
      "screen": getScreenTrackingName()
    ])
  }
}
