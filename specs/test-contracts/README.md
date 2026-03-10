# Test Contracts

Test contracts are platform-agnostic behavioral specifications that both iOS and Android
must implement. They are the primary mechanism for ensuring feature parity.

## Format

Each feature has a YAML file defining test tags and test cases:

```yaml
feature: feature-name
description: What this feature does

# Shared element identifiers — MUST be identical on both platforms
test_tags:
  - loading_indicator
  - empty_state
  - error_state

cases:
  - id: TC001
    test_name: test_TC001_loadsIncidents       # EXACT function name on both platforms
    category: unit | ui | integration
    description: Human-readable description
    given: Initial state or preconditions
    when: Action or event
    then: Expected outcome
    verify_tags: [loading_indicator]            # UI tests: tags to assert on
    video_checkpoint: "What to verify visually" # UI tests: video review note
```

## Rules

1. Every feature spec in `specs/features/` MUST have a corresponding test contract
2. Both platforms MUST implement every test case in the contract
3. Test function names MUST be **identical** on both platforms (from the `test_name` field)
4. Adding a new test case to a contract requires implementation on BOTH platforms
5. UI test cases should specify `verify_tags` and `video_checkpoint`

## Test Naming

The `test_name` field in each case defines the **exact function name** both platforms use:

```
// Contract:    test_name: test_IL001_initialLoadFetchesAndPopulatesState
// iOS:         func test_IL001_initialLoadFetchesAndPopulatesState()
// Android:     fun  test_IL001_initialLoadFetchesAndPopulatesState()
```

This makes it trivial to:
- Verify both platforms cover every case (grep for the function name)
- Compare test results side-by-side (same names in test reports)
- Match video recordings 1:1 between platforms

## Test Tags

The `test_tags` section defines shared element identifiers. Both platforms use the
exact same string:

- **iOS:** `.accessibilityIdentifier("empty_state")`
- **Android:** `Modifier.testTag("empty_state")`

This ensures UI tests can assert on the same elements regardless of platform.

## File Naming

| Test Type | iOS | Android |
|-----------|-----|---------|
| Unit (ViewModel) | `{Feature}ViewModelTests.swift` | `{Feature}ViewModelTest.kt` |
| UI (Screen) | `{Feature}UITests.swift` | `{Feature}UITest.kt` |

## Parity Validation

CI runs `tools/ci/validate-test-parity.sh` which:
1. Parses all test contract YAML files
2. Extracts `test_name` values from each case
3. Scans iOS and Android test files for those exact function names
4. Reports any contract cases missing on either platform
5. Fails the build if parity is broken
