platform :ios, '18.0'

project 'BostonFreedomTrail.xcodeproj'

target :BostonFreedomTrail do
  inhibit_all_warnings!
  use_frameworks!

  # Analytics - Migrated from deprecated GoogleAnalytics to Firebase
  pod 'FirebaseAnalytics'

  # Networking & Location
  pod 'ReachabilitySwift'

  # Maps
  pod 'GoogleMaps'

  # UI Components
  pod 'MaterialComponents/Typography'
  pod 'MaterialComponents/Buttons'
  pod 'MaterialComponents/Snackbar'

  target :BostonFreedomTrailTests do
    pod 'Quick'
    pod 'Nimble'
    pod 'OHHTTPStubs'
  end

end
