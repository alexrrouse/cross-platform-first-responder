#!/bin/bash
# validate-test-parity.sh
# Ensures both iOS and Android implement all test cases from shared test contracts.
# Validates by test_name (exact function name) for strict cross-platform parity.
# Run from repo root.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SPECS_DIR="specs/test-contracts"
IOS_TEST_DIRS="ios/TandemEMTTests ios/TandemEMTUITests"
ANDROID_TEST_DIRS="android/app/src/test android/app/src/androidTest"

MISSING_IOS=()
MISSING_ANDROID=()
NAME_MISMATCH=()
TOTAL_CASES=0

echo "=== Test Parity Validation ==="
echo ""

# Find all YAML contract files (skip templates and README)
for contract in "$SPECS_DIR"/*.yaml; do
  [ -f "$contract" ] || continue
  [[ "$(basename "$contract")" == "TEMPLATE.yaml" ]] && continue

  feature=$(basename "$contract" .yaml)
  echo "Checking feature: $feature"

  # Extract case IDs (compatible with macOS and Linux)
  case_ids=$(grep -E '^\s*-\s*id:\s*' "$contract" | sed 's/.*id:[[:space:]]*//' | sed 's/[[:space:]]*$//' || true)

  # Extract test_names keyed by case ID
  # We parse id + test_name pairs from the YAML
  test_names=$(grep -E '^\s*(- id:|test_name:)' "$contract" | sed 's/[[:space:]]*$//' || true)

  for case_id in $case_ids; do
    [ -z "$case_id" ] && continue
    TOTAL_CASES=$((TOTAL_CASES + 1))

    # Try to find the test_name for this case ID
    # Look for the test_name line that follows the id line
    test_name=$(echo "$test_names" | grep -A1 "id: *${case_id}$" | grep "test_name:" | sed 's/.*test_name:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1 || true)

    # Use test_name for lookup if available, otherwise fall back to case_id
    search_term="${test_name:-$case_id}"

    # Check iOS
    ios_found=""
    for dir in $IOS_TEST_DIRS; do
      if [ -d "$dir" ]; then
        result=$(grep -r "$search_term" "$dir" 2>/dev/null | head -1 || true)
        if [ -n "$result" ]; then
          ios_found="$result"
          break
        fi
      fi
    done
    if [ -z "$ios_found" ]; then
      MISSING_IOS+=("$feature:$case_id ($search_term)")
      echo -e "  ${RED}✗ iOS missing:${NC} $case_id → $search_term"
    fi

    # Check Android
    android_found=""
    for dir in $ANDROID_TEST_DIRS; do
      if [ -d "$dir" ]; then
        result=$(grep -r "$search_term" "$dir" 2>/dev/null | head -1 || true)
        if [ -n "$result" ]; then
          android_found="$result"
          break
        fi
      fi
    done
    if [ -z "$android_found" ]; then
      MISSING_ANDROID+=("$feature:$case_id ($search_term)")
      echo -e "  ${RED}✗ Android missing:${NC} $case_id → $search_term"
    fi

    if [ -n "$ios_found" ] && [ -n "$android_found" ]; then
      echo -e "  ${GREEN}✓${NC} $case_id → $search_term"
    fi
  done
  echo ""
done

# Validate test_name uniqueness and cross-platform naming
echo "=== Checking test name parity ==="
PARITY_ERRORS=0

for contract in "$SPECS_DIR"/*.yaml; do
  [ -f "$contract" ] || continue
  [[ "$(basename "$contract")" == "TEMPLATE.yaml" ]] && continue

  feature=$(basename "$contract" .yaml)

  # Extract all test_names
  names=$(grep -E '^\s*test_name:\s*' "$contract" | sed 's/.*test_name:[[:space:]]*//' | sed 's/[[:space:]]*$//' || true)

  for name in $names; do
    [ -z "$name" ] && continue

    # Check iOS has this exact function name
    ios_match=""
    for dir in $IOS_TEST_DIRS; do
      if [ -d "$dir" ]; then
        result=$(grep -r "func ${name}()" "$dir" 2>/dev/null | head -1 || true)
        if [ -n "$result" ]; then
          ios_match="$result"
          break
        fi
      fi
    done

    # Check Android has this exact function name
    android_match=""
    for dir in $ANDROID_TEST_DIRS; do
      if [ -d "$dir" ]; then
        result=$(grep -r "fun ${name}()" "$dir" 2>/dev/null | head -1 || true)
        if [ -n "$result" ]; then
          android_match="$result"
          break
        fi
      fi
    done

    if [ -n "$ios_match" ] && [ -n "$android_match" ]; then
      echo -e "  ${GREEN}✓${NC} $name"
    else
      PARITY_ERRORS=$((PARITY_ERRORS + 1))
      if [ -z "$ios_match" ]; then
        echo -e "  ${RED}✗ iOS missing exact func:${NC} $name"
      fi
      if [ -z "$android_match" ]; then
        echo -e "  ${RED}✗ Android missing exact fun:${NC} $name"
      fi
    fi
  done
done
echo ""

# Summary
echo "=== Summary ==="
echo "Total contract cases: $TOTAL_CASES"
echo -e "iOS missing: ${#MISSING_IOS[@]}"
echo -e "Android missing: ${#MISSING_ANDROID[@]}"
echo "Name parity errors: $PARITY_ERRORS"

HAS_ERRORS=false

if [ ${#MISSING_IOS[@]} -gt 0 ] || [ ${#MISSING_ANDROID[@]} -gt 0 ]; then
  HAS_ERRORS=true
  echo ""
  echo -e "${RED}COVERAGE CHECK FAILED${NC}"

  if [ ${#MISSING_IOS[@]} -gt 0 ]; then
    echo ""
    echo "Missing on iOS:"
    for item in "${MISSING_IOS[@]}"; do
      echo "  - $item"
    done
  fi

  if [ ${#MISSING_ANDROID[@]} -gt 0 ]; then
    echo ""
    echo "Missing on Android:"
    for item in "${MISSING_ANDROID[@]}"; do
      echo "  - $item"
    done
  fi
fi

if [ $PARITY_ERRORS -gt 0 ]; then
  HAS_ERRORS=true
  echo ""
  echo -e "${RED}NAME PARITY CHECK FAILED${NC}"
  echo "Both platforms must use identical test function names from the contract."
fi

if [ "$HAS_ERRORS" = true ]; then
  exit 1
fi

echo -e "${GREEN}ALL TESTS IN PARITY${NC}"
exit 0
