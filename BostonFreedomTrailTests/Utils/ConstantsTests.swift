/*
 Copyright (c) 2014 - present Upwards Northwards Software Limited
 All rights reserved.
 */

import Testing
@testable import BostonFreedomTrail

@Suite("Constants")
struct ConstantsTests {

    @Test("Analytics screen names are not empty")
    func analyticsScreenNamesNotEmpty() {
        #expect(!AnalyticsScreenNames.mapScreen.rawValue.isEmpty)
        #expect(!AnalyticsScreenNames.virtualTourScreen.rawValue.isEmpty)
        #expect(!AnalyticsScreenNames.aboutScreen.rawValue.isEmpty)
        #expect(!AnalyticsScreenNames.placemarkScreen.rawValue.isEmpty)
    }

    @Test("Analytics labels are not empty")
    func analyticsLabelsNotEmpty() {
        #expect(!AnalyticsLabels.markerPress.rawValue.isEmpty)
        #expect(!AnalyticsLabels.infoWindowPress.rawValue.isEmpty)
        #expect(!AnalyticsLabels.tabBarPress.rawValue.isEmpty)
    }

    @Test("Resource constants are valid")
    func resourceConstantsValid() {
        #expect(!ResourceConstants.infoWindowXibName.rawValue.isEmpty)
        #expect(!ResourceConstants.placemarkIdentifier.rawValue.isEmpty)
        #expect(!ResourceConstants.placemarkResourceImage.rawValue.isEmpty)
    }

    @Test("Segue constants are valid")
    func segueConstantsValid() {
        #expect(!SegueConstants.mapToPlacemarkSegueIdentifier.rawValue.isEmpty)
    }
}
