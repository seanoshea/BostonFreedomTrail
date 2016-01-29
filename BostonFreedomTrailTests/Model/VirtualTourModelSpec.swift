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

import Quick
import Nimble

@testable import BostonFreedomTrail

import GoogleMaps

class VirtualTourModelTest: QuickSpec {
    
    override func spec() {
        
        describe("VirtualTourModel") {
            
            var subject:VirtualTourModel?
            
            beforeEach({ () -> () in
                subject = VirtualTourModel.init()
                subject?.setupTour()
                ApplicationSharedState.sharedInstance.clear()
            })
            
            context("Tour Controls") {
                
                it("should start the tour when startTour is invoked") {
                    subject?.startTour()
                    
                    expect(subject?.currentTourState).to(equal(VirtualTourLocationState.InProgress))
                    expect(subject?.currentTourLocation).to(equal(0))
                }
                
                it("should pause the tour when pauseTour is invoked") {
                    subject?.pauseTour()
                    expect(subject?.currentTourState).to(equal(VirtualTourLocationState.Paused))
                }
                
                it("should mark the tour as not running if it has finished") {
                    subject?.currentTourState = VirtualTourLocationState.Finished
                    expect(subject?.tourIsRunning()).to(beFalse())
                }
                
                it("should mark the tour as not running if it has been paused") {
                    subject?.currentTourState = VirtualTourLocationState.Paused
                    expect(subject?.tourIsRunning()).to(beFalse())
                }
                
                it("should advance the tour when enqueueNextTourStop is invoked") {
                    subject?.currentTourLocation = 1
                    
                    let location:CLLocation = (subject?.enqueueNextTourStop())!
                    
                    expect(location).toNot(beNil())
                    expect(subject?.currentTourLocation).to(equal(2))
                }
            }
            
            context("Calculating the camera position for locations in the trail") {
                
                it("should be able to calculate the correct direction of the camera to naviagte between two points") {
                    let from:CLLocation = CLLocation.init(latitude: 42.355393, longitude: -71.063756)
                    let to:CLLocation = CLLocation.init(latitude: 42.355357, longitude: -71.063666)
                    
                    let direction:CLLocationDirection = (subject?.locationDirection(from, to: to))!
                    
                    expect(direction).to(beCloseTo(118.426051240986))
                }
            }
        }
    }
}
