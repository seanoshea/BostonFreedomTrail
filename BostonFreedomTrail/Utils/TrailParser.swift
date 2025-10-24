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
 * XML element and attribute names for parsing the Freedom Trail KML file.
 * 
 * These constants ensure consistent parsing of the trail.kml file that contains
 * all Freedom Trail location data, coordinates, and metadata.
 */
enum TrailParserConstants: String {
  /// Root filename for the trail data
  case trail = "trail"
  /// KML file extension
  case kml = "kml"
  /// KML folder element containing placemarks
  case folder = "Folder"
  /// Individual placemark element
  case placemark = "Placemark"
  /// Name element for location titles
  case name = "name"
  /// Style URL reference (unused but parsed)
  case styleUrl = "styleUrl"
  /// Description element containing HTML content
  case description = "description"
  /// Multi-geometry container element
  case multiGeometry = "MultiGeometry"
  /// Point geometry element
  case point = "Point"
  /// Coordinates element containing lat/lng data
  case coordinates = "coordinates"
  /// Unique identifier attribute
  case identifier = "id"
  /// Line string geometry for paths
  case lineString = "LineString"
  /// Camera positioning element
  case lookAt = "LookAt"
  /// Latitude coordinate element
  case latitude = "latitude"
  /// Longitude coordinate element
  case longitude = "longitude"
  /// Camera tilt angle element
  case tilt = "tilt"
  /// Camera heading angle element
  case heading = "heading"
}

/**
 * XML parser for processing Freedom Trail data from KML files.
 * 
 * TrailParser implements XMLParserDelegate to parse the trail.kml file containing
 * all Freedom Trail locations, coordinates, descriptions, and camera positioning data.
 * The parser handles complex KML structures including nested geometries and metadata.
 * 
 * ## Features
 * - Parses placemark locations and descriptions
 * - Extracts coordinate paths for trail navigation
 * - Processes camera positioning data for street view
 * - Handles HTML-encoded descriptions
 * - Creates complete Trail data structure
 * 
 * ## Usage
 * ```swift
 * let parser = TrailParser()
 * let trail = parser.parseTrail()
 * print("Loaded \(trail.placemarks.count) locations")
 * ```
 * 
 * - Author: Upwards Northwards Software Limited
 * - Since: 1.0
 */
final class TrailParser: NSObject, XMLParserDelegate {

  var trail = Trail()
  var currentLocation: CLLocation?

  var startFolder = false
  var startPlacemark = false
  var startName = false
  var startDescription = false
  var startPoint = false
  var startCoordinates = false
  var startLine = false
  var startLineCoordinates = false
  var hasLookAt = false
  var startLookAt = false
  var startLatitude = false
  var startLongitude = false
  var startTilt = false
  var startHeading = false

  var currentIdentifier: String?
  var currentName: String?
  var currentLineCoordinates: String?
  var currentDescription: String?
  var currentLatitude: String?
  var currentLongitude: String?
  var currentTilt: String?
  var currentHeading: String?

