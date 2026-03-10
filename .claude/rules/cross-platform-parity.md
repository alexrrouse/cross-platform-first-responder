# Cross-Platform Parity — Mandatory Rules

This is a dual-native mobile app (iOS: Swift/SwiftUI, Android: Kotlin/Jetpack Compose).
**Every feature must be implemented on BOTH platforms simultaneously.**

## Before Implementing ANY Feature or Change
- Read the feature spec in `specs/features/` first
- Check both `ios/` and `android/` directories for existing related code
- If modifying an existing feature, read BOTH platform implementations before making changes

## When Implementing a Feature
- Always implement on BOTH platforms in the same session
- Follow the shared test contract in `specs/test-contracts/` for that feature
- Both implementations must pass the same behavioral test cases
- Do NOT submit or consider work "done" if only one platform is implemented

## When Fixing a Bug
- Check if the same bug exists on the other platform
- If the bug is logic-related (not platform-specific rendering), fix it on both platforms
- Document in the PR if a bug is confirmed platform-specific

## When Reviewing or Reading Code
- Always read the equivalent file on the other platform for context
- The parallel file structure makes this straightforward

## Never Do This
- Never implement a feature on only one platform without explicitly stating why
- Never modify a shared spec without updating both platform implementations
- Never add a test on one platform without adding the equivalent test on the other
- Never change a data model on one platform without changing it on the other
- Never skip reading the feature spec before implementing
