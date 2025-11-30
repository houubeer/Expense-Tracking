#!/bin/bash

echo "🧪 Running comprehensive test suite..."

# Run all tests with coverage
flutter test --coverage

# Check if tests passed
if [ $? -eq 0 ]; then
  echo "✅ All tests passed!"
  
  # Generate HTML coverage report (if genhtml is available)
  if command -v genhtml &> /dev/null; then
    echo "📊 Generating coverage report..."
    genhtml coverage/lcov.info -o coverage/html
    echo "📁 Coverage report generated at: coverage/html/index.html"
  else
    echo "ℹ️  Install lcov to generate HTML coverage reports: sudo apt-get install lcov"
  fi
  
  # Display coverage summary
  if command -v lcov &> /dev/null; then
    echo "📈 Coverage Summary:"
    lcov --summary coverage/lcov.info
  fi
else
  echo "❌ Tests failed!"
  exit 1
fi
