# Contributing to Boston Freedom Trail

Contributions to the development of the app are always welcome! Please follow these guidelines to ensure smooth collaboration.

## How to Contribute

- **Found a bug?** _If you can provide steps to reliably reproduce it_, open an issue.
- **Have a feature request?** Open an issue to discuss it.
- **Want to contribute code?** Submit a pull request.

See the [Issue Template](ISSUE_TEMPLATE.md) for helpful tips on what information is useful for getting quick issue resolution.

## Pull Request Guidelines

GitHub has published [How to write the perfect pull request](https://github.com/blog/1943-how-to-write-the-perfect-pull-request). While it's not necessary to follow every suggestion, it provides excellent guidance on creating quality pull requests.

### Before Submitting a PR

1. **Run Tests**: Ensure all tests pass locally
   ```bash
   bundle exec fastlane test
   ```

2. **Check Code Coverage**: Verify coverage meets minimum standards
   ```bash
   bundle exec fastlane coverage
   ```

3. **Run SwiftLint**: Fix any linting violations
   ```bash
   swiftlint
   # Auto-fix where possible
   swiftlint --fix
   ```

4. **Commit Standards**: Follow conventional commit messages
   - Use descriptive commit messages
   - Reference related issues (e.g., "Fixes #123")

### Code Quality Standards

#### Testing Requirements

- **New Features**: Must include unit tests with ≥80% coverage
- **Bug Fixes**: Should include regression tests
- **All Code**: Should maintain or improve overall project coverage (currently 84.22%, target 90%+)

Coverage targets by component:
- Models: 100%
- ViewControllers: 80%+
- Utilities: 90%+
- Views: 80%+

See [TESTING.md](../TESTING.md) for detailed testing guidelines.

#### Code Style

- Follow Swift API Design Guidelines
- Use SwiftLint for style consistency (pre-commit hook will check)
- Use meaningful variable and function names
- Document public APIs and complex logic

#### Swift 6 Compatibility

- Code must compile with Swift 6 strict concurrency checking
- Properly annotate main actor isolation
- Use `@MainActor` for UI-related code
- Handle concurrency safely

### Development Workflow

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Make** your changes
4. **Write** tests for your changes
5. **Run** tests and ensure they pass
6. **Commit** your changes (`git commit -m 'Add amazing feature'`)
7. **Push** to your fork (`git push origin feature/amazing-feature`)
8. **Open** a Pull Request

### PR Review Process

All pull requests will be reviewed for:
- ✅ All tests passing
- ✅ Code coverage maintained or improved
- ✅ No SwiftLint violations
- ✅ Swift 6 concurrency compliance
- ✅ Code quality and style
- ✅ Appropriate documentation

CI will automatically:
- Run all tests
- Generate coverage reports
- Check SwiftLint compliance
- Verify Swift 6 compilation

### Getting Help

If you need help:
- Check [TESTING.md](../TESTING.md) for testing guidance
- Check [README.md](../README.md) for setup instructions
- Open an issue with questions
- Join the discussion in existing issues/PRs

## Code of Conduct

There's a simple well-intentioned [Code of Conduct](http://contributor-covenant.org/version/1/2/0/code_of_conduct.txt) for our community. Please be respectful and professional in all interactions.
