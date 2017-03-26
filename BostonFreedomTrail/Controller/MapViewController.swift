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
import GoogleMaps

/// Delegate for the `MapViewController`
protocol MapViewControllerDelegate:class {
  /**
   Executed when navigating to the virtual tour screen.
   
   - parameter placemark: The `Placemark` to land on after switching to the virtual tour.
   */
  func navigateToVirtualTourWithPlacemark(_ placemark: Placemark)
}

/// View Controller class for presenting the map of Boston to the user.
final class MapViewController: BaseViewController {
  
  // MARK: Properties
  
  /// Basic business logic for the `MapViewController`
  var model: MapModel = MapModel()
  /// The view which dominates the `MapViewController`
  var mapView: GMSMapView?
  /// Delegate for the `MapViewController`
  weak var delegate: MapViewControllerDelegate?
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initializeDelegate()
    createMapView()
    setupPlacemarks()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }
    if SegueConstants.MapToPlacemarkSegueIdentifier.rawValue.caseInsensitiveCompare(identifier) == ComparisonResult.orderedSame {
      guard let placemarkViewController = segue.destination as? PlacemarkViewController else { return }
      guard let placemark = mapView?.selectedMarker!.userData as? Placemark else { return }
      placemarkViewController.delegate = self
      placemarkViewController.popoverPresentationController?.delegate = self
      placemarkViewController.modalPresentationStyle = UIModalPresentationStyle.popover
      placemarkViewController.model!.placemark = placemark
    }
  }
  
  // MARK: Analytics
  
  override func getScreenTrackingName() -> String {
    return AnalyticsScreenNames.MapScreen.rawValue
  }
  
  // MARK: Private Functions
  
  /// Initializes the `mapView` and configures properties on it to make sure it displays correctly.
  func createMapView() {
    let lastKnownCoordinate = model.lastKnownCoordinate()
    let camera = GMSCameraPosition.camera(withLatitude: lastKnownCoordinate.latitude, longitude:lastKnownCoordinate.longitude, zoom:model.zoomForMap())
    let mapView = GMSMapView.map(withFrame: CGRect.zero, camera:camera)
    mapView.padding = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 48.0, right: 0.0)
    mapView.isIndoorEnabled = false
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
    mapView.settings.compassButton = false
    mapView.delegate = self
    self.mapView = mapView
    view = mapView
  }
  
  /// Adds all the placemarks to the `mapView`. Also responsible for mapping out the path between the placemarks.
  func setupPlacemarks() {
    let markers = model.addPlacemarksToMap(mapView!)
    model.addPathToMap(mapView!)
    // do some checking for fastlane
    snaplaneCallbacks(markers)
  }
  
  /// Ensures that the `delegate` property is set to the `AppDelegate`.
  func initializeDelegate() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    delegate = appDelegate
  }
}

// MARK: GMSMapViewDelegate Functions

/// Extensiom for all the Google Maps callbacks
extension MapViewController : GMSMapViewDelegate {
  
