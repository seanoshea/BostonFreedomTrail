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
import UIKit

/**
 * Identifiers for storyboard segues used throughout the app.
 * 
 * This enum provides type-safe access to segue identifiers, preventing
 * runtime errors from typos in segue names.
 */
enum SegueConstants: String {
  /// Segue from map view to placemark detail view
  case mapToPlacemarkSegueIdentifier
}

/**
 * Identifiers for loading files and resources from the app bundle.
 * 
 * This enum provides type-safe access to resource names, preventing
 * runtime errors from incorrect resource references.
 */
enum ResourceConstants: String {
  /// HTML template file for placemark detail view content
  case placemarkIdentifier = "placemark"
  /// Image asset name for map placemark markers
  case placemarkResourceImage = "orange_red"
  /// XIB file name for custom map marker info windows
  case infoWindowXibName = "InfoWindow"
}

/**
 * Tag identifiers for the main tab bar controller tabs.
 * 
 * These integer tags are used to identify and programmatically
 * access specific tabs in the main navigation interface.
 */
enum TabBarControllerTags: Int {
  /// Map view tab showing the Freedom Trail route
  case mapViewTag = 0
  /// Virtual tour tab for street view exploration
  case virtualTourViewTag = 1
  /// About tab with app information and credits
  case aboutViewTag = 2
}

/**
 * Camera zoom level constraints for the map view.
 * 
 * These values define the acceptable range of zoom levels to ensure
 * optimal user experience and performance on the map.
 */
enum CameraZoomConstraints: Float {
  /// Minimum zoom level (city-wide view of Boston)
  case minimum = 12.0
  /// Maximum zoom level (detailed street-level view)
  case maximum = 20.0
}

/**
 * Layout constants for snackbar message positioning.
 * 
 * These values ensure proper positioning of user notification messages
 * relative to the app's navigation and status bar elements.
 */
enum SnackbarMessageViewOffsets: CGFloat {
  /// Vertical offset from top of screen for snackbar messages
  case topOffset = 94.0
}

/**
 * Extension providing Boston Freedom Trail specific color constants.
 * 
 * This extension adds branded colors to UIColor for consistent theming
 * throughout the application interface.
 */
extension UIColor {

  /**
   * Primary dark text color for the app interface.
   * 
   * - Returns: Dark gray color (RGB: 33, 33, 33) for readable text
   */
  static func bftDarkTextColor() -> UIColor {
    UIColor(red: 33 / 255, green: 33 / 255, blue: 33 / 255, alpha: 1.0)
  }

  /**
   * Signature orange-red brand color used throughout the app.
   * 
   * This color represents the Freedom Trail's iconic red brick path
   * and is used for markers, paths, and accent elements.
   * 
   * - Returns: Orange-red color (RGB: 216, 67, 21) matching the trail theme
   */
  static func bftOrangeRedColor() -> UIColor {
    UIColor(red: 216 / 255, green: 67 / 255, blue: 21 / 255, alpha: 1.0)
  }
}
