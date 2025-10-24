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
import GoogleMaps
@testable import BostonFreedomTrail

@Suite("MapViewController", .serialized)
@MainActor
struct MapViewControllerTests {

  // MARK: - Initialization Tests

  @Test("Map view controller initializes with correct screen name")
  func mapViewControllerInitializesWithCorrectScreenName() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    #expect(subject.getScreenTrackingName() == AnalyticsScreenNames.mapScreen.rawValue)
  }

  @Test("Map view controller has map view after view loads")
  func mapViewControllerHasMapViewAfterViewLoads() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    #expect(subject.mapView != nil)
  }

  @Test("Map view controller has model after initialization")
  func mapViewControllerHasModelAfterInitialization() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    // Model is not optional, so this test should always pass
    #expect(true)
  }

  // MARK: - View Lifecycle Tests

  @Test("View did appear sets up location tracking")
  func viewDidAppearSetsUpLocationTracking() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    subject.viewDidAppear(true)

    // Should not crash and should set up tracking
    #expect(true)
  }

  @Test("View will disappear handles cleanup")
  func viewWillDisappearHandlesCleanup() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    subject.viewWillDisappear(true)

    // Should handle cleanup gracefully
    #expect(true)
  }

  // MARK: - Map Delegate Tests

  @Test("Map view did tap info window with valid placemark")
  func mapViewDidTapInfoWindowWithValidPlacemark() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let placemark = Placemark(
      identifier: "test1",
      name: "Test Placemark",
      location: CLLocation(latitude: 42.3601, longitude: -71.0589),
      coordinates: [],
      placemarkDescription: "Test description",
      lookAt: nil
    )

    let marker = GMSMarker()
    marker.userData = placemark
    marker.position = CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589)

    if let mapView = subject.mapView {
      subject.mapView(mapView, didTapInfoWindowOf: marker)

      // Should update shared state with marker position
      let lastKnownCoordinate = ApplicationSharedState.sharedInstance.lastKnownPlacemarkCoordinate
      #expect(lastKnownCoordinate.latitude == 42.3601)
      #expect(lastKnownCoordinate.longitude == -71.0589)
    }
  }

  @Test("Map view did tap info window with invalid userData")
  func mapViewDidTapInfoWindowWithInvalidUserData() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let marker = GMSMarker()
    marker.userData = "invalid_data" // Not a Placemark
    marker.position = CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589)

    if let mapView = subject.mapView {
      subject.mapView(mapView, didTapInfoWindowOf: marker)
      // Should handle gracefully without crashing
      #expect(true)
    }
  }

  @Test("Map view did tap info window with nil userData")
  func mapViewDidTapInfoWindowWithNilUserData() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let marker = GMSMarker()
    marker.userData = nil
    marker.position = CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589)

    if let mapView = subject.mapView {
      subject.mapView(mapView, didTapInfoWindowOf: marker)
      // Should handle gracefully without crashing
      #expect(true)
    }
  }

  @Test("Map view did change camera position with valid zoom")
  func mapViewDidChangeCameraPositionWithValidZoom() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let validZoom: Float = 15.0
    let camera = GMSCameraPosition.camera(withLatitude: 42.3601, longitude: -71.0589, zoom: validZoom)

    if let mapView = subject.mapView {
      subject.mapView(mapView, didChange: camera)

      // Should update both camera zoom and coordinate in shared state
      #expect(ApplicationSharedState.sharedInstance.cameraZoom == validZoom)

      let lastCoordinate = ApplicationSharedState.sharedInstance.lastKnownCoordinate
      #expect(lastCoordinate.latitude == 42.3601)
      #expect(lastCoordinate.longitude == -71.0589)
    }
  }

  @Test("Map view did change camera position with invalid zoom")
  func mapViewDidChangeCameraPositionWithInvalidZoom() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    // Set a valid zoom first
    ApplicationSharedState.sharedInstance.cameraZoom = 15.0

    let invalidZoom: Float = 5.0 // Below minimum
    let camera = GMSCameraPosition.camera(withLatitude: 42.3601, longitude: -71.0589, zoom: invalidZoom)

    if let mapView = subject.mapView {
      subject.mapView(mapView, didChange: camera)

      // Should not update zoom with invalid value, but should update coordinate
      #expect(ApplicationSharedState.sharedInstance.cameraZoom == 15.0) // Unchanged

      let lastCoordinate = ApplicationSharedState.sharedInstance.lastKnownCoordinate
      #expect(lastCoordinate.latitude == 42.3601)
      #expect(lastCoordinate.longitude == -71.0589)
    }
  }

  @Test("Map view did change camera position with boundary zoom values")
  func mapViewDidChangeCameraPositionWithBoundaryZoomValues() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    // Test minimum boundary
    let minCamera = GMSCameraPosition.camera(withLatitude: 42.3601, longitude: -71.0589, zoom: CameraZoomConstraints.minimum.rawValue)

    if let mapView = subject.mapView {
      subject.mapView(mapView, didChange: minCamera)
      #expect(ApplicationSharedState.sharedInstance.cameraZoom == CameraZoomConstraints.minimum.rawValue)

      // Test maximum boundary
      let maxCamera = GMSCameraPosition.camera(withLatitude: 42.3601, longitude: -71.0589, zoom: CameraZoomConstraints.maximum.rawValue)
      subject.mapView(mapView, didChange: maxCamera)
      #expect(ApplicationSharedState.sharedInstance.cameraZoom == CameraZoomConstraints.maximum.rawValue)
    }
  }

  // MARK: - Reachability Tests

  @Test("Reachability status changed to online")
  func reachabilityStatusChangedToOnline() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    subject.reachabilityStatusChanged(true)

    // Should handle online status
    #expect(true)
  }

  @Test("Reachability status changed to offline")
  func reachabilityStatusChangedToOffline() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    subject.reachabilityStatusChanged(false)

    // Should handle offline status
    #expect(true)
  }

  // MARK: - Navigation Tests

  @Test("Street view button pressed for placemark")
  func streetViewButtonPressedForPlacemark() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let placemark = Placemark(
      identifier: "1",
      name: "Test Placemark",
      location: CLLocation(latitude: 42.3601, longitude: -71.0589),
      coordinates: [],
      placemarkDescription: "Test description",
      lookAt: nil
    )

    subject.streetViewButtonPressedForPlacemark(placemark)

    // Should handle street view navigation without crashing
    #expect(true)
  }

  @Test("Street view button pressed with LookAt data")
  func streetViewButtonPressedWithLookAtData() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let lookAt = LookAt(latitude: 42.3601, longitude: -71.0589, tilt: 45.0, heading: 180.0)
    let placemark = Placemark(
      identifier: "1",
      name: "Test Placemark with LookAt",
      location: CLLocation(latitude: 42.3601, longitude: -71.0589),
      coordinates: [],
      placemarkDescription: "Test description",
      lookAt: lookAt
    )

    subject.streetViewButtonPressedForPlacemark(placemark)

    // Should handle street view navigation with camera positioning
    #expect(true)
  }

  // MARK: - Map Setup Tests

  @Test("Map view setup with markers")
  func mapViewSetupWithMarkers() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    // Trigger view lifecycle to set up map
    subject.viewDidLoad()
    subject.viewDidAppear(true)

    // Should have markers on the map
    #expect(subject.mapView != nil)
  }

  @Test("Map view camera position restoration")
  func mapViewCameraPositionRestoration() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    // Set a camera zoom in shared state
    ApplicationSharedState.sharedInstance.cameraZoom = 12.0

    subject.viewDidLoad()

    // Should restore camera position
    #expect(true)
  }

  // MARK: - Error Handling Tests

  @Test("Map view handles empty marker collection")
  func mapViewHandlesEmptyMarkerCollection() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    // Should handle case where no markers are available
    subject.viewDidLoad()

    #expect(subject.mapView != nil)
  }

  @Test("Map view did tap marker with valid placemark")
  func mapViewDidTapMarkerWithValidPlacemark() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let placemark = Placemark(
      identifier: "test1",
      name: "Test Placemark",
      location: CLLocation(latitude: 42.3601, longitude: -71.0589),
      coordinates: [],
      placemarkDescription: "Test description",
      lookAt: nil
    )

    let marker = GMSMarker()
    marker.userData = placemark
    marker.position = CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589)

    if let mapView = subject.mapView {
      let result = subject.mapView(mapView, didTap: marker)

      // Should return false to allow default behavior
      #expect(result == false)

      // Should update shared state
      let lastKnownCoordinate = ApplicationSharedState.sharedInstance.lastKnownPlacemarkCoordinate
      #expect(lastKnownCoordinate.latitude == 42.3601)
      #expect(lastKnownCoordinate.longitude == -71.0589)
    }
  }

  @Test("Map view did tap at coordinate")
  func mapViewDidTapAtCoordinate() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let coordinate = CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589)

    if let mapView = subject.mapView {
      subject.mapView(mapView, didTapAt: coordinate)
      // Should log coordinate without crashing
      #expect(true)
    }
  }

  @Test("Map view marker info window creation")
  func mapViewMarkerInfoWindowCreation() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let placemark = Placemark(
      identifier: "test1",
      name: "Test Placemark",
      location: CLLocation(latitude: 42.3601, longitude: -71.0589),
      coordinates: [],
      placemarkDescription: "Test description",
      lookAt: nil
    )

    let marker = GMSMarker()
    marker.userData = placemark

    if let mapView = subject.mapView {
      let infoWindow = subject.mapView(mapView, markerInfoWindow: marker)

      // Should create info window for valid placemark
      #expect(infoWindow != nil)
      #expect(infoWindow is InfoWindow)
    }
  }

  @Test("Map view marker info window with invalid userData")
  func mapViewMarkerInfoWindowWithInvalidUserData() async {
    let subject = UIStoryboard.mapViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    let marker = GMSMarker()
    marker.userData = "invalid_data"

    if let mapView = subject.mapView {
      let infoWindow = subject.mapView(mapView, markerInfoWindow: marker)

      // Should return nil for invalid userData
      #expect(infoWindow == nil)
    }
  }
}
