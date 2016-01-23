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

import GoogleMaps
@testable import BostonFreedomTrail

class ApplicationSharedStateTest: QuickSpec {
    
    override func spec() {
        
        describe("ApplicationSharedState") {
            
            context("the camera zoom") {
                
                it("should know the current camera zoom") {
                    
                    NSUserDefaults.standardUserDefaults().setFloat(12.0, forKey: "ApplicationSharedStateCameraZoom")
                    
                    expect(ApplicationSharedState.sharedState.cameraZoom).to(equal(12.0))
                }
                
                it("should be able to set the current camera zoom") {
                    
                    ApplicationSharedState.sharedState.cameraZoom = 8.0
                    
                    expect(NSUserDefaults.standardUserDefaults().floatForKey("ApplicationSharedStateCameraZoom")).to(equal(8.0))
                }
                
                it("should not allow a camera zoom level that is too small") {

                    ApplicationSharedState.sharedState.cameraZoom = 12.0
                    
                    ApplicationSharedState.sharedState.cameraZoom = 1.0
                    
                    expect(NSUserDefaults.standardUserDefaults().floatForKey("ApplicationSharedStateCameraZoom")).to(equal(12.0))
                }
            }
            
            context("the last placemark pressed") {
                
                let latitude:Double = -71.063303
                let longitude:Double = 42.35769
                
                it("should be able to retrieve the lat and long of a recently pressed placemark") {
                    
                    NSUserDefaults.standardUserDefaults().setFloat(12.0, forKey: "ApplicationSharedStateLastKnownPlacemarkCoordinateLatitude")
                    NSUserDefaults.standardUserDefaults().setFloat(11.0, forKey: "ApplicationSharedStateLastKnownPlacemarkCoordinateLongitude")
                    
                    let coordinate = ApplicationSharedState.sharedState.lastKnownPlacemarkCoordinate
                    
                    expect(coordinate.latitude).to(equal(12.0))
                    expect(coordinate.longitude).to(equal(11.0))
                }
                
                it("should be able to store the lat and long of a recently pressed placemark") {
                    
                    ApplicationSharedState.sharedState.lastKnownPlacemarkCoordinate = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
                    expect(NSUserDefaults.standardUserDefaults().floatForKey("ApplicationSharedStateLastKnownPlacemarkCoordinateLatitude")).to(equal(-71.063303))
                    expect(NSUserDefaults.standardUserDefaults().floatForKey("ApplicationSharedStateLastKnownPlacemarkCoordinateLongitude")).to(equal(42.35769))
                }
            }
        }
    }
}
