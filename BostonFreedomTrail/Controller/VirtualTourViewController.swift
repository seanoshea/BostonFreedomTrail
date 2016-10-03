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

import GoogleMaps
import MaterialComponents

final class VirtualTourViewController: BaseViewController {
  
  // MARK: Properties
  
  var model: VirtualTourModel = VirtualTourModel()
  var panoView: GMSPanoramaView?
  var playPauseButton: VirtualTourPlayPauseButton!
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupPlayPauseButton()
    self.model.delegate = self
    let firstPlacemark = self.model.firstPlacemark()
    self.addPanoramaView(CLLocationCoordinate2DMake(firstPlacemark.location.coordinate.latitude, firstPlacemark.location.coordinate.longitude))
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.model.setupTour()
    self.playPauseButton?.isEnabled = true
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    self.pauseTour()
  }
  
  // MARK: Analytics
  
  override func getScreenTrackingName() -> String {
    return AnalyticsScreenNames.VirtualTourScreen.rawValue
  }
  
  // MARK: Private Functions
  
  func setupPlayPauseButton() {
    playPauseButton = VirtualTourPlayPauseButton()
    playPauseButton.paused = true
    playPauseButton.sizeToFit()
    let selector = #selector(pressedOnPlayPauseButton as (_: UIButton) -> Void)
    playPauseButton.addTarget(self, action: selector, for: .touchUpInside)
    playPauseButton.setBackgroundColor(UIColor.init(red:231/255, green:232/255, blue:235/255, alpha: 1), for: .normal)
    playPauseButton.setTitleColor(UIColor.init(red:92/255, green:92/255, blue:92/255, alpha: 1), for: .normal)
  }
  
  func pressedOnPlayPauseButton(_ sender: UIButton) {
    self.model.togglePlayPause()
    switch self.model.currentTourState {
    case VirtualTourState.postSetup:
      self.startTour()
      break
    case VirtualTourState.inProgress:
      self.postDispatchAction(self.model.nextLocation())
      break
    default:
      break
    }
    self.playPauseButton?.paused = !self.model.tourIsRunning()
  }
  
  func addPanoramaView(_ panoramaNear: CLLocationCoordinate2D) {
    let panoView = GMSPanoramaView.panorama(withFrame: self.view.frame, nearCoordinate:panoramaNear)
    panoView.navigationLinksHidden = true
    panoView.delegate = self
    self.view.addSubview(panoView)
    panoView.addSubview(self.playPauseButton!)
    playPauseButton.center = panoView.center
    self.panoView = panoView
  }
  
  func startTour() {
    let firstTourLocation = self.model.startTour()
    self.panoView?.moveNearCoordinate(CLLocationCoordinate2DMake(firstTourLocation.coordinate.latitude, firstTourLocation.coordinate.longitude))
  }
  
  func cameraPositionForNextLocation(_ nextLocation: CLLocation) -> GMSPanoramaCamera {
    var pitch = 0.0
    var heading: CLLocationDirection?
    if self.model.atLookAtLocation() {
      let lookAt: LookAt = self.model.lookAtForCurrentLocation()!
      pitch = lookAt.tilt
      heading = lookAt.heading
    } else {
      heading = self.model.locationDirectionForNextLocation(nextLocation)
    }
    return GMSPanoramaCamera.init(heading:heading!, pitch:pitch, zoom:1)
  }
  
  func shouldEnqueueNextLocationForPanorama(_ panorama: GMSPanorama?) -> Bool {
    return self.model.tourIsRunning()
  }
  
  func postDispatchAction(_ nextLocation: CLLocation) {
    self.postDispatchAction(nextLocation, force:false)
  }
  
  func postDispatchAction(_ nextLocation: CLLocation, force: Bool) {
    if self.model.tourIsRunning() || force {
      self.repositionPanoViewForNextLocation(nextLocation)
      self.panoView?.moveNearCoordinate(CLLocationCoordinate2DMake(nextLocation.coordinate.latitude, nextLocation.coordinate.longitude))
    } else {
      // back up
      self.model.reverseLocation()
    }
  }
  
  func repositionPanoViewForNextLocation(_ nextLocation: CLLocation) {
    if self.model.hasAdvancedPastFirstLocation() {
      let newCamera = self.cameraPositionForNextLocation(nextLocation)
      self.panoView?.animate(to: newCamera, animationDuration: VirtualTourStopStopDuration.cameraRepositionAnimation.rawValue)
      if self.model.atLookAtLocation() {
        if let pm = self.model.placemarkForNextLocation() {
          self.displaySnackbarMessage(pm.name)
        }
      }
    }
  }
  
  func advanceToNextLocation(_ delayTime: DispatchTime) {
    unowned let unownedSelf: VirtualTourViewController = self
    DispatchQueue.main.asyncAfter(deadline: self.model.delayTime()) {
      unownedSelf.postDispatchAction(unownedSelf.model.nextLocation())
    }
  }
  
  func pauseTour() {
    self.playPauseButton?.paused = true
    self.model.pauseTour()
  }
}

// MARK: GMSPanoramaViewDelegate Functions

extension VirtualTourViewController : GMSPanoramaViewDelegate {
  
  func panoramaView(_ view: GMSPanoramaView, didMoveTo panorama: GMSPanorama?) {
    if self.shouldEnqueueNextLocationForPanorama(panorama) {
      self.advanceToNextLocation(self.model.delayTime())
    }
  }
  
  func panoramaView(_ panoramaView: GMSPanoramaView, didMove camera: GMSPanoramaCamera) {
    panoramaView.logLocation()
    camera.logLocation()
  }
}

// MARK: VirtualTourModelDelegate Functions

extension VirtualTourViewController : VirtualTourModelDelegate {
  
  func navigateToCurrentPosition(_ model: VirtualTourModel) {
    self.postDispatchAction(self.model.nextLocation(), force:true)
  }
}
