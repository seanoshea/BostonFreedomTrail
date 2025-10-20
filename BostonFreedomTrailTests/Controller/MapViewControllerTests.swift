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

@Suite("MapViewController")
@MainActor
struct MapViewControllerTests {

  // MARK: - Analytics Tests

  @Test("Has unique screen name for analytics")
  func hasUniqueScreenName() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    #expect(subject.getScreenTrackingName() == AnalyticsScreenNames.mapScreen.rawValue)
  }

  // MARK: - Initialization Tests

  @Test("Has model set by default")
  func hasModelSetByDefault() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    // model is always non-nil since it's a non-optional var with default value
    _ = subject.model
  }

  @Test("Has GMSMapView when loaded")
  func hasGMSMapViewWhenLoaded() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    #expect(subject.mapView != nil)
  }

  @Test("Map view configured with location button and no compass")
  func mapViewConfiguredCorrectly() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let mapView = subject.mapView!
    #expect(!mapView.settings.compassButton)
    #expect(mapView.isMyLocationEnabled)
    #expect(mapView.settings.myLocationButton)
  }

  @Test("Map view has indoor capabilities disabled")
  func mapViewHasIndoorDisabled() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let mapView = subject.mapView!
    #expect(!mapView.isIndoorEnabled)
  }

  @Test("Map view delegate is set to MapViewController")
  func mapViewDelegateIsSet() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let mapView = subject.mapView!
    #expect(mapView.delegate != nil)
  }

  // MARK: - GMSMapViewDelegate Tests

  @Test("Sets zoom level in application state when camera changes")
  func setsZoomLevelOnCameraChange() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let zoom: Float = 14
    let position = GMSCameraPosition(
      target: CLLocationCoordinate2D(latitude: 45, longitude: 45),
      zoom: zoom,
      bearing: 14.0,
      viewingAngle: 1.2
    )

    subject.mapView(subject.mapView!, didChange: position)

    #expect(ApplicationSharedState.sharedInstance.cameraZoom == zoom)
  }

  @Test("Sets last known placemark when marker is tapped")
  func setsLastKnownPlacemarkOnMarkerTap() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: 45, longitude: 45))
    marker.userData = Placemark(
      identifier: "placemark identifier",
      name: "placemark name",
      location: CLLocation(latitude: 10, longitude: 10),
      coordinates: [CLLocation(latitude: 10, longitude: 10)],
      placemarkDescription: "placemark description",
      lookAt: nil
    )

    _ = subject.mapView(subject.mapView!, didTap: marker)

    let lastKnownPlacemark = ApplicationSharedState.sharedInstance.lastKnownPlacemarkCoordinate

    #expect(lastKnownPlacemark.latitude == 45)
    #expect(lastKnownPlacemark.longitude == 45)

    ApplicationSharedState.sharedInstance.clear()
  }

  @Test("Navigates to VirtualTourViewController when info window tapped")
  func navigatesToVirtualTourOnInfoWindowTap() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let dummyDelegate = DummyMapViewControllerDelegate()
    subject.delegate = dummyDelegate

    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: 45, longitude: 45))
    marker.userData = Placemark(
      identifier: "placemark identifier",
      name: "placemark name",
      location: CLLocation(latitude: 10, longitude: 10),
      coordinates: [CLLocation(latitude: 10, longitude: 10)],
      placemarkDescription: "placemark description",
      lookAt: nil
    )

    subject.mapView(subject.mapView!, didTapInfoWindowOf: marker)

    #expect(dummyDelegate.navigationInitiated)
  }

  // MARK: - UIPopoverPresentationControllerDelegate Tests

  @Test("Returns view controller for adaptive presentation style")
  func returnsViewControllerForAdaptivePresentationStyle() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let placemarkViewController = UIStoryboard.placemarkViewController()
    _ = placemarkViewController.view
    let popoverPresentationController = UIPopoverPresentationController(
      presentedViewController: subject,
      presenting: placemarkViewController
    )

    let returnedViewController = subject.presentationController(
      popoverPresentationController,
      viewControllerForAdaptivePresentationStyle: .popover
    )

    #expect(returnedViewController != nil)
  }
}

// MARK: - Test Helpers

@MainActor
class DummyMapViewControllerDelegate: MapViewControllerDelegate {

  var navigationInitiated = false

  func navigateToVirtualTourWithPlacemark(_ placemark: Placemark) {
    self.navigationInitiated = true
  }
}