  /**
   * Parses the Freedom Trail KML file and returns a complete Trail data structure.
   * 
   * This method loads the trail.kml file from the app bundle and processes it
   * using XMLParser to extract all placemark data, coordinates, and metadata.
   * 
   * - Returns: Complete Trail object containing all Freedom Trail locations
   * 
   * ## Implementation Details
   * - Loads trail.kml from the main bundle
   * - Uses XMLParser with delegate pattern
   * - Processes all placemarks sequentially
   * - Handles parsing errors gracefully
   */
  func parseTrail() -> Trail {
    guard let path = Bundle.main.path(forResource: TrailParserConstants.trail.rawValue, ofType: TrailParserConstants.kml.rawValue) else {
      print("Error: trail.kml file not found in bundle")
      return Trail() // Return empty trail
    }

    let fileURL = URL(fileURLWithPath: path)
    guard let parser = XMLParser(contentsOf: fileURL) else {
      print("Error: Could not create XML parser for trail.kml")
      return Trail() // Return empty trail
    }

    parser.delegate = self
    let success = parser.parse()

    if !success {
      print("Error: Failed to parse trail.kml - \(parser.parserError?.localizedDescription ?? "Unknown error")")
    }

    print("Successfully parsed \(trail.placemarks.count) placemarks from trail.kml")
    return trail
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
    switch elementName {
    case TrailParserConstants.folder.rawValue:
      startFolder = true
    case TrailParserConstants.placemark.rawValue:
      guard let identifier = attributeDict[TrailParserConstants.identifier.rawValue] else { break }
      currentIdentifier = identifier
      startPlacemark = true
    case TrailParserConstants.name.rawValue:
      startName = true
    case TrailParserConstants.description.rawValue:
      startDescription = true
    case TrailParserConstants.lineString.rawValue:
      startLine = true
    case TrailParserConstants.coordinates.rawValue:
      if startLine {
        startLineCoordinates = true
      } else {
        startCoordinates = true
      }
    case TrailParserConstants.point.rawValue:
      startPoint = true
    case TrailParserConstants.lookAt.rawValue:
      startLookAt = true
    case TrailParserConstants.latitude.rawValue:
      startLatitude = true
    case TrailParserConstants.longitude.rawValue:
      startLongitude = true
    case TrailParserConstants.tilt.rawValue:
      startTilt = true
    case TrailParserConstants.heading.rawValue:
      startHeading = true
    default:
      break
    }
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    if startFolder {
      if startName {
        currentName = string
      } else if startDescription {
        currentDescription = string
      } else if startCoordinates && !startLineCoordinates {
        let coordinates = string.components(separatedBy: ",")
        currentLocation = CLLocation(latitude: Double(coordinates[1])!, longitude: Double(coordinates[0])!)
      } else if startLineCoordinates {
        currentLineCoordinates = string
      }
    }
    if startLookAt {
      hasLookAt = true
      if startLatitude {
        currentLatitude = string
      } else if startLongitude {
        currentLongitude = string
      } else if startTilt {
        currentTilt = string
      } else if startHeading {
        currentHeading = string
      }
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    switch elementName {
    case TrailParserConstants.folder.rawValue:
      startFolder = false
    case TrailParserConstants.name.rawValue:
      startName = false
    case TrailParserConstants.description.rawValue:
      startDescription = false
    case TrailParserConstants.coordinates.rawValue:
      if startLine {
        startLineCoordinates = false
      } else {
        startCoordinates = false
      }
    case TrailParserConstants.point.rawValue:
      startPoint = false
    case TrailParserConstants.placemark.rawValue:
      startPlacemark = false
    case TrailParserConstants.lineString.rawValue:
      startLine = false
      let lookAt = parseLookAt()
      let placemark = Placemark(identifier: currentIdentifier!, name: currentName!, location: currentLocation!, coordinates: parseLineCoordinates(), placemarkDescription: currentDescription!, lookAt: lookAt)
      trail.placemarks.append(placemark)
      hasLookAt = false
    case TrailParserConstants.lookAt.rawValue:
      startLookAt = false
    case TrailParserConstants.latitude.rawValue:
      startLatitude = false
    case TrailParserConstants.longitude.rawValue:
      startLongitude = false
    case TrailParserConstants.tilt.rawValue:
      startTilt = false
    case TrailParserConstants.heading.rawValue:
      startHeading = false
    default:
      break
    }
  }

  /**
   * Converts KML coordinate strings into CLLocation objects for path navigation.
   * 
   * This method processes the coordinate strings from KML LineString elements,
   * parsing comma-separated longitude,latitude pairs into CLLocation objects
   * that define the walking path to each placemark.
   * 
   * - Returns: Array of CLLocation objects representing the path coordinates
   * 
   * ## Format Processing
   * - Input: "lng1,lat1,0.0 lng2,lat2,0.0 ..."
   * - Output: [CLLocation(lat1, lng1), CLLocation(lat2, lng2), ...]
   * - Removes elevation data (0.0) as it's not needed
   */
  func parseLineCoordinates() -> [CLLocation] {
    var path = [CLLocation]()

    guard let coordinateString = currentLineCoordinates, !coordinateString.isEmpty else {
      print("Warning: No line coordinates to parse")
      return path
    }

    let cleanedString = coordinateString.replacingOccurrences(of: "0.0 ", with: "")
    var coordinatesArray = cleanedString.components(separatedBy: ",")

    // Remove last element if it's empty
    if coordinatesArray.last?.isEmpty == true {
      coordinatesArray.removeLast()
    }

    // Ensure we have pairs of coordinates
    guard coordinatesArray.count >= 2 && coordinatesArray.count % 2 == 0 else {
      print("Warning: Invalid coordinate array count: \(coordinatesArray.count)")
      return path
    }

    for index in stride(from: 0, to: coordinatesArray.count - 1, by: 2) {
      guard index + 1 < coordinatesArray.count else { break }

      guard let longitude = Double(coordinatesArray[index]),
            let latitude = Double(coordinatesArray[index + 1]) else {
        print("Warning: Could not parse coordinates at index \(index)")
        continue
      }

      // Validate coordinate bounds
      guard latitude >= -90.0 && latitude <= 90.0 &&
            longitude >= -180.0 && longitude <= 180.0 else {
        print("Warning: Invalid coordinate bounds - lat: \(latitude), lng: \(longitude)")
        continue
      }

      path.append(CLLocation(latitude: latitude, longitude: longitude))
    }

    return path
  }

  /**
   * Creates a LookAt object from parsed camera positioning data.
   * 
   * This method converts the string values parsed from KML LookAt elements
   * into a structured LookAt object containing camera positioning information
   * for optimal street view presentation.
   * 
   * - Returns: LookAt object with camera positioning data, or nil if no LookAt data exists
   * 
   * ## Data Conversion
   * - Converts string coordinates to Double values
   * - Validates that all required LookAt elements are present
   * - Returns nil for placemarks without camera positioning data
   */
  func parseLookAt() -> LookAt? {
    guard hasLookAt else { return nil }

    guard let latString = currentLatitude, let latitude = Double(latString) else {
      print("Warning: Could not parse LookAt latitude")
      return nil
    }

    guard let lngString = currentLongitude, let longitude = Double(lngString) else {
      print("Warning: Could not parse LookAt longitude")
      return nil
    }

    guard let tiltString = currentTilt, let tilt = Double(tiltString) else {
      print("Warning: Could not parse LookAt tilt")
      return nil
    }

    guard let headingString = currentHeading, let heading = Double(headingString) else {
      print("Warning: Could not parse LookAt heading")
      return nil
    }

    // Validate coordinate bounds
    guard latitude >= -90.0 && latitude <= 90.0 else {
      print("Warning: Invalid LookAt latitude: \(latitude)")
      return nil
    }

    guard longitude >= -180.0 && longitude <= 180.0 else {
      print("Warning: Invalid LookAt longitude: \(longitude)")
      return nil
    }

    // Validate tilt and heading ranges
    guard tilt >= 0.0 && tilt <= 90.0 else {
      print("Warning: Invalid LookAt tilt: \(tilt)")
      return nil
    }

    guard heading >= 0.0 && heading <= 360.0 else {
      print("Warning: Invalid LookAt heading: \(heading)")
      return nil
    }

    return LookAt(latitude: latitude, longitude: longitude, tilt: tilt, heading: heading)
  }
}
