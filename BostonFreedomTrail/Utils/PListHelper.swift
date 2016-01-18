//
//  PListHelper.swift
//  BostonFreedomTrail
//
//  Created by Sean O'Shea on 1/18/16.
//  Copyright © 2016 UpwardsNorthwards. All rights reserved.
//

import Foundation

enum PListHelperConstants : String {
    case BostonFreedomTrailGoogleMapAPIKey = "BostonFreedomTrailGoogleMapAPIKey"
    case BostonFreedomTrailDefaultLatitude = "BostonFreedomTrailDefaultLatitude"
    case BostonFreedomTrailDefaultLongitude = "BostonFreedomTrailDefaultLongitude"
    case BostonFreedomTrailDefaultCameraZoom = "BostonFreedomTrailDefaultCameraZoom"
}

class PListHelper {
    
    static func googleMapsApiKey() -> String {
        return (self.plistDictionary()[PListHelperConstants.BostonFreedomTrailGoogleMapAPIKey.rawValue] as? String)!
    }
    
    static func defaultLatitude() -> Double {
        return self.plistDictionary()[PListHelperConstants.BostonFreedomTrailDefaultLatitude.rawValue]!.doubleValue
    }

    static func defaultLongitude() -> Double {
        return self.plistDictionary()[PListHelperConstants.BostonFreedomTrailDefaultLongitude.rawValue]!.doubleValue
    }
    
    static func defaultCameraZoom() -> Float {
        return self.plistDictionary()[PListHelperConstants.BostonFreedomTrailDefaultCameraZoom.rawValue]!.floatValue
    }
    
    static func plistDictionary() -> [String: AnyObject] {
        let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!) as? [String: AnyObject]
        return dict!
    }
}