#!/bin/bash

# Privacy Validation Script for Findly Now Event Contracts
# This script ensures NO PII is present in any event schema

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔒 Privacy Validation: Scanning for PII violations...${NC}"
echo ""

VIOLATIONS_FOUND=0
TOTAL_FILES=0

# Function to check for actual PII field definitions (not enum values or descriptions)
check_file_for_pii() {
    local file="$1"
    local violations=0

    echo -e "${BLUE}📁 Checking: ${file}${NC}"

    # Skip privacy-validation.json as it's a meta-schema for detecting violations
    if [[ "$file" == *"privacy-validation.json" ]]; then
        echo -e "${YELLOW}ℹ️  Skipping meta-schema file${NC}"
        echo ""
        return 0
    fi

    # Check for actual PII field definitions in JSON Schema format
    # Pattern: "fieldname": { ... } or "fieldname": "type"

    # Critical PII field patterns that should never be object properties
    if grep -qE '"email"[[:space:]]*:[[:space:]]*\{' "$file"; then
        echo -e "${RED}❌ PII VIOLATION: 'email' field definition found in ${file}${NC}"
        violations=$((violations + 1))
    fi

    if grep -qE '"phone"[[:space:]]*:[[:space:]]*\{' "$file"; then
        echo -e "${RED}❌ PII VIOLATION: 'phone' field definition found in ${file}${NC}"
        violations=$((violations + 1))
    fi

    if grep -qE '"full_name"[[:space:]]*:[[:space:]]*\{' "$file"; then
        echo -e "${RED}❌ PII VIOLATION: 'full_name' field definition found in ${file}${NC}"
        violations=$((violations + 1))
    fi

    if grep -qE '"first_name"[[:space:]]*:[[:space:]]*\{' "$file"; then
        echo -e "${RED}❌ PII VIOLATION: 'first_name' field definition found in ${file}${NC}"
        violations=$((violations + 1))
    fi

    if grep -qE '"last_name"[[:space:]]*:[[:space:]]*\{' "$file"; then
        echo -e "${RED}❌ PII VIOLATION: 'last_name' field definition found in ${file}${NC}"
        violations=$((violations + 1))
    fi

    if grep -qE '"ssn"[[:space:]]*:[[:space:]]*\{' "$file"; then
        echo -e "${RED}❌ PII VIOLATION: 'ssn' field definition found in ${file}${NC}"
        violations=$((violations + 1))
    fi

    if grep -qE '"social_security_number"[[:space:]]*:[[:space:]]*\{' "$file"; then
        echo -e "${RED}❌ PII VIOLATION: 'social_security_number' field definition found in ${file}${NC}"
        violations=$((violations + 1))
    fi

    if grep -qE '"passport"[[:space:]]*:[[:space:]]*\{' "$file"; then
        echo -e "${RED}❌ PII VIOLATION: 'passport' field definition found in ${file}${NC}"
        violations=$((violations + 1))
    fi

    if grep -qE '"driver_license"[[:space:]]*:[[:space:]]*\{' "$file"; then
        echo -e "${RED}❌ PII VIOLATION: 'driver_license' field definition found in ${file}${NC}"
        violations=$((violations + 1))
    fi

    if grep -qE '"credit_card"[[:space:]]*:[[:space:]]*\{' "$file"; then
        echo -e "${RED}❌ PII VIOLATION: 'credit_card' field definition found in ${file}${NC}"
        violations=$((violations + 1))
    fi

    if grep -qE '"ip_address"[[:space:]]*:[[:space:]]*\{' "$file"; then
        echo -e "${RED}❌ PII VIOLATION: 'ip_address' field definition found in ${file}${NC}"
        violations=$((violations + 1))
    fi

    if grep -qE '"date_of_birth"[[:space:]]*:[[:space:]]*\{' "$file"; then
        echo -e "${RED}❌ PII VIOLATION: 'date_of_birth' field definition found in ${file}${NC}"
        violations=$((violations + 1))
    fi

    # Special handling for ContactInfo fields - these should use tokens
    if grep -qE '"recipient_info"[[:space:]]*:[[:space:]]*\{[^}]*"email"' "$file"; then
        echo -e "${RED}❌ PII VIOLATION: recipient_info contains 'email' field in ${file} - use privacy-safe pattern${NC}"
        violations=$((violations + 1))
    fi

    if grep -qE '"contact_info"[[:space:]]*:[[:space:]]*\{[^}]*"email"' "$file"; then
        echo -e "${RED}❌ PII VIOLATION: contact_info contains 'email' field in ${file} - use ContactExchangeToken instead${NC}"
        violations=$((violations + 1))
    fi

    # Check for raw user objects instead of PrivacySafeUser references
    if grep -qE '"user"[[:space:]]*:[[:space:]]*\{[^}]*"email"' "$file"; then
        echo -e "${RED}❌ PII VIOLATION: user object contains 'email' field in ${file} - use PrivacySafeUser reference${NC}"
        violations=$((violations + 1))
    fi

    if [ $violations -eq 0 ]; then
        echo -e "${GREEN}✅ No PII violations found${NC}"
    else
        echo -e "${RED}❌ ${violations} PII violations found${NC}"
    fi

    echo ""
    return $violations
}

