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

import UIKit

import GoogleMaps

/**
 * View controller for the About screen displaying app information and credits.
 * 
 * AboutViewController presents information about the app developer, Freedom Trail
 * resources, and Google Maps licensing. It handles localization and creates
 * interactive links to external resources.
 * 
 * ## Features
 * - Developer information with GitHub link
 * - Freedom Trail resource links
 * - Google Maps open source license information
 * - Fully localized content
 * - Interactive attributed text with clickable links
 * 
 * ## Screen Content
 * - Developer details section
 * - Trail information with external links
 * - Google Maps legal information
 * 
 * - Author: Upwards Northwards Software Limited
 * - Since: 1.0
 */
final class AboutViewController: BaseViewController {

  // MARK: Properties

  /// Title label for the developer information section
  @IBOutlet weak var developerLabel: AboutTitleLabel?

  /// Text view containing developer details with interactive GitHub link
  @IBOutlet weak var developerDetailsTextView: AboutTextView?

  /// Title label for the Freedom Trail information section
  @IBOutlet weak var trailInformationLabel: AboutTitleLabel?

  /// Text view with Freedom Trail resources and external website links
  @IBOutlet weak var trailInformationDetailsTextView: AboutTextView?

  /// Title label for the Google Maps information section
  @IBOutlet weak var googleMapsLabel: AboutTitleLabel?

  /// Text view displaying Google Maps open source license information
  @IBOutlet weak var googleMapsDetailsTextView: AboutTextView?

  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    localizeLabelsAndTextViews()
  }

  // MARK: Analytics

  override func getScreenTrackingName() -> String {
    AnalyticsScreenNames.aboutScreen.rawValue
  }

  // MARK: Private Functions

  /**
   * Configures all labels and text views with localized content and interactive links.
   * 
   * This method sets up the About screen content including section titles,
   * developer information with GitHub link, Freedom Trail resource links,
   * and Google Maps licensing information.
   * 
   * ## Content Setup
   * - Localizes all section titles
   * - Creates attributed strings with clickable links
   * - Links developer name to GitHub profile
   * - Links trail resources to official websites
   * - Displays Google Maps open source licenses
   * 
   * ## External Links
   * - Developer: https://github.com/seanoshea
   * - Official Trail: https://www.thefreedomtrail.org/
   * - Wikipedia: https://en.wikipedia.org/wiki/Freedom_Trail/
   * - City of Boston: http://www.cityofboston.gov/freedomtrail/
   */
  func localizeLabelsAndTextViews() {
    // developer info
    developerLabel!.text = NSLocalizedString("Developer Details", comment: "")
    let developerAttributedString = NSMutableAttributedString(string: NSLocalizedString("Developed by Sean O'Shea", comment: ""))
    let trailInformationAttributedString = NSMutableAttributedString(string: NSLocalizedString("There are several different websites which have additional information on the Freedom Trail", comment: ""))
    developerAttributedString.linkify("Sean O'Shea", linkURL: "https://github.com/seanoshea")
    trailInformationAttributedString.linkify("several", linkURL: "https://www.thefreedomtrail.org/")
    trailInformationAttributedString.linkify("different", linkURL: "https://en.wikipedia.org/wiki/Freedom_Trail/")
    trailInformationAttributedString.linkify("websites", linkURL: "http://www.cityofboston.gov/freedomtrail/")
    developerDetailsTextView!.attributedText = developerAttributedString

    // trail info
    trailInformationLabel!.text = NSLocalizedString("Trail Information", comment: "")
    trailInformationDetailsTextView!.attributedText = trailInformationAttributedString

    // google maps info
    googleMapsLabel!.text = NSLocalizedString("Google Maps Information", comment: "")
    googleMapsDetailsTextView!.attributedText = NSAttributedString(string: GMSServices.openSourceLicenseInfo())
  }
}
