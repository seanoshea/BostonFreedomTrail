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

import GoogleMaps

/// Keys used to store user preferences in NSUserDefaults
enum DefaultsKeys: String {
  /// Key for storing the last known camera zoom in the map view
  case applicationSharedStateCameraZoom
  /// Key for storing the latitude of the placemark on which the user last tapped
  case lastKnownPlacemarkCoordinateLatitude
  /// Key for storing the longitude of the placemark on which the user last tapped
  case lastKnownPlacemarkCoordinateLongitude
  /// Key for storing the latitude of where the user last tapped on the map view
  case lastKnownLocationLatitude
  /// Key for storing the longitude of where the user last tapped on the map view
  case lastKnownLocationLongitude
  /// Key for storing the latitude of where the user was last noticed on the map view
  case lastKnownCoordinateLatitude
  /// Key for storing the longitude of where the user was last noticed on the map view
  case lastKnownCoordinateLongitude
}

/// Simple accessors for user defaults used throughout the app.
final class ApplicationSharedState {
  
  /// Singleton accessor for `ApplicationSharedState`.
  static let sharedInstance = ApplicationSharedState()
  
  /// The last known camera zoom specified by the user in the virtual tour.
  var cameraZoom: Float {
    set {
      guard newValue > kGMSMinZoomLevel && newValue < kGMSMaxZoomLevel else {
        return
      }
      UserDefaults.standard.set(newValue, forKey: DefaultsKeys.applicationSharedStateCameraZoom.rawValue)
    }
    get {
      return UserDefaults.standard.float(forKey: DefaultsKeys.applicationSharedStateCameraZoom.rawValue)
    }
  }
  
  /// The last known placemark that the user interacted with in the map view.
  var lastKnownPlacemarkCoordinate: CLLocationCoordinate2D {
    set {
      UserDefaults.standard.set(newValue.latitude, forKey: DefaultsKeys.lastKnownPlacemarkCoordinateLatitude.rawValue)
      UserDefaults.standard.set(newValue.longitude, forKey: DefaultsKeys.lastKnownPlacemarkCoordinateLongitude.rawValue)
    }
    get {
      let latitude = UserDefaults.standard.double(forKey: DefaultsKeys.lastKnownPlacemarkCoordinateLatitude.rawValue)
      let longitude = UserDefaults.standard.double(forKey: DefaultsKeys.lastKnownPlacemarkCoordinateLongitude.rawValue)
      return CLLocationCoordinate2D.init(latitude:latitude, longitude:longitude)
    }
  }

  /// The last known location that the user interacted with in the map view.
  var lastKnownCoordinate: CLLocationCoordinate2D {
    set {
      UserDefaults.standard.set(newValue.latitude, forKey: DefaultsKeys.lastKnownCoordinateLatitude.rawValue)
      UserDefaults.standard.set(newValue.longitude, forKey: DefaultsKeys.lastKnownCoordinateLongitude.rawValue)
    }
    get {
      let latitude = UserDefaults.standard.double(forKey: DefaultsKeys.lastKnownCoordinateLatitude.rawValue)
      let longitude = UserDefaults.standard.double(forKey: DefaultsKeys.lastKnownCoordinateLongitude.rawValue)
      return CLLocationCoordinate2D.init(latitude:latitude, longitude:longitude)
    }
  }
  
  /// The last known location the user was seen in the map view.
  var lastKnownLocation: CLLocation {
    set {
      UserDefaults.standard.set(newValue.coordinate.latitude, forKey: DefaultsKeys.lastKnownLocationLatitude.rawValue)
      UserDefaults.standard.set(newValue.coordinate.longitude, forKey: DefaultsKeys.lastKnownLocationLongitude.rawValue)
    }
    get {
      let latitude = UserDefaults.standard.double(forKey: DefaultsKeys.lastKnownLocationLatitude.rawValue)
      let longitude = UserDefaults.standard.double(forKey: DefaultsKeys.lastKnownLocationLongitude.rawValue)
      return CLLocation.init(latitude:latitude, longitude:longitude)
    }
  }
  
  /// Indicates whether the app is built in debug mode or not.
  func isDebug() -> Bool {
    #if DEBUG
      return true
    #else
      return false
    #endif
  }
  
  /// Gives a clean slate to the user defaults.
  func clear() {
    UserDefaults.standard.removeObject(forKey: DefaultsKeys.applicationSharedStateCameraZoom.rawValue)
    UserDefaults.standard.removeObject(forKey: DefaultsKeys.lastKnownPlacemarkCoordinateLatitude.rawValue)
    UserDefaults.standard.removeObject(forKey: DefaultsKeys.lastKnownPlacemarkCoordinateLongitude.rawValue)
    UserDefaults.standard.removeObject(forKey: DefaultsKeys.lastKnownLocationLatitude.rawValue)
    UserDefaults.standard.removeObject(forKey: DefaultsKeys.lastKnownLocationLongitude.rawValue)
    UserDefaults.standard.removeObject(forKey: DefaultsKeys.lastKnownCoordinateLatitude.rawValue)
    UserDefaults.standard.removeObject(forKey: DefaultsKeys.lastKnownCoordinateLongitude.rawValue)
  }
}