# Check all JSON schema files
echo -e "${YELLOW}Scanning event schemas...${NC}"
for file in $(find . -name "*.json" -path "*/schemas/*" -o -path "*/shared/*"); do
    if [[ -f "$file" ]]; then
        TOTAL_FILES=$((TOTAL_FILES + 1))
        if ! check_file_for_pii "$file"; then
            VIOLATIONS_FOUND=$((VIOLATIONS_FOUND + $?))
        fi
    fi
done

# Check AsyncAPI specification for PII in examples
echo -e "${YELLOW}Scanning AsyncAPI specification...${NC}"
if [[ -f "events/asyncapi.yaml" ]]; then
    TOTAL_FILES=$((TOTAL_FILES + 1))
    echo -e "${BLUE}📁 Checking: events/asyncapi.yaml${NC}"

    violations=0

    # Check for PII in examples (but not in descriptions or enum values)
    if grep -qE 'email[[:space:]]*:[[:space:]]*"[^"]*@[^"]*"' "events/asyncapi.yaml"; then
        echo -e "${RED}❌ PII VIOLATION: Email address found in AsyncAPI examples${NC}"
        violations=$((violations + 1))
    fi

    if grep -qE 'phone[[:space:]]*:[[:space:]]*"[\+\-0-9\(\) ]*"' "events/asyncapi.yaml"; then
        echo -e "${RED}❌ PII VIOLATION: Phone number found in AsyncAPI examples${NC}"
        violations=$((violations + 1))
    fi

    if [ $violations -eq 0 ]; then
        echo -e "${GREEN}✅ No PII violations found in AsyncAPI${NC}"
    else
        echo -e "${RED}❌ ${violations} PII violations found in AsyncAPI${NC}"
        VIOLATIONS_FOUND=$((VIOLATIONS_FOUND + violations))
    fi
    echo ""
fi

# Summary
echo -e "${BLUE}📊 Privacy Validation Summary${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Files scanned: $TOTAL_FILES"
echo -e "PII violations: ${RED}$VIOLATIONS_FOUND${NC}"
echo ""

if [ $VIOLATIONS_FOUND -eq 0 ]; then
    echo -e "${GREEN}🎉 SUCCESS: All schemas are privacy-compliant!${NC}"
    echo -e "${GREEN}✅ No PII found in event contracts${NC}"
    echo -e "${GREEN}✅ Privacy-first architecture maintained${NC}"
    exit 0
else
    echo -e "${RED}🚨 FAILURE: Privacy violations detected!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Required Actions:${NC}"
    echo "1. Remove all PII fields from event schemas"
    echo "2. Use PrivacySafeUser references for user data"
    echo "3. Use ContactExchangeToken for contact sharing"
    echo "4. Replace direct contact info with encrypted tokens"
    echo ""
    echo -e "${YELLOW}📖 Reference:${NC}"
    echo "- Privacy rules: /fn-contract/COMPATIBILITY.md"
    echo "- PrivacySafeUser schema: /fn-contract/shared/domains.json"
    echo "- ContactExchangeToken schema: /fn-contract/shared/domains.json"
    echo ""
    echo -e "${RED}❌ BUILD MUST FAIL: PII in events violates GDPR/CCPA compliance${NC}"
    exit 1
fi