  /**
   Ensures that the last known coordinate is set in the app's state.
   
   - parameter mapView: the view associated with the `MapViewController`.
   - parameter position: defines where the `mapView` is positioned.
   */
  func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    if model.isViableZoom(position.zoom) {
      ApplicationSharedState.sharedInstance.cameraZoom = position.zoom
    }
    ApplicationSharedState.sharedInstance.lastKnownCoordinate = position.target
    debugPrint(position.target)
  }
  
  /**
   Ensures that the last known placemark pressed by the user is set in the app's state.
   
   - parameter mapView: the view associated with the `MapViewController`.
   - parameter marker: the `GMSMarker` the user pressed.
   - returns: always returns false as this delegate does not handle the tap event.
   */
  func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    ApplicationSharedState.sharedInstance.lastKnownPlacemarkCoordinate = marker.position
    guard let userData = marker.userData as? Placemark else { return false }
    trackButtonPressForPlacemark(userData, label: AnalyticsLabels.MarkerPress.rawValue)
    return false
  }
  
  /**
   Transitions the user over to the `VirtualTourViewController`.
   
   - parameter mapView: the view associated with the `MapViewController`.
   - parameter marker: the `GMSMarker` associated with the info window that the user just pressed.
   */
  func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
    ApplicationSharedState.sharedInstance.lastKnownPlacemarkCoordinate = marker.position
    guard let userData = marker.userData as? Placemark else { return }
    trackButtonPressForPlacemark(userData, label: AnalyticsLabels.InfoWindowPress.rawValue)
    streetViewButtonPressedForPlacemark(userData)
    // previous implementation.
    // performSegue(withIdentifier: SegueConstants.MapToPlacemarkSegueIdentifier.rawValue, sender: self)
  }
  
  /**
   Allows us to customize the marker window when the user taps on a pin in the map view.
   
   - parameter mapView: the view associated with the `MapViewController`.
   - parameter marker: the `GMSMarker` the user just tapped on.
   - returns: a view to present beside the pin the user just tapped on.
   */
  func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
    guard let userData = marker.userData as? Placemark else { return nil }
    guard let viewArray = Bundle.main.loadNibNamed(ResourceConstants.InfoWindowXibName.rawValue, owner: self, options: nil) else { return nil }
    guard let infoWindow = viewArray[0] as? InfoWindow else { return nil }
    infoWindow.header?.text = userData.name
    return infoWindow
  }
  
  /**
   Simple logging callback which logs to the console the coordinates of the current position when the user presses in the map view.
   
   - parameter mapView: the view associated with the `MapViewController`
   - parameter coordinate: the coordinate at which the user just pressed
   */
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    coordinate.logCoordinate()
  }
}

// MARK: PlacemarkViewControllerDelegate Functions

/// Extension for the `MapViewController` to take care of all the `PlacemarkViewControllerDelegate` methods.
extension MapViewController : PlacemarkViewControllerDelegate {
  
  /**
   Allows the `MapViewController` to navigate to the virtual tour.
   
   - parameter placemark: the placemark at which to land the user on the virtual tour screen
   */
  func streetViewButtonPressedForPlacemark(_ placemark: Placemark) {
    guard let delegate = delegate else { trackNonFatalErrorMessage("No delegate for allowing the user navigate to street view from a placemark view"); return }
    delegate.navigateToVirtualTourWithPlacemark(placemark)
  }
}

// MARK: UIPopoverPresentationControllerDelegate Functions

/// Extension for the `MapViewController` to ensure that the user can sucessfully close out of a `PlacemarkViewController`
extension MapViewController : UIPopoverPresentationControllerDelegate {

  /**
   Allows the `MapViewController` to navigate to the virtual tour.
   
   - parameter controller:
   - parameter style:
   */
  func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
    let selector = #selector(dismiss as (Void) -> Void)
    let doneButton = UIBarButtonItem(title:NSLocalizedString("Done", comment: ""), style:.done, target:self, action:selector)
    let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
    navigationController.topViewController!.navigationItem.leftBarButtonItem = doneButton
    return navigationController
  }
  
  /// Simply dismisses the current view controller.
  func dismiss() {
    dismiss(animated: true, completion: nil)
  }
}

extension MapViewController {
  
  func snaplaneCallbacks(_ markers:[GMSMarker]) {
    if ProcessInfo.processInfo.arguments.contains("SnapshotIdentifier") {
      if let lastArgument = ProcessInfo.processInfo.arguments.last {
        var markerName = ""
        switch lastArgument {
          case "TapOnStateHouse":
            markerName = "State House"
          break
          case "TapOnPaulRevereHouse":
            markerName = "Paul Revere House"
          break
          case "TapOnFaneuilHallMarketplace":
            markerName = "Faneuil Hall Marketplace"
          break
        default:
          break
        }
        for marker:GMSMarker in markers {
          if marker.title?.caseInsensitiveCompare(markerName) == .orderedSame {
            mapView?.selectedMarker = marker
            let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude:marker.position.longitude, zoom:model.zoomForMap())
            mapView?.camera = camera
            break
          }
        }
      }
    }
  }
}
