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

enum VirtualTourLocationState : Int {
    case BeforeStart = 0
    case InProgress = 1
    case Paused = 2
    case Finished = 3
}

class VirtualTourModel : NSObject {
    var tour:[CLLocation] = []
    var currentTourLocation:Int = 0
    var currentTourState:VirtualTourLocationState = VirtualTourLocationState.BeforeStart
    
    func setupTour() {
        for placemark in Trail.instance.placemarks {
            for location in placemark.coordinates {
                tour.append(location)
            }
        }
    }
    
    func startTour() -> CLLocation {
        self.currentTourLocation = 0
        self.currentTourState = VirtualTourLocationState.InProgress
        return self.tour[self.currentTourLocation]
    }
    
    func enqueueNextLocation() -> CLLocation {
        self.currentTourLocation = self.currentTourLocation + 1
        return self.tour[self.currentTourLocation]
    }
    
    func pauseTour() {
        self.currentTourState = VirtualTourLocationState.Paused
    }
    
    func resumeTour() {
        self.currentTourState = VirtualTourLocationState.InProgress
    }
    
    func tourIsRunning() -> Bool {
        return self.currentTourState != VirtualTourLocationState.Finished && self.currentTourState != VirtualTourLocationState.Paused
    }
    
    func firstPlacemark() -> Placemark {
        return Trail.instance.placemarks[0]
    }

// MARK: Calculating Camera Directions
    
    func locationDirection(from:CLLocation, to:CLLocation) -> CLLocationDirection {
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