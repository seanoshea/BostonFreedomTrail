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

enum VirtualTourLocationState : Int {
    case BeforeStart = 0
    case InProgress = 1
    case Paused = 2
    case Finished = 3
}

class VirtualTourViewController : UIViewController, GMSPanoramaViewDelegate {
    
    var model:MapModel = MapModel()
    var tour:[CLLocation] = []
    var currentTourLocation:Int = 0
    var currentTourState:VirtualTourLocationState = VirtualTourLocationState.BeforeStart
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
        self.setupTour()
        self.startTour()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.pauseTour()
    }
    
    func setupTour() {
        for placemark in self.model.trail.placemarks {
            for location in placemark.coordinates {
                tour.append(location)
            }
        }
    }
    
    func startTour() {
        self.currentTourLocation = 0
        let firstTourLocation = self.tour[self.currentTourLocation]
        self.currentTourState = VirtualTourLocationState.InProgress
        self.panoView?.moveNearCoordinate(CLLocationCoordinate2DMake(firstTourLocation.coordinate.latitude, firstTourLocation.coordinate.longitude))
    }
    
    func pauseTour() {
        
    }
    
    func enqueueNextTourStop() -> CLLocation {
        self.currentTourLocation = self.currentTourLocation + 1
        return self.tour[self.currentTourLocation]
    }
    
// MARK: GMSPanoramaViewDelegate
    
    func panoramaView(view: GMSPanoramaView!, didMoveToPanorama panorama: GMSPanorama!) {
        if panorama.panoramaID != nil {
            if currentTourLocation < self.tour.count - 1 {
                let nextTourStop = self.enqueueNextTourStop()
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.panoView?.moveNearCoordinate(CLLocationCoordinate2DMake(nextTourStop.coordinate.latitude, nextTourStop.coordinate.longitude))
                }
            }
        }
    }
}