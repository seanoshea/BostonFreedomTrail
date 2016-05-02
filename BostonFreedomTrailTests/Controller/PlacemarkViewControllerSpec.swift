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

class PlacemarkViewControllerTest: QuickSpec {
    
    override func spec() {
        
        describe("PlacemarkViewController") {
            
            var subject:PlacemarkViewController?
            
            beforeEach({ () -> () in
                subject = UIStoryboard.placemarkViewController()
                subject?.view
                ApplicationSharedState.sharedInstance.clear()
            })
            
            context("Analytics") {
                
                it("should have a unique screen name to track analytics") {
                    expect(subject?.getScreenTrackingName()).to(equal(AnalyticsScreenNames.PlacemarkScreen.rawValue))
                }
            }
            
            context("Online and Offline") {
                
                it("should not allow the user to navigate to the street view if the user if offline") {
                    subject?.reachabilityStatusChanged(false)
                    
                    expect(subject?.streetViewButton?.enabled).to(beFalse())
                }
                
                it("should allow the user to navigate to the street view when the user comes back online") {
                    subject?.reachabilityStatusChanged(true)
                    
                    expect(subject?.streetViewButton?.enabled).to(beTrue())
                }
            }
            
            context("Initialization of the PlacemarkViewController") {
                
                it("should have a model set by default") {
                    expect(subject?.model).toNot(beNil())
                }
                
                it("should have view properties set after it loads") {
                    expect(subject?.streetViewButton).toNot(beNil())
                }
                
                context("LookAt associated with the model") {
                    
                    it("should show the street view button") {
                        let placemark = Trail.instance.placemarks[1]
                        subject?.model?.placemark = placemark
                        
                        subject?.viewDidLoad()
                        
                        expect(subject?.streetViewButton?.hidden).to(beFalse())
                    }
                }
                
                context("LookAt not associated with the model") {

                    it("should hide the street view button") {
                        let placemark = Trail.instance.placemarks[0]
                        subject?.model?.placemark = placemark

                        subject?.viewDidLoad()
                        
                        expect(subject?.streetViewButton?.hidden).to(beTrue())
                    }
                }
            }
            
            context("Navigating to the Virtual Tour View Controller") {
                
                context("No placemark associated with the model") {
                    
                    it("should not tell its delegate that the street view button was pressed") {
                        let dummyDelegate = DummyDelegate.init()
                        subject?.delegate = dummyDelegate
                        subject?.streetViewButtonPressed((subject?.streetViewButton)!)
                        expect(dummyDelegate.buttonPressed).to(beFalse())
                    }
                }
                
                context("Placemark associated with the model") {
                    
                    it("should tell its delegate that the street view button was pressed") {
                        let dummyDelegate = DummyDelegate.init()
                        subject?.delegate = dummyDelegate
                        let placemark = Trail.instance.placemarks[1]
                        subject?.model?.placemark = placemark
                        subject?.viewDidLoad()
                        
                        subject?.streetViewButtonPressed((subject?.streetViewButton)!)
                        expect(dummyDelegate.buttonPressed).to(beTrue())
                    }
                }
            }
        }
    }
}

class DummyDelegate : PlacemarkViewControllerDelegate {
    
    var buttonPressed = false
    
    func streetViewButtonPressedForPlacemark(placemark: Placemark) {
        self.buttonPressed = true
    }
}
