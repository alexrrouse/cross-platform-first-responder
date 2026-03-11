# Implement Feature

Implement the feature described by the argument: $ARGUMENTS

The argument can be either:
- A path to a feature spec or implementation markdown (e.g., `specs/features/incident-list.md`)
- A brief description of what to implement

Follow every step below **in order**. Do not skip steps. Use subagents where specified.

---

## Step 1 — Gather context and create feature branch

### If a spec file path was provided:
1. Read the feature spec file.
2. Read the corresponding test contract in `specs/test-contracts/` if one exists.
3. Read `specs/design/design-language.md` for design tokens.

### If a description was provided:
1. Search `specs/features/` for a matching spec.
2. If no spec exists, note that you'll need to create one in Step 3.
3. Read `specs/design/design-language.md` for design tokens.

### Create the feature branch:
1. Generate a short kebab-case description (2-4 words) from the feature name.
2. Create the branch:
   ```bash
   git fetch origin main && git checkout -b feature/<short-description> origin/main
   ```

Save all context — you will need it for planning.

---

## Step 2 — Plan the implementation

Launch an **Agent tool** with `subagent_type: "Plan"` to create the implementation plan. Pass the feature spec, test contract, and design language context. Instruct the agent to:

1. Read the project rules in `CLAUDE.md` and `.claude/rules/` to understand conventions.
2. Check both `ios/` and `android/` directories for existing related code.
3. Use the **codebase-pattern-finder** agent if needed to find existing patterns to follow.
4. Build an implementation plan covering:
   - **Shared specs**: Any specs or test contracts to create/modify
   - **iOS files**: Every file to create or modify, following the mirrored structure
   - **Android files**: Every file to create or modify, mirroring iOS
   - **State/Event/Effect definitions**: The exact state model both platforms will share
   - **Test plan**: How test contract cases map to test files on both platforms
   - **Design tokens**: Which colors, icons, and spacing tokens from the design language to use
   - **Test tags**: All accessibility identifiers / test tags both platforms will share
5. Return the plan.

Proceed directly to Step 3 — do not wait for user approval.

---

## Step 3 — Implement on BOTH platforms

Execute the plan. **Both platforms must be implemented together.**

### Implementation order:
1. **Spec first**: Create or update the feature spec in `specs/features/` and test contract in `specs/test-contracts/` if needed.
2. **Models**: Implement data models on both platforms (or generate from `specs/api/`).
3. **ViewModels**: Implement State/Event/Effect and business logic on both platforms.
4. **Views/Screens**: Implement UI on both platforms using design tokens.
5. **Tests**: Write tests alongside the implementation, not as a separate step.

### Rules:
- Follow all project conventions from `.claude/rules/`.
- **State model fields, Event cases, and Effect cases must be identical across platforms.**
- **Test function names must match the test contract `test_name` exactly.**
- **Test tags must be identical**: iOS `.accessibilityIdentifier("tag")` = Android `Modifier.testTag("tag")`.
- Use design tokens from `specs/design/design-language.md` — never hardcode colors.
- Use the icon mapping table — never guess icons.
- Make logical, atomic commits as you go — **never add `Co-Authored-By:` trailers**.
- Include tests in the same commit as the feature code they test.

### Required tests by change type:
- ViewModel logic → Unit tests (`{Feature}ViewModelTests.swift` / `{Feature}ViewModelTest.kt`)
- UI rendering → UI tests (`{Feature}UITests.swift` / `{Feature}UITest.kt`)
- Every `category: unit` case in the test contract → unit test on both platforms
- Every `category: ui` case in the test contract → UI test on both platforms

---

## Step 4 — Validate parity and tests

Run the parity checker and any available test suites:

```bash
tools/ci/validate-test-parity.sh
```

**Parity check MUST pass before proceeding.**

If it fails:
- Identify which test cases are missing on which platform
- Implement the missing tests
- Re-run until parity passes

Additionally, if platform build tools are available:
- iOS: `xcodebuild build -project ios/TandemEMT.xcodeproj -scheme TandemEMT -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'`
- Android: `cd android && ./gradlew assembleDebug && ./gradlew testDebugUnitTest`

---

