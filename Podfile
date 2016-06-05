platform :ios, '9.0'

project 'BostonFreedomTrail.xcodeproj'

target :BostonFreedomTrail do
  inhibit_all_warnings!
  use_frameworks!

  pod 'Google/Analytics'
  pod 'GoogleMaps', '1.13.2'
  pod 'ReachabilitySwift', :git => 'https://github.com/ashleymills/Reachability.swift'
  pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'

  target :BostonFreedomTrailTests do
    inherit! :search_paths
    pod 'Quick', '~> 0.9.2'
    pod 'Nimble', '~> 4.0.1'
    pod 'OHHTTPStubs', '~> 5.0.0'
  end

end
