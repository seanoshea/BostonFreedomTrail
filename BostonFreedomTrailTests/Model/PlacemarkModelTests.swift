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
import GoogleMaps

@Suite("PlacemarkModel")
@MainActor
struct PlacemarkModelTests {

  // MARK: - Initialization Tests

  @Test("Initializes with nil placemark")
  func initializesWithNilPlacemark() async {
    let subject = PlacemarkModel()

    #expect(subject.placemark == nil)
  }

  // MARK: - Placemark Property Tests

  @Test("Sets and retrieves placemark")
  func setsAndRetrievesPlacemark() async {
    let subject = PlacemarkModel()
    let location = CLLocation(latitude: 42.3601, longitude: -71.0589)
    let placemark = Placemark(
      identifier: "test-id",
      name: "Test Placemark",
      location: location,
      coordinates: [location],
      placemarkDescription: "Test description",
      lookAt: nil
    )

    subject.placemark = placemark

    #expect(subject.placemark?.identifier == "test-id")
    #expect(subject.placemark?.name == "Test Placemark")
    #expect(subject.placemark?.placemarkDescription == "Test description")
  }

  // MARK: - stringForWebView Tests

  @Test("Returns empty string when placemark is nil")
  func returnsEmptyStringWhenPlacemarkIsNil() async {
    let subject = PlacemarkModel()

    let result = subject.stringForWebView()

    #expect(result.isEmpty)
  }

  @Test("Returns HTML template when placemark description is empty")
  func returnsHTMLTemplateWhenDescriptionIsEmpty() async {
    let subject = PlacemarkModel()
    let location = CLLocation(latitude: 42.3601, longitude: -71.0589)
    let placemark = Placemark(
      identifier: "test-id",
      name: "Test Placemark",
      location: location,
      coordinates: [location],
      placemarkDescription: "",
      lookAt: nil
    )
    subject.placemark = placemark

    let result = subject.stringForWebView()

    // Should still return HTML template even with empty description
    #expect(!result.isEmpty)
    #expect(result.contains("<!doctype html>") || result.contains("<!DOCTYPE html>"))
  }

  @Test("Uses placemark description when creating web view")
  func usesPlacemarkDescriptionInWebView() async {
    let subject = PlacemarkModel()
    let location = CLLocation(latitude: 42.3601, longitude: -71.0589)
    let testDescription = "This is a test description for the placemark"
    subject.placemark = Placemark(
      identifier: "placemark identifier",
      name: "placemark name",
      location: location,
      coordinates: [location],
      placemarkDescription: testDescription,
      lookAt: nil
    )

    let webViewString = subject.stringForWebView()

    // Should contain the description
    #expect(webViewString.contains(testDescription))
    // Should contain HTML content (not empty)
    #expect(!webViewString.isEmpty)
  }
}
