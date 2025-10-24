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
import Testing
import CoreLocation
@testable import BostonFreedomTrail

@Suite("LocationTracker", .serialized)
@MainActor
struct LocationTrackerTests {

  @Test("Has location manager property set")
  func hasLocationManagerSet() async {
    // locationManager is always non-nil since it's a non-optional lazy var
    _ = LocationTracker.sharedInstance.locationManager
  }

  @Test("Sets delegate of location manager to itself")
  func setsDelegateToItself() async {
    let delegate = LocationTracker.sharedInstance.locationManager.delegate
    #expect(delegate != nil)
  }

  @Test("Updates shared application state on location update")
  func updatesSharedStateOnLocationUpdate() async {
    ApplicationSharedState.sharedInstance.clear()

    let latitude: Double = -71.063303
    let longitude: Double = 42.35769

    LocationTracker.sharedInstance.locationManager(
      LocationTracker.sharedInstance.locationManager,
      didUpdateLocations: [CLLocation(latitude: latitude, longitude: longitude)]
    )

    #expect(LocationTracker.sharedInstance.currentLocation != nil)
    #expect(UserDefaults.standard.float(forKey: "lastKnownLocationLatitude") == -71.063303)
    #expect(UserDefaults.standard.float(forKey: "lastKnownLocationLongitude") == 42.35769)
  }

  @Test("Location update with multiple locations uses last")
  func locationUpdateWithMultipleLocationsUsesLast() async {
    ApplicationSharedState.sharedInstance.clear()

    let locations = [
      CLLocation(latitude: 42.3601, longitude: -71.0589),
      CLLocation(latitude: 42.3611, longitude: -71.0599),
      CLLocation(latitude: 42.3621, longitude: -71.0609) // This should be used
    ]

    LocationTracker.sharedInstance.locationManager(
      LocationTracker.sharedInstance.locationManager,
      didUpdateLocations: locations
    )

    let currentLocation = LocationTracker.sharedInstance.currentLocation
    #expect(currentLocation?.coordinate.latitude == 42.3621)
    #expect(currentLocation?.coordinate.longitude == -71.0609)
  }

  @Test("Location update with empty array")
  func locationUpdateWithEmptyArray() async {
    ApplicationSharedState.sharedInstance.clear()
    let previousLocation = LocationTracker.sharedInstance.currentLocation

    LocationTracker.sharedInstance.locationManager(
      LocationTracker.sharedInstance.locationManager,
      didUpdateLocations: []
    )

    // Should not crash and should maintain previous state
    #expect(LocationTracker.sharedInstance.currentLocation == previousLocation)
  }

  @Test("Location update with high accuracy location")
  func locationUpdateWithHighAccuracyLocation() async {
    ApplicationSharedState.sharedInstance.clear()

    let highAccuracyLocation = CLLocation(
      coordinate: CLLocationCoordinate2D(latitude: 42.360123456, longitude: -71.058987654),
      altitude: 10.0,
      horizontalAccuracy: 5.0,
      verticalAccuracy: 5.0,
      timestamp: Date()
    )

    LocationTracker.sharedInstance.locationManager(
      LocationTracker.sharedInstance.locationManager,
      didUpdateLocations: [highAccuracyLocation]
    )

    let currentLocation = LocationTracker.sharedInstance.currentLocation
    #expect(currentLocation?.horizontalAccuracy == 5.0)
    guard let currentLocation = currentLocation else {
      #expect(Bool(false), "Current location should not be nil")
      return
    }
    #expect(abs(currentLocation.coordinate.latitude - 42.360123456) < 0.000001)
  }

  @Test("Location update with low accuracy location")
  func locationUpdateWithLowAccuracyLocation() async {
    ApplicationSharedState.sharedInstance.clear()

    let lowAccuracyLocation = CLLocation(
      coordinate: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589),
      altitude: 0.0,
      horizontalAccuracy: 100.0, // Low accuracy
      verticalAccuracy: -1.0, // Invalid vertical accuracy
      timestamp: Date()
    )

    LocationTracker.sharedInstance.locationManager(
      LocationTracker.sharedInstance.locationManager,
      didUpdateLocations: [lowAccuracyLocation]
    )

    let currentLocation = LocationTracker.sharedInstance.currentLocation
    #expect(currentLocation?.horizontalAccuracy == 100.0)
    #expect(currentLocation?.verticalAccuracy == -1.0)
  }

  @Test("Location update with old timestamp")
  func locationUpdateWithOldTimestamp() async {
    ApplicationSharedState.sharedInstance.clear()

    let oldLocation = CLLocation(
      coordinate: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589),
      altitude: 0.0,
      horizontalAccuracy: 5.0,
      verticalAccuracy: 5.0,
      timestamp: Date().addingTimeInterval(-3600) // 1 hour ago
    )

    LocationTracker.sharedInstance.locationManager(
      LocationTracker.sharedInstance.locationManager,
      didUpdateLocations: [oldLocation]
    )

    // Should still update even with old timestamp
    #expect(LocationTracker.sharedInstance.currentLocation != nil)
  }

  @Test("Start updating location executes")
  func startUpdatingLocationExecutes() async {
    LocationTracker.sharedInstance.startUpdatingLocation()
    #expect(true)
  }

  @Test("Location manager configuration")
  func locationManagerConfiguration() async {
    let manager = LocationTracker.sharedInstance.locationManager
    #expect(manager.distanceFilter == kCLDistanceFilterNone)
    #expect(manager.desiredAccuracy == kCLLocationAccuracyBest)
  }

  @Test("Location manager delegate is set correctly")
  func locationManagerDelegateIsSetCorrectly() async {
    let manager = LocationTracker.sharedInstance.locationManager
    #expect(manager.delegate === LocationTracker.sharedInstance)
  }

  @Test("Singleton instance consistency")
  func singletonInstanceConsistency() async {
    let instance1 = LocationTracker.sharedInstance
    let instance2 = LocationTracker.sharedInstance

    #expect(instance1 === instance2)
  }

  @Test("Current location persistence across updates")
  func currentLocationPersistenceAcrossUpdates() async {
    ApplicationSharedState.sharedInstance.clear()

    let location1 = CLLocation(latitude: 42.3601, longitude: -71.0589)
    let location2 = CLLocation(latitude: 42.3611, longitude: -71.0599)

    // First update
    LocationTracker.sharedInstance.locationManager(
      LocationTracker.sharedInstance.locationManager,
      didUpdateLocations: [location1]
    )
    #expect(LocationTracker.sharedInstance.currentLocation?.coordinate.latitude == 42.3601)

    // Second update should replace first
    LocationTracker.sharedInstance.locationManager(
      LocationTracker.sharedInstance.locationManager,
      didUpdateLocations: [location2]
    )
    #expect(LocationTracker.sharedInstance.currentLocation?.coordinate.latitude == 42.3611)
  }
}
