/*
Copyright (c) 2014 - 2016 Upwards Northwards Software Limited
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

// Screen name constants for analytics
enum AnalyticsScreenNames: String {
    case AboutScreen = "AboutScreen"
    case MapScreen = "MapScreen"
    case PlacemarkScreen = "PlacemarkScreen"
    case VirtualTourScreen = "VirtualTourScreen"
}

// Category constants for analytics
enum AnalyticsEventCategories: String {
    case Action = "ui_action"
}

// Action constants for analytics
enum AnalyticsActions: String {
    case ButtonPress = "button_press"
}

// Label constants for analytics
enum AnalyticsLabels: String {
    case MarkerPress = "marker_press"
    case InfoWindowPress = "info_window_press"
    case StreetViewPress = "street_view_press"
}

// Protocol for analytics
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

    // Tracks the user viewing a screen in the app.
    func trackScreenName() {
        if let tracker = GAI.sharedInstance().defaultTracker {
            let trackingName = self.getScreenTrackingName()
            guard trackingName.characters.count > 0 else { return }
            tracker.set(kGAIScreenName, value: trackingName)
            let builder = GAIDictionaryBuilder.createScreenView()
//            tracker.send(builder?.build() as NSMutableDictionary)
        }
    }

    /**
     Tracks a button press when the user requests information on a placemark.
     - parameter placemark: the placemark about which the user is requesting information.
     - parameter label: additional label information about the placemark & where the user is requesting the info from.
     */
    func trackButtonPressForPlacemark(_ placemark: Placemark, label: String) {
        if let tracker = GAI.sharedInstance().defaultTracker {
            let parameters = GAIDictionaryBuilder.createEvent(withCategory: AnalyticsEventCategories.Action.rawValue, action:AnalyticsActions.ButtonPress.rawValue, label:AnalyticsLabels.InfoWindowPress.rawValue, value: Int(placemark.identifier) as NSNumber!).build()
//            tracker.send(parameters as [AnyHashable: Any])
        }
    }

    /**
     Tracks an error happening in the application.
     - parameter errorMessage: information on where the error occured.
     */
    func trackNonFatalErrorMessage(_ errorMessage:String) {
        if let tracker = GAI.sharedInstance().defaultTracker {
            let parameters = GAIDictionaryBuilder.createException(withDescription: errorMessage, withFatal:0).build()
//            tracker.send(parameters as! [NSObject : AnyObject])
        }
    }
}
