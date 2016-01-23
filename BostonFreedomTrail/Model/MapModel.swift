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

import GoogleMaps

class MapModel : NSObject {
    
    var trail:Trail
    
    override init() {
        self.trail = TrailParser().parseTrail()
    }
    
    func addPlacemarksToMap(mapView:GMSMapView) -> [GMSMarker] {
        var markers = [GMSMarker]()
        for placemark:Placemark in self.trail.placemarks {
            let marker = GMSMarker()
            marker.userData = placemark;
            marker.position = CLLocationCoordinate2DMake(placemark.point.latitude, placemark.point.longitude)
            marker.title = placemark.name
            marker.snippet = placemark.identifier
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = mapView
            markers.append(marker)
        }
        return markers
    }
    
    func addPathToMap(mapView:GMSMapView) {
        let path = GMSMutablePath()
        for placemark:Placemark in self.trail.placemarks {
            for point:Point in placemark.coordinates {
                path.addLatitude(point.latitude, longitude: point.longitude)
            }
        }

        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor.lightGrayColor()
        polyline.strokeWidth = 5.0
        
        polyline.map = mapView
    }
}