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

@Suite("MapModel")
@MainActor
struct MapModelTests {

  @Test("Adds all placemarks to the map")
  func addsAllPlacemarksToMap() async {
    let subject = MapModel()
    let mapViewController = UIStoryboard.mapViewController()
    _ = mapViewController.view

    guard let mapView = mapViewController.mapView else {
      #expect(Bool(false), "MapView should be available")
      return
    }
    let placemarks = subject.addPlacemarksToMap(mapView)
    let marker = placemarks[0]

    #expect(marker.map != nil)
  }

  @Test("Placemark markers have correct properties")
  func placemarkMarkersHaveCorrectProperties() async {
    let subject = MapModel()
    let mapViewController = UIStoryboard.mapViewController()
    _ = mapViewController.view

    guard let mapView = mapViewController.mapView else {
      #expect(Bool(false), "MapView should be available")
      return
    }
    let markers = subject.addPlacemarksToMap(mapView)

    #expect(!markers.isEmpty)

    let firstMarker = markers[0]
    #expect(firstMarker.userData != nil)
    #expect(firstMarker.icon != nil)
    #expect(firstMarker.title != nil)
    #expect(firstMarker.position.latitude != 0.0)
    #expect(firstMarker.position.longitude != 0.0)
  }

  @Test("Marker count matches trail placemark count")
  func markerCountMatchesTrailPlacemarkCount() async {
    let subject = MapModel()
    let mapViewController = UIStoryboard.mapViewController()
    _ = mapViewController.view

    guard let mapView = mapViewController.mapView else {
      #expect(Bool(false), "MapView should be available")
      return
    }
    let markers = subject.addPlacemarksToMap(mapView)

    #expect(markers.count == Trail.instance.placemarks.count)
  }

  @Test("Allows reasonable zoom value")
  func allowsReasonableZoomValue() async {
    let subject = MapModel()

    #expect(subject.isViableZoom(14))
  }

  @Test("Zoom validation - boundary conditions")
  func zoomValidationBoundaryConditions() async {
    let subject = MapModel()

    // Test exact boundaries
    #expect(subject.isViableZoom(CameraZoomConstraints.minimum.rawValue))
    #expect(subject.isViableZoom(CameraZoomConstraints.maximum.rawValue))

    // Test just outside boundaries
    #expect(!subject.isViableZoom(CameraZoomConstraints.minimum.rawValue - 0.1))
    #expect(!subject.isViableZoom(CameraZoomConstraints.maximum.rawValue + 0.1))
  }

  @Test("Does not allow unreasonable zoom values")
  func doesNotAllowUnreasonableZoomValues() async {
    let subject = MapModel()

    #expect(!subject.isViableZoom(-1))
    #expect(!subject.isViableZoom(400))
    #expect(!subject.isViableZoom(Float.infinity))
    #expect(!subject.isViableZoom(-Float.infinity))
    #expect(!subject.isViableZoom(Float.nan))
  }

  @Test("Last known coordinate with no stored data")
  func lastKnownCoordinateWithNoStoredData() async {
    let subject = MapModel()
    ApplicationSharedState.sharedInstance.clear()

    let coordinate = subject.lastKnownCoordinate()

    // Should return default coordinates when no data stored
    #expect(coordinate.latitude != 0.0)
    #expect(coordinate.longitude != 0.0)
  }

  @Test("Last known coordinate with stored data")
  func lastKnownCoordinateWithStoredData() async {
    let subject = MapModel()
    ApplicationSharedState.sharedInstance.clear()

    let testCoordinate = CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589)
    ApplicationSharedState.sharedInstance.lastKnownCoordinate = testCoordinate

    let retrievedCoordinate = subject.lastKnownCoordinate()

    #expect(retrievedCoordinate.latitude == testCoordinate.latitude)
    #expect(retrievedCoordinate.longitude == testCoordinate.longitude)
  }

  @Test("Zoom for map with stored data")
  func zoomForMapWithStoredData() async {
    let subject = MapModel()
    ApplicationSharedState.sharedInstance.clear()

    let testZoom: Float = 15.0
    ApplicationSharedState.sharedInstance.cameraZoom = testZoom

    let retrievedZoom = subject.zoomForMap()

    #expect(retrievedZoom == testZoom)
  }
}
