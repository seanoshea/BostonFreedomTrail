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

enum AnalyticsScreenNames: String {
    case AboutScreen = "AboutScreen"
    case MapScreen = "MapScreen"
    case PlacemarkScreen = "PlacemarkScreen"
    case VirtualTourScreen = "VirtualTourScreen"
}

enum AnalyticsEventCategories: String {
    case Action = "ui_action"
}

enum AnalyticsActions: String {
    case ButtonPress = "button_press"
}

enum AnalyticsLabels: String {
    case MarkerPress = "marker_press"
    case InfoWindowPress = "info_window_press"
    case StreetViewPress = "street_view_press"
}

protocol AnalyticsTracker {
    func getScreenTrackingName() -> String
    func trackButtonPressForPlacemark(placemark: Placemark, label: String)
}

extension AnalyticsTracker where Self : UIViewController {

    func trackScreenName() {
        if let tracker = GAI.sharedInstance().defaultTracker {
            let trackingName = self.getScreenTrackingName()
            guard trackingName.characters.count > 0 else { return }
            tracker.set(kGAIScreenName, value: trackingName)
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker.send(builder.build() as [NSObject : AnyObject])
        }
    }

    func trackButtonPressForPlacemark(placemark: Placemark, label: String) {
        if let tracker = GAI.sharedInstance().defaultTracker {
            let parameters = GAIDictionaryBuilder.createEventWithCategory(AnalyticsEventCategories.Action.rawValue, action:AnalyticsActions.ButtonPress.rawValue, label:AnalyticsLabels.InfoWindowPress.rawValue, value: Int(placemark.identifier)).build()
            tracker.send(parameters as [NSObject : AnyObject])
        }
    }
}
