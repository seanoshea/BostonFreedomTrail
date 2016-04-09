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
import TSMessages

class VirtualTourViewController : BaseViewController {
    
    var model:VirtualTourModel = VirtualTourModel()
    var panoView:GMSPanoramaView?
    @IBOutlet weak var playPauseButton: VirtualTourPlayPauseButton?

// MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.model.delegate = self
        let firstPlacemark = self.model.firstPlacemark()
        self.addPanoramaView(CLLocationCoordinate2DMake(firstPlacemark.location.coordinate.latitude, firstPlacemark.location.coordinate.longitude))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.model.setupTour()
        if self.isOnline() && !self.model.tourIsRunning() {
            // TODO: Should give the user the opportunity to restart the tour
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.model.pauseTour()
    }
    
    @IBAction func pressedOnPlayPauseButton(sender: UIButton) {
        self.model.togglePlayPause()
        switch (self.model.currentTourState) {
        case VirtualTourState.PostSetup:
            self.startTour()
            break
        case VirtualTourState.InProgress:
            self.postDispatchAction(self.model.nextLocation())
            break
        default:
            break
        }
        self.playPauseButton?.paused = !self.model.tourIsRunning()
    }
    
// MARK: Private Functions
    
    func addPanoramaView(panoramaNear:CLLocationCoordinate2D) {
        let panoView = GMSPanoramaView.panoramaWithFrame(self.view.frame, nearCoordinate:panoramaNear)
        panoView.navigationLinksHidden = true
        panoView.delegate = self
        self.view.addSubview(panoView)
        panoView.addSubview(self.playPauseButton!)
        self.panoView = panoView
    }
    
    func startTour() {
        let firstTourLocation = self.model.startTour()
        self.panoView?.moveNearCoordinate(CLLocationCoordinate2DMake(firstTourLocation.coordinate.latitude, firstTourLocation.coordinate.longitude))
    }
    
    func cameraPositionForNextLocation(nextLocation:CLLocation) -> GMSPanoramaCamera {
        var pitch = 0.0
        var heading:CLLocationDirection?
        if self.model.atLookAtLocation() {
            let lookAt:LookAt = self.model.lookAtForCurrentLocation()!
            pitch = lookAt.tilt
            heading = lookAt.heading
        } else {
            heading = self.model.locationDirectionForNextLocation(nextLocation)
        }
        return GMSPanoramaCamera.init(heading:heading!, pitch:pitch, zoom:1)
    }
    
    func shouldEnqueueNextLocationForPanorama(panorama:GMSPanorama?) -> Bool {
        return self.model.tourIsRunning()
    }
    
    func postDispatchAction(nextLocation:CLLocation) {
        if self.model.tourIsRunning() {
            self.repositionPanoViewForNextLocation(nextLocation)
            self.panoView?.moveNearCoordinate(CLLocationCoordinate2DMake(nextLocation.coordinate.latitude, nextLocation.coordinate.longitude))
        } else {
            // back up
            self.model.reverseLocation()
        }
    }
    
    func repositionPanoViewForNextLocation(nextLocation:CLLocation) {
        if self.model.hasAdvancedPastFirstLocation() {
            let newCamera = self.cameraPositionForNextLocation(nextLocation)
            self.panoView?.animateToCamera(newCamera, animationDuration: VirtualTourStopStopDuration.CameraRepositionAnimation.rawValue)
            if self.model.atLookAtLocation() {
                let pm = self.model.placemarkForCurrentLookAt()
                TSMessage.showNotificationWithTitle(pm.name, type: TSMessageNotificationType.Message)
            }
        }
    }
    
    func advanceToNextLocation(delayTime:dispatch_time_t) {
        unowned let unownedSelf: VirtualTourViewController = self
        dispatch_after(self.model.delayTime(), dispatch_get_main_queue()) {
            unownedSelf.postDispatchAction(unownedSelf.model.nextLocation())
        }
    }
}

extension VirtualTourViewController : GMSPanoramaViewDelegate {
    
    func panoramaView(view: GMSPanoramaView, didMoveToPanorama panorama: GMSPanorama?) {
        if self.shouldEnqueueNextLocationForPanorama(panorama) {
            self.advanceToNextLocation(self.model.delayTime())
        }
    }
    
    func panoramaView(panoramaView: GMSPanoramaView, didMoveCamera camera: GMSPanoramaCamera) {
        panoramaView.logLocation()
        camera.logLocation()
    }
}

extension VirtualTourViewController : VirtualTourModelDelegate {
    
    func navigateToCurrentPosition(model: VirtualTourModel) {
        self.postDispatchAction(self.model.nextLocation())
    }
}

extension GMSPanoramaView {
    func logLocation() {
        if let pano = self.panorama {
            pano.coordinate.logCoordinate()
        }
    }
}

extension GMSPanoramaCamera {
    func logLocation() {
        NSLog("Heading: %.10f, Pitch: %.10f", self.orientation.heading, self.orientation.pitch)
    }
}