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

  // MARK: - Camera Zoom Tests

  @Test("Gets current camera zoom")
  func getsCurrentCameraZoom() async {
    ApplicationSharedState.sharedInstance.clear()
    UserDefaults.standard.set(12.0, forKey: "applicationSharedStateCameraZoom")

    #expect(ApplicationSharedState.sharedInstance.cameraZoom == 12.0)
  }

  @Test("Sets current camera zoom")
  func setsCurrentCameraZoom() async {
    ApplicationSharedState.sharedInstance.clear()
    ApplicationSharedState.sharedInstance.cameraZoom = 8.0

    #expect(UserDefaults.standard.float(forKey: "applicationSharedStateCameraZoom") == 8.0)
  }

  @Test("Does not allow camera zoom that is too small")
  func doesNotAllowTooSmallCameraZoom() async {
    ApplicationSharedState.sharedInstance.clear()
    ApplicationSharedState.sharedInstance.cameraZoom = 12.0

    ApplicationSharedState.sharedInstance.cameraZoom = 1.0

    #expect(UserDefaults.standard.float(forKey: "applicationSharedStateCameraZoom") == 12.0)
  }

  // MARK: - Last Placemark Pressed Tests

  @Test("Retrieves lat and long of recently pressed placemark")
  func retrievesLastKnownPlacemarkCoordinate() async {
    ApplicationSharedState.sharedInstance.clear()
    UserDefaults.standard.set(12.0, forKey: "lastKnownPlacemarkCoordinateLatitude")
    UserDefaults.standard.set(11.0, forKey: "lastKnownPlacemarkCoordinateLongitude")

    let coordinate = ApplicationSharedState.sharedInstance.lastKnownPlacemarkCoordinate

    #expect(coordinate.latitude == 12.0)
    #expect(coordinate.longitude == 11.0)
  }

  @Test("Stores lat and long of recently pressed placemark")
  func storesLastKnownPlacemarkCoordinate() async {
    ApplicationSharedState.sharedInstance.clear()
    let latitude: Double = -71.063303
    let longitude: Double = 42.35769

    ApplicationSharedState.sharedInstance.lastKnownPlacemarkCoordinate = CLLocationCoordinate2D(
      latitude: latitude,
      longitude: longitude
    )

    #expect(UserDefaults.standard.double(forKey: "lastKnownPlacemarkCoordinateLatitude") == -71.063303)
    #expect(UserDefaults.standard.double(forKey: "lastKnownPlacemarkCoordinateLongitude") == 42.35769)
  }

  // MARK: - Last User Location Tests

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
}
