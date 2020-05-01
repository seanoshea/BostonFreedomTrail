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

import UIKit
import Reachability
import MaterialComponents

protocol ReachabilityListener:class {
  func registerListener()
  func reachabilityStatusChanged(_ online: Bool)
  func isOnline() -> Bool
}

extension ReachabilityListener where Self : BaseViewController {
  
  func registerListener() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    appDelegate.reachability?.whenReachable = { reachability in
      DispatchQueue.main.async { [weak self] in
        self?.reachabilityStatusChanged(true)
      }
    }
    appDelegate.reachability?.whenUnreachable = { reachability in
      DispatchQueue.main.async { [weak self] in
        self?.reachabilityStatusChanged(false)
      }
    }
  }
  
  func reachabilityStatusChanged(_ online: Bool) {
    if online {
      MDCSnackbarManager.dismissAndCallCompletionBlocks(withCategory: nil)
    } else {
      displaySnackbarMessage(NSLocalizedString("Please check your network connection", comment: ""))
    }
  }
  
  func isOnline() -> Bool {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
    guard let reachability = appDelegate.reachability else { return false }
    return reachability.connection != .unavailable
  }
}
