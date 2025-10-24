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
 * Business logic model for the MapViewController providing map-related functionality.
 * 
 * This model handles all map-related operations including placemark management,
 * path drawing, camera positioning, and coordinate tracking for the Boston Freedom Trail.
 * It serves as the data layer between the MapViewController and the underlying
 * Google Maps SDK.
 * 
 * ## Responsibilities
 * - Adding Freedom Trail placemarks to the map
 * - Drawing the trail path between locations
 * - Managing camera zoom and positioning
 * - Coordinate validation and defaults
 * 
 * ## Usage
 * ```swift
 * let model = MapModel()
 * let markers = model.addPlacemarksToMap(mapView)
 * model.addPathToMap(mapView)
 * ```
 * 
 * - Author: Upwards Northwards Software Limited
 * - Since: 1.0
 */
final class MapModel {

  /**
   * Adds Freedom Trail placemark markers to the specified map view.
   * 
   * This method creates and configures GMSMarker objects for each placemark in the
   * Freedom Trail, using data parsed from the KML file. Each marker is positioned
   * at the correct coordinates and configured with the appropriate icon and title.
   * 
   * - Parameter mapView: The Google Maps view to add the markers to
   * - Returns: An array of configured GMSMarker objects representing all Freedom Trail locations
   * 
   * ## Implementation Details
   * - Uses Trail.instance.placemarks as the data source
   * - Sets custom orange/red icon for each marker
   * - Associates Placemark object as userData for each marker
   * - Automatically adds markers to the provided map view
   */
  func addPlacemarksToMap(_ mapView: GMSMapView) -> [GMSMarker] {
    var markers = [GMSMarker]()
    for placemark: Placemark in Trail.instance.placemarks {
      let marker = GMSMarker()
      marker.userData = placemark
      marker.position = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude)
      marker.icon = UIImage(named: ResourceConstants.placemarkResourceImage.rawValue)
      marker.title = placemark.name
      marker.map = mapView
      markers.append(marker)
    }
    return markers
  }

  /**
   * Draws the Freedom Trail path connecting all placemarks on the map.
   * 
   * This method creates a polyline path that connects all the Freedom Trail locations,
   * providing a visual representation of the walking route. The path uses the app's
   * signature orange-red color and appropriate stroke width for visibility.
   * 
   * - Parameter mapView: The Google Maps view to draw the path on
   * 
   * ## Visual Properties
   * - Color: Orange-red (matching app theme)
   * - Stroke width: 3.0 points
   * - Path follows all placemark coordinates in sequence
   */
  func addPathToMap(_ mapView: GMSMapView) {
    let path = GMSMutablePath()
    for placemark: Placemark in Trail.instance.placemarks {
      for location: CLLocation in placemark.coordinates {
        path.addLatitude(location.coordinate.latitude, longitude: location.coordinate.longitude)
      }
    }
    let polyline = GMSPolyline(path: path)
    polyline.strokeColor = UIColor.bftOrangeRedColor()
    polyline.strokeWidth = 3.0
    polyline.map = mapView
  }

  /**
   * Determines the appropriate camera zoom level for the map view.
   * 
   * This method retrieves the user's last known zoom preference from shared state,
   * or falls back to default values from the app's configuration if no previous
   * interaction has been recorded.
   * 
   * - Returns: Float value representing the camera zoom level (higher = more zoomed in)
   * 
   * ## Fallback Behavior
   * - Primary: Uses ApplicationSharedState.sharedInstance.cameraZoom
   * - Fallback: Uses PListHelper.defaultCameraZoom() from configuration
   * - Ensures zoom level is within viable constraints (12.0 - 20.0)
   */
  func zoomForMap() -> Float {
    var zoom = ApplicationSharedState.sharedInstance.cameraZoom
    if zoom <= 0 {
      zoom = PListHelper.defaultCameraZoom()
    }
    return zoom
  }

  /**
   * Determines the appropriate initial camera position for the map view.
   * 
   * This method retrieves the user's last known map position from shared state,
   * ensuring the map opens to a familiar location. If no previous interaction
   * exists, it falls back to default Boston coordinates from the app configuration.
   * 
   * - Returns: CLLocationCoordinate2D representing the map's initial center position
   * 
   * ## Coordinate Sources
   * - Primary: ApplicationSharedState.sharedInstance.lastKnownCoordinate
   * - Fallback: Default Boston coordinates from PListHelper configuration
   * - Validation: Checks for zero coordinates (0.0, 0.0) to trigger fallback
   */
  func lastKnownCoordinate() -> CLLocationCoordinate2D {
    var lastKnownCoordinate = ApplicationSharedState.sharedInstance.lastKnownCoordinate
    if lastKnownCoordinate.latitude == 0.0 && lastKnownCoordinate.longitude == 0.0 {
      lastKnownCoordinate = CLLocationCoordinate2D(latitude: PListHelper.defaultLatitude(), longitude: PListHelper.defaultLongitude())
    }
    return lastKnownCoordinate
  }

  /**
   * Validates whether a zoom level is within acceptable bounds for the application.
   * 
   * This method ensures zoom levels are within the app's defined constraints,
   * preventing extreme zoom values that could degrade user experience or
   * performance. Only validated zoom levels are saved to user preferences.
   * 
   * - Parameter zoom: The zoom level to validate
   * - Returns: true if the zoom level is within acceptable bounds (12.0 - 20.0), false otherwise
   * 
   * ## Constraints
   * - Minimum zoom: 12.0 (city-level view)
   * - Maximum zoom: 20.0 (street-level detail)
   * - Used to filter zoom values before saving to ApplicationSharedState
   */
  func isViableZoom(_ zoom: Float) -> Bool {
    zoom >= CameraZoomConstraints.minimum.rawValue && zoom <= CameraZoomConstraints.maximum.rawValue
  }
}
