#!/bin/bash

# Script to filter out generated files from coverage report
# Removes .freezed.dart and .g.dart files from lcov.info

set -e

COVERAGE_DIR="${1:-.}"

if [ ! -f "$COVERAGE_DIR/lcov.info" ]; then
  echo "Error: lcov.info not found in $COVERAGE_DIR"
  exit 1
fi

# Create backup
cp "$COVERAGE_DIR/lcov.info" "$COVERAGE_DIR/lcov.info.bak"

# Remove coverage records for generated files
lcov --remove "$COVERAGE_DIR/lcov.info" \
  '*/**.freezed.dart' \
  '*/**.g.dart' \
  -o "$COVERAGE_DIR/lcov.info"

echo "Coverage report filtered. Generated files (.freezed.dart and .g.dart) excluded."
