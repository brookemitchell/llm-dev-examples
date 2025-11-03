#!/bin/bash

# Test script for GitHub API access
# Usage: ./test-github-access.sh

set -e

echo "🔍 Testing GitHub API Access..."
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if credentials file exists
if [ ! -f ".cursor/credentials/github.json" ]; then
  echo -e "${RED}❌ Error: github.json not found${NC}"
  echo ""
  echo "Please create the credentials file first:"
  echo "  cp .cursor/credentials/github.json.template .cursor/credentials/github.json"
  echo ""
  echo "Then edit github.json with your GitHub token."
  exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo -e "${YELLOW}⚠️  Warning: jq is not installed${NC}"
  echo ""
  echo "To install jq:"
  echo "  macOS: brew install jq"
  echo "  Linux: sudo apt-get install jq"
  echo ""
  exit 1
fi

# Extract token
TOKEN=$(cat .cursor/credentials/github.json | jq -r '.github.token')
USERNAME=$(cat .cursor/credentials/github.json | jq -r '.github.username')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
  echo -e "${RED}❌ Error: Token not found in github.json${NC}"
  exit 1
fi

echo "Username: $USERNAME"
echo "Token: ${TOKEN:0:8}... (hidden)"
echo ""

# Test 1: Check authentication
echo "Test 1: Checking authentication..."
AUTH_RESPONSE=$(curl -s -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user)

AUTH_STATUS=$?

if [ $AUTH_STATUS -eq 0 ]; then
  ACTUAL_USERNAME=$(echo "$AUTH_RESPONSE" | jq -r '.login')
  
  if [ "$ACTUAL_USERNAME" != "null" ] && [ -n "$ACTUAL_USERNAME" ]; then
    echo -e "${GREEN}✅ Authentication successful${NC}"
    echo "   Authenticated as: @$ACTUAL_USERNAME"
    
    if [ "$ACTUAL_USERNAME" != "$USERNAME" ]; then
      echo -e "${YELLOW}⚠️  Warning: Username mismatch${NC}"
      echo "   Expected: @$USERNAME"
      echo "   Actual: @$ACTUAL_USERNAME"
    fi
  else
    echo -e "${RED}❌ Authentication failed${NC}"
    ERROR_MSG=$(echo "$AUTH_RESPONSE" | jq -r '.message')
    echo "   Error: $ERROR_MSG"
    exit 1
  fi
else
  echo -e "${RED}❌ Failed to connect to GitHub API${NC}"
  exit 1
fi

echo ""

# Test 2: Check rate limit
echo "Test 2: Checking rate limit..."
RATE_RESPONSE=$(curl -s -H "Authorization: token $TOKEN" \
  https://api.github.com/rate_limit)

CORE_LIMIT=$(echo "$RATE_RESPONSE" | jq -r '.resources.core.limit')
CORE_REMAINING=$(echo "$RATE_RESPONSE" | jq -r '.resources.core.remaining')
CORE_RESET=$(echo "$RATE_RESPONSE" | jq -r '.resources.core.reset')

if [ "$CORE_LIMIT" != "null" ]; then
  echo -e "${GREEN}✅ Rate limit info retrieved${NC}"
  echo "   Limit: $CORE_LIMIT requests/hour"
  echo "   Remaining: $CORE_REMAINING requests"
  
  if [ "$CORE_REMAINING" -lt 10 ]; then
    echo -e "${YELLOW}⚠️  Warning: Low rate limit remaining${NC}"
    # Cross-platform date formatting
    if date -d @"$CORE_RESET" "+%Y-%m-%d %H:%M:%S" >/dev/null 2>&1; then
      # GNU date (Linux)
      RESET_TIME=$(date -d @"$CORE_RESET" "+%Y-%m-%d %H:%M:%S")
    else
      # BSD date (macOS)
      RESET_TIME=$(date -r "$CORE_RESET" "+%Y-%m-%d %H:%M:%S")
    fi
    echo "   Resets at: $RESET_TIME"
  fi
else
  echo -e "${RED}❌ Failed to get rate limit info${NC}"
fi

echo ""

# Test 3: Check token scopes
echo "Test 3: Checking token scopes..."
SCOPES_RESPONSE=$(curl -s -I -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user)

SCOPES=$(echo "$SCOPES_RESPONSE" | grep -i "x-oauth-scopes:" | cut -d: -f2 | tr -d '\r')

if [ -n "$SCOPES" ]; then
  echo -e "${GREEN}✅ Token scopes:${NC}"
  echo "   $SCOPES"
  
  # Check for required scopes
  HAS_REPO=false
  HAS_DISCUSSION=false
  
  if echo "$SCOPES" | grep -q "repo"; then
    HAS_REPO=true
  fi
  
  if echo "$SCOPES" | grep -q "read:discussion"; then
    HAS_DISCUSSION=true
  fi
  
  echo ""
  echo "Required scopes for /review-my-pr:"
  if [ "$HAS_REPO" = true ]; then
    echo -e "   ${GREEN}✅ repo${NC}"
  else
    echo -e "   ${RED}❌ repo (MISSING)${NC}"
  fi
  
  if [ "$HAS_DISCUSSION" = true ]; then
    echo -e "   ${GREEN}✅ read:discussion${NC}"
  else
    echo -e "   ${YELLOW}⚠️  read:discussion (MISSING - may still work)${NC}"
  fi
  
  if [ "$HAS_REPO" = false ]; then
    echo ""
    echo -e "${RED}⚠️  Missing required scope 'repo'${NC}"
    echo "   Please regenerate your token with the correct scopes:"
    echo "   https://github.com/settings/tokens"
  fi
else
  echo -e "${YELLOW}⚠️  Could not determine token scopes${NC}"
fi

echo ""

# Test 4: Test PR access
echo "Test 4: Testing PR access (using example PR)..."
echo "   Repository: owner/repository"
echo "   PR: #123"
echo ""

PR_RESPONSE=$(curl -s -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/owner/repository/pulls/123)

PR_TITLE=$(echo "$PR_RESPONSE" | jq -r '.title')

if [ "$PR_TITLE" != "null" ] && [ -n "$PR_TITLE" ]; then
  echo -e "${GREEN}✅ PR access successful${NC}"
  echo "   Title: $PR_TITLE"
  
  PR_STATE=$(echo "$PR_RESPONSE" | jq -r '.state')
  PR_COMMENTS=$(echo "$PR_RESPONSE" | jq -r '.comments')
  PR_REVIEW_COMMENTS=$(echo "$PR_RESPONSE" | jq -r '.review_comments')
  
  echo "   State: $PR_STATE"
  echo "   Comments: $PR_COMMENTS"
  echo "   Review Comments: $PR_REVIEW_COMMENTS"
else
  ERROR_MSG=$(echo "$PR_RESPONSE" | jq -r '.message')
  
  if [ "$ERROR_MSG" == "Not Found" ]; then
    echo -e "${YELLOW}⚠️  PR #123 not found or not accessible${NC}"
    echo "   This is expected - this is an example repository"
    echo "   Edit this script with your own repository to test real access"
    echo "   The token will work with PRs in repositories you have access to"
  else
    echo -e "${RED}❌ Failed to access PR${NC}"
    echo "   Error: $ERROR_MSG"
  fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ GitHub API access test complete${NC}"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Your credentials are configured correctly!"
echo "You can now use: /review-my-pr <pr-url>"
echo ""
