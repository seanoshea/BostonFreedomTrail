# Contributing

Contributions to Boston Freedom Trail are welcome! Please follow these guidelines:

## Getting Started
- Review the [README](../README.md) for development setup requirements
- Ensure you have Ruby 3.4.7+, iOS 18.0+, and Xcode 16.0+
- **MANDATORY**: Run `./scripts/install-git-hooks.sh` to install git hooks
- Set up API keys following the [Development Guide](../DEVELOPMENT.md)

## Reporting Issues
- **Bug reports**: Provide steps to reproduce reliably
- **Feature requests**: Describe the use case and expected behavior
- Use the [Issue Template](ISSUE_TEMPLATE.md) for guidance

## Pull Requests
- Include unit tests for new features
- Follow existing code style
- Reference related issues in your PR description
- Run `bundle exec fastlane test` before submitting
- Ensure API keys are not exposed (placeholders only in committed files)

## Security Requirements

- Never commit real API keys to the repository
- Use placeholder values in plist files (protected by git hooks)
- Test with your own API keys in `.env` file (gitignored)
- Verify `bundle exec fastlane cleanup` resets keys to placeholders

## Code of Conduct

There's a simple well-intentioned [Code of Conduct](http://contributor-covenant.org/version/1/2/0/code_of_conduct.txt) for our community. Please be respectful and professional in all interactions.
