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

import Quick
import Nimble

@testable import BostonFreedomTrail

import GoogleMaps

class MapViewControllerTest: QuickSpec {
    
    override func spec() {
        
        describe("MapViewController") {

            var subject:MapViewController?
            
            beforeEach({ () -> () in
                subject = UIStoryboard.mapViewController()
                subject?.view
                ApplicationSharedState.sharedInstance.clear()
            })
            
            context("Analytics") {
                
                it("should have a unique screen name to track analytics") {
                    expect(subject?.getScreenTrackingName()).to(equal(AnalyticsScreenNames.MapScreen.rawValue))
                }
            }
            
            context("Initialization of the MapViewController") {
                
                it("should have a model set by default") {
                    expect(subject?.model).toNot(beNil())
                }
                
                it("should ensure that the view is set to a GMSMapView when it is loaded") {
                    expect(subject?.mapView).toNot(beNil())
                }
                
                it("should set up the map to allow a location button and disallow a compass button") {
                    let mapView:GMSMapView = (subject?.mapView)!
                    expect(mapView.settings.compassButton).to(beFalse())
                    expect(mapView.myLocationEnabled).to(beTrue())
                    expect(mapView.settings.myLocationButton).to(beTrue())
                }
                
                it("should disable the indoor capabilities of the map view") {
                    let mapView:GMSMapView = (subject?.mapView)!
                    expect(mapView.indoorEnabled).to(beFalse())
                }
                
                it("should set the delegate of the map view to be the MapViewController") {
                    let mapView:GMSMapView = (subject?.mapView)!
                    expect(mapView.delegate).toNot(beNil())
                }
            }
            
            context("GMSMapViewDelegate") {
                
                it("should set the zoom level in the application state when the user zooms with the camera") {
                    let zoom:Float = 14
                    let position:GMSCameraPosition = GMSCameraPosition.init(target: CLLocationCoordinate2D.init(latitude: 45, longitude: 45), zoom: zoom, bearing: 14.0, viewingAngle: 1.2)
                    
                    subject?.mapView((subject?.mapView)!, didChangeCameraPosition: position)
                    
                    expect(ApplicationSharedState.sharedInstance.cameraZoom).to(equal(zoom))
                }
                
                it("should set the last known placemark in the application state when the user taps on a marker") {
                    
                    let marker = GMSMarker.init(position: CLLocationCoordinate2D.init(latitude: 45, longitude: 45))
                    marker.userData = Placemark.init(identifier: "placemark identifier", name: "placemark name", location: CLLocation.init(latitude: 10, longitude: 10), coordinates: [CLLocation.init(latitude: 10, longitude: 10)], placemarkDescription: "placemark description", lookAt:nil)
                    
                    subject?.mapView((subject?.mapView)!, didTapMarker: marker)
                    
                    let lastKnownPlacemark = ApplicationSharedState.sharedInstance.lastKnownPlacemarkCoordinate
                    
                    expect(lastKnownPlacemark.latitude).to(equal(45))
                    expect(lastKnownPlacemark.longitude).to(equal(45))
                }
            }
        }
    }
}
