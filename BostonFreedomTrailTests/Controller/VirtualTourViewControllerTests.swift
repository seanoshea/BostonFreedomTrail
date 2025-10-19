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
import Reachability
@testable import BostonFreedomTrail
import GoogleMaps

@Suite("VirtualTourViewController")
@MainActor
struct VirtualTourViewControllerTests {

  // MARK: - Initialization Tests

  @Test("Starts with tour location of zero")
  func startsWithTourLocationZero() async {
    let subject = UIStoryboard.virtualTourViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    #expect(subject.model.currentTourPosition == 0)
  }

  @Test("Has panoView set by default")
  func hasPanoViewSetByDefault() async {
    let subject = UIStoryboard.virtualTourViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    #expect(subject.panoView != nil)
  }

  @Test("Is initialized to PreSetup state")
  func isInitializedToPreSetupState() async {
    let subject = UIStoryboard.virtualTourViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    #expect(subject.model.currentTourState == .preSetup)
  }

  // MARK: - View Controller Lifecycle Tests

  @Test("Sets up tour when view appears")
  func setUpTourWhenViewAppears() async {
    let subject = UIStoryboard.virtualTourViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    subject.viewDidAppear(true)

    #expect(subject.model.currentTourState == .postSetup)
  }

  // NOTE: The following tests were commented out in the original Quick/Nimble version
  // Keeping them commented for now until the implementation is verified

  // @Test("Automatically pauses tour when view disappears and tour not finished")
  // func automaticallyPausesTourOnViewDisappear() async {
  //   let subject = UIStoryboard.virtualTourViewController()
  //   _ = subject.view
  //   ApplicationSharedState.sharedInstance.clear()
  //
  //   subject.viewDidDisappear(true)
  //
  //   #expect(subject.model.currentTourState == .paused)
  //   #expect(subject.virtualTourButton?.title(for: .normal) == "▷")
  // }

  // @Test("Does not pause tour when view disappears and tour is finished")
  // func doesNotPauseTourWhenFinished() async {
  //   let subject = UIStoryboard.virtualTourViewController()
  //   _ = subject.view
  //   ApplicationSharedState.sharedInstance.clear()
  //
  //   subject.model.currentTourState = .finished
  //   subject.viewDidDisappear(true)
  //
  //   #expect(subject.model.currentTourState == .finished)
  //   #expect(subject.virtualTourButton?.title(for: .normal) == "↻")
  // }

  // MARK: - Analytics Tests

  @Test("Has unique screen name for analytics")
  func hasUniqueScreenName() async {
    let subject = UIStoryboard.virtualTourViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    #expect(subject.getScreenTrackingName() == AnalyticsScreenNames.virtualTourScreen.rawValue)
  }

  // MARK: - Virtual Tour Button Tests
  // NOTE: These tests were commented out in the original Quick/Nimble version

  // @Test("Toggles tour state when button pressed and tour not finished")
  // func togglesTourStateWhenButtonPressed() async {
  //   let subject = UIStoryboard.virtualTourViewController()
  //   _ = subject.view
  //   ApplicationSharedState.sharedInstance.clear()
  //   subject.viewDidAppear(true)
  //
  //   subject?.pressedOnVirtualTourButton(subject!.virtualTourButton!)
  //   #expect(subject.virtualTourButton?.title(for: .normal) == "||")
  //
  //   subject?.pressedOnVirtualTourButton(subject!.virtualTourButton!)
  //   #expect(subject.virtualTourButton?.title(for: .normal) == "▷")
  // }

  // @Test("Restarts tour when button pressed and tour is finished")
  // func restartsTourWhenFinished() async {
  //   let subject = UIStoryboard.virtualTourViewController()
  //   _ = subject.view
  //   ApplicationSharedState.sharedInstance.clear()
  //   subject.viewDidAppear(true)
  //
  //   subject.model.currentTourState = .finished
  //
  //   subject?.pressedOnVirtualTourButton(subject!.virtualTourButton!)
  //   #expect(subject.virtualTourButton?.title(for: .normal) == "||")
  // }

  // MARK: - Online and Offline Tests

  @Test("Pauses tour when user goes offline")
  func pausesTourWhenOffline() async {
    let subject = UIStoryboard.virtualTourViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    subject.reachabilityStatusChanged(false)

    #expect(subject.model.currentTourState == .paused)
    #expect(subject.virtualTourButton?.isEnabled == false)
  }

  @Test("Allows tour restart when user comes back online")
  func allowsTourRestartWhenOnline() async {
    let subject = UIStoryboard.virtualTourViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    subject.reachabilityStatusChanged(true)

    #expect(subject.virtualTourButton?.isEnabled == true)
  }

  // MARK: - Queue Next Location Tests

  @Test("Queues next location when tour is running")
  func queuesNextLocationWhenRunning() async {
    let subject = UIStoryboard.virtualTourViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    subject.model.currentTourState = .inProgress

    #expect(subject.shouldEnqueueNextLocationForPanorama(nil) == true)
  }

  @Test("Does not queue next location when tour is not running")
  func doesNotQueueNextLocationWhenNotRunning() async {
    let subject = UIStoryboard.virtualTourViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    subject.model.currentTourState = .paused

    #expect(subject.shouldEnqueueNextLocationForPanorama(nil) == false)
  }

  // MARK: - Post Dispatch Action Tests

  @Test("Backs up tour one location when paused")
  func backsUpTourOneLocationWhenPaused() async {
    let subject = UIStoryboard.virtualTourViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    subject.viewDidAppear(true)
    subject.startTour()
    subject.model.currentTourPosition = 14

    let location = CLLocation(latitude: 123, longitude: 312)
    subject.model.currentTourState = .paused

    subject.postDispatchAction(location)

    #expect(subject.model.currentTourPosition == 13)
  }

  // MARK: - Tour Finished Tests

  @Test("Sets model to finished when reaching final location")
  func setsModelToFinishedAtFinalLocation() async {
    let subject = UIStoryboard.virtualTourViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    subject.viewDidAppear(true)
    subject.startTour()
    let nextLocation = CLLocation()
    subject.model.currentTourPosition = subject.model.tour.count - 1

    subject.repositionPanoViewForNextLocation(nextLocation)

    #expect(subject.model.currentTourState == .finished)
  }

  // MARK: - Camera Repositioning Tests

  @Test("Returns camera with correct bearing zoom and pitch")
  func returnsCameraWithCorrectProperties() async {
    let subject = UIStoryboard.virtualTourViewController()
    _ = subject.view
    ApplicationSharedState.sharedInstance.clear()

    subject.model.setupTour()
    _ = subject.model.startTour()
    let nextStop = subject.model.enqueueNextLocation()

    let newCamera = subject.cameraPositionForNextLocation(nextStop)

    #expect(newCamera.zoom == 1.0)
    #expect(abs(newCamera.orientation.heading - 118.426040649414) < 0.0001)
    #expect(newCamera.orientation.pitch == 0.0)
  }
}

// MARK: - Test Helpers

class DummyPanoramaView: GMSPanoramaView {

  var wasMoved = false

  override func moveNearCoordinate(_ coordinate: CLLocationCoordinate2D) {
    self.wasMoved = true
  }
}
