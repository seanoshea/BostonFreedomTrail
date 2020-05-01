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

import GoogleMaps
import MaterialComponents

final class VirtualTourViewController: BaseViewController {
  
  // MARK: Properties
  
  var model: VirtualTourModel = VirtualTourModel()
  var panoView: GMSPanoramaView?
  @IBOutlet weak var virtualTourButton: VirtualTourButton!
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    model.delegate = self
    let firstPlacemark = model.firstPlacemark()
    addPanoramaView(CLLocationCoordinate2DMake(firstPlacemark.location.coordinate.latitude, firstPlacemark.location.coordinate.longitude))
    MDCSnackbarManager.setPresentationHostView(view)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    model.setupTour()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if model.currentTourState != VirtualTourState.finished {
      model.pauseTour()
    }
  }
  
  // MARK: IBActions
  
  @IBAction func pressedOnVirtualTourButton(_ sender: UIButton) {
    // first check to see that the user is actually online
    if isOnline() {
      model.togglePlayPause()
      switch model.currentTourState {
      case VirtualTourState.postSetup:
        startTour()
      case VirtualTourState.inProgress:
        postDispatchAction(model.nextLocation())
      case VirtualTourState.finished:
        restartTour()
      default:
        break
      }
      MDCSnackbarManager.dismissAndCallCompletionBlocks(withCategory: nil)
    } else {
      displaySnackbarMessage(NSLocalizedString("Please check your network connection", comment: ""))
    }
  }
  
  // MARK: Analytics
  
  override func getScreenTrackingName() -> String {
    return AnalyticsScreenNames.virtualTourScreen.rawValue
  }
  
  // MARK: Online/Offline
  
  func reachabilityStatusChanged(_ online: Bool) {
    super.reachabilityStatusChanged(online)
    if online {
      virtualTourButton?.isEnabled = true
      reloadCurrentLocation()
    } else {
      virtualTourButton?.isEnabled = false
      model.pauseTour()
    }
  }
  
  // MARK: Private Functions
  
  func addPanoramaView(_ panoramaNear: CLLocationCoordinate2D) {
    let panoView = GMSPanoramaView.panorama(withFrame: view.frame, nearCoordinate:panoramaNear)
    panoView.navigationLinksHidden = true
    panoView.delegate = self
    view.addSubview(panoView)
    panoView.addSubview(virtualTourButton!)
    self.panoView = panoView
  }
  
  func startTour() {
    let firstTourLocation = model.startTour()
    panoView?.moveNearCoordinate(CLLocationCoordinate2DMake(firstTourLocation.coordinate.latitude, firstTourLocation.coordinate.longitude))
  }
  
  func restartTour() {
    model.currentTourState = VirtualTourState.postSetup
    startTour()
  }
  
  func cameraPositionForNextLocation(_ nextLocation: CLLocation) -> GMSPanoramaCamera {
    var pitch = 0.0
    var heading: CLLocationDirection?
    if model.atLookAtLocation() {
      let lookAt: LookAt = model.lookAtForCurrentLocation()!
      pitch = lookAt.tilt
      heading = lookAt.heading
    } else {
      heading = model.locationDirectionForNextLocation(nextLocation)
    }
    return GMSPanoramaCamera.init(heading:heading!, pitch:pitch, zoom:1)
  }
  
  func shouldEnqueueNextLocationForPanorama(_ panorama: GMSPanorama?) -> Bool {
    return model.tourIsRunning()
  }
  
  func postDispatchAction(_ nextLocation: CLLocation) {
    postDispatchAction(nextLocation, force:false)
  }
  
  func postDispatchAction(_ nextLocation: CLLocation, force: Bool) {
    if model.tourIsRunning() || force {
      if isOnline() {
        repositionPanoViewForNextLocation(nextLocation)
        panoView?.moveNearCoordinate(CLLocationCoordinate2DMake(nextLocation.coordinate.latitude, nextLocation.coordinate.longitude))
      } else {
        model.pauseTour()
      }
    } else {
      // back up
      model.reverseLocation()
    }
  }
  
  func repositionPanoViewForNextLocation(_ nextLocation: CLLocation) {
    if model.hasAdvancedPastFirstLocation() {
      let newCamera = cameraPositionForNextLocation(nextLocation)
      panoView?.animate(to: newCamera, animationDuration: VirtualTourStopStopDuration.cameraRepositionAnimation.rawValue)
      if model.atLookAtLocation() {
        guard let placemark = model.placemarkForNextLocation() else { return }
        displaySnackbarMessage(placemark.name)
      }
    }
    if model.isAtLastPosition() {
      model.finishTour()
    }
  }
  
  func advanceToNextLocation(_ delayTime: DispatchTime) {
    unowned let unownedSelf: VirtualTourViewController = self
    DispatchQueue.main.asyncAfter(deadline: model.delayTime()) {
      unownedSelf.postDispatchAction(unownedSelf.model.nextLocation())
    }
  }
  
  func reloadCurrentLocation() {
    guard let currentLocation = model.getCurrentTourLocation() else { return }
    if model.currentTourState == .paused {
      DispatchQueue.main.asyncAfter(deadline: model.delayTime()) { [weak self] in
        self?.postDispatchAction(currentLocation)
      }
    }
  }
}

// MARK: GMSPanoramaViewDelegate Functions

extension VirtualTourViewController : GMSPanoramaViewDelegate {
  
  func panoramaView(_ view: GMSPanoramaView, didMoveTo panorama: GMSPanorama?) {
    if shouldEnqueueNextLocationForPanorama(panorama) {
      advanceToNextLocation(model.delayTime())
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
    postDispatchAction(model.nextLocation(), force:true)
  }
  
  func didChangeTourState(_ fromState:VirtualTourState, toState:VirtualTourState) {
    virtualTourButton.updateButtonTitle(toState)
  }
}
