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

enum TrailParserConstants : String {
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
}

public class TrailParser : NSObject, NSXMLParserDelegate {
 
    var trail = Trail()
    var currentPoint:Point?

    var startFolder = false
    var startPlacemark = false
    var startName = false
    var startDescription = false
    var startPoint = false
    var startCoordinates = false
    var startLine = false
    var startLineCoordinates = false
    
    var currentIdentifier:String?
    var currentName:String?
    var currentLineCoordinates:String?
    var currentDescription:String?

    public func parseTrail() -> Trail {
        let path = NSBundle.mainBundle().pathForResource(TrailParserConstants.trail.rawValue, ofType: TrailParserConstants.kml.rawValue)
        let parser = NSXMLParser(contentsOfURL: NSURL.fileURLWithPath(path!))!
        parser.delegate = self
        parser.parse()
        return trail
    }
    
    public func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch (elementName) {
        case TrailParserConstants.folder.rawValue:
            startFolder = true
            break
        case TrailParserConstants.placemark.rawValue:
            if let identifier = attributeDict[TrailParserConstants.identifier.rawValue] {
                currentIdentifier = identifier
            }
            startPlacemark = true
            break
        case TrailParserConstants.name.rawValue:
            startName = true
            break
        case TrailParserConstants.description.rawValue:
            startDescription = true
            break
        case TrailParserConstants.lineString.rawValue:
            startLine = true
            break
        case TrailParserConstants.coordinates.rawValue:
            if startLine {
                startLineCoordinates = true
            } else {
                startCoordinates = true
            }
            break
        case TrailParserConstants.point.rawValue:
            startPoint = true
            currentPoint = Point()
            break
        default:
            break
        }
    }
    
    public func parser(parser: NSXMLParser, foundCharacters string: String) {
        if startFolder {
            if startName {
                currentName = string
            } else if startDescription {
                currentDescription = string
            } else if startCoordinates && !startLineCoordinates {
                let coordinates = string.componentsSeparatedByString(",")
                currentPoint?.longitude = Double(coordinates[0])!
                currentPoint?.latitude = Double(coordinates[1])!
            } else if startLineCoordinates {
                currentLineCoordinates = string
            }
        }
    }
    
    public func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch (elementName) {
        case TrailParserConstants.folder.rawValue:
            startFolder = false
            break
        case TrailParserConstants.name.rawValue:
            startName = false
            break
        case TrailParserConstants.description.rawValue:
            startDescription = false
            break
        case TrailParserConstants.coordinates.rawValue:
            if startLine {
                startLineCoordinates = false
            } else {
                startCoordinates = false
            }
            break
        case TrailParserConstants.point.rawValue:
            startPoint = false
            break
        case TrailParserConstants.placemark.rawValue:
            startPlacemark = false
            break
        case TrailParserConstants.lineString.rawValue:
            startLine = false
            let placemark = Placemark(identifier: currentIdentifier!, name: currentName!, point: currentPoint!, coordinates: self.parseLineCoordinates(), placemarkDescription: currentDescription!)
            trail.placemarks.append(placemark)
            break
        default:
            break
        }
    }
    
    func parseLineCoordinates() -> [Point] {
        var path = [Point]()
        guard currentLineCoordinates != nil else { return path }
        currentLineCoordinates = currentLineCoordinates?.stringByReplacingOccurrencesOfString("0.0 ", withString: "")
        var coordinatesArray = currentLineCoordinates!.componentsSeparatedByString(",")
        coordinatesArray.removeLast()
        for index in 0.stride(to: coordinatesArray.count - 1, by: 2) {
            let point:Point = Point.init()
            point.longitude = Double(coordinatesArray[index])!
            point.latitude = Double(coordinatesArray[index + 1])!
            path.append(point)
        }
        return path
    }
}