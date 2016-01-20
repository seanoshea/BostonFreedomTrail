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

class AboutViewController : UIViewController {
  
    @IBOutlet weak var developerLabel: AboutTitleLabel?
    @IBOutlet weak var developerDetailsLabel: AboutDetailsLabel?
    @IBOutlet weak var designerLabel: AboutTitleLabel?
    @IBOutlet weak var designerDetailsLabel: AboutDetailsLabel?
    @IBOutlet weak var nounProjectLabel: AboutTitleLabel?
    @IBOutlet weak var nounProjectDetailsLabel: AboutDetailsLabel?
    @IBOutlet weak var googleMapsLabel: AboutTitleLabel?
    @IBOutlet weak var googleMapsDetailsLabel: AboutDetailsLabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.localizeLabels()
    }
    
    func localizeLabels() {
        self.developerLabel!.text = NSLocalizedString("Developer Details", comment: "")
        self.developerDetailsLabel!.text = NSLocalizedString("Developed by Sean O'Shea", comment: "")
        self.designerLabel!.text = NSLocalizedString("Designer Details", comment: "")
        self.designerDetailsLabel!.text = NSLocalizedString("TBD", comment: "")
        self.nounProjectLabel!.text = NSLocalizedString("Noun Project", comment: "")
        self.nounProjectDetailsLabel!.text = NSLocalizedString("Some of the icons in this application are freely downloadable from The Noun Project. Information Icon by Creatorid'immagine & Map Icon by Stefan Zoll", comment: "")
        self.googleMapsLabel!.text = NSLocalizedString("Google Maps Information", comment: "")
        self.googleMapsDetailsLabel!.text = GMSServices.openSourceLicenseInfo()
    }
}
