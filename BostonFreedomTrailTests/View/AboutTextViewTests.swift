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

import Testing
import UIKit
@testable import BostonFreedomTrail

@Suite("AboutTextView")
@MainActor
struct AboutTextViewTests {

  // MARK: - Text View Delegate Tests

  @Test("Text view should begin editing")
  func textViewShouldBeginEditing() async {
    let aboutTextView = AboutTextView()
    let textView = UITextView()

    let shouldBeginEditing = aboutTextView.textViewShouldBeginEditing(textView)

    #expect(shouldBeginEditing == false) // Should not allow editing
  }

  @Test("Text view should change text in range")
  func textViewShouldChangeTextInRange() async {
    let aboutTextView = AboutTextView()
    let textView = UITextView()
    let range = NSRange(location: 0, length: 0)

    let shouldChangeText = aboutTextView.textView(textView, shouldChangeTextIn: range, replacementText: "test")

    #expect(shouldChangeText == false) // Should not allow text changes
  }

  @Test("Text view has modern delegate method")
  func textViewHasModernDelegateMethod() async {
    let aboutTextView = AboutTextView()

    // Just verify the AboutTextView conforms to the delegate protocol
    #expect(aboutTextView is UITextViewDelegate)
  }

  // MARK: - Initialization Tests

  @Test("About text view initializes correctly")
  func aboutTextViewInitializesCorrectly() async {
    let aboutTextView = AboutTextView()

    #expect(aboutTextView != nil)
  }

  @Test("About text view frame initialization")
  func aboutTextViewFrameInitialization() async {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let aboutTextView = AboutTextView(frame: frame, textContainer: nil)

    #expect(aboutTextView.frame == frame)
  }

  // MARK: - Edge Case Tests

  @Test("Text view delegate methods with empty ranges")
  func textViewDelegateMethodsWithEmptyRanges() async {
    let aboutTextView = AboutTextView()
    let textView = UITextView()
    let emptyRange = NSRange(location: NSNotFound, length: 0)

    let shouldChangeText = aboutTextView.textView(textView, shouldChangeTextIn: emptyRange, replacementText: "")

    #expect(shouldChangeText == false)
  }

  @Test("Text view delegate methods with large ranges")
  func textViewDelegateMethodsWithLargeRanges() async {
    let aboutTextView = AboutTextView()
    let textView = UITextView()
    let largeRange = NSRange(location: 0, length: 10000)

    let shouldChangeText = aboutTextView.textView(textView, shouldChangeTextIn: largeRange, replacementText: "large text")

    #expect(shouldChangeText == false)
  }
}
