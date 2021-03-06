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

/// Screen name constants for analytics
enum AnalyticsScreenNames: String {
  /// Used when the user taps on the about tab
  case aboutScreen
  /// Used when the user taps on the map tab
  case mapScreen
  /// Used when the user taps into more information on a placemark
  case placemarkScreen
  /// Used when the user taps on the virtual tour tab
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

/// Protocol for analytics
protocol AnalyticsTracker:class {
  /**
   Retrieves the screen name.
   
   - returns: the screen name which will be used for any screen tracking in analytics
   */
  func getScreenTrackingName() -> String
  
  /**
   Tracks a button press when the user requests information on a placemark.
   
   - parameter placemark: the placemark about which the user is requesting information.
   - parameter label: additional label information about the placemark & where the user is requesting the info from.
   */
  func trackButtonPressForPlacemark(_ placemark: Placemark, label: String)
}

extension AnalyticsTracker where Self : UIViewController {
  
  /// Tracks the user viewing a screen in the app.
  func trackScreenName() {
    guard let tracker = GAI.sharedInstance().defaultTracker else { return }
    let trackingName = getScreenTrackingName()
    guard trackingName.count > 0 else { return }
    tracker.set(kGAIScreenName, value: trackingName)
    guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
    tracker.send(builder.build() as [NSObject : AnyObject])
  }

  /**
   Tracks when a tab bar button is selected.
   
   - parameter index: the index of the tab bar button which was just selected.
   */
  func trackTabBarButtonPress(index:Int) {
    guard let tracker = GAI.sharedInstance().defaultTracker else { return }
    guard let parameters = GAIDictionaryBuilder.createEvent(withCategory: AnalyticsEventCategories.action.rawValue, action:AnalyticsActions.buttonPress.rawValue, label:AnalyticsLabels.tabBarPress.rawValue, value: index as NSNumber).build() else { return }
    tracker.send(parameters as [NSObject : AnyObject])
  }
  
  /**
   Tracks a button press when the user requests information on a placemark.
   
   - parameter placemark: the placemark about which the user is requesting information.
   - parameter label: additional label information about the placemark & where the user is requesting the info from.
   */
  func trackButtonPressForPlacemark(_ placemark: Placemark, label: String) {
    guard let tracker = GAI.sharedInstance().defaultTracker else { return }
    guard let parameters = GAIDictionaryBuilder.createEvent(withCategory: AnalyticsEventCategories.action.rawValue, action:AnalyticsActions.buttonPress.rawValue, label:AnalyticsLabels.infoWindowPress.rawValue, value: Int(placemark.identifier) as NSNumber?).build() else { return }
    tracker.send(parameters as [NSObject : AnyObject])
  }
  
  /**
   Tracks an error happening in the application.
   
   - parameter errorMessage: information on where the error occured.
   */
  func trackNonFatalErrorMessage(_ errorMessage:String) {
    guard let tracker = GAI.sharedInstance().defaultTracker else { return }
    guard let parameters = GAIDictionaryBuilder.createException(withDescription: errorMessage, withFatal:0).build() else { return }
    tracker.send(parameters as [NSObject : AnyObject])
  }
}
