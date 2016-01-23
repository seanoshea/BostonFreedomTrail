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

import UIKit
import GoogleMaps

class MapViewController : UIViewController, GMSMapViewDelegate {
    
    var model:MapModel = MapModel()
    var mapView:GMSMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createMapView()
        setupPlacemarks()
        zoomToMostRecentPosition()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if SegueConstants.MapToPlacemarkSegueIdentifier.rawValue.caseInsensitiveCompare(identifier) == NSComparisonResult.OrderedSame {
                let placemarkViewController = segue.destinationViewController as! PlacemarkViewController
                let placemark = self.mapView?.selectedMarker.userData as! Placemark
                placemarkViewController.model = PlacemarkModel.init(placemark: placemark)
            }
        }
    }
    
    func createMapView() {
        let camera = GMSCameraPosition.cameraWithLatitude(PListHelper.defaultLatitude(), longitude:PListHelper.defaultLongitude(), zoom:PListHelper.defaultCameraZoom())
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        let mapInsets = UIEdgeInsetsMake(0.0, 5.0, 48.0, 0.0)
        mapView.padding = mapInsets;
        mapView.indoorEnabled = false
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = false
        mapView.delegate = self
        self.mapView = mapView
        self.view = self.mapView
    }
    
    func setupPlacemarks() {
        self.model.addPlacemarksToMap(self.mapView!)
        self.model.addPathToMap(self.mapView!)
    }
    
    func zoomToMostRecentPosition() {
        
    }
    
// MARK: GMSMapViewDelegate
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        if position.zoom > 0.0 {
            ApplicationSharedState.sharedState.cameraZoom = position.zoom
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        ApplicationSharedState.sharedState.lastKnownPlacemarkCoordinate = marker.position
        // TODO: Analytics
        return false
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        ApplicationSharedState.sharedState.lastKnownPlacemarkCoordinate = marker.position
        // TODO: Analytics
        self.performSegueWithIdentifier(SegueConstants.MapToPlacemarkSegueIdentifier.rawValue, sender: self)
    }
}
