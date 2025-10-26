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
 4. Neither th e name of Upwards Northwards Software Limited nor the
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
 * Custom information window displayed when users tap map markers.
 * 
 * InfoWindow provides a styled popup view that appears above map markers
 * when users tap on Freedom Trail location pins. It displays the location
 * name in a custom-styled label.
 * 
 * ## Features
 * - Custom UIView loaded from XIB file
 * - Styled header label for location names
 * - Integrated with Google Maps marker system
 * - Consistent visual design with app theme
 * 
 * ## Usage
 * This view is automatically loaded and configured by MapViewController
 * when implementing the GMSMapViewDelegate markerInfoWindow method:
 * ```swift
 * func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
 *   let infoWindow = // load from XIB
 *   infoWindow.header?.text = placemark.name
 *   return infoWindow
 * }
 * ```
 * 
 * - Author: Upwards Northwards Software Limited
 * - Since: 1.0
 */
class InfoWindow: UIView {
  /// Header label displaying the Freedom Trail location name
  @IBOutlet weak var header: AboutTitleLabel?
}
