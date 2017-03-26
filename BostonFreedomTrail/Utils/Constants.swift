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

/// Identifiers for segues in the app
enum SegueConstants: String {
  case MapToPlacemarkSegueIdentifier
}

/// Identifiers for loading files from the resources bundle
enum ResourceConstants: String {
  case PlacemarkIdentifier = "placemark"
  case PlacemarkResourceImage = "orange_red"
  case InfoWindowXibName = "InfoWindow"
}

/// Tags for the three tabs in the app
enum TabBarControllerTags: Int {
  case mapViewTag = 0
  case virtualTourViewTag = 1
  case aboutViewTag = 2
}

/// Zoom constants for the camera
enum CameraZoomConstraints: Float {
  case minimum = 12.0
  case maximum = 20.0
}

/// Constants for displaying the snackbar at the top of the app
enum SnackbarMessageViewOffsets: CGFloat {
  case topOffset = 52.0
}

/// Constants when running the snapshot tests
enum SnapshotConstants: Float {
  case cameraZoom = 16.0
  case defaultLatitude = 42.358969550484964
  case defaultLongitude = -71.06010876595974
}

/// Extension on `UIColor` for colors specific to the app
extension UIColor {
  
  /// Text color for the app
  static func bftDarkTextColor() -> UIColor {
    return UIColor.init(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
  }
  
  /// Orange/Red color used throughout the app
  static func bftOrangeRedColor() -> UIColor {
    return UIColor.init(red: 216/255, green: 67/255, blue: 21/255, alpha: 1.0)
  }
}
