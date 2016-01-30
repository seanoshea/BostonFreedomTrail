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

class VirtualTourViewControllerTest: QuickSpec {
    
    override func spec() {
        
        describe("VirtualTourViewController") {
            
            var subject:VirtualTourViewController?
            
            beforeEach({ () -> () in
                subject = UIStoryboard.virtualTourViewController()
                subject?.view
                ApplicationSharedState.sharedInstance.clear()
            })
            
            context("Initialization of the VirtualTourViewController") {
                
                it("should start with a tour location of zero") {
                    expect(subject?.model.currentTourLocation).to(equal(0))
                }
                
                it("should have a panoView set by default") {
                    expect(subject?.panoView).toNot(beNil())
                }
                
                it("should be initialized to having a state of BeforeStart") {
                    expect(subject?.model.currentTourState).to(equal(VirtualTourState.BeforeStart))
                }
            }
            
            context("View Controller Lifecycle") {
                
                it("should automatically start the tour when the view appears") {
                    subject?.viewDidAppear(true)
                    expect(subject?.model.currentTourState).to(equal(VirtualTourState.InProgress))
                }
                
                it("should automatically stop the tour when the view disappears") {
                    subject?.viewDidDisappear(true)
                    expect(subject?.model.currentTourState).to(equal(VirtualTourState.Paused))
                }
            }
            
            context("Repositioning the camera") {
                
                it("should return a camera with the correct bearing zoom and pitch for the next location when repositionCamera is invoked") {
                    
                    subject?.model.setupTour()
                    subject?.model.startTour()
                    let nextStop = (subject?.model.enqueueNextLocation())!
                    
                    let newCamera:GMSPanoramaCamera = (subject?.cameraPositionForNextLocation(nextStop))!
                    
                    expect(newCamera.zoom).to(equal(1.0))
                    expect(newCamera.orientation.heading).to(beCloseTo(118.426040649414))
                    expect(newCamera.orientation.pitch).to(equal(0.0))
                }
            }
            
            context("GMSPanoramaViewDelegate methods") {
                
                beforeEach({
                    subject?.model.setupTour()
                })
                
                it("should pause the tour if it is in progress and the user taps on the pano view") {
                    subject?.model.currentTourState = VirtualTourState.InProgress
                    
                    subject?.panoramaView(subject?.panoView, didTap: CGPointMake(0.0, 0.1))
                    
                    expect(subject?.model.currentTourState).to(equal(VirtualTourState.Paused))
                }
                
                it("should resume the tour if it is paused and the user taps on the pano view") {
                    subject?.model.currentTourState = VirtualTourState.Paused
                    
                    subject?.panoramaView(subject?.panoView, didTap: CGPointMake(0.0, 0.1))
                    
                    expect(subject?.model.currentTourState).to(equal(VirtualTourState.InProgress))
                }
            }
        }
    }
}
