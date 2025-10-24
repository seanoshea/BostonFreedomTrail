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
import MaterialComponents

/**
 * Base view controller providing common functionality for all view controllers in the app.
 * 
 * This class serves as the foundation for all view controllers in the Boston Freedom Trail app,
 * providing shared functionality including analytics tracking, network reachability monitoring,
 * and user notification display via snackbar messages.
 * 
 * ## Features
 * - Analytics tracking integration
 * - Network reachability monitoring
 * - Material Design snackbar message display
 * - Automatic listener registration on view appearance
 * 
 * ## Usage
 * ```swift
 * class MyViewController: BaseViewController {
 *   override func getScreenTrackingName() -> String {
 *     return "MyScreen"
 *   }
 * }
 * ```
 * 
 * - Author: Upwards Northwards Software Limited
 * - Since: 1.0
 */
class BaseViewController: UIViewController, AnalyticsTracker, ReachabilityListener {

  // MARK: Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerListener()
  }

  // MARK: Snackbar Messages

  /**
   * Displays a snackbar message to the user using Material Design components.
   * 
   * This method safely displays messages on the main thread, making it suitable
   * for showing user feedback, error messages, or status updates.
   * 
   * - Parameter text: The message text to display to the user
   * 
   * ## Example
   * ```swift
   * displaySnackbarMessage("Location updated successfully")
   * ```
   */
  func displaySnackbarMessage(_ text: String) {
    DispatchQueue.main.async {
      MDCSnackbarManager.default.show(MDCSnackbarMessage(text: text))
    }
  }

  // MARK: Analytics

  /**
   * Provides the screen tracking name for analytics purposes.
   * 
   * This method should be overridden by subclasses to provide a unique identifier
   * for analytics tracking. The returned string is used to track user navigation
   * and screen usage patterns.
   * 
   * - Returns: A unique string identifier for this view controller's screen.
   *           Base implementation returns an empty string.
   * 
   * ## Implementation Note
   * Subclasses must override this method to provide meaningful analytics data:
   * ```swift
   * override func getScreenTrackingName() -> String {
   *   return AnalyticsScreenNames.mapScreen.rawValue
   * }
   * ```
   */
  func getScreenTrackingName() -> String {
    ""
  }
}
