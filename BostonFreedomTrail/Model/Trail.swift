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

import CoreLocation

/// Backling class for every placemark on the Boston Freedom Trail.
final class Placemark {
  
  // MARK: Properties
  
  /// Unique identifier for the placemark
  var identifier: String = ""
  /// Human readable placemark name
  var name: String = ""
  /// Defines where the placemark is located
  var location: CLLocation = CLLocation()
  /// Array of coordinates which defines the path up to the placemark
  var coordinates = [CLLocation]()
  /// A brief HTML-encoded description of the placemark.
  var placemarkDescription: String = ""
  /// Includes heading and pitch information for the best view of the placemark
  var lookAt: LookAt?
  
  /**
   Convenience initializer. Sets all the properties for the `Placemark` class.
   
   - parameter identifier: the identifier for the `Placemark`.
   - parameter name: the name for the `Placemark`.
   - parameter location: the location for the `Placemark`.
   - parameter coordinates: the coordinates associated with the `Placemark`.
   - parameter placemarkDescription: the description for the `Placemark`.
   - parameter lookAt: `LookAt` associated with the `Placemark`.
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

/// Similar to a `CLLocation` but includes tilt and heading properties too.
struct LookAt {
  
  // MARK: Properties
  
  /// Latitude for the LookAt
  var latitude: Double = 0.0
  /// Longitude for the LookAt
  var longitude: Double = 0.0
  /// The tilt at which the camera should be position for the best view of the LookAt
  var tilt: Double = 0.0
  /// The relative positioning of the camera for the best view of the LookAt
  var heading: Double = 0.0
  
  /**
   Convenience initializer. Sets all the properties for the `LookAt` class.
   
   - parameter latitude: latitude for the `LookAt`.
   - parameter longitude: longitude for the `LookAt`.
   - parameter tilt: tilt for the `LookAt`.
   - parameter heading: heading for the `LookAt`.
   */
  init(latitude: Double, longitude: Double, tilt: Double, heading: Double) {
    self.latitude = latitude
    self.longitude = longitude
    self.tilt = tilt
    self.heading = heading
  }
}

/// Defines the full trail and collection of placemarks for the app.
struct Trail {
  
  // MARK: Properties
  
  /// Singleton accessor
  static let instance = TrailParser().parseTrail()
  /// Collection of placemarks which represents the Freedom Trail
  var placemarks = [Placemark]()
  
  /**
   Given a `Placemark` this function returns the associated index of the placemark in the trail.
   - parameter placemark: the `Placemark` to search for
   - returns: index of the `Placemark` in the trail
   */
  func placemarkIndex(_ placemark: Placemark) -> Int {
    var placemarkIndex = 0
    for (index, pm) in placemarks.enumerated() {
      if pm.identifier.caseInsensitiveCompare(placemark.identifier) == ComparisonResult.orderedSame {
        placemarkIndex = index
        break
      }
    }
    return placemarkIndex
  }
}
