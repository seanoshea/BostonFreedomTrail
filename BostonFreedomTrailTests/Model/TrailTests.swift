/*
 Copyright (c) 2014 - present Upwards Northwards Software Limited
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
import Testing
@testable import BostonFreedomTrail

@Suite("Trail")
struct TrailTests {

  @Test("Serves up index based on placemark")
  func servesUpIndexBasedOnPlacemark() async {
    let index = 2
    let placemark = Trail.instance.placemarks[index]

    #expect(Trail.instance.placemarkIndex(placemark) == index)
  }

  @Test("Placemark index for first placemark")
  func placemarkIndexForFirstPlacemark() async {
    guard !Trail.instance.placemarks.isEmpty else { return }
    let firstPlacemark = Trail.instance.placemarks[0]
    #expect(Trail.instance.placemarkIndex(firstPlacemark) == 0)
  }

  @Test("Placemark index for last placemark")
  func placemarkIndexForLastPlacemark() async {
    guard !Trail.instance.placemarks.isEmpty else { return }
    let lastIndex = Trail.instance.placemarks.count - 1
    let lastPlacemark = Trail.instance.placemarks[lastIndex]
    #expect(Trail.instance.placemarkIndex(lastPlacemark) == lastIndex)
  }

  @Test("Placemark index case insensitive matching")
  func placemarkIndexCaseInsensitiveMatching() async {
    guard !Trail.instance.placemarks.isEmpty else { return }
    let placemark = Trail.instance.placemarks[0]
    let originalIdentifier = placemark.identifier

    // Create a placemark with uppercase identifier
    let uppercasePlacemark = Placemark(
      identifier: originalIdentifier.uppercased(),
      name: placemark.name,
      location: placemark.location,
      coordinates: placemark.coordinates,
      placemarkDescription: placemark.placemarkDescription,
      lookAt: placemark.lookAt
    )

    #expect(Trail.instance.placemarkIndex(uppercasePlacemark) == 0)
  }

  @Test("Trail instance is not empty")
  func trailInstanceIsNotEmpty() async {
    #expect(!Trail.instance.placemarks.isEmpty)
    #expect(!Trail.instance.placemarks.isEmpty)
  }

  @Test("All placemarks have required properties")
  func allPlacemarksHaveRequiredProperties() async {
    for placemark in Trail.instance.placemarks {
      #expect(!placemark.identifier.isEmpty)
      #expect(!placemark.name.isEmpty)
      #expect(placemark.location.coordinate.latitude != 0.0 || placemark.location.coordinate.longitude != 0.0)
    }
  }

  @Test("Placemark identifiers are unique")
  func placemarkIdentifiersAreUnique() async {
    let identifiers = Trail.instance.placemarks.map { $0.identifier }
    let uniqueIdentifiers = Set(identifiers)
    #expect(identifiers.count == uniqueIdentifiers.count)
  }

  @Test("Figures out correct placemark index from identifier")
  func figuresOutPlacemarkIndexFromIdentifier() async {
    let i = 16
    #expect(i.placemarkIndexFromIdentifier("placemark9") == 8)
  }

  @Test("Placemark index from identifier - boundary cases")
  func placemarkIndexFromIdentifierBoundaryCases() async {
    let i = 0

    // Test first placemark
    #expect(i.placemarkIndexFromIdentifier("placemark1") == 0)

    // Test double digit
    #expect(i.placemarkIndexFromIdentifier("placemark10") == 9)
    #expect(i.placemarkIndexFromIdentifier("placemark99") == 98)
  }

  @Test("Fails gracefully with poorly formed placemark identifier")
  func failsGracefullyWithPoorlyFormedIdentifier() async {
    let i = 16
    #expect(i.placemarkIndexFromIdentifier("placeak9") == 0)
  }

  @Test("Placemark index from identifier - edge cases")
  func placemarkIndexFromIdentifierEdgeCases() async {
    let i = 0

    // Empty string
    #expect(i.placemarkIndexFromIdentifier("") == 0)

    // No number
    #expect(i.placemarkIndexFromIdentifier("placemark") == 0)

    // Invalid number
    #expect(i.placemarkIndexFromIdentifier("placemarkABC") == 0)

    // Negative number (should still parse but return negative index)
    #expect(i.placemarkIndexFromIdentifier("placemark-1") == -2)

    // Zero
    #expect(i.placemarkIndexFromIdentifier("placemark0") == -1)
  }

  @Test("Placemark coordinates are valid")
  func placemarkCoordinatesAreValid() async {
    for placemark in Trail.instance.placemarks {
      // Check main location
      let lat = placemark.location.coordinate.latitude
      let lng = placemark.location.coordinate.longitude

      #expect(lat >= -90.0 && lat <= 90.0)
      #expect(lng >= -180.0 && lng <= 180.0)

      // Check path coordinates
      for coordinate in placemark.coordinates {
        let pathLat = coordinate.coordinate.latitude
        let pathLng = coordinate.coordinate.longitude

        #expect(pathLat >= -90.0 && pathLat <= 90.0)
        #expect(pathLng >= -180.0 && pathLng <= 180.0)
      }
    }
  }

  @Test("LookAt data validation")
  func lookAtDataValidation() async {
    for placemark in Trail.instance.placemarks {
      if let lookAt = placemark.lookAt {
        #expect(lookAt.latitude >= -90.0 && lookAt.latitude <= 90.0)
        #expect(lookAt.longitude >= -180.0 && lookAt.longitude <= 180.0)
        // Note: heading and tilt can have various values in KML data
        // including negative tilt values and heading values outside 0-360 range
        // The underlying APIs handle these appropriately
      }
    }
  }
}
