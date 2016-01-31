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

enum VirtualTourStopStopDuration : Double {
    case CameraRepositionAnimation = 0.5
    case DefaultDelay = 1.0
    case DelayForCameraRepositioning = 2.0
    case DelayForLookAt = 5.0
}

class VirtualTourViewController : UIViewController {
    
    var model:VirtualTourModel = VirtualTourModel()
    var panoView:GMSPanoramaView?

// MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let firstPlacemark = self.model.firstPlacemark()
        let panoramaNear = CLLocationCoordinate2DMake(firstPlacemark.location.coordinate.latitude, firstPlacemark.location.coordinate.longitude)
        let panoView = GMSPanoramaView.panoramaWithFrame(CGRectZero, nearCoordinate:panoramaNear)
        panoView.navigationLinksHidden = true
        panoView.delegate = self
        self.panoView = panoView
        self.view = panoView
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.startTour()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.model.pauseTour()
    }
    
// MARK: Private Functions
    
    func startTour() {
        self.model.setupTour()
        let firstTourLocation = self.model.startTour()
        self.panoView?.moveNearCoordinate(CLLocationCoordinate2DMake(firstTourLocation.coordinate.latitude, firstTourLocation.coordinate.longitude))
    }
    
    func cameraPositionForNextLocation(nextLocation:CLLocation) -> GMSPanoramaCamera {
        let from = self.model.tour[self.model.currentTourLocation - 1]
        let to = CLLocation.init(latitude: nextLocation.coordinate.latitude, longitude: nextLocation.coordinate.longitude)
        let heading = self.model.locationDirection(from, to:to)
        return GMSPanoramaCamera.init(heading:heading, pitch:0, zoom:1)
    }
    
    func delayTime() -> dispatch_time_t {
        var delay = self.model.currentTourLocation > 0 ? VirtualTourStopStopDuration.DelayForCameraRepositioning.rawValue : VirtualTourStopStopDuration.DefaultDelay.rawValue
        if (self.model.atLookAtLocation()) {
            let lookAt = self.model.lookAtForCurrentLocation()
            if lookAt != nil {
                delay = delay * 5
            }
        }
        return dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    }
    
    func shouldEnqueueNextLocationForPanorama(panorama:GMSPanorama) -> Bool {
        return panorama.panoramaID != nil && self.model.tourIsRunning()
    }
    
    func postDispatchAction(nextLocation:CLLocation) {
        if self.model.tourIsRunning() {
            self.repositionPanoViewForNextLocation(nextLocation)
            self.panoView?.moveNearCoordinate(CLLocationCoordinate2DMake(nextLocation.coordinate.latitude, nextLocation.coordinate.longitude))
        } else {
            // back up
            self.model.currentTourLocation = self.model.currentTourLocation - 1
        }
    }
    
    func repositionPanoViewForNextLocation(nextLocation:CLLocation) {
        if self.model.currentTourLocation > 0 {
            let newCamera = self.cameraPositionForNextLocation(nextLocation)
            self.panoView?.animateToCamera(newCamera, animationDuration: VirtualTourStopStopDuration.CameraRepositionAnimation.rawValue)
        }
    }
    
    func advanceToNextLocation(delayTime:dispatch_time_t) {
        unowned let unownedSelf: VirtualTourViewController = self
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            let nextLocation = unownedSelf.model.enqueueNextLocation()
            unownedSelf.postDispatchAction(nextLocation)
        }
    }
}

extension VirtualTourViewController : GMSPanoramaViewDelegate {
    
    func panoramaView(view: GMSPanoramaView!, didMoveToPanorama panorama: GMSPanorama!) {
        if self.shouldEnqueueNextLocationForPanorama(panorama) {
            self.advanceToNextLocation(self.delayTime())
        }
    }
    
    func panoramaView(panoramaView: GMSPanoramaView!, didMoveCamera camera: GMSPanoramaCamera!) {
        if let unwrapped = panoramaView.panorama {
            if self.model.atLookAtLocation() {
                let s = NSString(format: "Coordinate %.6f %.6f Zoom %.2f Pitch %.6f Heading %.6f", unwrapped.coordinate.latitude, unwrapped.coordinate.longitude, camera.zoom, camera.orientation.pitch, camera.orientation.heading)
                NSLog(s as String)
            }
        }
    }
    
    func panoramaView(panoramaView: GMSPanoramaView!, didTap point: CGPoint) {
        if self.model.tourIsRunning() {
            self.model.pauseTour()
        } else {
            self.model.resumeTour()
            self.advanceToNextLocation(1)
        }
    }
}