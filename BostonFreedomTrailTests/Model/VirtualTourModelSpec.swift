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
                    
                    expect(subject?.currentTourState).to(equal(VirtualTourState.InProgress))
                    expect(subject?.currentTourLocation).to(equal(0))
                }
                
                it("should pause the tour when pauseTour is invoked") {
                    subject?.pauseTour()
                    expect(subject?.currentTourState).to(equal(VirtualTourState.Paused))
                }
                
                it("should mark the tour as not running if it has finished") {
                    subject?.currentTourState = VirtualTourState.Finished
                    expect(subject?.tourIsRunning()).to(beFalse())
                }
                
                it("should mark the tour as not running if it has been paused") {
                    subject?.currentTourState = VirtualTourState.Paused
                    expect(subject?.tourIsRunning()).to(beFalse())
                }
                
                it("should advance the tour when enqueueNextLocation is invoked") {
                    subject?.currentTourLocation = 1
                    
                    let location:CLLocation = (subject?.enqueueNextLocation())!
                    
                    expect(location).toNot(beNil())
                    expect(subject?.currentTourLocation).to(equal(2))
                }
                
                it("should mark the tour as in progress when the model is asked to resume the tour") {
                    subject?.resumeTour()
                    
                    expect(subject?.currentTourState).to(equal(VirtualTourState.InProgress))
                }
                
                it("should bump the currentTourLocation when advance is invoked") {
                    let before = subject?.currentTourLocation
                    subject?.advanceLocation()
                    expect(subject?.currentTourLocation).to(equal(before! + 1))
                }
                
                it("should decrement the currentTourLocation when reverseLocation is invoked") {
                    subject?.advanceLocation()
                    subject?.advanceLocation()
                    let before = subject?.currentTourLocation
                    subject?.reverseLocation()
                    expect(subject?.currentTourLocation).to(equal(before! - 1))
                }
                
                it("should understand when the tour has already been initialized") {
                    subject?.currentTourState = VirtualTourState.PreSetup
                    expect(subject?.tourNotInitialized()).to(beTrue())
                    subject?.currentTourState = VirtualTourState.PostSetup
                    subject?.lookAts = [Int:Int]()
                    expect(subject?.tourNotInitialized()).to(beTrue())
                    subject?.setupTour()
                    expect(subject?.tourNotInitialized()).to(beFalse())
                }
                
                it("should be able to toggle the tour state") {
                    subject?.currentTourState = VirtualTourState.Paused
                    subject?.togglePlayPause()
                    expect(subject?.currentTourState).to(equal(VirtualTourState.InProgress))
                    subject?.togglePlayPause()
                    expect(subject?.currentTourState).to(equal(VirtualTourState.Paused))
                }
            }
            
            context("LookAts") {
                
                var dummyDelegate:DummyVirtualTourModelDelegate?
                
                beforeEach({ () -> () in
                    dummyDelegate = DummyVirtualTourModelDelegate.init()
                    subject?.delegate = dummyDelegate
                })
                
                it("should not return a look at for an invalid tour location") {
                    subject?.currentTourLocation = 0
                    expect(subject?.lookAtForCurrentLocation()).to(beNil())
                }
                
                it("should return a LookAt for a valid tour location") {
                    subject?.currentTourLocation = 15
                    expect(subject?.lookAtForCurrentLocation()).toNot(beNil())
                }

                it("should not be able to find a LookAt for the 1st placemark") {
                    expect(subject?.lookAtPositionInTourForPlacementIndex(0)).to(beNil())
                }
                
                it("should not be able to find a LookAt if a placemark is requested which is out of bounds on the lower end") {
                    expect(subject?.lookAtPositionInTourForPlacementIndex(-1)).to(beNil())
                }
                
                it("should not be able to find a LookAt if a placemark is requested which is out of bounds on the upper end") {
                    expect(subject?.lookAtPositionInTourForPlacementIndex(51)).to(beNil())
                }
                
                it("should be able to find a LookAt for the 4th placemark") {
                    expect(subject?.lookAtPositionInTourForPlacementIndex(3)).to(equal(25))
                }
                
                it("should be able to navigate directly to a LookAt when the placement index has a LookAt associated with it") {
                    subject?.navigateToLookAt(3)
                    
                    expect(subject?.currentTourState).to(equal(VirtualTourState.Paused))
                    expect(dummyDelegate!.navigationInitiated).to(beTrue())
                }
                
                it("should not navigate directly to a LookAt when the placement index does not have a LookAt associated with it") {
                    subject?.navigateToLookAt(0)
                    
                    expect(subject?.currentTourState).to(equal(VirtualTourState.PostSetup))
                    expect(dummyDelegate!.navigationInitiated).to(beFalse())
                }
            }
            
            context("Understanding the next location to go to") {
                
                it("should use the next location in the queue if the current location does not represent a LookAt") {
                    subject?.currentTourLocation = 14
                    let location:CLLocation = (subject?.nextLocation())!
                    
                    expect(location.coordinate.latitude).to(equal(42.357560999999997))
                    expect(location.coordinate.longitude).to(equal(-71.063400999999999))
                }
                
                it("should use the LookAt location if the current location represents a LookAt") {
                    subject?.currentTourLocation = 15
                    let location:CLLocation = (subject?.nextLocation())!
                    let lookAtIndex = subject?.lookAts[15]!
                    let lookAt = Trail.instance.placemarks[lookAtIndex!].lookAt
                    
                    
                    expect(location.coordinate.latitude).to(equal(lookAt?.latitude))
                    expect(location.coordinate.longitude).to(equal(lookAt?.longitude))
                }
            }
            
            context("Calculating the delayTime for a location") {
                
                it("should wait longer at a LookAt location than it does at a regular location") {
                    subject?.currentTourLocation = 15
                    let firstDelay = (subject?.delayTime())!
                    subject?.currentTourLocation = 16
                    let secondDelay = (subject?.delayTime())!
                    expect(firstDelay) > secondDelay
                }
            }
            
            context("Calculating the camera position for locations in the trail") {
                
                it("should be able to calculate the correct direction of the camera to naviagte between two points") {
                    subject?.advanceLocation()
                    let to:CLLocation = CLLocation.init(latitude: 42.355357, longitude: -71.063666)
                    
                    let direction:CLLocationDirection = (subject?.locationDirectionForNextLocation(to))!
                    
                    expect(direction).to(beCloseTo(118.426051240986))
                }
            }
        }
    }
}


class DummyVirtualTourModelDelegate : VirtualTourModelDelegate {
    
    var navigationInitiated = false
    
    func navigateToCurrentPosition(model:VirtualTourModel) {
        self.navigationInitiated = true
    }
}