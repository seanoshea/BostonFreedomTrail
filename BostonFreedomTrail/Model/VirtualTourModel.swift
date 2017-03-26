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

import Foundation
import CoreLocation

/// enum for understanding what state the virtual tour is in
enum VirtualTourState: Int {
  case preSetup = 0
  case postSetup = 1
  case inProgress = 2
  case paused = 3
  case finished = 4
}

/// enum for the durations to wait while moving through the virtial tour
enum VirtualTourStopStopDuration: Double {
  case cameraRepositionAnimation = 0.5
  case defaultDelay = 1.0
  case delayForCameraRepositioning = 2.0
  case delayForLookAt = 5.0
}

/// Delegate protocol for the `VirtualTourModel`
protocol VirtualTourModelDelegate:class {
  
  /**
   Given a `VirtualTourModel` this function navigates to the current position in the tour automatically.
   
   - parameter model: the `VirtualTourModel`
   */
  func navigateToCurrentPosition(_ model: VirtualTourModel)
  
  /**
   Records when the tour state changes.
   
   - parameter fromState: the previous tour state
   - parameter toState: the new tour state
   */
  func didChangeTourState(_ fromState:VirtualTourState, toState:VirtualTourState)
}

/// Backling business logic class for the `VirtualTourController`
final class VirtualTourModel {
  
  // MARK: Properties
  
  /// Contains all the locations for the virtual tour
  var tour: [CLLocation] = []
  /// Collection of indexes for `LookAt`s during the virtual tour
  var lookAts = [Int:Int]()
  /// Collection of indexes for understanding what `Placemark` the user is navigating towards
  var placemarkDemarkations = [Int:Int]()
  /// Where the tour is currently positioned
  var currentTourLocation: CLLocation? {
    get {
      guard tour.count > currentTourPosition else { return nil }
      return tour[currentTourPosition]
    }
  }
  /// Where the tour is currently located
  var currentTourPosition: Int = 0
  /// The state of the virtual tour
  var currentTourState: VirtualTourState = VirtualTourState.preSetup {
    didSet {
      delegate?.didChangeTourState(oldValue, toState:currentTourState)
    }
  }
  /// Simple delegate to allow the model navigate to the current position in the tour
  weak var delegate: VirtualTourModelDelegate?
  
  /// Initializes the tour
  func setupTour() {
    guard tourNotInitialized() else { return }
    var index = 0
    for (placemarkIndex, placemark) in Trail.instance.placemarks.enumerated() {
      for (locationIndex, location) in placemark.coordinates.enumerated() {
        if locationIndex == placemark.coordinates.count - 1 {
          if placemark.lookAt != nil {
            lookAts[index] = placemarkIndex
          }
        }
        index = index + 1
        tour.append(location)
      }
      placemarkDemarkations[index] = placemarkIndex
    }
    currentTourState = VirtualTourState.postSetup
  }
  
  /**
   Starts the virtual tour from the very beginning
   
   - returns: a `CLLocation` which represents the starting point on the virtual tour
   */
  func startTour() -> CLLocation {
    currentTourPosition = 0
    currentTourState = VirtualTourState.inProgress
    return tour[currentTourPosition]
  }
  
  /**
   Checks the `currentTourPosition` to see if the virtual tour is currently at a `LookAt` location.
   
   - returns: Bool indicating that the tour is currently positioned at a `LookAt`
   */
  func atLookAtLocation() -> Bool {
    return currentTourPosition > 0 && lookAts[currentTourPosition] != nil
  }
  
  /**
   Possibly returns a `LookAt` if the virtual tour is at a LookAt location.
   
   - returns: a `LookAt` corresponding to the current location of the tour
   */
  func lookAtForCurrentLocation() -> LookAt? {
    guard currentTourPosition > 0 else { return nil}
    let placemarkIndex = lookAts[currentTourPosition]
    let placemark = Trail.instance.placemarks[placemarkIndex!]
    return placemark.lookAt
  }
  
  /**
   Gets the placemark based on the next location in the tour.
   
   - returns: a `Placemark` corresponding to the next tour location
   */
  func placemarkForNextLocation() -> Placemark? {
    let placemarkIndex = currentTourPosition + 1
    guard placemarkDemarkations.count < placemarkIndex + 1 else { return nil }
    let index = placemarkDemarkations[placemarkIndex]
    return Trail.instance.placemarks[index!]
  }
  
  /**
   Bumps the `currentTourPosition` and returns the next placemark in the tour
   
   - returns: a `Placemark` corresponding to the next tour location
   */
  func enqueueNextLocation() -> CLLocation {
    advanceLocation()
    return tour[currentTourPosition]
  }
  
  /// Toggles the virtual tour state between play and pause
  func togglePlayPause() {
    guard tourIsToggleable() else { return }
    if tourIsPlayable() {
      if currentTourState != VirtualTourState.postSetup {
        resumeTour()
      }
    } else {
      pauseTour()
    }
  }
  
  /// Pauses the tour
  func pauseTour() {
    currentTourState = VirtualTourState.paused
  }
  
  /// Unpauses the tour
  func resumeTour() {
    currentTourState = VirtualTourState.inProgress
  }
  
