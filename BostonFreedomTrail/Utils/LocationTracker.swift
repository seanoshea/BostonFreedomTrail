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

import CoreLocation

/**
 * Singleton class for tracking user location throughout the app.
 * 
 * LocationTracker manages Core Location functionality, providing centralized
 * location services for the Boston Freedom Trail app. It handles location
 * permissions, updates, and maintains the user's current position.
 * 
 * ## Features
 * - Singleton pattern for app-wide location access
 * - Automatic location permission requests
 * - High-accuracy location tracking
 * - Integration with ApplicationSharedState for persistence
 * 
 * ## Usage
 * ```swift
 * LocationTracker.sharedInstance.startUpdatingLocation()
 * let currentLocation = LocationTracker.sharedInstance.currentLocation
 * ```
 * 
 * - Author: Upwards Northwards Software Limited
 * - Since: 1.0
 */
final class LocationTracker: NSObject, @unchecked Sendable {

  // MARK: Properties

  /// Shared singleton instance for app-wide location tracking
  static let sharedInstance = LocationTracker()

  /// The user's most recent location, updated automatically by Core Location
  var currentLocation: CLLocation?

  /**
   * Core Location manager configured for high-accuracy tracking.
   * 
   * This lazy property initializes the location manager with optimal settings
   * for the Freedom Trail experience, including permission requests and
   * accuracy configuration.
   * 
   * ## Configuration
   * - Requests both "always" and "when in use" location permissions
   * - No distance filter (updates on any movement)
   * - Best accuracy setting for precise trail navigation
   */
  lazy var locationManager: CLLocationManager = {
    var manager = CLLocationManager()
    manager.delegate = LocationTracker.sharedInstance
    manager.requestAlwaysAuthorization()
    manager.requestWhenInUseAuthorization()
    manager.distanceFilter = kCLDistanceFilterNone
    manager.desiredAccuracy = kCLLocationAccuracyBest
    return manager
  }()

  /**
   * Begins location tracking for the user's position.
   * 
   * This method starts the Core Location services to track the user's movement
   * along the Freedom Trail. Location updates are automatically handled by
   * the CLLocationManagerDelegate methods.
   * 
   * ## Behavior
   * - Starts continuous location updates
   * - Updates are stored in currentLocation property
   * - Integrates with ApplicationSharedState for persistence
   * - Requires location permissions to function
   */
  func startUpdatingLocation() {
    locationManager.startUpdatingLocation()
  }
}

/**
 * Core Location delegate implementation for handling location updates.
 * 
 * This extension implements the CLLocationManagerDelegate protocol to process
 * location updates and maintain the user's current position throughout the app.
 */
extension LocationTracker: CLLocationManagerDelegate {
  /**
   * Processes location updates from Core Location services.
   * 
   * This delegate method is called whenever the user's location changes,
   * updating both the local currentLocation property and the app's shared state
   * for persistence across app launches.
   * 
   * - Parameter manager: The CLLocationManager instance providing the update
   * - Parameter locations: Array of CLLocation objects, with the most recent location last
   * 
   * ## Implementation Details
   * - Uses the most recent location from the locations array
   * - Updates both local and shared state simultaneously
   * - Provides location data for map positioning and trail navigation
   */
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    LocationTracker.sharedInstance.currentLocation = locations.last
    guard let lastKnownLocation = LocationTracker.sharedInstance.currentLocation else { return }
    ApplicationSharedState.sharedInstance.lastKnownLocation = lastKnownLocation
  }
}
