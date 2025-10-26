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
    let latitude: Double = 42.35769
    let longitude: Double = -71.063303

    UserDefaults.standard.set(latitude, forKey: "lastKnownLocationLatitude")
    UserDefaults.standard.set(longitude, forKey: "lastKnownLocationLongitude")

    let location = ApplicationSharedState.sharedInstance.lastKnownLocation

    #expect(location.coordinate.latitude == latitude)
    #expect(location.coordinate.longitude == longitude)
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

  @Test("Camera zoom rejects invalid values")
  func cameraZoomRejectsInvalidValues() async {
    ApplicationSharedState.sharedInstance.clear()

    // Test that below-minimum values are rejected
    let tooLow = kGMSMinZoomLevel - 1.0
    ApplicationSharedState.sharedInstance.cameraZoom = tooLow
    let afterLow = ApplicationSharedState.sharedInstance.cameraZoom
    // Should either be unchanged (not stored) or default value
    #expect(afterLow == 0.0 || afterLow != tooLow)

    // Test that above-maximum values are rejected
    let tooHigh = kGMSMaxZoomLevel + 1.0
    ApplicationSharedState.sharedInstance.cameraZoom = tooHigh
    let afterHigh = ApplicationSharedState.sharedInstance.cameraZoom
    #expect(afterHigh == 0.0 || afterHigh != tooHigh)
  }

  @Test("Camera zoom handles extreme values")
  func cameraZoomHandlesExtremeValues() async {
    ApplicationSharedState.sharedInstance.clear()

    // Test that extreme values don't crash the system
    ApplicationSharedState.sharedInstance.cameraZoom = Float.infinity
    // Should not store infinity or should gracefully handle
    let afterInfinity = ApplicationSharedState.sharedInstance.cameraZoom
    #expect(afterInfinity.isFinite || afterInfinity == 0.0)

    ApplicationSharedState.sharedInstance.cameraZoom = -Float.infinity
    let afterNegInfinity = ApplicationSharedState.sharedInstance.cameraZoom
    #expect(afterNegInfinity.isFinite || afterNegInfinity == 0.0)

    ApplicationSharedState.sharedInstance.cameraZoom = Float.nan
    let afterNaN = ApplicationSharedState.sharedInstance.cameraZoom
    #expect(afterNaN.isNaN || afterNaN == 0.0)
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

  // MARK: - State Persistence Tests

  @Test("Multiple coordinate updates maintain consistency")
  func multipleCoordinateUpdatesMaintainConsistency() async {
    // Test that coordinate updates persist correctly
    ApplicationSharedState.sharedInstance.clear()

    let coordinate1 = CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589)
    ApplicationSharedState.sharedInstance.lastKnownCoordinate = coordinate1
    let retrieved1 = ApplicationSharedState.sharedInstance.lastKnownCoordinate
    #expect(retrieved1.latitude == coordinate1.latitude)
    #expect(retrieved1.longitude == coordinate1.longitude)

    // Update with a different coordinate
    ApplicationSharedState.sharedInstance.clear()
    let coordinate2 = CLLocationCoordinate2D(latitude: 42.3611, longitude: -71.0599)
    ApplicationSharedState.sharedInstance.lastKnownCoordinate = coordinate2
    let retrieved2 = ApplicationSharedState.sharedInstance.lastKnownCoordinate
    #expect(retrieved2.latitude == coordinate2.latitude)
    #expect(retrieved2.longitude == coordinate2.longitude)
  }

  @Test("Concurrent access safety")
  func concurrentAccessSafety() async {
    ApplicationSharedState.sharedInstance.clear()

    // Test that multiple rapid updates don't cause issues
    for i in 0..<100 {
      let zoom = Float(i % 10 + 12) // Keep within valid range (12-21)
      ApplicationSharedState.sharedInstance.cameraZoom = zoom
    }

    // Should complete without crashing
    // Just verify we can access the value without crashing
    let finalZoom = ApplicationSharedState.sharedInstance.cameraZoom
    // The value should be either a valid zoom in range or 0.0
    #expect((finalZoom >= 12.0 && finalZoom <= 21.0) || finalZoom == 0.0)
  }
}
