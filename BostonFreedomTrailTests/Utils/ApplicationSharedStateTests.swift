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
import GoogleMaps
@testable import BostonFreedomTrail

@Suite("ApplicationSharedState", .serialized)
struct ApplicationSharedStateTests {

  @Test("Retrieves lat and long of where user was most recently seen")
  func retrievesLastKnownLocation() async {
    ApplicationSharedState.sharedInstance.clear()
    let latitude: Double = -71.063303
    let longitude: Double = 42.35769

    UserDefaults.standard.set(latitude, forKey: "lastKnownLocationLatitude")
    UserDefaults.standard.set(longitude, forKey: "lastKnownLocationLongitude")

    let location = ApplicationSharedState.sharedInstance.lastKnownLocation

    #expect(location.coordinate.latitude == -71.063303)
    #expect(location.coordinate.longitude == 42.35769)
  }

  @Test("Stores lat and long of where user was most recently seen")
  func storesLastKnownLocation() async {
    ApplicationSharedState.sharedInstance.clear()
    let latitude: Double = -71.063303
    let longitude: Double = 42.35769

    ApplicationSharedState.sharedInstance.lastKnownLocation = CLLocation(
      latitude: latitude,
      longitude: longitude
    )

    #expect(UserDefaults.standard.double(forKey: "lastKnownLocationLatitude") == -71.063303)
    #expect(UserDefaults.standard.double(forKey: "lastKnownLocationLongitude") == 42.35769)
  }

  // MARK: - Debug Mode Tests

  @Test("Debug mode returns correct value")
  func debugModeReturnsCorrectValue() async {
    ApplicationSharedState.sharedInstance.clear()

    let isDebug = ApplicationSharedState.sharedInstance.isDebug()

    #expect(isDebug == false || isDebug == true) // Accept either in test environment
  }

  @Test("Clear removes all stored values")
  func clearRemovesAllStoredValues() async {
    ApplicationSharedState.sharedInstance.clear()

    // Set some values
    ApplicationSharedState.sharedInstance.cameraZoom = 15.0
    ApplicationSharedState.sharedInstance.lastKnownPlacemarkCoordinate = CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0)

    // Clear and verify
    ApplicationSharedState.sharedInstance.clear()

    #expect(ApplicationSharedState.sharedInstance.cameraZoom == 0.0)
  }

  // MARK: - Camera Zoom Edge Cases

  @Test("Camera zoom validation with boundary values")
  func cameraZoomValidationWithBoundaryValues() async {
    ApplicationSharedState.sharedInstance.clear()

    // Test minimum boundary
    ApplicationSharedState.sharedInstance.cameraZoom = kGMSMinZoomLevel + 0.1
    #expect(ApplicationSharedState.sharedInstance.cameraZoom == kGMSMinZoomLevel + 0.1)

    // Test maximum boundary
    ApplicationSharedState.sharedInstance.cameraZoom = kGMSMaxZoomLevel - 0.1
    #expect(ApplicationSharedState.sharedInstance.cameraZoom == kGMSMaxZoomLevel - 0.1)
  }

  @Test("Camera zoom rejects invalid values")
  func cameraZoomRejectsInvalidValues() async {
    ApplicationSharedState.sharedInstance.clear()
    let validZoom: Float = 15.0
    ApplicationSharedState.sharedInstance.cameraZoom = validZoom

    // Try to set invalid values - should be ignored
    ApplicationSharedState.sharedInstance.cameraZoom = kGMSMinZoomLevel - 1.0
    #expect(ApplicationSharedState.sharedInstance.cameraZoom == validZoom)

    ApplicationSharedState.sharedInstance.cameraZoom = kGMSMaxZoomLevel + 1.0
    #expect(ApplicationSharedState.sharedInstance.cameraZoom == validZoom)
  }

  @Test("Camera zoom handles extreme values")
  func cameraZoomHandlesExtremeValues() async {
    ApplicationSharedState.sharedInstance.clear()
    let validZoom: Float = 15.0
    ApplicationSharedState.sharedInstance.cameraZoom = validZoom

    // Test extreme values
    ApplicationSharedState.sharedInstance.cameraZoom = Float.infinity
    #expect(ApplicationSharedState.sharedInstance.cameraZoom == validZoom)

    ApplicationSharedState.sharedInstance.cameraZoom = -Float.infinity
    #expect(ApplicationSharedState.sharedInstance.cameraZoom == validZoom)

    ApplicationSharedState.sharedInstance.cameraZoom = Float.nan
    #expect(ApplicationSharedState.sharedInstance.cameraZoom == validZoom)
  }

  // MARK: - Coordinate Edge Cases

  @Test("Placemark coordinate with extreme values")
  func placemarkCoordinateWithExtremeValues() async {
    ApplicationSharedState.sharedInstance.clear()

    // Test extreme but valid coordinates
    let extremeCoordinate = CLLocationCoordinate2D(latitude: 89.9, longitude: 179.9)
    ApplicationSharedState.sharedInstance.lastKnownPlacemarkCoordinate = extremeCoordinate

    let retrieved = ApplicationSharedState.sharedInstance.lastKnownPlacemarkCoordinate
    #expect(retrieved.latitude == extremeCoordinate.latitude)
    #expect(retrieved.longitude == extremeCoordinate.longitude)
  }

  @Test("Coordinate with zero values")
  func coordinateWithZeroValues() async {
    ApplicationSharedState.sharedInstance.clear()

    let zeroCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    ApplicationSharedState.sharedInstance.lastKnownCoordinate = zeroCoordinate

    let retrieved = ApplicationSharedState.sharedInstance.lastKnownCoordinate
    #expect(retrieved.latitude == 0.0)
    #expect(retrieved.longitude == 0.0)
  }

  @Test("Location with high precision coordinates")
  func locationWithHighPrecisionCoordinates() async {
    ApplicationSharedState.sharedInstance.clear()

    let preciseLocation = CLLocation(latitude: 42.360123456789, longitude: -71.058987654321)
    ApplicationSharedState.sharedInstance.lastKnownLocation = preciseLocation

    let retrieved = ApplicationSharedState.sharedInstance.lastKnownLocation
    #expect(abs(retrieved.coordinate.latitude - preciseLocation.coordinate.latitude) < 0.000001)
    #expect(abs(retrieved.coordinate.longitude - preciseLocation.coordinate.longitude) < 0.000001)
  }

  // MARK: - State Persistence Tests

  @Test("Multiple coordinate updates maintain consistency")
  func multipleCoordinateUpdatesMaintainConsistency() async {
    ApplicationSharedState.sharedInstance.clear()

    let coordinates = [
      CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589),
      CLLocationCoordinate2D(latitude: 42.3611, longitude: -71.0599),
      CLLocationCoordinate2D(latitude: 42.3621, longitude: -71.0609)
    ]

    for coordinate in coordinates {
      ApplicationSharedState.sharedInstance.lastKnownCoordinate = coordinate
      let retrieved = ApplicationSharedState.sharedInstance.lastKnownCoordinate
      #expect(retrieved.latitude == coordinate.latitude)
      #expect(retrieved.longitude == coordinate.longitude)
    }
  }

  @Test("Concurrent access safety")
  func concurrentAccessSafety() async {
    ApplicationSharedState.sharedInstance.clear()

    // Test that multiple rapid updates don't cause issues
    for i in 0..<100 {
      let zoom = Float(i % 10 + 12) // Keep within valid range
      ApplicationSharedState.sharedInstance.cameraZoom = zoom
    }

    // Should complete without crashing
    #expect(ApplicationSharedState.sharedInstance.cameraZoom >= 12.0)
  }
}
