# Test Contracts

Test contracts are platform-agnostic behavioral specifications that both iOS and Android
must implement. They are the primary mechanism for ensuring feature parity.

## Format

Each feature has a YAML file defining test cases:

```yaml
feature: feature-name
description: What this feature does
cases:
  - id: TC001
    category: unit | ui | integration
    description: Human-readable description
    given: Initial state or preconditions
    when: Action or event
    then: Expected outcome
    edge_case: true | false
```

## Rules

1. Every feature spec in `specs/features/` MUST have a corresponding test contract
2. Both platforms MUST implement every test case in the contract
3. Test functions MUST reference the case ID (e.g., `test_TC001_loads_incidents`)
4. Adding a new test case to a contract requires implementation on BOTH platforms
5. UI test cases should specify what to visually verify for video recording validation

## Parity Validation

CI runs `tools/ci/validate-test-parity.sh` which:
1. Parses all test contract YAML files
2. Scans iOS and Android test files for case ID references
3. Reports any contract cases missing on either platform
4. Fails the build if parity is broken
