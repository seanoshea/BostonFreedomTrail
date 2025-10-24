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

/**
 * UserDefaults keys for persisting user preferences and app state.
 * 
 * These keys provide type-safe access to stored user preferences including
 * map positioning, zoom levels, and location tracking data.
 */
enum DefaultsKeys: String {
  /// Camera zoom level preference for map and street view
  case applicationSharedStateCameraZoom
  /// Latitude of the last placemark the user interacted with
  case lastKnownPlacemarkCoordinateLatitude
  /// Longitude of the last placemark the user interacted with
  case lastKnownPlacemarkCoordinateLongitude
  /// Latitude of the user's last map interaction location
  case lastKnownLocationLatitude
  /// Longitude of the user's last map interaction location
  case lastKnownLocationLongitude
  /// Latitude of the user's last known position (from GPS)
  case lastKnownCoordinateLatitude
  /// Longitude of the user's last known position (from GPS)
  case lastKnownCoordinateLongitude
}

/**
 * Singleton class managing persistent app state and user preferences.
 * 
 * ApplicationSharedState provides centralized access to user preferences and
 * app state that persists across app launches. It handles map positioning,
 * zoom levels, and location tracking data using UserDefaults.
 * 
 * ## Features
 * - Singleton pattern for app-wide state access
 * - Type-safe UserDefaults access
 * - Coordinate and zoom level persistence
 * - Debug mode detection
 * - State clearing functionality
 * 
 * ## Usage
 * ```swift
 * let state = ApplicationSharedState.sharedInstance
 * state.cameraZoom = 15.0
 * let lastLocation = state.lastKnownCoordinate
 * ```
 * 
 * - Author: Upwards Northwards Software Limited
 * - Since: 1.0
 */
final class ApplicationSharedState: @unchecked Sendable {

  /// Shared singleton instance for app-wide state management
  static let sharedInstance = ApplicationSharedState()

  /**
   * User's preferred camera zoom level for map and street view.
   * 
   * This property persists the user's zoom preference across app launches,
   * ensuring a consistent viewing experience. Values are validated against
   * Google Maps SDK limits before storage.
   * 
   * ## Validation
   * - Minimum: kGMSMinZoomLevel (typically 2.0)
   * - Maximum: kGMSMaxZoomLevel (typically 21.0)
   * - Invalid values are ignored and not stored
   */
  var cameraZoom: Float {
    // swiftlint:disable:next computed_accessors_order
    set {
      guard newValue > kGMSMinZoomLevel && newValue < kGMSMaxZoomLevel else {
        return
      }
      UserDefaults.standard.set(newValue, forKey: DefaultsKeys.applicationSharedStateCameraZoom.rawValue)
    }
    get {
      UserDefaults.standard.float(forKey: DefaultsKeys.applicationSharedStateCameraZoom.rawValue)
    }
  }

  /**
   * Coordinates of the last Freedom Trail placemark the user interacted with.
   * 
   * This property tracks which placemark the user last tapped or viewed,
   * enabling features like "return to last viewed location" and analytics.
   * Coordinates are stored separately as latitude and longitude values.
   */
  var lastKnownPlacemarkCoordinate: CLLocationCoordinate2D {
    // swiftlint:disable:next computed_accessors_order
    set {
      UserDefaults.standard.set(newValue.latitude, forKey: DefaultsKeys.lastKnownPlacemarkCoordinateLatitude.rawValue)
      UserDefaults.standard.set(newValue.longitude, forKey: DefaultsKeys.lastKnownPlacemarkCoordinateLongitude.rawValue)
    }
    get {
      let latitude = UserDefaults.standard.double(forKey: DefaultsKeys.lastKnownPlacemarkCoordinateLatitude.rawValue)
      let longitude = UserDefaults.standard.double(forKey: DefaultsKeys.lastKnownPlacemarkCoordinateLongitude.rawValue)
      return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
  }

  /**
   * Coordinates of the user's last map interaction or camera position.
   * 
   * This property stores where the user last positioned the map camera,
   * allowing the app to restore the same view when reopened. Updated
   * whenever the user pans or interacts with the map.
   */
  var lastKnownCoordinate: CLLocationCoordinate2D {
    // swiftlint:disable:next computed_accessors_order
    set {
      UserDefaults.standard.set(newValue.latitude, forKey: DefaultsKeys.lastKnownCoordinateLatitude.rawValue)
      UserDefaults.standard.set(newValue.longitude, forKey: DefaultsKeys.lastKnownCoordinateLongitude.rawValue)
    }
    get {
      let latitude = UserDefaults.standard.double(forKey: DefaultsKeys.lastKnownCoordinateLatitude.rawValue)
      let longitude = UserDefaults.standard.double(forKey: DefaultsKeys.lastKnownCoordinateLongitude.rawValue)
      return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
  }

  /**
   * The user's last known GPS location from Core Location services.
   * 
   * This property stores the user's actual physical location as determined
   * by GPS, WiFi, or cellular triangulation. Used for location-based features
   * and proximity detection to Freedom Trail sites.
   */
  var lastKnownLocation: CLLocation {
    // swiftlint:disable:next computed_accessors_order
    set {
      UserDefaults.standard.set(newValue.coordinate.latitude, forKey: DefaultsKeys.lastKnownLocationLatitude.rawValue)
      UserDefaults.standard.set(newValue.coordinate.longitude, forKey: DefaultsKeys.lastKnownLocationLongitude.rawValue)
    }
    get {
      let latitude = UserDefaults.standard.double(forKey: DefaultsKeys.lastKnownLocationLatitude.rawValue)
      let longitude = UserDefaults.standard.double(forKey: DefaultsKeys.lastKnownLocationLongitude.rawValue)
      return CLLocation(latitude: latitude, longitude: longitude)
    }
  }

  /**
   * Determines if the app is running in debug mode.
   * 
   * This method uses compiler directives to detect debug builds,
   * enabling debug-specific functionality like enhanced logging.
   * 
   * - Returns: true if running in debug mode, false for release builds
   */
  func isDebug() -> Bool {
    #if DEBUG
      return true
    #else
      return false
    #endif
  }

  /**
   * Clears all stored user preferences and app state.
   * 
   * This method removes all persisted data from UserDefaults, effectively
   * resetting the app to its initial state. Useful for testing, debugging,
   * or providing a "reset app" feature.
   * 
   * ## Cleared Data
   * - Camera zoom preferences
   * - Last known placemark coordinates
   * - Last known user location
   * - Last known map camera position
   */
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
