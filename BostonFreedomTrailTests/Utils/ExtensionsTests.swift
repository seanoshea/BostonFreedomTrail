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

import Testing
import CoreLocation
import GoogleMaps
@testable import BostonFreedomTrail

@Suite("Extensions")
struct ExtensionsTests {

  // MARK: - CLLocationCoordinate2D Tests

  @Test("Coordinate logging executes without error")
  func coordinateLoggingExecutes() async {
    let coordinate = CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589)
    
    // Should not crash when called
    coordinate.logCoordinate()
    
    #expect(true) // Test passes if no crash occurs
  }

  // MARK: - Int Extension Tests

  @Test("Placemark index from identifier with valid input")
  func placemarkIndexFromValidIdentifier() async {
    let result = 0.placemarkIndexFromIdentifier("placemark5")
    
    #expect(result == 4) // placemark5 -> 5 - 1 = 4
  }

  @Test("Placemark index from identifier with invalid input")
  func placemarkIndexFromInvalidIdentifier() async {
    let result = 0.placemarkIndexFromIdentifier("invalid")
    
    #expect(result == 0) // Should return 0 for invalid input
  }

  @Test("Placemark index from identifier with empty string")
  func placemarkIndexFromEmptyIdentifier() async {
    let result = 0.placemarkIndexFromIdentifier("")
    
    #expect(result == 0) // Should return 0 for empty string
  }

  @Test("Placemark index from identifier with placemark prefix only")
  func placemarkIndexFromPrefixOnly() async {
    let result = 0.placemarkIndexFromIdentifier("placemark")
    
    #expect(result == 0) // Should return 0 when no number follows
  }

  // MARK: - GMSPanoramaView Extension Tests
  // Note: These tests are disabled because they require Google Maps SDK initialization
  
  // MARK: - GMSPanoramaCamera Extension Tests
  // Note: These tests are disabled because they require Google Maps SDK initialization

  // MARK: - NSMutableAttributedString Extension Tests

  @Test("Linkify adds link attribute to found text")
  func linkifyAddsLinkToFoundText() async {
    let attributedString = NSMutableAttributedString(string: "Visit our website for more info")
    
    attributedString.linkify("website", linkURL: "https://example.com")
    
    _ = NSRange(location: 10, length: 7) // "website" location
    let linkAttribute = attributedString.attribute(.link, at: 10, effectiveRange: nil) as? String
    let fontAttribute = attributedString.attribute(.font, at: 10, effectiveRange: nil) as? UIFont
    
    #expect(linkAttribute == "https://example.com")
    #expect(fontAttribute?.pointSize == 14.0)
  }

  @Test("Linkify handles text not found")
  func linkifyHandlesTextNotFound() async {
    let attributedString = NSMutableAttributedString(string: "This is some text")
    
    attributedString.linkify("missing", linkURL: "https://example.com")
    
    // Should not add any link attributes since text is not found
    let linkAttribute = attributedString.attribute(.link, at: 0, effectiveRange: nil)
    
    #expect(linkAttribute == nil)
  }

  @Test("Linkify handles empty string")
  func linkifyHandlesEmptyString() async {
    let attributedString = NSMutableAttributedString(string: "")
    
    attributedString.linkify("text", linkURL: "https://example.com")
    
    #expect(attributedString.length == 0)
  }

  @Test("Linkify handles multiple occurrences")
  func linkifyHandlesMultipleOccurrences() async {
    let attributedString = NSMutableAttributedString(string: "Click here and here for more")
    
    attributedString.linkify("here", linkURL: "https://example.com")
    
    // Should only linkify the first occurrence
    let firstLinkAttribute = attributedString.attribute(.link, at: 6, effectiveRange: nil) as? String
    
    #expect(firstLinkAttribute == "https://example.com")
  }
}
