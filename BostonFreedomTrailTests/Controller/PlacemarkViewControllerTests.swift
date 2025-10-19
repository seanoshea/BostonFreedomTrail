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
@testable import BostonFreedomTrail
import GoogleMaps

@Suite("PlacemarkViewController")
@MainActor
struct PlacemarkViewControllerTests {

  // MARK: - Analytics Tests

  @Test("Has unique screen name for analytics")
  func hasUniqueScreenName() async {
    let subject = UIStoryboard.placemarkViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    #expect(subject.getScreenTrackingName() == AnalyticsScreenNames.placemarkScreen.rawValue)
  }

  // MARK: - Initialization Tests

  @Test("Has model set by default")
  func hasModelSetByDefault() async {
    let subject = UIStoryboard.placemarkViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    #expect(subject.model != nil)
  }

  @Test("Has view properties set after loading")
  func hasViewPropertiesSetAfterLoading() async {
    let subject = UIStoryboard.placemarkViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    #expect(subject.streetViewButton != nil)
  }

  @Test("Sets view title when loaded with placemark")
  func setsTitleWhenLoaded() async {
    let subject = UIStoryboard.placemarkViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let location = CLLocation(latitude: 120, longitude: 122)
    subject.model?.placemark = Placemark(
      identifier: "1",
      name: "Old State House",
      location: location,
      coordinates: [location],
      placemarkDescription: "Old State House Description",
      lookAt: nil
    )

    subject.viewDidLoad()

    #expect(subject.title != nil)
    #expect(subject.title == "Old State House")
  }

  @Test("Shows street view button when placemark has LookAt")
  func showsStreetViewButtonWithLookAt() async {
    let subject = UIStoryboard.placemarkViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let placemark = Trail.instance.placemarks[1]
    subject.model?.placemark = placemark

    subject.viewDidLoad()

    #expect(subject.streetViewButton?.isHidden == false)
  }

  @Test("Hides street view button when placemark has no LookAt")
  func hidesStreetViewButtonWithoutLookAt() async {
    let subject = UIStoryboard.placemarkViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let placemark = Trail.instance.placemarks[0]
    subject.model?.placemark = placemark

    subject.viewDidLoad()

    #expect(subject.streetViewButton?.isHidden == true)
  }

  // MARK: - Street View Button Tests

  @Test("Does not notify delegate when no placemark is associated")
  func doesNotNotifyDelegateWithoutPlacemark() async {
    let subject = UIStoryboard.placemarkViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let dummyDelegate = DummyDelegate()
    subject.delegate = dummyDelegate

    subject.streetViewButtonPressed(subject.streetViewButton!)

    #expect(!dummyDelegate.buttonPressed)
  }

  @Test("Notifies delegate when placemark is associated")
  func notifiesDelegateWithPlacemark() async {
    let subject = UIStoryboard.placemarkViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let dummyDelegate = DummyDelegate()
    subject.delegate = dummyDelegate
    let placemark = Trail.instance.placemarks[1]
    subject.model?.placemark = placemark
    subject.viewDidLoad()

    subject.streetViewButtonPressed(subject.streetViewButton!)

    #expect(dummyDelegate.buttonPressed)
  }
}

// MARK: - Test Helpers

@MainActor
class DummyDelegate: PlacemarkViewControllerDelegate {

  var buttonPressed = false

  func streetViewButtonPressedForPlacemark(_ placemark: Placemark) {
    self.buttonPressed = true
  }
}
