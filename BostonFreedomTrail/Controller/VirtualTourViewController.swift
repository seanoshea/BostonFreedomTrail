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

class VirtualTourViewController : UIViewController {
    
    var model:MapModel = MapModel()
    var panoView:GMSPanoramaView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let firstPlacemark = self.model.trail.placemarks[0]
        let panoramaNear = CLLocationCoordinate2DMake(firstPlacemark.location.coordinate.latitude, firstPlacemark.location.coordinate.longitude)
        let panoView = GMSPanoramaView.panoramaWithFrame(CGRectZero,
            nearCoordinate:panoramaNear)
        self.panoView = panoView
        self.view = panoView
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let delay = 1
        var positionOffset:Int = 0
        
        for (placemarkIndex, placemark) in self.model.trail.placemarks.enumerate() {
            for (index, location) in placemark.coordinates.enumerate() {
                let offset = (index + placemarkIndex) * delay
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(offset + positionOffset) * Double(NSEC_PER_SEC)))
                if index == placemark.coordinates.count - 1 {
                    positionOffset = positionOffset + Int(offset) - 1
                }
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.panoView?.moveNearCoordinate(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude))
                }
            }
        }
    }
}