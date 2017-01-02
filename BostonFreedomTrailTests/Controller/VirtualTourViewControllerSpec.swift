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
        let _ = subject?.view
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
          expect(subject?.model.currentTourState).to(equal(VirtualTourState.preSetup))
        }
      }
      
      context("View Controller Lifecycle") {
        
        it("should set up the tour when the view appears") {
          subject?.viewDidAppear(true)
          expect(subject?.model.currentTourState).to(equal(VirtualTourState.postSetup))
        }
        
        context("The tour is not finished") {
          
          it("should automatically pause the tour when the view disappears") {
            subject?.viewDidDisappear(true)
            
            expect(subject?.model.currentTourState).to(equal(VirtualTourState.paused))
            expect(subject?.virtualTourButton?.title(for: .normal)).to(equal("▷"))
          }
        }
        
        context("The tour is finished") {
          
          it("should not automatically pause the tour when the view disappears") {
            subject?.model.currentTourState = VirtualTourState.finished
            subject?.viewDidDisappear(true)
            
            expect(subject?.model.currentTourState).to(equal(VirtualTourState.finished))
            expect(subject?.virtualTourButton?.title(for: .normal)).to(equal("↻"))
          }
        }
      }
      
      context("Analytics") {
        
        it("should have a unique screen name to track analytics") {
          expect(subject?.getScreenTrackingName()).to(equal(AnalyticsScreenNames.VirtualTourScreen.rawValue))
        }
      }
      
      context("Play Pause Button") {
        
        beforeEach({ () -> () in
          subject?.viewDidAppear(true)
        })
        
        context("The tour is not finished") {
          
          it("should toggle the tour state when the user presses on the virtual tour button") {
            subject?.pressedOnVirtualTourButton((subject?.virtualTourButton)!)
            expect(subject?.virtualTourButton?.title(for: .normal)).to(equal("||"))
            
            subject?.pressedOnVirtualTourButton((subject?.virtualTourButton)!)
            expect(subject?.virtualTourButton?.title(for: .normal)).to(equal("▷"))
          }
        }
        
        context("The tour is finished") {
          
          it("should restart the tour when the user presses on the virtual tour button") {
            subject?.model.currentTourState = VirtualTourState.finished
            
            subject?.pressedOnVirtualTourButton((subject?.virtualTourButton)!)
            expect(subject?.virtualTourButton?.title(for: .normal)).to(equal("||"))
          }
        }
      }
      
      context("Queuing up the next location") {
        
        context("Tour is running") {
          
          it("should queue up the next location") {
            subject?.model.currentTourState = VirtualTourState.inProgress
            
            expect(subject?.shouldEnqueueNextLocationForPanorama(nil)).to(beTrue())
          }
        }
        
        context("Tour is not running") {
          
          it("should queue up the next location") {
            subject?.model.currentTourState = VirtualTourState.paused
            
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
            subject?.model.currentTourState = VirtualTourState.paused
            
            subject?.postDispatchAction(location)
            
            expect(subject?.model.currentTourLocation).to(equal(13))
          }
        }
      }
      
      context("Repositioning the camera") {
        
        it("should return a camera with the correct bearing zoom and pitch for the next location when repositionCamera is invoked") {
          
          subject?.model.setupTour()
          let _ = subject?.model.startTour()
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

class DummyPanoramaView : GMSPanoramaView {
  
  var wasMoved = false
  
  override func moveNearCoordinate(_ coordinate: CLLocationCoordinate2D) {
    self.wasMoved = true
  }
}
