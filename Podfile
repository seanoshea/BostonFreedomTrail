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
    pod 'OHHTTPStubs'
  end

end

# Post-install hook to ensure all pods use minimum deployment target
# This ensures consistency with the main project target and avoids libarclite errors
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Set minimum deployment target to 18.0 for all pods
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 18.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.0'
      end
    end
  end
end
