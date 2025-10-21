#!/bin/bash
#
# Install git hooks for the BostonFreedomTrail project
#

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

echo "📦 Installing git hooks..."

# Check if .git directory exists
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    echo "❌ Error: .git directory not found. Are you in a git repository?"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Install pre-commit hook
cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/bin/bash
#
# Pre-commit hook to run SwiftLint on staged Swift files
#

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "⚠️  SwiftLint is not installed. Install it with: brew install swiftlint"
    echo "⚠️  Skipping SwiftLint checks..."
    exit 0
fi

# Get list of staged Swift files
SWIFT_FILES=$(git diff --cached --name-only --diff-filter=d | grep -E '\.swift$')

if [ -z "$SWIFT_FILES" ]; then
    # No Swift files to lint
    exit 0
fi

echo "🔍 Running SwiftLint on staged files..."

# Run SwiftLint on staged files
LINT_ERRORS=0
for file in $SWIFT_FILES; do
    swiftlint lint --strict "$file"
    if [ $? -ne 0 ]; then
        LINT_ERRORS=1
    fi
done

if [ $LINT_ERRORS -ne 0 ]; then
    echo ""
    echo "❌ SwiftLint found violations. Please fix them before committing."
    echo "💡 You can run 'swiftlint --fix' to auto-fix some issues."
    echo "💡 Or use 'git commit --no-verify' to skip this check (not recommended)."
    exit 1
fi

echo "✅ SwiftLint passed!"

# Protect API keys from being committed
echo "🔒 Protecting API keys..."
plutil -replace API_KEY -string "FIREBASE_API_KEY_PLACEHOLDER" "BostonFreedomTrail/GoogleService-Info.plist" 2>/dev/null || true
plutil -replace GoogleMapsAPIKey -string "GOOGLE_MAPS_API_KEY_PLACEHOLDER" "BostonFreedomTrail/Resources/APIKeys.plist" 2>/dev/null || true

# Stage the protected files
git add BostonFreedomTrail/GoogleService-Info.plist BostonFreedomTrail/Resources/APIKeys.plist 2>/dev/null || true

echo "🔒 API keys protected!"
exit 0
EOF

# Make pre-commit hook executable
chmod +x "$HOOKS_DIR/pre-commit"

echo "✅ Git hooks installed successfully!"
echo ""
echo "📝 Installed hooks:"
echo "  - pre-commit: Runs SwiftLint on staged Swift files"
echo "  - pre-commit: Protects API keys from being committed"
echo ""
echo "💡 To bypass hooks temporarily, use: git commit --no-verify"
