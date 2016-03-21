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
import ReachabilitySwift

enum TabBarControllerIndices : Int {
    case MapViewController = 0
    case VirtualTourViewController = 1
    case AboutViewController = 2
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reachability: Reachability?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.initializeCrashReporting()
        self.initializeGoogleMapsApi()
        self.initializeStyling()
        self.initializeReachability()
        self.initializeLocalization()
        self.initializeAnalytics()
        self.initializeDelegates()
        return true
    }
    
    func isOnline() -> Bool {
        var isOnline = false
        if let unwrappedReachability = self.reachability {
            isOnline = unwrappedReachability.isReachable()
        }
        return isOnline
    }
    
    func initializeGoogleMapsApi() {
        GMSServices.provideAPIKey(PListHelper.googleMapsApiKey())
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        LocationTracker.sharedInstance.startUpdatingLocation()
    }
    
    func initializeStyling() {
        
    }
    
    func initializeReachability() {
        do {
            self.reachability = try Reachability.reachabilityForInternetConnection()
            do {
                try self.reachability!.startNotifier()
            } catch {
                NSLog("Failed to start the reachability notifier")
            }
        } catch {
            NSLog("Failed to start Reachability")
        }
    }
    
    func initializeLocalization() {
        
    }
    
    func initializeAnalytics() {
        
    }
    
    func initializeCrashReporting() {
        Fabric.with([Crashlytics.self])
    }
    
    func initializeDelegates() {
        let tabBarController:UITabBarController = self.window!.rootViewController as! UITabBarController
        let mapViewController = tabBarController.viewControllers![TabBarControllerIndices.MapViewController.rawValue] as! MapViewController
        mapViewController.delegate = self
    }
}

extension AppDelegate : MapViewControllerDelegate {
    
    func navigateToVirtualTourWithPlacemark(placemark: Placemark) {
        
    }
}
