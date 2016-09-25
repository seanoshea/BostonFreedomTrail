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
import ReachabilitySwift

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
                
                it("should be initialized to having a state of PreSetup") {
                    expect(subject?.model.currentTourState).to(equal(VirtualTourState.PreSetup))
                }
            }
            
            context("View Controller Lifecycle") {
                
                it("should set up the tour when the view appears") {
                    subject?.viewDidAppear(true)
                    expect(subject?.model.currentTourState).to(equal(VirtualTourState.PostSetup))
                }
                
                it("should automatically pause the tour when the view disappears") {
                    subject?.viewDidDisappear(true)
                    expect(subject?.model.currentTourState).to(equal(VirtualTourState.Paused))
                    expect(subject?.playPauseButton?.paused).to(beTrue())
                }
            }
            
            context("Analytics") {
                
                it("should have a unique screen name to track analytics") {
                    expect(subject?.getScreenTrackingName()).to(equal(AnalyticsScreenNames.VirtualTourScreen.rawValue))
                }
            }
            
            context("Play Pause Button") {
                
                it("should toggle the tour state when the user presses on the play pause button") {
                    subject?.viewDidAppear(true)
                    
                    subject?.pressedOnPlayPauseButton((subject?.playPauseButton)!)
                    expect(subject?.playPauseButton?.paused).to(beFalse())
                    
                    subject?.pressedOnPlayPauseButton((subject?.playPauseButton)!)
                    expect(subject?.playPauseButton?.paused).to(beTrue())
                }
            }
            
            context("Online and Offline") {
                
                it("should pause the tour if the user goes offline") {
                    subject?.reachabilityStatusChanged(false)
                    
                    expect(subject?.model.currentTourState).to(equal(VirtualTourState.Paused))
                    expect(subject?.playPauseButton?.enabled).to(beFalse())
                }
                
                it("should allow the user to restart the tour if the user comes back online") {
                    subject?.reachabilityStatusChanged(true)
                    
                    expect(subject?.playPauseButton?.enabled).to(beTrue())
                }
            }
            
            context("Queuing up the next location") {
                
                context("Tour is running") {
                    
                    it("should queue up the next location") {
                        subject?.model.currentTourState = VirtualTourState.InProgress
                        
                        expect(subject?.shouldEnqueueNextLocationForPanorama(nil)).to(beTrue())
                    }
                }
                
                context("Tour is not running") {

                    it("should queue up the next location") {
                        subject?.model.currentTourState = VirtualTourState.Paused
                        
                        expect(subject?.shouldEnqueueNextLocationForPanorama(nil)).to(beFalse())
                    }
                }
            }
            
            context("After deciding to move onto the next location") {
                
                let location = CLLocation.init(latitude: 123, longitude: 312)
                
                beforeEach({ () -> () in
                    subject?.viewDidAppear(true)
                    subject?.startTour()
                    subject?.model.currentTourLocation = 14
                })
                
                context("the user has decided to pause the tour") {
                    
                    it("should back up the tour one location") {
                        subject?.model.currentTourState = VirtualTourState.Paused
                        
                        subject?.postDispatchAction(location)
                        
                        expect(subject?.model.currentTourLocation).to(equal(13))
                    }
                }
                
                context("the user has decided to allow the tour to continue") {

                    var dummyReachability:DummyReachability?
                    var dummyPanoView:DummyPanoramaView?
                    
                    beforeEach({ () -> () in
                        do {
                            dummyReachability = try DummyReachability.init(hostname:"https://google.com")
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            appDelegate.reachability = dummyReachability
                            GMSServices.provideAPIKey(PListHelper.googleMapsApiKey())
                            dummyPanoView = DummyPanoramaView.init(frame: CGRectMake(0, 0, 100, 100))
                            subject?.panoView = dummyPanoView
                        } catch {
                            NSLog("Failed to start the reachability notifier")
                        }
                    })
                    
                    context("the user is offline") {
                        
                        it("should automatically pause the tour") {
                            
                            dummyReachability?.dummyIsReachable = false
                            subject?.postDispatchAction(location)
                            
                            expect(subject?.playPauseButton?.paused).to(beTrue())
                            expect(subject?.model.currentTourState).to(equal(VirtualTourState.Paused))
                            expect(dummyPanoView?.wasMoved).to(beFalse())
                        }
                    }
                    
                    context("the user is online") {
                        
                        it("should reposition the panorama view to focus on the new location") {
                            
                            dummyReachability?.dummyIsReachable = true
                            subject?.postDispatchAction(location)
                            
                            expect(subject?.model.currentTourState).to(equal(VirtualTourState.InProgress))
                            expect(dummyPanoView?.wasMoved).to(beTrue())
                        }
                    }
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
        }
    }
}

class DummyReachability : Reachability {
    
    var dummyIsReachable = false
    
    override func isReachable() -> Bool {
        return self.dummyIsReachable
    }
}

class DummyPanoramaView : GMSPanoramaView {
    
    var wasMoved = false
    
    override func moveNearCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.wasMoved = true
    }
}
