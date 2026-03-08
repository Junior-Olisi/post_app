#!/bin/bash

# Convenience script to run tests with coverage and automatically filter generated files

set -e

echo "🧪 Running Flutter tests with coverage..."
flutter test --coverage

echo ""
echo "📊 Filtering generated files from coverage report..."
dart coverage_helper.dart coverage/

echo ""
echo "✅ Done! Coverage report is ready."
echo ""
echo "Generated files excluded from coverage:"
echo "  - *.freezed.dart (from freezed package)"
echo "  - *.g.dart (from json_serializable)"
echo ""
echo "View coverage report:"
echo "  - lcov.info location: coverage/lcov.info"
echo "  - Backup location: coverage/lcov.info.bak"
