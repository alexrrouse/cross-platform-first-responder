#!/bin/bash
# validate-test-parity.sh
# Ensures both iOS and Android implement all test cases from shared test contracts.
# Run from repo root.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SPECS_DIR="specs/test-contracts"
IOS_TEST_DIR="ios/Tests"
ANDROID_TEST_DIR="android/app/src/test android/app/src/androidTest"

MISSING_IOS=()
MISSING_ANDROID=()
TOTAL_CASES=0

echo "=== Test Parity Validation ==="
echo ""

# Find all YAML contract files (skip templates and README)
for contract in "$SPECS_DIR"/*.yaml; do
  [ -f "$contract" ] || continue
  [[ "$(basename "$contract")" == "TEMPLATE.yaml" ]] && continue

  feature=$(basename "$contract" .yaml)
  echo "Checking feature: $feature"

  # Extract case IDs from YAML (lines matching "- id: XXNNN")
  case_ids=$(grep -oP '^\s*-\s*id:\s*\K\S+' "$contract" 2>/dev/null || true)

  for case_id in $case_ids; do
    TOTAL_CASES=$((TOTAL_CASES + 1))

    # Check iOS
    ios_found=$(grep -r "$case_id" "$IOS_TEST_DIR" 2>/dev/null | head -1 || true)
    if [ -z "$ios_found" ]; then
      MISSING_IOS+=("$feature:$case_id")
      echo -e "  ${RED}✗ iOS missing:${NC} $case_id"
    fi

    # Check Android
    android_found=""
    for dir in $ANDROID_TEST_DIR; do
      result=$(grep -r "$case_id" "$dir" 2>/dev/null | head -1 || true)
      if [ -n "$result" ]; then
        android_found="$result"
        break
      fi
    done
    if [ -z "$android_found" ]; then
      MISSING_ANDROID+=("$feature:$case_id")
      echo -e "  ${RED}✗ Android missing:${NC} $case_id"
    fi

    if [ -n "$ios_found" ] && [ -n "$android_found" ]; then
      echo -e "  ${GREEN}✓${NC} $case_id"
    fi
  done
  echo ""
done

# Summary
echo "=== Summary ==="
echo "Total contract cases: $TOTAL_CASES"
echo -e "iOS missing: ${#MISSING_IOS[@]}"
echo -e "Android missing: ${#MISSING_ANDROID[@]}"

if [ ${#MISSING_IOS[@]} -gt 0 ] || [ ${#MISSING_ANDROID[@]} -gt 0 ]; then
  echo ""
  echo -e "${RED}PARITY CHECK FAILED${NC}"

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

  exit 1
fi

echo -e "${GREEN}ALL TESTS IN PARITY${NC}"
exit 0