  /// Marks the tour as finished
  func finishTour() {
    currentTourState = VirtualTourState.finished
  }
  
  /**
   Checks to see if the tour has gone past the first `Placemark`
   
   - returns: Bool indicating that the tour has advanced past the first `Placemark`
   */
  func hasAdvancedPastFirstLocation() -> Bool {
    return currentTourPosition > 0
  }
  
  /**
   Checks to see if the tour is currently active.
   
   - returns: Bool indicating that the tour is running
   */
  func tourIsRunning() -> Bool {
    return currentTourState == VirtualTourState.inProgress
  }
  
  /**
   Retrieves the first placemark in the virtual tour.
   
   - returns: `Placemark` representing the first stop in the virtual tour
   */
  func firstPlacemark() -> Placemark {
    return Trail.instance.placemarks[0]
  }
  
  /// Bumps the `currentTourPosition` by one.
  func advanceLocation() {
    currentTourPosition = currentTourPosition + 1
  }
  
  /// Decrements the `currentTourPosition` by one.
  func reverseLocation() {
    currentTourPosition = currentTourPosition - 1
  }
  
  /**
   Checks to see if we can advance in the tour.
   
   - returns: Bool indicating that the tour is startable or resumable
   */
  func tourIsPlayable() -> Bool {
    return currentTourState == VirtualTourState.postSetup || currentTourState == VirtualTourState.paused
  }
  
  /**
   Checks to see if we can toggle between a paused and resumed state in the virtual tour.
   
   - returns: Bool indicating that the user can pause or resume the virtual tour
   */
  func tourIsToggleable() -> Bool {
    return tourIsRunning() || tourIsPlayable()
  }

  /**
   Checks to see if the tour has finished or not.
   
   - returns: Bool indicating that the tour has reached it's final location.
   */
  func isAtLastPosition() -> Bool {
    return currentTourPosition == tour.count - 1
  }
  
  /**
   Retrieves the next `CLLocation` in the virtual tour.
   
   - returns: a `CLLocation` object which is the next location to navigate to in the virtual tour
   */
  func nextLocation() -> CLLocation {
    var nextLocation: CLLocation
    if atLookAtLocation() {
      let lookAt = lookAtForCurrentLocation()!
      nextLocation = CLLocation.init(latitude:lookAt.latitude, longitude:lookAt.longitude)
      advanceLocation()
    } else {
      nextLocation = enqueueNextLocation()
    }
    return nextLocation
  }
  
  /**
   Retrieves the the time we should delay for at the current location.
   
   - returns: a time in seconds that we should wait for at the current location in the virtual tour
   */
  func delayTime() -> DispatchTime {
    var delay = hasAdvancedPastFirstLocation() ? VirtualTourStopStopDuration.delayForCameraRepositioning.rawValue : VirtualTourStopStopDuration.defaultDelay.rawValue
    if atLookAtLocation() {
      delay = VirtualTourStopStopDuration.delayForLookAt.rawValue
    }
    return DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
  }
  
  func navigateToLookAt(_ placemarkIndex: Int) {
    setupTour()
    guard let delegate = delegate else { return }
    guard let position = lookAtPositionInTourForPlacementIndex(placemarkIndex) else { return }
    currentTourPosition = position
    currentTourState = VirtualTourState.paused
    delegate.navigateToCurrentPosition(self)
  }
  
  // MARK: Private Functions
  
  func lookAtPositionInTourForPlacementIndex(_ placemarkIndex: Int) -> Int? {
    if placemarkIndex == 0 {
      return 0
    }
    var foundKey: Int?
    for (key, value) in lookAts {
      if value == placemarkIndex {
        foundKey = key
        break
      }
    }
    guard let positionInTour = foundKey else { return nil }
    return positionInTour - 1
  }
  
  /**
   Figures out whether or not the tour has been initialized and is ready to go yet.
   
   - returns: Bool indicating that the tour has not been set up yet
   */
  func tourNotInitialized() -> Bool {
    return currentTourState == VirtualTourState.preSetup || lookAts.count == 0
  }
  
  // MARK: Calculating Camera Directions
  
  func locationDirectionForNextLocation(_ nextLocation: CLLocation) -> CLLocationDirection {
    let from = tour[currentTourPosition - 1]
    let to = CLLocation.init(latitude:nextLocation.coordinate.latitude, longitude:nextLocation.coordinate.longitude)
    let fromLatitude = degreesToRadians(from.coordinate.latitude)
    let fromLongitude = degreesToRadians(from.coordinate.longitude)
    let toLatitude = degreesToRadians(to.coordinate.latitude)
    let toLongitude = degreesToRadians(to.coordinate.longitude)
    let degree = radiansToDegrees(atan2(sin(toLongitude - fromLongitude) * cos(toLatitude), cos(fromLatitude) * sin(toLatitude)-sin(fromLatitude) * cos(toLatitude) * cos(toLongitude - fromLongitude)))
    return degree >= 0.0 ? degree : 360.0 + degree
  }
  
  func degreesToRadians(_ value: CLLocationDegrees) -> CLLocationDegrees {
    return value * Double.pi / 180.0
  }
  
  func radiansToDegrees(_ value: Double) -> Double {
    return (value * 180.0 / Double.pi)
  }
}
