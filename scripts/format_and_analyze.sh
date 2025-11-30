#!/bin/bash

echo "🎨 Formatting Dart code..."

# Format all Dart files
dart format lib/ test/ integration_test/ --line-length 80 --set-exit-if-changed

if [ $? -eq 0 ]; then
  echo "✅ Code is properly formatted"
else
  echo "⚠️  Code formatting issues found. Run 'dart format lib/ test/ integration_test/' to fix"
  exit 1
fi

echo "🔍 Running static analysis..."

# Run analyzer with strict settings
dart analyze --fatal-infos --fatal-warnings

if [ $? -eq 0 ]; then
  echo "✅ No analysis issues found"
else
  echo "❌ Analysis issues found. Please fix before committing"
  exit 1
fi

echo "✨ All checks passed!"
