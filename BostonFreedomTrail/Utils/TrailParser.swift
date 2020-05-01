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

/// Constants for parsing the kml file.
enum TrailParserConstants: String {
  case trail = "trail"
  case kml = "kml"
  case folder = "Folder"
  case placemark = "Placemark"
  case name = "name"
  case styleUrl = "styleUrl"
  case description = "description"
  case multiGeometry = "MultiGeometry"
  case point = "Point"
  case coordinates = "coordinates"
  case identifier = "id"
  case lineString = "LineString"
  case lookAt = "LookAt"
  case latitude = "latitude"
  case longitude = "longitude"
  case tilt = "tilt"
  case heading = "heading"
}

/// Used to parse the trails from the kml file.
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
  
  func parseTrail() -> Trail {
    let path = Bundle.main.path(forResource: TrailParserConstants.trail.rawValue, ofType: TrailParserConstants.kml.rawValue)
    let parser = XMLParser(contentsOf: URL(fileURLWithPath: path!))!
    parser.delegate = self
    parser.parse()
    return trail
  }
  
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
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
        currentLocation = CLLocation.init(latitude: Double(coordinates[1])!, longitude: Double(coordinates[0])!)
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
      let placemark = Placemark(identifier:currentIdentifier!, name:currentName!, location:currentLocation!, coordinates:parseLineCoordinates(), placemarkDescription:currentDescription!, lookAt:lookAt)
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
  
  func parseLineCoordinates() -> [CLLocation] {
    var path = [CLLocation]()
    guard currentLineCoordinates != nil else { return path }
    currentLineCoordinates = currentLineCoordinates?.replacingOccurrences(of: "0.0 ", with: "")
    var coordinatesArray = currentLineCoordinates!.components(separatedBy: ",")
    coordinatesArray.removeLast()
    for index in stride(from: 0, to: coordinatesArray.count - 1, by: 2) {
      path.append(CLLocation.init(latitude: Double(coordinatesArray[index + 1])!, longitude: Double(coordinatesArray[index])!))
    }
    return path
  }
  
  func parseLookAt() -> LookAt? {
    guard hasLookAt else { return nil }
    let latitude: Double = Double(currentLatitude!)!
    let longitude: Double = Double(currentLongitude!)!
    let tilt = Double(currentTilt!)!
    let heading = Double(currentHeading!)!
    return LookAt.init(latitude:latitude, longitude:longitude, tilt:tilt, heading:heading)
  }
}
