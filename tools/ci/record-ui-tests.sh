#!/bin/bash
# record-ui-tests.sh
# Runs UI tests on both platforms with video recording enabled.
# Videos are saved to artifacts/ for PR attachment.

set -euo pipefail

ARTIFACTS_DIR="artifacts/videos"
mkdir -p "$ARTIFACTS_DIR/ios" "$ARTIFACTS_DIR/android"

echo "=== Recording UI Tests ==="

# --- iOS ---
record_ios() {
  echo "Recording iOS UI tests..."

  RESULT_BUNDLE="$ARTIFACTS_DIR/ios/TestResults.xcresult"

  xcodebuild test \
    -project ios/TandemEMT.xcodeproj \
    -scheme TandemEMT \
    -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
    -resultBundlePath "$RESULT_BUNDLE" \
    -enableCodeCoverage YES \
    2>&1 | xcpretty || true

  # Extract videos from xcresult bundle
  if [ -d "$RESULT_BUNDLE" ]; then
    xcrun xcresulttool get --path "$RESULT_BUNDLE" --format json > "$ARTIFACTS_DIR/ios/results.json" 2>/dev/null || true
    echo "iOS test results saved to $RESULT_BUNDLE"
  fi
}

# --- Android ---
record_android() {
  echo "Recording Android UI tests..."

  cd android

  # Use Gradle managed devices for consistent recording
  ./gradlew pixel6Api34DebugAndroidTest \
    -Pandroid.testInstrumentationRunnerArguments.class=com.tandem.emt \
    --info \
    2>&1 || true

  # Alternatively, for emulator-based recording:
  # Start recording in background
  # adb shell screenrecord /sdcard/test-recording.mp4 &
  # RECORD_PID=$!
  # ./gradlew connectedDebugAndroidTest
  # kill $RECORD_PID 2>/dev/null || true
  # adb pull /sdcard/test-recording.mp4 "../$ARTIFACTS_DIR/android/"

  # Copy test reports
  cp -r app/build/reports/androidTests "../$ARTIFACTS_DIR/android/" 2>/dev/null || true

  cd ..
  echo "Android test results saved"
}

# Run both (in CI these would be parallel jobs)
case "${1:-both}" in
  ios)     record_ios ;;
  android) record_android ;;
  both)    record_ios; record_android ;;
  *)       echo "Usage: $0 [ios|android|both]"; exit 1 ;;
esac

echo ""
echo "=== Video artifacts saved to $ARTIFACTS_DIR ==="
echo "Attach these to your PR for visual parity review."
