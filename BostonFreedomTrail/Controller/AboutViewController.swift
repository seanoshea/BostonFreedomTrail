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

import UIKit

import GoogleMaps

/// View Controller class for the About Screen.
final class AboutViewController: BaseViewController {
  
  // MARK: Properties
  
  /// A title label for developer details
  @IBOutlet weak var developerLabel: AboutTitleLabel?
  /// Information label for the developer details
  @IBOutlet weak var developerDetailsTextView: AboutTextView?
  /// A title label for trail details
  @IBOutlet weak var trailInformationLabel: AboutTitleLabel?
  /// Information label for the trail details
  @IBOutlet weak var trailInformationDetailsTextView: AboutTextView?
  /// A title label for Google Maps details
  @IBOutlet weak var googleMapsLabel: AboutTitleLabel?
  /// Information label for the Google Maps legalese
  @IBOutlet weak var googleMapsDetailsTextView: AboutTextView?
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.localizeLabelsAndTextViews()
  }
  
  // MARK: Analytics
  
  override func getScreenTrackingName() -> String {
    return AnalyticsScreenNames.AboutScreen.rawValue
  }
  
  // MARK: Private Functions
  
  /// Ensures that the labels on this screen are localized and fully filled in.
  func localizeLabelsAndTextViews() {
    // developer info
    self.developerLabel!.text = NSLocalizedString("Developer Details", comment: "")
    let developerAttributedString = NSMutableAttributedString(string:NSLocalizedString("Developed by Sean O'Shea", comment: ""))
    let trailInformationAttributedString = NSMutableAttributedString(string:NSLocalizedString("There are several different websites which have additional information on the Freedom Trail", comment: ""))
    developerAttributedString.linkify(textToFind: "Sean O'Shea", linkURL: "https://twitter.com/seanoshea")
    trailInformationAttributedString.linkify(textToFind: "several", linkURL: "https://www.thefreedomtrail.org/")
    trailInformationAttributedString.linkify(textToFind: "different", linkURL: "https://en.wikipedia.org/wiki/Freedom_Trail/")
    trailInformationAttributedString.linkify(textToFind: "websites", linkURL: "http://www.cityofboston.gov/freedomtrail/")
    self.developerDetailsTextView!.attributedText = developerAttributedString
    
    // trail info
    self.trailInformationLabel!.text = NSLocalizedString("Trail Information", comment: "")
    self.trailInformationDetailsTextView!.attributedText = trailInformationAttributedString

    // google maps info
    self.googleMapsLabel!.text = NSLocalizedString("Google Maps Information", comment: "")
    self.googleMapsDetailsTextView!.text = GMSServices.openSourceLicenseInfo()
  }
}