## Step 5 — Cross-platform parity review

Launch an **Agent tool** with `subagent_type: "code-reviewer"` to perform the parity-focused code review.

Pass it this context:
- The feature spec and test contract content
- The list of files created/modified on each platform
- A one-line summary of what each file does

The review agent will run `git diff main...HEAD` and review for parity, correctness, security, and performance.

**After the code-reviewer returns**, perform an additional manual check:

1. **State model comparison**: Read both ViewModels and confirm State/Event/Effect definitions match field-for-field.
2. **Test tag audit**: Grep both platforms for test tags and confirm every tag in the test contract exists on both platforms:
   ```
   grep -r "accessibilityIdentifier\|testTag" ios/ android/ --include="*.swift" --include="*.kt"
   ```
3. **Design token audit**: Confirm no hardcoded hex colors exist in view/screen files:
   ```
   grep -rn "#[0-9A-Fa-f]\{6\}" ios/**/Views/ android/**/ui/ --include="*.swift" --include="*.kt"
   ```
4. **Test name audit**: Confirm every `test_name` in the contract has an exact `func` (iOS) and `fun` (Android) match.

---

## Step 6 — Address ALL review feedback

**Every piece of feedback must be addressed.** For each item, do exactly one:

- **`Fixed`** (default) — fix and commit now.
- **`Not Valid`** — push back with justification. Should be rare.
- **`Deferred`** — only for genuinely large scope expansions. Note what was deferred and why.

After addressing all feedback, re-run:
```bash
tools/ci/validate-test-parity.sh
```

---

## Step 7 — Record UI test videos locally

Run UI tests with video recording for both platforms **locally before pushing**:

```bash
tools/ci/record-ui-tests.sh both
```

**Video recording is required before creating the PR.** If a simulator/emulator is not available, troubleshoot and fix the issue rather than skipping. Videos are the primary way reviewers verify cross-platform visual parity.

If a platform's toolchain is genuinely not installed (e.g., no Xcode on a Linux machine), record the other platform and document the gap in the PR — but this should be the exception, not the norm.

Video artifacts are saved to `artifacts/videos/ios/` and `artifacts/videos/android/`. Commit them so they are available in the PR.

---

## Step 8 — Create PR

Run a final parity check, then push and create the PR:

```bash
tools/ci/validate-test-parity.sh
git push -u origin HEAD
```

Create the PR using `gh`:

```bash
gh pr create --title "<Feature Name>" --body "$(cat <<'PREOF'
## Summary
- <1-3 bullet points describing what was implemented>

## Spec
- Feature spec: `specs/features/<name>.md`
- Test contract: `specs/test-contracts/<name>.yaml`

## Platform Implementation
### iOS
- <list of key iOS files created/modified>

### Android
- <list of key Android files created/modified>

## Parity Checklist
- [ ] State/Event/Effect models match across platforms
- [ ] All test contract cases implemented on both platforms
- [ ] Test function names identical on both platforms
- [ ] Test tags identical on both platforms
- [ ] Design tokens used (no hardcoded colors/icons)
- [ ] `validate-test-parity.sh` passes

## Test Plan
- <count> unit tests on each platform
- <count> UI tests on each platform
- All test contract cases covered

## Video Recordings
- iOS: `artifacts/videos/ios/<feature>.mp4`
- Android: `artifacts/videos/android/<feature>.mp4`
PREOF
)"
```

---

## Step 9 — Final summary


Provide a **final summary** including:

1. **What was implemented** — brief description
2. **Platform breakdown** — files created/modified on each platform
3. **Parity status** — confirmation that both platforms match
4. **Tests written** — count per platform, broken down by unit/UI
5. **Design tokens used** — colors, icons, spacing referenced
6. **Key decisions** — notable architectural or design choices
7. **Link to the PR**
8. **Review Feedback Disposition Table** (MANDATORY — every feedback item must appear):

| #   | Feedback    | Action                              | Reason            |
| --- | ----------- | ----------------------------------- | ----------------- |
| 1   | Description | `Fixed` / `Not Valid` / `Deferred`  | Brief explanation |

Zero unaccounted-for items. If no feedback was given, state that explicitly.
