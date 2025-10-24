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

/// Enum for loading values from the app's plist
enum PListHelperConstants: String {
  /// Constant for the API key for Google Maps
  case bostonFreedomTrailGoogleMapAPIKey
  /// Constant for the default latitude for the map view
  case bostonFreedomTrailDefaultLatitude
  /// Constant for the default longitude for the map view
  case bostonFreedomTrailDefaultLongitude
  /// Constant for the default camera zoom for the map view
  case bostonFreedomTrailDefaultCameraZoom
}

/// Helper functions for loading values from the app's plist
struct PListHelper {

  /**
   Retrieves the Google Maps API which is used to initialize the map in the map view
   
   - returns: the Google Maps API key used in the app
   - throws: fatalError if API key is not found or not properly configured
   */
  static func googleMapsApiKey() -> String {
    guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else {
      fatalError("APIKeys.plist file not found in bundle")
    }

    guard let apiKeys = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else {
      fatalError("APIKeys.plist could not be parsed as dictionary")
    }

    guard let googleMapsKey = apiKeys["GoogleMapsAPIKey"] as? String else {
      fatalError("GoogleMapsAPIKey not found in APIKeys.plist")
    }

    guard !googleMapsKey.isEmpty && googleMapsKey != "GOOGLE_MAPS_API_KEY_PLACEHOLDER" else {
      fatalError("GoogleMapsAPIKey not configured - please set a valid API key in APIKeys.plist")
    }

    return googleMapsKey
  }

  /**
   Retrieves the latitude to set the map to if the user has never used the app before
   
   - returns: the default latitude used in the map view
   */
  static func defaultLatitude() -> Double {
    guard let value = plistDictionary()[PListHelperConstants.bostonFreedomTrailDefaultLatitude.rawValue] else {
      return 42.355721486582 // Boston Common default
    }

    let latitude = value.doubleValue

    // Validate latitude is within valid range
    guard latitude >= -90.0 && latitude <= 90.0 else {
      print("Warning: Invalid latitude \(latitude) in plist, using default")
      return 42.355721486582
    }

    return latitude
  }

  /**
   Retrieves the longitude to set the map to if the user has never used the app before
   
   - returns: the default longitude used in the map view
   */
  static func defaultLongitude() -> Double {
    guard let value = plistDictionary()[PListHelperConstants.bostonFreedomTrailDefaultLongitude.rawValue] else {
      return -71.063303947449 // Boston Common default
    }

    let longitude = value.doubleValue

    // Validate longitude is within valid range
    guard longitude >= -180.0 && longitude <= 180.0 else {
      print("Warning: Invalid longitude \(longitude) in plist, using default")
      return -71.063303947449
    }

    return longitude
  }

  /**
   Retrieves the camera zoom to set the map to if the user has never used the app before
   
   - returns: the default camera zoom used in the map view
   */
  static func defaultCameraZoom() -> Float {
    guard let value = plistDictionary()[PListHelperConstants.bostonFreedomTrailDefaultCameraZoom.rawValue] else {
      return 14.0
    }

    let zoom = value.floatValue

    // Validate zoom is within reasonable range
    guard zoom >= CameraZoomConstraints.minimum.rawValue && zoom <= CameraZoomConstraints.maximum.rawValue else {
      print("Warning: Invalid zoom \(zoom) in plist, using default")
      return 14.0
    }

    return zoom
  }

  /**
   Retrieves the plist in key/value format
   
   - returns: dictionary representation of the app's plist
   */
  static func plistDictionary() -> [String: AnyObject] {
    guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else {
      print("Warning: Info.plist not found in bundle")
      return [:]
    }

    guard let pListContents = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else {
      print("Warning: Info.plist could not be parsed as dictionary")
      return [:]
    }

    return pListContents
  }
}
