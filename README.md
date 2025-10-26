# Boston Freedom Trail

> A comprehensive iOS application for exploring Boston's historic Freedom Trail with interactive maps, GPS navigation, and rich historical content.

[![CI](https://github.com/seanoshea/BostonFreedomTrail/actions/workflows/ci.yml/badge.svg)](https://github.com/seanoshea/BostonFreedomTrail/actions/workflows/ci.yml)
[![PRs Welcome](https://img.shields.io/badge/prs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
[![License](http://img.shields.io/badge/license-BSD-green.svg?style=flat)](https://github.com/seanoshea/BostonFreedomTrail/blob/master/LICENSE)
[![Swift Version](https://img.shields.io/badge/swift-6.0-orange.svg)](https://swift.org/)
[![iOS Version](https://img.shields.io/badge/iOS-18.0+-blue.svg)](https://developer.apple.com/ios/)
[![Languages](https://img.shields.io/github/languages/count/seanoshea/BostonFreedomTrail)](https://img.shields.io/github/languages/count/seanoshea/BostonFreedomTrail)
[![Top Language](https://img.shields.io/github/languages/top/seanoshea/BostonFreedomTrail)](https://img.shields.io/github/languages/top/seanoshea/BostonFreedomTrail)
[![Open Issues](https://img.shields.io/github/issues/seanoshea/BostonFreedomTrail)](https://img.shields.io/github/issues/seanoshea/BostonFreedomTrail)
[![Closed Issues](https://img.shields.io/github/issues-closed/seanoshea/BostonFreedomTrail)](https://img.shields.io/github/issues-closed/seanoshea/BostonFreedomTrail)
[![Twitter: @seanoshea](https://img.shields.io/badge/contact-@seanoshea-blue.svg?style=flat)](https://twitter.com/seanoshea)

## Overview

The Boston Freedom Trail app transforms your iPhone or iPad into an interactive guide for one of America's most important historical walking tours. Follow the red-brick path through downtown Boston and discover 16 historically significant sites that tell the story of the American Revolution.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/seanoshea/BostonFreedomTrail.git
cd BostonFreedomTrail

# Install dependencies
bundle install
pod install

# Set up API keys (see DEVELOPMENT.md for details)
cp .env.example .env
# Edit .env with your API keys

# Inject API keys and run
bundle exec fastlane setup
open BostonFreedomTrail.xcworkspace
```

## Features

### Core Functionality
- 📍 **Interactive Map** - Explore all 16 Freedom Trail locations with custom markers and the iconic red-brick path overlay
- 🔍 **Historical Details** - Rich HTML content for each site with historical context, significance, and imagery
- 🗺️ **GPS Navigation** - Real-time location tracking to guide you along the 2.5-mile trail through downtown Boston
- 👁️ **Virtual Tour** - Immersive Google Street View integration with guided camera positioning for optimal viewing

### Technical Features
- 📱 **Native iOS** - Built with Swift 6.0, optimized for iPhone and iPad running iOS 18.0+
- 🏛️ **Offline Support** - Trail data and historical content available without internet connection
- 🎯 **Location Awareness** - Automatic positioning and zoom level restoration based on user's last interaction
- 📊 **Analytics Integration** - Firebase Analytics for usage tracking and app improvement insights
- 🔒 **Security First** - API key protection, automated security scanning, and secure build processes

## For Developers

Interested in contributing or running the project locally? Check out our [Development Guide](DEVELOPMENT.md) for detailed setup instructions including API key configuration and security requirements.

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](.github/CONTRIBUTING.md) and [Development Guide](DEVELOPMENT.md) to get started.

## Beta Builds

If you're interested in access to beta-builds of the application, send an email to oshea.ie@gmail.com

## License

See [LICENSE](LICENSE) for details.
