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
4. Neither th e name of Upwards Northwards Software Limited nor the
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

enum VirtualTourStopDelays : Double {
    case DefaultDelay = 1.0
    case DelayForCamera = 2.0
    case DelayForPlacemark = 5.0
}

class VirtualTourViewController : UIViewController, GMSPanoramaViewDelegate {
    
    var model:VirtualTourModel = VirtualTourModel()
    var panoView:GMSPanoramaView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let firstPlacemark = self.model.trail.placemarks[0]
        let panoramaNear = CLLocationCoordinate2DMake(firstPlacemark.location.coordinate.latitude, firstPlacemark.location.coordinate.longitude)
        let panoView = GMSPanoramaView.panoramaWithFrame(CGRectZero, nearCoordinate:panoramaNear)
        self.panoView = panoView
        self.panoView?.delegate = self
        self.view = panoView
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.model.setupTour()
        self.startTour()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.model.pauseTour()
    }
    
    func startTour() {
        let firstTourLocation = self.model.startTour()
        self.panoView?.moveNearCoordinate(CLLocationCoordinate2DMake(firstTourLocation.coordinate.latitude, firstTourLocation.coordinate.longitude))
    }
    
// MARK: GMSPanoramaViewDelegate
    
    func panoramaView(view: GMSPanoramaView!, didMoveToPanorama panorama: GMSPanorama!) {
        if panorama.panoramaID != nil && self.model.tourIsRunning() {
            let nextTourStop = self.model.enqueueNextTourStop()
            var delay = VirtualTourStopDelays.DefaultDelay.rawValue
            if self.model.currentTourLocation > 0 {
                delay = VirtualTourStopDelays.DelayForCamera.rawValue
                self.repositionCamera(nextTourStop)
            }
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            unowned let unownedSelf: VirtualTourViewController = self
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                if unownedSelf.model.tourIsRunning() {
                    unownedSelf.panoView?.moveNearCoordinate(CLLocationCoordinate2DMake(nextTourStop.coordinate.latitude, nextTourStop.coordinate.longitude))
                } else {
                    // back up
                    unownedSelf.model.currentTourLocation = unownedSelf.model.currentTourLocation - 1
                }
            }
        }
    }
    
    func repositionCamera(nextTourStop:CLLocation) {
        let currentCameraPosition = (self.panoView?.camera)!
        let from = self.model.tour[self.model.currentTourLocation - 1]
        let to = CLLocation.init(latitude: nextTourStop.coordinate.latitude, longitude: nextTourStop.coordinate.longitude)
        let heading = self.model.locationDirection(from, to:to)
        let newCamera = GMSPanoramaCamera.init(heading: heading, pitch: currentCameraPosition.orientation.pitch, zoom: currentCameraPosition.zoom)
        self.panoView?.animateToCamera(newCamera, animationDuration: 0.75)
    }
}