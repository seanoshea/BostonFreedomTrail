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
import CoreLocation
import GoogleMaps

/**
 * Extension for CLLocationCoordinate2D providing debug logging functionality.
 * 
 * This extension adds coordinate logging capabilities for debugging map interactions
 * and location tracking throughout the app.
 */
extension CLLocationCoordinate2D {
  /**
   * Logs the current latitude and longitude coordinates for debugging.
   * 
   * This method only logs in non-debug builds to avoid cluttering development logs.
   * Useful for tracking user interactions with map locations.
   */
  func logCoordinate() {
    guard !ApplicationSharedState.sharedInstance.isDebug() else { return }
    debugPrint(longitude, latitude)
  }
}

/**
 * Extension for Int providing placemark identifier parsing functionality.
 */
extension Int {
  /**
   * Converts a placemark identifier string to a zero-based array index.
   * 
   * This method parses placemark identifiers (e.g., "placemark1", "placemark2")
   * and converts them to array indices for accessing the placemarks collection.
   * 
   * - Parameter placemarkIdentifier: String identifier in format "placemarkN"
   * - Returns: Zero-based index for array access (N-1), or 0 if parsing fails
   * 
   * ## Example
   * ```swift
   * let index = 0.placemarkIndexFromIdentifier("placemark3") // Returns 2
   * ```
   */
  func placemarkIndexFromIdentifier(_ placemarkIdentifier: String) -> Int {
    let stringRepresentation = placemarkIdentifier.replacingOccurrences(of: "placemark", with: "")
    guard let integerRepresentation = Int(stringRepresentation) else { return 0 }
    return integerRepresentation - 1
  }
}

/**
 * Extension for GMSPanoramaView providing location logging functionality.
 */
extension GMSPanoramaView {
  /**
   * Logs the current panorama location coordinates for debugging.
   * 
   * This method extracts the coordinate from the current panorama and logs it
   * using the CLLocationCoordinate2D extension method.
   */
  final func logLocation() {
    guard let pano = panorama else { return }
    pano.coordinate.logCoordinate()
  }
}

/**
 * Extension for GMSPanoramaCamera providing camera orientation logging.
 */
extension GMSPanoramaCamera {
  /**
   * Logs the current camera orientation (heading and pitch) for debugging.
   * 
   * This method logs camera orientation data to help debug street view
   * positioning and user interactions with panorama views.
   */
  final func logLocation() {
    guard !ApplicationSharedState.sharedInstance.isDebug() else { return }
    debugPrint(orientation.heading, orientation.pitch, separator: ",", terminator: "")
  }
}

/**
 * Extension for NSMutableAttributedString providing link creation functionality.
 * 
 * This extension enables easy creation of clickable links within attributed text,
 * commonly used in the About screen for external resource links.
 */
extension NSMutableAttributedString {
  /**
   * Converts specified text within the attributed string into a clickable web link.
   * 
   * This method searches for the specified text and applies link attributes,
   * making it clickable and styled appropriately for web navigation.
   * 
   * - Parameter textToFind: The text to convert into a clickable link
   * - Parameter linkURL: The URL to navigate to when the link is tapped
   * 
   * ## Usage
   * ```swift
   * let attributedText = NSMutableAttributedString(string: "Visit our website")
   * attributedText.linkify("website", linkURL: "https://example.com")
   * ```
   * 
   * ## Styling
   * - Applies NSAttributedString.Key.link attribute for functionality
   * - Sets system font at 14pt for consistent appearance
   */
  public func linkify(_ textToFind: String, linkURL: String) {
    let foundRange = mutableString.range(of: textToFind)
    if foundRange.location != NSNotFound {
      addAttribute(NSAttributedString.Key.link, value: linkURL, range: foundRange)
      addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14.0), range: foundRange)
    }
  }
}
