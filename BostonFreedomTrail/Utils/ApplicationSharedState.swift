/*
 Copyright (c) 2014 - 2016 Upwards Northwards Software Limited
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

enum DefaultsKeys: String {
  case ApplicationSharedStateCameraZoom = "ApplicationSharedStateCameraZoom"
  case ApplicationSharedStateLastKnownPlacemarkCoordinateLatitude = "ApplicationSharedStateLastKnownPlacemarkCoordinateLatitude"
  case ApplicationSharedStateLastKnownPlacemarkCoordinateLongitude = "ApplicationSharedStateLastKnownPlacemarkCoordinateLongitude"
  case ApplicationSharedStateLastKnownLocationLatitude = "ApplicationSharedStateLastKnownLocationLatitude"
  case ApplicationSharedStateLastKnownLocationLongitude = "ApplicationSharedStateLastKnownLocationLongitude"
  case ApplicationSharedStateLastKnownCoordinateLatitude = "ApplicationSharedStateLastKnownCoordinateLatitude"
  case ApplicationSharedStateLastKnownCoordinateLongitude = "ApplicationSharedStateLastKnownCoordinateLongitude"
}

final class ApplicationSharedState {
  
  static let sharedInstance = ApplicationSharedState()
  
  var cameraZoom: Float {
    set {
      guard newValue > kGMSMinZoomLevel && newValue < kGMSMaxZoomLevel else {
        return
      }
      UserDefaults.standard.set(newValue, forKey: DefaultsKeys.ApplicationSharedStateCameraZoom.rawValue)
    }
    get {
      return UserDefaults.standard.float(forKey: DefaultsKeys.ApplicationSharedStateCameraZoom.rawValue) ?? PListHelper.defaultCameraZoom()
    }
  }
  
  var lastKnownPlacemarkCoordinate: CLLocationCoordinate2D {
    set {
      UserDefaults.standard.set(newValue.latitude, forKey: DefaultsKeys.ApplicationSharedStateLastKnownPlacemarkCoordinateLatitude.rawValue)
      UserDefaults.standard.set(newValue.longitude, forKey: DefaultsKeys.ApplicationSharedStateLastKnownPlacemarkCoordinateLongitude.rawValue)
    }
    get {
      let latitude = UserDefaults.standard.double(forKey: DefaultsKeys.ApplicationSharedStateLastKnownPlacemarkCoordinateLatitude.rawValue)
      let longitude = UserDefaults.standard.double(forKey: DefaultsKeys.ApplicationSharedStateLastKnownPlacemarkCoordinateLongitude.rawValue)
      return CLLocationCoordinate2D.init(latitude:latitude, longitude:longitude)
    }
  }
  
  var lastKnownCoordinate: CLLocationCoordinate2D {
    set {
      UserDefaults.standard.set(newValue.latitude, forKey: DefaultsKeys.ApplicationSharedStateLastKnownCoordinateLatitude.rawValue)
      UserDefaults.standard.set(newValue.longitude, forKey: DefaultsKeys.ApplicationSharedStateLastKnownCoordinateLongitude.rawValue)
    }
    get {
      let latitude = UserDefaults.standard.double(forKey: DefaultsKeys.ApplicationSharedStateLastKnownCoordinateLatitude.rawValue)
      let longitude = UserDefaults.standard.double(forKey: DefaultsKeys.ApplicationSharedStateLastKnownCoordinateLongitude.rawValue)
      return CLLocationCoordinate2D.init(latitude:latitude, longitude:longitude)
    }
  }
  
  var lastKnownLocation: CLLocation {
    set {
      UserDefaults.standard.set(newValue.coordinate.latitude, forKey: DefaultsKeys.ApplicationSharedStateLastKnownLocationLatitude.rawValue)
      UserDefaults.standard.set(newValue.coordinate.longitude, forKey: DefaultsKeys.ApplicationSharedStateLastKnownLocationLongitude.rawValue)
    }
    get {
      let latitude = UserDefaults.standard.double(forKey: DefaultsKeys.ApplicationSharedStateLastKnownLocationLatitude.rawValue)
      let longitude = UserDefaults.standard.double(forKey: DefaultsKeys.ApplicationSharedStateLastKnownLocationLongitude.rawValue)
      return CLLocation.init(latitude:latitude, longitude:longitude)
    }
  }
  
  func isDebug() -> Bool {
    #if DEBUG
      return true
    #else
      return false
    #endif
  }
  
  func clear() {
    UserDefaults.standard.removeObject(forKey: DefaultsKeys.ApplicationSharedStateCameraZoom.rawValue)
    UserDefaults.standard.removeObject(forKey: DefaultsKeys.ApplicationSharedStateLastKnownPlacemarkCoordinateLatitude.rawValue)
    UserDefaults.standard.removeObject(forKey: DefaultsKeys.ApplicationSharedStateLastKnownPlacemarkCoordinateLongitude.rawValue)
    UserDefaults.standard.removeObject(forKey: DefaultsKeys.ApplicationSharedStateLastKnownLocationLatitude.rawValue)
    UserDefaults.standard.removeObject(forKey: DefaultsKeys.ApplicationSharedStateLastKnownLocationLongitude.rawValue)
  }
}
