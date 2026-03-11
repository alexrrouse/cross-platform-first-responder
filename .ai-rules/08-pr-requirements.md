# PR Requirements

- Every feature PR must include changes to BOTH `ios/` and `android/`
- PR must include locally-recorded mp4 video demos from both platforms
  - Run `./tools/ci/record-ui-tests.sh` to generate them
  - Attach `artifacts/videos/ios/ui-test-recording.mp4` and `artifacts/videos/android/ui-test-recording.mp4` to the PR
- If a PR only touches one platform, it must be labeled `platform-specific` with justification
- CI will fail if a feature spec has test contracts that aren't covered on both platforms
