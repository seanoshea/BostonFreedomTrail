# Development Guide

This guide covers everything you need to know to develop, build, and deploy Boston Freedom Trail.

## Prerequisites

- **Ruby**: 3.4.7 or later
- **iOS**: 18.0 or later
- **Xcode**: 16.0 or later
- **CocoaPods**: Latest version

## Initial Setup

1. Clone the repository
2. Install Ruby dependencies: `bundle install`
3. Install iOS dependencies: `pod install`
4. **MANDATORY**: Run `./scripts/install-git-hooks.sh` to install git hooks
5. Set up API keys (see below)
6. Open `BostonFreedomTrail.xcworkspace` in Xcode

## API Key Configuration

### Google Maps API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a project or select existing one
3. Enable Maps SDK for iOS
4. Create API key and restrict to iOS apps
5. Add your bundle ID: `com.upwardsnorthwards.BostonFreedomTrail`

### Firebase API Key
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a project or select existing one
3. Add iOS app with bundle ID: `com.upwardsnorthwards.BostonFreedomTrail`
4. Download `GoogleService-Info.plist` and extract the `API_KEY` value

### Environment Variables Setup

Create a `.env` file in the project root:

```bash
# API Keys
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
FIREBASE_API_KEY=your_firebase_api_key_here
```

## Building and Testing

### Run Tests
```bash
bundle exec fastlane test
```

### Build for Development
```bash
bundle exec fastlane build
```

### Deploy to TestFlight
```bash
bundle exec fastlane beta
```

### Deploy to App Store
```bash
bundle exec fastlane release
```

### Reset API Keys (if needed)
```bash
bundle exec fastlane cleanup
```

## Security Notes

- API keys are automatically injected at build time using `plutil`
- Real keys are never committed to git (protected by pre-commit hooks)
- The `.env` file is gitignored - never commit it
- Placeholder values in plist files get replaced during builds

## Contributing

Before contributing, please:

1. Read [CONTRIBUTING.md](.github/CONTRIBUTING.md)
2. Ensure git hooks are installed: `./scripts/install-git-hooks.sh`
3. Run tests: `bundle exec fastlane test`
4. Follow existing code style and patterns

## Troubleshooting

### "API key not found" errors
- Verify your `.env` file exists and contains the correct keys
- Run `bundle exec fastlane cleanup` then rebuild

### Build failures
- Ensure all dependencies are installed: `bundle install && pod install`
- Check that Xcode version meets requirements (16.0+)

### Git hook issues
- Re-run `./scripts/install-git-hooks.sh` if hooks aren't working
- Verify hooks are executable: `ls -la .git/hooks/`