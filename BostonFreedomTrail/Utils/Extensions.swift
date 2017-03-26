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
import GoogleMaps

/// Extension for logging the coordinate of the `CLLocationCoordinate2D`
extension CLLocationCoordinate2D {
  /// Debug logs the current lat and long
  func logCoordinate() {
    guard !ApplicationSharedState.sharedInstance.isDebug() else { return }
    debugPrint(longitude, latitude)
  }
}

extension Int {
  func placemarkIndexFromIdentifier(_ placemarkIdentifier: String) -> Int {
    let stringRepresentation = placemarkIdentifier.replacingOccurrences(of: "placemark", with:"")
    guard let integerRepresentation = Int(stringRepresentation) else { return 0 }
    return integerRepresentation - 1
  }
}

/// Extension for logging the coordinate of the `GMSPanoramaView`
extension GMSPanoramaView {
  /// Logs the current coordinate of the `GMSPanoramaView`
  final func logLocation() {
    guard let pano = panorama else { return }
    pano.coordinate.logCoordinate()
  }
}

/// Extension for logging the coordinate of the `GMSPanoramaCamera`
extension GMSPanoramaCamera {
  /// Logs the current coordinate of the `GMSPanoramaCamera`
  final func logLocation() {
    guard !ApplicationSharedState.sharedInstance.isDebug() else { return }
    debugPrint(orientation.heading, orientation.pitch, separator: ",", terminator: "")
  }
}

/// Extension for creating links in the middle of `NSMutableAttributedString`
extension NSMutableAttributedString {
  /**
   Allows parts of the text in the `NSMutableAttributedString` to be made into web links.
   
   - parameter textToFind: the text to make into a link
   - parameter linkURL: where to send the user should they press on the link
   */
  public func linkify(_ textToFind:String, linkURL:String) {
    let foundRange = mutableString.range(of: textToFind)
    if foundRange.location != NSNotFound {
      addAttribute(NSLinkAttributeName, value: linkURL, range: foundRange)
      addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 14.0), range: foundRange)
    }
  }
}
