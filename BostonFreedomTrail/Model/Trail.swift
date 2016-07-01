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

final class Placemark {
    var identifier: String = ""
    var name: String = ""
    var location: CLLocation = CLLocation()
    var coordinates = [CLLocation]()
    var placemarkDescription: String = ""
    var lookAt: LookAt?

    init(identifier: String, name: String, location: CLLocation, coordinates: [CLLocation], placemarkDescription: String, lookAt: LookAt?) {
        self.identifier = identifier
        self.name = name
        self.location = location
        self.coordinates = coordinates
        self.placemarkDescription = placemarkDescription
        self.lookAt = lookAt
    }
}

struct LookAt {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var tilt: Double = 0.0
    var heading: Double = 0.0

    init(latitude: Double, longitude: Double, tilt: Double, heading: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.tilt = tilt
        self.heading = heading
    }
}

struct Trail {
    static let instance = TrailParser().parseTrail()
    var placemarks = [Placemark]()

    func placemarkIndex(placemark: Placemark) -> Int {
        var placemarkIndex = 0
        for (index, pm) in self.placemarks.enumerate() {
            if pm.identifier.caseInsensitiveCompare(placemark.identifier) == NSComparisonResult.OrderedSame {
                placemarkIndex = index
                break
            }
        }
        return placemarkIndex
    }
}
