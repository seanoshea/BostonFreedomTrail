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

import Foundation
import Testing
@testable import BostonFreedomTrail
import GoogleMaps

@Suite("VirtualTourModel")
@MainActor
struct VirtualTourModelTests {

  // MARK: - Tour Controls Tests

  @Test("Start tour sets state to inProgress and position to 0")
  func startTourSetsStateAndPosition() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()

    _ = subject.startTour()

    #expect(subject.currentTourState == .inProgress)
    #expect(subject.currentTourPosition == 0)
  }

  @Test("Pause tour sets state to paused")
  func pauseTourSetsStateToPaused() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()

    subject.pauseTour()

    #expect(subject.currentTourState == .paused)
  }

  @Test("Tour is not running when finished")
  func tourNotRunningWhenFinished() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()

    subject.currentTourState = .finished

    #expect(!subject.tourIsRunning())
  }

  @Test("Tour is not running when paused")
  func tourNotRunningWhenPaused() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()

    subject.currentTourState = .paused

    #expect(!subject.tourIsRunning())
  }

  @Test("Enqueue next location advances tour position")
  func enqueueNextLocationAdvancesPosition() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()
    subject.currentTourPosition = 1

    _ = subject.enqueueNextLocation()

    // Location is always non-nil since enqueueNextLocation() returns CLLocation (not optional)
    #expect(subject.currentTourPosition == 2)
  }

  @Test("Resume tour sets state to inProgress")
  func resumeTourSetsStateToInProgress() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()

    subject.resumeTour()

    #expect(subject.currentTourState == .inProgress)
  }

  @Test("Advance location increments position")
  func advanceLocationIncrementsPosition() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()

    let before = subject.currentTourPosition
    subject.advanceLocation()

    #expect(subject.currentTourPosition == before + 1)
  }

  @Test("Reverse location decrements position")
  func reverseLocationDecrementsPosition() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()
    subject.advanceLocation()
    subject.advanceLocation()

    let before = subject.currentTourPosition
    subject.reverseLocation()

    #expect(subject.currentTourPosition == before - 1)
  }

  @Test("Tour initialization states")
  func tourInitializationStates() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()

    subject.currentTourState = .preSetup
    #expect(subject.tourNotInitialized())

    subject.currentTourState = .postSetup
    subject.lookAts = [Int:Int]()
    #expect(subject.tourNotInitialized())

    subject.setupTour()
    #expect(!subject.tourNotInitialized())
  }

  @Test("Toggle play pause changes tour state")
  func togglePlayPauseChangesState() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()

    subject.currentTourState = .paused
    subject.togglePlayPause()
    #expect(subject.currentTourState == .inProgress)

    subject.togglePlayPause()
    #expect(subject.currentTourState == .paused)
  }

  @Test("Detects when tour is at last position")
  func detectsAtLastPosition() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()

    subject.currentTourPosition = subject.tour.count - 1

    #expect(subject.isAtLastPosition())
  }

  @Test("Finish tour sets state to finished")
  func finishTourSetsStateToFinished() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()

    subject.finishTour()

    #expect(subject.currentTourState == .finished)
  }

  // MARK: - LookAt Tests

  @Test("Does not return LookAt for invalid tour location")
  func doesNotReturnLookAtForInvalidLocation() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()
    let dummyDelegate = DummyVirtualTourModelDelegate()
    subject.delegate = dummyDelegate

    subject.currentTourPosition = 0

    #expect(subject.lookAtForCurrentLocation() == nil)
  }

  @Test("Returns LookAt for valid tour location")
  func returnsLookAtForValidLocation() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()
    let dummyDelegate = DummyVirtualTourModelDelegate()
    subject.delegate = dummyDelegate

    subject.currentTourPosition = 15

    #expect(subject.lookAtForCurrentLocation() != nil)
  }

  @Test("Cannot find LookAt for out of bounds placemark (lower)")
  func cannotFindLookAtForLowerBounds() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()
    let dummyDelegate = DummyVirtualTourModelDelegate()
    subject.delegate = dummyDelegate

    #expect(subject.lookAtPositionInTourForPlacementIndex(-1) == nil)
  }

  @Test("Cannot find LookAt for out of bounds placemark (upper)")
  func cannotFindLookAtForUpperBounds() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()
    let dummyDelegate = DummyVirtualTourModelDelegate()
    subject.delegate = dummyDelegate

    #expect(subject.lookAtPositionInTourForPlacementIndex(51) == nil)
  }

  @Test("Finds LookAt for 4th placemark at position 25")
  func findsLookAtForFourthPlacemark() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()
    let dummyDelegate = DummyVirtualTourModelDelegate()
    subject.delegate = dummyDelegate

    #expect(subject.lookAtPositionInTourForPlacementIndex(3) == 25)
  }

  @Test("Navigate to LookAt sets state and triggers delegate")
  func navigateToLookAtSetsStateAndTriggersDelegate() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()
    let dummyDelegate = DummyVirtualTourModelDelegate()
    subject.delegate = dummyDelegate

    subject.navigateToLookAt(3)

    // Give async delegate call time to execute
    try? await Task.sleep(for: .milliseconds(100))

    #expect(subject.currentTourState == .paused)
    #expect(dummyDelegate.navigationInitiated)
  }

  // MARK: - Next Location Tests

  @Test("Retrieves placemark for next location")
  func retrievesPlacemarkForNextLocation() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()

    subject.setupTour()
    subject.currentTourPosition = 23

    #expect(subject.placemarkForNextLocation() != nil)
  }

  @Test("Uses next location when not at LookAt")
  func usesNextLocationWhenNotAtLookAt() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()

    subject.currentTourPosition = 14
    let location = subject.nextLocation()

    #expect(location.coordinate.latitude == 42.357560999999997)
    #expect(location.coordinate.longitude == -71.063400999999999)
  }

  @Test("Uses LookAt location when at LookAt position")
  func usesLookAtLocationWhenAtLookAt() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()

    subject.currentTourPosition = 15
    let location = subject.nextLocation()
    let lookAtIndex = subject.lookAts[15]!
    let lookAt = Trail.instance.placemarks[lookAtIndex].lookAt

    #expect(location.coordinate.latitude == lookAt?.latitude)
    #expect(location.coordinate.longitude == lookAt?.longitude)
  }

  // MARK: - Delay Time Tests

  @Test("Waits longer at LookAt location than regular location")
  func waitsLongerAtLookAt() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()

    subject.currentTourPosition = 15
    let firstDelay = subject.delayTime()
    subject.currentTourPosition = 16
    let secondDelay = subject.delayTime()

    #expect(firstDelay > secondDelay)
  }

  // MARK: - Camera Direction Tests

  @Test("Calculates correct camera direction between two points")
  func calculatesCorrectCameraDirection() async {
    let subject = VirtualTourModel()
    subject.setupTour()
    ApplicationSharedState.sharedInstance.clear()

    subject.advanceLocation()
    let to = CLLocation(latitude: 42.355357, longitude: -71.063666)

    let direction = subject.locationDirectionForNextLocation(to)

    // Using isApproximatelyEqual with tolerance
    let expected = 118.426051240986
    #expect(abs(direction - expected) < 0.0001)
  }
}

// MARK: - Test Helpers

@MainActor
class DummyVirtualTourModelDelegate : VirtualTourModelDelegate {

  var navigationInitiated = false

  func navigateToCurrentPosition(_ model: VirtualTourModel) {
    self.navigationInitiated = true
  }

  func didChangeTourState(_ fromState: VirtualTourState, toState: VirtualTourState) {
    // No-op for testing
  }
}
