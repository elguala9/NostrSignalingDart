#!/bin/bash

# Script di test runner per nostr_signaling_test

set -e

echo "================================================"
echo "Nostr Signaling - Test Suite Runner"
echo "================================================"
echo ""

# Get dependencies
echo "📦 Fetching dependencies..."
dart pub get
echo "✅ Dependencies fetched"
echo ""

# Run tests
echo "🧪 Running tests..."
dart test --coverage=coverage
echo "✅ Tests completed"
echo ""

# Format coverage if available
if command -v coverage &> /dev/null; then
    echo "📊 Formatting coverage report..."
    dart pub global activate coverage
    dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
    echo "✅ Coverage report generated"
else
    echo "⚠️  Coverage tool not available, skipping coverage report"
fi

echo ""
echo "================================================"
echo "✅ All tests completed!"
echo "================================================"
