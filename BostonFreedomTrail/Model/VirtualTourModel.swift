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

import CoreLocation

enum VirtualTourState : Int {
    case BeforeStart = 0
    case InProgress = 1
    case Paused = 2
    case Finished = 3
}

enum VirtualTourStopStopDuration : Double {
    case CameraRepositionAnimation = 0.5
    case DefaultDelay = 1.0
    case DelayForCameraRepositioning = 2.0
    case DelayForLookAt = 5.0
}

class VirtualTourModel : NSObject {
    var tour:[CLLocation] = []
    var lookAts = [Int:Int]()
    var placemarkDemarkations = [Int:Int]()
    var currentTourLocation:Int = 0
    var currentTourState:VirtualTourState = VirtualTourState.BeforeStart
    
    func setupTour() {
        var index = 0
        for (placemarkIndex, placemark) in Trail.instance.placemarks.enumerate() {
            for (locationIndex, location) in placemark.coordinates.enumerate() {
                if locationIndex == placemark.coordinates.count - 1 {
                    if placemark.lookAt != nil {
                        self.lookAts[index] = placemarkIndex
                    }
                }
                index = index + 1
                tour.append(location)
            }
            self.placemarkDemarkations[index] = placemarkIndex
        }
    }
    
    func startTour() -> CLLocation {
        self.currentTourLocation = 0
        self.currentTourState = VirtualTourState.InProgress
        return self.tour[self.currentTourLocation]
    }
    
    func atLookAtLocation() -> Bool {
        return self.currentTourLocation > 0 && self.lookAts[self.currentTourLocation] != nil
    }
    
    func lookAtForCurrentLocation() -> LookAt? {
        guard self.currentTourLocation > 0 else { return nil}
        let placemarkIndex = self.lookAts[self.currentTourLocation]
        let placemark = Trail.instance.placemarks[placemarkIndex!]
        return placemark.lookAt
    }
    
    func placemarkForCurrentLookAt() -> Placemark {
        let index = self.placemarkDemarkations[self.currentTourLocation + 1]
        return Trail.instance.placemarks[index!]
    }
    
    func enqueueNextLocation() -> CLLocation {
        self.currentTourLocation = self.currentTourLocation + 1
        return self.tour[self.currentTourLocation]
    }
    
    func pauseTour() {
        self.currentTourState = VirtualTourState.Paused
    }
    
    func resumeTour() {
        self.currentTourState = VirtualTourState.InProgress
    }
    
    func hasAdvancedPastFirstLocation() -> Bool {
        return self.currentTourLocation > 0
    }
    
    func tourIsRunning() -> Bool {
        return self.currentTourState == VirtualTourState.InProgress
    }
    
    func firstPlacemark() -> Placemark {
        return Trail.instance.placemarks[0]
    }
    
    func advanceLocation() {
        self.currentTourLocation = self.currentTourLocation + 1
    }
    
    func reverseLocation() {
        self.currentTourLocation = self.currentTourLocation - 1
    }
    
    func nextLocation() -> CLLocation {
        var nextLocation:CLLocation
        if self.atLookAtLocation() {
            let lookAt = self.lookAtForCurrentLocation()!
            nextLocation = CLLocation.init(latitude:lookAt.latitude, longitude:lookAt.longitude)
            self.advanceLocation()
        } else {
            nextLocation = self.enqueueNextLocation()
        }
        return nextLocation
    }
    
    func delayTime() -> dispatch_time_t {
        var delay = self.hasAdvancedPastFirstLocation() ? VirtualTourStopStopDuration.DelayForCameraRepositioning.rawValue : VirtualTourStopStopDuration.DefaultDelay.rawValue
        if self.atLookAtLocation() {
            delay = VirtualTourStopStopDuration.DelayForLookAt.rawValue
        }
        return dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    }
    
    func navigateToLookAt(placemarkIndex:Int) {
        let lookAtPosition = self.lookAtPositionInTourForPlacementIndex(placemarkIndex)
        if let position = lookAtPosition {
            self.currentTourLocation = position
        }
        self.pauseTour()
    }
    
    func lookAtPositionInTourForPlacementIndex(placemarkIndex:Int) -> Int? {
        var foundKey:Int?
        for (key, value) in self.lookAts {
            if value == placemarkIndex {
                foundKey = key
                break
            }
        }
        if let positionInTour = foundKey {
            return positionInTour
        } else {
            return nil
        }
    }

// MARK: Calculating Camera Directions
    
    func locationDirectionForNextLocation(nextLocation:CLLocation) -> CLLocationDirection {
        let from = self.tour[self.currentTourLocation - 1]
        let to = CLLocation.init(latitude:nextLocation.coordinate.latitude, longitude:nextLocation.coordinate.longitude)
        let fromLatitude = self.degreesToRadians(from.coordinate.latitude)
        let fromLongitude = self.degreesToRadians(from.coordinate.longitude)
        let toLatitude = self.degreesToRadians(to.coordinate.latitude)
        let toLongitude = self.degreesToRadians(to.coordinate.longitude)
        let degree = radiansToDegrees(atan2(sin(toLongitude - fromLongitude) * cos(toLatitude), cos(fromLatitude) * sin(toLatitude)-sin(fromLatitude) * cos(toLatitude) * cos(toLongitude - fromLongitude)))
        return degree >= 0.0 ? degree : 360.0 + degree
    }
    
    func degreesToRadians(value:CLLocationDegrees) -> CLLocationDegrees {
        return value * M_PI / 180.0
    }
    
    func radiansToDegrees(value:Double) -> Double {
        return (value * 180.0 / M_PI)
    }
}