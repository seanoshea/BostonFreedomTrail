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
 derived from this software without speciMapViewControllerSpec.swiftfic prior written permission.
 
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

import UIKit
import WebKit

/// Delegate for the `PlacemarkViewController`
@MainActor
protocol PlacemarkViewControllerDelegate: AnyObject {
  /**
   Executed when the user indicates that they want to go to the virtual tour.
   
   - parameter placemark: The `Placemark` to land on after switching to the virtual tour.
   */
  func streetViewButtonPressedForPlacemark(_ placemark: Placemark)
}

/// Responsible for showing additional information on a placemark to the user.
final class PlacemarkViewController: BaseViewController {

  // MARK: Properties

  /// Used to display information on the specific placemark associated with the `PlacemarkViewController`
  @IBOutlet weak var webView: WKWebView?
  /// Button to allow users navigate to the virtual tour.
  @IBOutlet weak var streetViewButton: UIButton?

  /// Contains and business logic and state for the `PlacemarkViewController`
  var model: PlacemarkModel?
  /// Delegate for the `PlacemarkViewController`
  weak var delegate: PlacemarkViewControllerDelegate?

  // MARK: Lifecycle

  override func awakeFromNib() {
    super.awakeFromNib()
    MainActor.assumeIsolated {
      model = PlacemarkModel()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
    loadPlacemarkInformation()
    title = model?.placemark?.name
  }

  // MARK: IBActions

  /**
   Executed when the street view button is pressed.
   
   - parameter sender: a reference to the `streetViewButton`
   */
  @IBAction func streetViewButtonPressed(_ sender: UIButton) {
    guard let delegate = delegate else {
      trackNonFatalErrorMessage("Street View Button Pressed, but no delegate available")
      return
    }

    guard let model = model else {
      trackNonFatalErrorMessage("Street View Button Pressed, but no model available")
      return
    }

    guard let placemark = model.placemark else {
      trackNonFatalErrorMessage("Street View Button Pressed, but no placemark associated with model")
      return
    }

    // Validate that the placemark has the necessary data for street view
    guard placemark.lookAt != nil else {
      trackNonFatalErrorMessage("Street View Button Pressed, but placemark has no LookAt data")
      displaySnackbarMessage(NSLocalizedString("Street view not available for this location", comment: ""))
      return
    }

    trackButtonPressForPlacemark(placemark, label: AnalyticsLabels.streetViewPress.rawValue)
    delegate.streetViewButtonPressedForPlacemark(placemark)
    dismiss(animated: true, completion: nil)
  }

  // MARK: Analytics

  override func getScreenTrackingName() -> String {
    AnalyticsScreenNames.placemarkScreen.rawValue
  }

  // MARK: Private Functions

  /// Configures the view specific to the placemark associated with the `PlacemarkViewController`
  func configureView() {
    guard let model = model else {
      trackNonFatalErrorMessage("Cannot configure view - model not available")
      streetViewButton?.isHidden = true
      return
    }

    guard let placemark = model.placemark else {
      trackNonFatalErrorMessage("Cannot configure view - placemark not available")
      streetViewButton?.isHidden = true
      return
    }

    // Only show the street view button if there is LookAt data for this placemark
    let hasLookAtData = placemark.lookAt != nil
    streetViewButton?.isHidden = !hasLookAtData

    if !hasLookAtData {
      print("Street view button hidden - no LookAt data for placemark: \(placemark.name)")
    }
  }

  /// Sets up the web view and loads the HTML content for the placemark.
  func loadPlacemarkInformation() {
    guard let webView = webView else {
      trackNonFatalErrorMessage("WebView not available for loading placemark information")
      return
    }

    guard let model = model else {
      trackNonFatalErrorMessage("Model not available for loading placemark information")
      return
    }

    let htmlString = model.stringForWebView()
    guard !htmlString.isEmpty else {
      trackNonFatalErrorMessage("Empty HTML string for placemark information")
      webView.loadHTMLString("<p>No information available for this location.</p>", baseURL: nil)
      return
    }

    webView.loadHTMLString(htmlString, baseURL: nil)
  }
}
