# Boston Freedom Trail

iOS Application for walking the Boston Freedom Trail.

[![CI](https://github.com/seanoshea/BostonFreedomTrail/actions/workflows/ci.yml/badge.svg)](https://github.com/seanoshea/BostonFreedomTrail/actions/workflows/ci.yml)
[![Code Coverage](http://codecov.io/github/seanoshea/BostonFreedomTrail/coverage.svg?branch=develop)](http://codecov.io/github/seanoshea/BostonFreedomTrail?branch=develop)
[![PRs Welcome](https://img.shields.io/badge/prs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
[![License](http://img.shields.io/badge/license-BSD-green.svg?style=flat)](https://github.com/seanoshea/BostonFreedomTrail/blob/master/LICENSE)
[![Languages](https://img.shields.io/github/languages/count/seanoshea/BostonFreedomTrail)](https://img.shields.io/github/languages/count/seanoshea/BostonFreedomTrail)
[![Top Language](https://img.shields.io/github/languages/top/seanoshea/BostonFreedomTrail)](https://img.shields.io/github/languages/top/seanoshea/BostonFreedomTrail)
[![Open Issues](https://img.shields.io/github/issues/seanoshea/BostonFreedomTrail)](https://img.shields.io/github/issues/seanoshea/BostonFreedomTrail)
[![Closed Issues](https://img.shields.io/github/issues-closed/seanoshea/BostonFreedomTrail)](https://img.shields.io/github/issues-closed/seanoshea/BostonFreedomTrail)
[![Twitter: @seanoshea](https://img.shields.io/badge/contact-@seanoshea-blue.svg?style=flat)](https://twitter.com/seanoshea)

## Requirements

- **iOS:** 18.0+
- **Xcode:** 16.0+
- **Swift:** 6.0
- **Ruby:** 3.4.7
- **CocoaPods:** 1.16.2+

## Setup

### 1. Install Ruby Dependencies
```bash
bundle install
```

### 2. Install CocoaPods Dependencies
```bash
bundle exec pod install
```

### 3. Configure Firebase
- Create a Firebase project at [https://console.firebase.google.com](https://console.firebase.google.com)
- Download `GoogleService-Info.plist` and replace the placeholder in `BostonFreedomTrail/`
- Add the file to the Xcode project

### 4. Configure Google Maps
- Obtain a Google Maps API key
- Update `Info.plist` with your API key under `GMSApiKey`

### 5. Open Workspace
```bash
open BostonFreedomTrail.xcworkspace
```

## Development

### Running Tests
```bash
bundle exec fastlane test
```

### SwiftLint
```bash
swiftlint
```

### Generating Documentation
Documentation is generated using [Jazzy](https://github.com/realm/jazzy):
```bash
./generate_docs.sh
```

## Deployment

### TestFlight (Beta)
```bash
bundle exec fastlane beta
```

### App Store
```bash
bundle exec fastlane release
```

## Gitflow Workflow

This project follows the Gitflow branching model:

- `main` - Production releases only
- `develop` - Active development branch
- `feature/*` - New features
- `release/*` - Release preparation
- `hotfix/*` - Production hotfixes

## Contributing

See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for details on submitting pull requests.

## Beta Builds

If you're interested in access to beta-builds of the application, send an email to oshea.ie@gmail.com

## License

See [LICENSE](LICENSE) for details.
