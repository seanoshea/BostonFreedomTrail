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

protocol PlacemarkViewControllerDelegate:class {
    func streetViewButtonPressedForPlacemark(placemark:Placemark)
}

class PlacemarkViewController : BaseViewController {
    
    @IBOutlet weak var webView: UIWebView?
    @IBOutlet weak var streetViewButton: UIButton?

    var model:PlacemarkModel?
    weak var delegate:PlacemarkViewControllerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.model = PlacemarkModel.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.loadPlacemarkInformation()
    }
    
    override func getScreenTrackingName() -> String {
        return AnalyticsScreenNames.PlacemarkScreen.rawValue
    }
    
    @IBAction func streetViewButtonPressed(sender: UIButton) {
        if let delegate = self.delegate {
            // TODO: Analytics
            delegate.streetViewButtonPressedForPlacemark((self.model?.placemark)!)
        }
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
// MARK: Private Functions
    
    func configureView() {
        // only bother showing the street view button if there is a LookAt associated with this placemark.
        self.streetViewButton?.hidden = self.model?.placemark?.lookAt == nil
    }
    
    func loadPlacemarkInformation() {
        self.webView?.delegate = self
        self.webView?.loadHTMLString((self.model?.stringForWebView())!, baseURL: nil)
    }
}

extension PlacemarkViewController : UIWebViewDelegate {
    
}
