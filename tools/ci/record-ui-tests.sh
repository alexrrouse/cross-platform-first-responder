#!/bin/bash
# record-ui-tests.sh
# Runs UI tests on both platforms with video recording.
# Saves mp4 files to artifacts/videos/ for PR attachment.
#
# Usage: ./tools/ci/record-ui-tests.sh [ios|android|both]
#
# Prerequisites:
#   iOS:     Xcode + iOS Simulator
#   Android: Android Studio JDK, Android SDK, running emulator
#            (start with: $ANDROID_HOME/emulator/emulator -avd <avd_name> &)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ARTIFACTS_DIR="$REPO_ROOT/artifacts/videos"
mkdir -p "$ARTIFACTS_DIR/ios" "$ARTIFACTS_DIR/android"

# --- Environment ---

setup_android_env() {
  export JAVA_HOME="${JAVA_HOME:-/Applications/Android Studio.app/Contents/jbr/Contents/Home}"
  export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
  export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
}

# --- iOS ---

record_ios() {
  echo "=== iOS: Recording UI tests ==="
  cd "$REPO_ROOT"

  local video_file="$ARTIFACTS_DIR/ios/ui-test-recording.mp4"

  # Pick first available iPhone simulator
  local sim_name
  sim_name=$(xcrun simctl list devices available | grep -m1 'iPhone' | sed 's/ (.*//' | xargs)
  echo "Using simulator: $sim_name"

  # Boot the simulator if needed
  local sim_udid
  sim_udid=$(xcrun simctl list devices available | grep "$sim_name" | head -1 | grep -oE '[0-9A-F-]{36}')
  xcrun simctl boot "$sim_udid" 2>/dev/null || true

  # Start screen recording in background
  echo "Starting screen recording..."
  rm -f "$video_file"
  xcrun simctl io "$sim_udid" recordVideo --codec h264 "$video_file" &
  local record_pid=$!
  sleep 1

  # Run UI tests (disable parallel testing so all tests run on the recorded simulator)
  echo "Running UI tests..."
  xcodebuild test \
    -project ios/TandemEMT.xcodeproj \
    -scheme TandemEMT \
    -destination "platform=iOS Simulator,id=$sim_udid" \
    -only-testing:TandemEMTUITests \
    -disable-concurrent-destination-testing \
    -parallel-testing-enabled NO \
    2>&1 | grep -E 'Test case|passed|failed|BUILD' || true

  # Stop recording
  kill -INT "$record_pid" 2>/dev/null || true
  wait "$record_pid" 2>/dev/null || true

  if [ -f "$video_file" ]; then
    echo "iOS video saved: $video_file"
  else
    echo "WARNING: iOS video recording was not created"
  fi
}

# --- Android ---

record_android() {
  echo "=== Android: Recording UI tests ==="
  setup_android_env
  cd "$REPO_ROOT/android"

  # Verify emulator is running
  if ! adb devices | grep -q 'emulator\|device$'; then
    echo "ERROR: No Android emulator/device connected."
    echo "Start one with: \$ANDROID_HOME/emulator/emulator -avd <avd_name> &"
    echo "Available AVDs:"
    "$ANDROID_HOME/emulator/emulator" -list-avds
    exit 1
  fi

  # Wait for device to be fully booted
  adb wait-for-device
  while [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]; do
    echo "Waiting for device to finish booting..."
    sleep 2
  done

  local device_video="/sdcard/ui-test-recording.mp4"
  local local_video="$ARTIFACTS_DIR/android/ui-test-recording.mp4"

  # Clean up any previous recording on device
  adb shell rm -f "$device_video" 2>/dev/null || true

  # Start screen recording in background (max 3 min)
  echo "Starting screen recording..."
  adb shell screenrecord --time-limit 180 "$device_video" &
  local record_pid=$!
  sleep 1

  # Run UI tests
  echo "Running UI tests..."
  ./gradlew connectedDebugAndroidTest \
    -Pandroid.testInstrumentationRunnerArguments.class=com.tandem.emt.features.incidentReport.IncidentReportUITest \
    2>&1 | grep -E 'Starting|FAILED|Finished|BUILD' || true

  # Stop recording
  kill "$record_pid" 2>/dev/null || true
  sleep 2

  # Pull video from device
  if adb shell "[ -f $device_video ]" 2>/dev/null; then
    adb pull "$device_video" "$local_video"
    adb shell rm -f "$device_video"
    echo "Android video saved: $local_video"
  else
    echo "WARNING: Screen recording file not found on device"
  fi

  cd "$REPO_ROOT"
}

# --- Main ---

echo "=== Recording UI Test Videos ==="
echo ""

case "${1:-both}" in
  ios)     record_ios ;;
  android) record_android ;;
  both)    record_ios; record_android ;;
  *)       echo "Usage: $0 [ios|android|both]"; exit 1 ;;
esac

echo ""
echo "=== Done ==="
echo "Artifacts:"
ls -lh "$ARTIFACTS_DIR/ios/"*.mp4 2>/dev/null || echo "  (no iOS video)"
ls -lh "$ARTIFACTS_DIR/android/"*.mp4 2>/dev/null || echo "  (no Android video)"
echo ""
echo "Attach these to your PR for visual parity review."
