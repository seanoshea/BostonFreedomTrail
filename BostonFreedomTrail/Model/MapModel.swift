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
    
    func addPlacemarksToMap(mapView:GMSMapView) -> [GMSMarker] {
        var markers = [GMSMarker]()
        for placemark:Placemark in Trail.instance.placemarks {
            let marker = GMSMarker()
            marker.userData = placemark;
            marker.position = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude)
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
        for placemark:Placemark in Trail.instance.placemarks {
            for location:CLLocation in placemark.coordinates {
                path.addLatitude(location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
        }
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor.blueColor()
        polyline.strokeWidth = 5.0
        polyline.map = mapView
    }
    
    func zoomForMap() -> Float {
        var zoom = ApplicationSharedState.sharedInstance.cameraZoom
        if zoom <= 0 {
            zoom = PListHelper.defaultCameraZoom()
        }
        return zoom
    }
    
    func lastKnownCoordinate() -> CLLocationCoordinate2D {
        var lastKnownCoordinate = ApplicationSharedState.sharedInstance.lastKnownCoordinate
        if lastKnownCoordinate.latitude == 0.0 && lastKnownCoordinate.longitude == 0.0 {
            lastKnownCoordinate = CLLocationCoordinate2D.init(latitude:PListHelper.defaultLatitude(), longitude:PListHelper.defaultLongitude())
        }
        return lastKnownCoordinate
    }
}