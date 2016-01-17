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
    case folder = "Folder"
    case placemark = "Placemark"
    case name = "name"
    case styleUrl = "styleUrl"
    case description = "description"
    case multiGeometry = "MultiGeometry"
    case point = "Point"
    case coordinates = "coordinates"
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
    
    var currentName:String?
    var currentDescription:String?

    public func parseTrail() -> Trail {
        let path = NSBundle.mainBundle().pathForResource("trail", ofType: "kml")
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
            startPlacemark = true
        case TrailParserConstants.name.rawValue:
            startName = true
            break
        case TrailParserConstants.description.rawValue:
            startDescription = true
            break
        case TrailParserConstants.coordinates.rawValue:
            startCoordinates = true
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
        if (startFolder) {
            if startName {
                currentName = string
            } else if startDescription {
                currentDescription = string
            } else if startCoordinates && currentPoint != nil {
                let coordinates = string.componentsSeparatedByString(",")
                currentPoint?.latitude = Double(coordinates[0])!
                currentPoint?.longitude = Double(coordinates[1])!
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
            startCoordinates = false
            break
        case TrailParserConstants.point.rawValue:
            startPoint = false
            let pm = Placemark(identifier: "", point: currentPoint!, placemarkDescription: currentDescription!)
            trail.placemarks.append(pm)
            currentPoint = nil
            break
        case TrailParserConstants.placemark.rawValue:
            startPlacemark = false
            break
        default:
            break
        }
    }
}