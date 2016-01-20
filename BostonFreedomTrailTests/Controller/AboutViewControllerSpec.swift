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

import Quick
import Nimble

class AboutViewControllerTest: QuickSpec {
    
    override func spec() {
        
        describe("AboutViewController") {
            
            context("Initialization of the AboutViewController") {
                
                var aboutViewController:AboutViewController?
                
                beforeEach({ () -> () in
                    aboutViewController = UIStoryboard.aboutViewController()
                    aboutViewController?.view
                })
                
                it("should have labels set via IBOutlets") {
                    expect(aboutViewController?.developerLabel).toNot(equal(nil))
                    expect(aboutViewController?.developerDetailsLabel).toNot(equal(nil))
                    expect(aboutViewController?.designerLabel).toNot(equal(nil))
                    expect(aboutViewController?.designerDetailsLabel).toNot(equal(nil))
                    expect(aboutViewController?.nounProjectLabel).toNot(equal(nil))
                    expect(aboutViewController?.nounProjectDetailsLabel).toNot(equal(nil))
                    expect(aboutViewController?.googleMapsLabel).toNot(equal(nil))
                }
                
                it("should have text on each of its labels") {
                    expect(aboutViewController?.developerLabel?.text).toNot(equal(""))
                    expect(aboutViewController?.developerDetailsLabel?.text).toNot(equal(""))
                    expect(aboutViewController?.designerLabel?.text).toNot(equal(""))
                    expect(aboutViewController?.designerDetailsLabel?.text).toNot(equal(""))
                    expect(aboutViewController?.nounProjectLabel?.text).toNot(equal(""))
                    expect(aboutViewController?.nounProjectDetailsLabel?.text).toNot(equal(""))
                    expect(aboutViewController?.googleMapsLabel?.text).toNot(equal(""))
                }
            }
        }
    }
}
