# Testing Guide

This document provides information about running tests and viewing code coverage for the Boston Freedom Trail iOS app.

## Overview

The project uses:
- **Swift Testing** framework for unit tests
- **XCTest** for test execution
- **xcov** for coverage report generation
- **Codecov** for CI coverage tracking

**Current Coverage: 84.22%** (target: 90%+)

## Running Tests

### Using Xcode

1. Open `BostonFreedomTrail.xcworkspace`
2. Press `⌘ + U` to run all tests
3. View results in the Test Navigator (`⌘ + 6`)

### Using Command Line

```bash
# Run all tests
xcodebuild test -workspace BostonFreedomTrail.xcworkspace \
  -scheme BostonFreedomTrail \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Run specific test suite
xcodebuild test -workspace BostonFreedomTrail.xcworkspace \
  -scheme BostonFreedomTrail \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:BostonFreedomTrailTests/MapModelTests

# Run specific test
xcodebuild test -workspace BostonFreedomTrail.xcworkspace \
  -scheme BostonFreedomTrail \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:BostonFreedomTrailTests/MapModelTests/addsPlacemarksToMap
```

### Using Fastlane

```bash
# Run tests with coverage
bundle exec fastlane test

# Generate coverage report
bundle exec fastlane coverage
```

## Code Coverage

### Viewing Coverage Locally

#### Option 1: Xcode Built-in Coverage

1. Enable code coverage: `Product > Scheme > Edit Scheme > Test > Options > Code Coverage`
2. Run tests (`⌘ + U`)
3. View coverage: `View > Navigators > Reports`
4. Select the latest test run and click "Coverage"

#### Option 2: Command Line with xcov

```bash
# Run tests with coverage enabled
xcodebuild test -workspace BostonFreedomTrail.xcworkspace \
  -scheme BostonFreedomTrail \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -enableCodeCoverage YES \
  -resultBundlePath ./TestResults.xcresult

# View text coverage report
xcrun xccov view --report ./TestResults.xcresult

# Generate HTML coverage report
bundle exec fastlane coverage
open xcov_output/index.html
```

#### Option 3: Using xcov Directly

```bash
# Generate detailed HTML report
bundle exec xcov --scheme BostonFreedomTrail \
  --workspace BostonFreedomTrail.xcworkspace \
  --output_directory coverage_html \
  --html_report

# Open the report
open coverage_html/index.html
```

### Coverage Reports on CI

Every pull request and push to `develop`/`main` automatically:
1. Runs all tests with coverage enabled
2. Generates coverage reports
3. Uploads to Codecov
4. Comments on PR with coverage diff (if applicable)

View coverage reports:
- **Codecov Dashboard**: https://codecov.io/gh/seanoshea/BostonFreedomTrail
- **CI Artifacts**: Available in GitHub Actions run artifacts

### Understanding Coverage Metrics

Coverage reports show:
- **Line Coverage**: Percentage of code lines executed during tests
- **Function Coverage**: Percentage of functions called during tests
- **Branch Coverage**: Percentage of conditional branches tested

Example coverage output:
```
BostonFreedomTrail.app                                    84.22% (870/1033)
    MapModel.swift                                       100.00% (44/44)
    VirtualTourViewController.swift                       53.42% (78/146)
    PlacemarkModel.swift                                 100.00% (9/9)
```

## Writing Tests

### Test Structure

Tests use the Swift Testing framework with the following structure:

```swift
import Testing
@testable import BostonFreedomTrail

@Suite("ComponentName")
@MainActor // If testing UI components
struct ComponentNameTests {

  @Test("Test description")
  func testMethodName() async {
    // Arrange
    let subject = ComponentUnderTest()

    // Act
    let result = subject.methodToTest()

    // Assert
    #expect(result == expectedValue)
  }
}
```

### Testing Best Practices

1. **Test Names**: Use descriptive names that explain what is being tested
   - Good: `"Returns empty string when placemark is nil"`
   - Bad: `"testStringForWebView"`

2. **Arrange-Act-Assert**: Structure tests clearly
   ```swift
   // Arrange - Set up test data
   let model = PlacemarkModel()

   // Act - Perform the action
   let result = model.stringForWebView()

   // Assert - Verify the result
   #expect(result == "")
   ```

3. **Test One Thing**: Each test should verify one behavior
   - Good: Separate tests for different scenarios
   - Bad: One test checking multiple unrelated things

4. **Use Test Isolation**: Clean up state between tests
   ```swift
   @Test("Test name", .serialized) // Run tests sequentially if needed
   func testWithCleanup() async {
     ApplicationSharedState.sharedInstance.clear() // Clean state
     // ... test code
   }
   ```

5. **Mock External Dependencies**: Don't rely on network, file system, etc.

### Coverage Goals

| Component Type | Minimum Coverage |
|---------------|------------------|
| Models | 100% |
| ViewControllers | 80%+ |
| Utilities | 90%+ |
| Views | 80%+ |
| Overall Project | 85%+ |

### Files Needing Coverage Improvement

Current files below target:

1. **PlacemarkModel.swift**: 0% → Target: 100% ✅ **DONE**
2. **VirtualTourViewController.swift**: 53.42% → Target: 85%
3. **ReachabilityListener.swift**: 48.78% → Target: 85%
4. **Extensions.swift**: 50% → Target: 80%
5. **MapViewController.swift**: 70.11% → Target: 90%

## Troubleshooting

### Tests Failing Locally But Passing on CI

- Ensure you're using the same Xcode version as CI (check `.github/workflows/ci.yml`)
- Clean build folder: `Product > Clean Build Folder` (`⌘ + Shift + K`)
- Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`

### Coverage Report Not Generated

- Ensure code coverage is enabled in the scheme
- Check that tests actually ran (not skipped)
- Verify xcov is installed: `bundle exec xcov --version`

### Simulator Not Found

```bash
# List available simulators
xcrun simctl list devices available | grep iPhone

# Use an available simulator
xcodebuild test ... -destination 'platform=iOS Simulator,name=<available-simulator>'
```

## Resources

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [XCTest Framework](https://developer.apple.com/documentation/xctest)
- [xcov Documentation](https://github.com/fastlane-community/xcov)
- [Codecov Documentation](https://docs.codecov.com/)

## Contributing

When contributing code:
1. Write tests for new functionality
2. Ensure all tests pass locally before submitting PR
3. Aim for 80%+ coverage on new code
4. Run `bundle exec fastlane test` before pushing
5. Check CI results and address any failures

For more details, see [CONTRIBUTING.md](.github/CONTRIBUTING.md).
