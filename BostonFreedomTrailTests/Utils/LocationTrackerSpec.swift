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

import CoreLocation

@testable import BostonFreedomTrail

class LocationTrackerTest: QuickSpec {
  
  override func spec() {
    
    describe("LocationTracker") {
      
      context("Initialization") {
        
        it("should always have a manager property set") {
          expect(LocationTracker.sharedInstance.locationManager).toNot(beNil())
        }
        
        it("should set the delegate of the LocationTracker manager to itself") {
          let delegate = LocationTracker.sharedInstance.locationManager.delegate
          expect(delegate).toNot(beNil())
        }
      }
      
      context("CLLocationManagerDelegate methods") {
        
        beforeEach({ () -> () in
          ApplicationSharedState.sharedInstance.clear()
        })
        
        it("should update the shared application state when the user moves to a new location") {
          
          let latitude:Double = -71.063303
          let longitude:Double = 42.35769
          
          LocationTracker.sharedInstance.locationManager(LocationTracker.sharedInstance.locationManager, didUpdateLocations: [CLLocation.init(latitude: latitude, longitude: longitude)])
          
          expect(LocationTracker.sharedInstance.currentLocation).toNot(beNil())
          expect(UserDefaults.standard.float(forKey: "ApplicationSharedStateLastKnownLocationLatitude")).to(equal(-71.063303))
          expect(UserDefaults.standard.float(forKey: "ApplicationSharedStateLastKnownLocationLongitude")).to(equal(42.35769))
        }
      }
    }
  }
}
