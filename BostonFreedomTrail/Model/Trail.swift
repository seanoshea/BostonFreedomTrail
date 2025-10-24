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
 * Represents a single location on the Boston Freedom Trail.
 * 
 * Each Placemark contains comprehensive information about a Freedom Trail stop,
 * including its location, historical description, navigation coordinates, and
 * optimal viewing angles for street view functionality.
 * 
 * ## Properties
 * - Unique identifier for database/analytics tracking
 * - Human-readable name and HTML description
 * - Precise GPS coordinates and navigation path
 * - Camera positioning data for optimal street view
 * 
 * ## Usage
 * ```swift
 * let placemark = Placemark(
 *   identifier: "boston_common",
 *   name: "Boston Common",
 *   location: commonLocation,
 *   coordinates: pathToCommon,
 *   placemarkDescription: "<p>Historic description...</p>",
 *   lookAt: cameraPosition
 * )
 * ```
 * 
 * - Author: Upwards Northwards Software Limited
 * - Since: 1.0
 */
final class Placemark: @unchecked Sendable {

  // MARK: Properties

  /// Unique string identifier used for tracking and database operations
  var identifier: String = ""

  /// Display name of the Freedom Trail location (e.g., "Boston Common")
  var name: String = ""

  /// Precise GPS coordinates of the placemark's primary location
  var location: CLLocation = CLLocation()

  /// Sequential coordinates defining the walking path to reach this placemark
  var coordinates = [CLLocation]()

  /// HTML-formatted historical description displayed in the detail view
  var placemarkDescription: String = ""

  /// Optional camera positioning data for optimal street view presentation
  var lookAt: LookAt?

  /**
   * Initializes a new Freedom Trail placemark with complete location data.
   * 
   * - Parameter identifier: Unique string identifier for tracking and analytics
   * - Parameter name: Human-readable display name for the location
   * - Parameter location: Primary GPS coordinates of the placemark
   * - Parameter coordinates: Array of coordinates defining the walking path
   * - Parameter placemarkDescription: HTML-formatted historical description
   * - Parameter lookAt: Optional camera positioning for street view (can be nil)
   */
  init(identifier: String, name: String, location: CLLocation, coordinates: [CLLocation], placemarkDescription: String, lookAt: LookAt?) {
    self.identifier = identifier
    self.name = name
    self.location = location
    self.coordinates = coordinates
    self.placemarkDescription = placemarkDescription
    self.lookAt = lookAt
  }
}

/**
 * Camera positioning data for optimal street view presentation.
 * 
 * LookAt extends basic coordinate information with camera orientation data,
 * enabling precise positioning of street view cameras for the best viewing
 * experience of each Freedom Trail location.
 * 
 * ## Usage
 * ```swift
 * let cameraPosition = LookAt(
 *   latitude: 42.3601,
 *   longitude: -71.0589,
 *   tilt: 45.0,
 *   heading: 180.0
 * )
 * ```
 */
struct LookAt {

  // MARK: Properties

  /// Latitude coordinate for camera positioning
  var latitude: Double = 0.0

  /// Longitude coordinate for camera positioning
  var longitude: Double = 0.0

  /// Camera tilt angle in degrees (0° = looking straight down, 90° = looking straight ahead)
  var tilt: Double = 0.0

  /// Camera heading in degrees (0° = North, 90° = East, 180° = South, 270° = West)
  var heading: Double = 0.0

  /**
   * Initializes camera positioning data for street view presentation.
   * 
   * - Parameter latitude: Latitude coordinate for camera position
   * - Parameter longitude: Longitude coordinate for camera position
   * - Parameter tilt: Camera tilt angle in degrees (0-90°)
   * - Parameter heading: Camera heading in degrees (0-360°)
   */
  init(latitude: Double, longitude: Double, tilt: Double, heading: Double) {
    self.latitude = latitude
    self.longitude = longitude
    self.tilt = tilt
    self.heading = heading
  }
}

/**
 * @brief Central data structure representing the complete Boston Freedom Trail
 * 
 * The Trail struct serves as the primary data container for all Freedom Trail
 * locations and provides essential operations for placemark management and lookup.
 * Uses singleton pattern for consistent data access across the application.
 * 
 * @author Upwards Northwards Software Limited
 * @since 1.0
 * @version 2.0
 * 
 * Key Features:
 * - Singleton access to trail data via Trail.instance
 * - Collection of all Freedom Trail placemarks
 * - Placemark indexing and lookup functionality
 * - Thread-safe Sendable implementation
 * 
 * Usage:
 * ```swift
 * let trail = Trail.instance
 * let totalPlacemarks = trail.placemarks.count
 * let index = trail.placemarkIndex(selectedPlacemark)
 * ```
 */
struct Trail: Sendable {

  // MARK: Properties

  /// Singleton accessor
  static let instance = TrailParser().parseTrail()
  /// Collection of placemarks which represents the Freedom Trail
  var placemarks = [Placemark]()

  /**
   * Finds the sequential index of a placemark within the Freedom Trail.
   * 
   * This method performs a case-insensitive search through the placemarks array
   * to locate the specified placemark and return its position in the trail sequence.
   * 
   * - Parameter placemark: The placemark to locate within the trail
   * - Returns: Zero-based index of the placemark in the trail sequence
   * 
   * ## Usage
   * ```swift
   * let trail = Trail.instance
   * let index = trail.placemarkIndex(selectedPlacemark)
   * print("This is stop \(index + 1) of \(trail.placemarks.count)")
   * ```
   */
  func placemarkIndex(_ placemark: Placemark) -> Int {
    var placemarkIndex = 0
    for (index, pMark) in placemarks.enumerated() where pMark.identifier.caseInsensitiveCompare(placemark.identifier) == ComparisonResult.orderedSame {
      placemarkIndex = index
      break
    }
    return placemarkIndex
  }
}
