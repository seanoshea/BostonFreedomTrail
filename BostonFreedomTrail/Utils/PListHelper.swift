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

/// Enum for loading values from the app's plist
enum PListHelperConstants: String {
  /// Constant for the API key for Google Maps
  case BostonFreedomTrailGoogleMapAPIKey
  /// Constant for the default latitude for the map view
  case BostonFreedomTrailDefaultLatitude
  /// Constant for the default longitude for the map view
  case BostonFreedomTrailDefaultLongitude
  /// Constant for the default camera zoom for the map view
  case BostonFreedomTrailDefaultCameraZoom
}

/// Helper functions for loading values from the app's plist
struct PListHelper {
  
  /**
   Retrieves the Google Maps API which is used to initialize the map in the map view
   
   - returns: the Google Maps API key used in the app
   */
  static func googleMapsApiKey() -> String {
    return (plistDictionary()[PListHelperConstants.BostonFreedomTrailGoogleMapAPIKey.rawValue] as? String)!
  }

  /**
   Retrieves the latitude to set the map to if the user has never used the app before
   
   - returns: the default latitude used in the map view
   */
  static func defaultLatitude() -> Double {
    return plistDictionary()[PListHelperConstants.BostonFreedomTrailDefaultLatitude.rawValue]!.doubleValue
  }

  /**
   Retrieves the longitude to set the map to if the user has never used the app before
   
   - returns: the default longitude used in the map view
   */
  static func defaultLongitude() -> Double {
    return plistDictionary()[PListHelperConstants.BostonFreedomTrailDefaultLongitude.rawValue]!.doubleValue
  }

  /**
   Retrieves the camera zoom to set the map to if the user has never used the app before
   
   - returns: the default camera zoom used in the map view
   */
  static func defaultCameraZoom() -> Float {
    return plistDictionary()[PListHelperConstants.BostonFreedomTrailDefaultCameraZoom.rawValue]!.floatValue
  }

  /**
   Retrieves the plist in key/value format
   
   - returns: dictionary representation of the app's plist
   */
  static func plistDictionary() -> [String: AnyObject] {
    let path = Bundle.main.path(forResource: "Info", ofType: "plist")
    let pListContents = NSDictionary(contentsOfFile: path!) as? [String: AnyObject]
    return pListContents!
  }
}
