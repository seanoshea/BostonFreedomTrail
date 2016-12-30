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
import CoreLocation
import Fabric
import Crashlytics
import MaterialComponents

/// Simple enum to keep track of the different tabs in the app.
enum TabBarControllerIndices: Int {
    case mapViewController = 0
    case virtualTourViewController = 1
    case aboutViewController = 2
}

/// Main entry point for the app.
@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    /// Main window for the app.
    var window: UIWindow?

// MARK: Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.initializeCrashReporting()
        self.initializeGoogleMapsApi()
        self.initializeStyling()
        self.initializeAnalytics()
        self.initializeLocalization()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        LocationTracker.sharedInstance.startUpdatingLocation()
    }
    
// MARK: Private Functions
    
    /// Crash reporting is used in `Release` builds of the app to ensure that all crashes in the live versions of the app are reported and can be analyzed for solutions.
    func initializeCrashReporting() {
        // only bother with crash reporting for release builds
        guard !ApplicationSharedState.sharedInstance.isDebug() else { return }
        Fabric.with([Crashlytics.self])
    }
    
    /// Sets up the Google Maps integration. See `GoogleService-Info.plist` for more details.
    func initializeGoogleMapsApi() {
        GMSServices.provideAPIKey(PListHelper.googleMapsApiKey())
    }

    /// Sets up all generic styling in the app.
    func initializeStyling() {
      UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName : MDCTypography.captionFont()], for: UIControlState.normal)
    }
    
    /// The app uses Google Analytics for tracking usage of the app. Only enabled for `Release` builds.
    func initializeAnalytics() {
        // only bother with analytics for prod builds
        guard !ApplicationSharedState.sharedInstance.isDebug() else { return }
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        guard configureError == nil else {
            NSLog("Error configuring Google services: \(configureError)")
            return
        }
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true
    }

    /// Ensures that the titles on the tabs at the bottom of the app are fully localized.
    func initializeLocalization() {
        guard let window = self.window else { return }
        guard let tabBarController = window.rootViewController as? UITabBarController else { return }
        for (index, item) in (tabBarController.tabBar.items?.enumerated())! {
            var title = ""
            switch index {
            case TabBarControllerIndices.mapViewController.rawValue:
                title = NSLocalizedString("Map", comment: "")
                break
            case TabBarControllerIndices.virtualTourViewController.rawValue:
                title = NSLocalizedString("Virtual Tour", comment: "")
                break
            case TabBarControllerIndices.aboutViewController.rawValue:
                title = NSLocalizedString("About", comment: "")
                break
            default:
                NSLog("Add a new index to TabBarControllerIndices for this new controller")
            }
            item.title = title
        }
    }
}

/// Allows a `PlacemarkViewController` to tell the delegate to navigate to the virtual tour section of the app.
extension AppDelegate : MapViewControllerDelegate {
    /**
     Executed when navigating to the virtual tour screen.
     - parameter placemark: The `Placemark` to land on after switching to the virtual tour.
     */
    func navigateToVirtualTourWithPlacemark(_ placemark: Placemark) {
        guard let window = self.window else { return }
        guard let tabBarController = window.rootViewController as? UITabBarController else { return }
        guard let viewControllers = tabBarController.viewControllers else { return }
        guard let virtualTourViewController = viewControllers[TabBarControllerIndices.virtualTourViewController.rawValue] as? VirtualTourViewController else { return }
        tabBarController.selectedIndex = TabBarControllerIndices.virtualTourViewController.rawValue
        let index = Trail.instance.placemarkIndex(placemark)
        virtualTourViewController.model.navigateToLookAt(index)
    }
}
