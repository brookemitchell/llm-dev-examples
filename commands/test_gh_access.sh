#!/bin/bash

# Test script for GitHub CLI access
# Usage: ./test_gh_access.sh [owner/repo] [PR-NUMBER]
#
# Examples:
#   ./test_gh_access.sh                        # Run basic tests only
#   ./test_gh_access.sh owner/repo            # Test repo access
#   ./test_gh_access.sh owner/repo 123        # Test PR access

set -e

echo "🔍 Testing GitHub CLI Access..."
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
TEST_REPO="${1:-}"
TEST_PR="${2:-}"

# Test 1: Check if gh CLI is installed
echo "Test 1: Checking if GitHub CLI is installed..."
if ! command -v gh &> /dev/null; then
  echo -e "${RED}❌ GitHub CLI (gh) is not installed${NC}"
  echo ""
  echo "Please install GitHub CLI first:"
  echo "  macOS:   brew install gh"
  echo "  Linux:   See https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
  echo "  Windows: winget install --id GitHub.cli"
  echo ""
  exit 1
else
  GH_VERSION=$(gh --version | head -n 1)
  echo -e "${GREEN}✅ GitHub CLI is installed${NC}"
  echo "   Version: $GH_VERSION"
fi

echo ""

# Test 2: Check authentication status
echo "Test 2: Checking authentication status..."
if ! gh auth status &> /dev/null; then
  echo -e "${RED}❌ Not authenticated with GitHub${NC}"
  echo ""
  echo "Please authenticate first:"
  echo "  gh auth login"
  echo ""
  echo "Then run this test again."
  exit 1
else
  AUTH_OUTPUT=$(gh auth status 2>&1)
  echo -e "${GREEN}✅ Authenticated with GitHub${NC}"
  
  # Extract username
  USERNAME=$(echo "$AUTH_OUTPUT" | grep "Logged in to github.com" | sed -n 's/.*as \([^ ]*\).*/\1/p')
  if [ -n "$USERNAME" ]; then
    echo "   Authenticated as: @$USERNAME"
  fi
  
  # Check for token
  if echo "$AUTH_OUTPUT" | grep -q "Token:"; then
    echo "   Token: Active"
  fi
  
  # Check authentication type
  if echo "$AUTH_OUTPUT" | grep -q "Token scopes:"; then
    SCOPES=$(echo "$AUTH_OUTPUT" | grep "Token scopes:" | cut -d: -f2 | xargs)
    echo "   Scopes: $SCOPES"
  fi
fi

echo ""

# Test 3: Check API access and rate limit
echo "Test 3: Checking API access and rate limit..."
RATE_OUTPUT=$(gh api /rate_limit 2>&1)

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ API access successful${NC}"
  
  # Parse rate limit info using jq if available, otherwise basic parsing
  if command -v jq &> /dev/null; then
    CORE_LIMIT=$(echo "$RATE_OUTPUT" | jq -r '.resources.core.limit')
    CORE_REMAINING=$(echo "$RATE_OUTPUT" | jq -r '.resources.core.remaining')
    CORE_RESET=$(echo "$RATE_OUTPUT" | jq -r '.resources.core.reset')
    
    echo "   Limit: $CORE_LIMIT requests/hour"
    echo "   Remaining: $CORE_REMAINING requests"
    
    if [ "$CORE_REMAINING" -lt 100 ]; then
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
    echo "   (Install jq for detailed rate limit info)"
  fi
else
  echo -e "${RED}❌ API access failed${NC}"
  echo "   Error: $RATE_OUTPUT"
fi

echo ""

# Test 4: Check token scopes/permissions
echo "Test 4: Checking token permissions..."
USER_OUTPUT=$(gh api /user 2>&1)

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ User API access successful${NC}"
  
  if command -v jq &> /dev/null; then
    USER_LOGIN=$(echo "$USER_OUTPUT" | jq -r '.login')
    USER_NAME=$(echo "$USER_OUTPUT" | jq -r '.name')
    
    echo "   Login: @$USER_LOGIN"
    if [ "$USER_NAME" != "null" ] && [ -n "$USER_NAME" ]; then
      echo "   Name: $USER_NAME"
    fi
  fi
  
  # Check what the token can do
  echo ""
  echo "   Testing permissions:"
  
  # Test repo read access
  REPO_TEST=$(gh api /user/repos?per_page=1 2>&1)
  if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✅ Can list repositories${NC}"
  else
    echo -e "   ${RED}❌ Cannot list repositories${NC}"
  fi
  
  # Test org access (optional)
  ORG_TEST=$(gh api /user/orgs 2>&1)
  if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✅ Can list organizations${NC}"
  else
    echo -e "   ${YELLOW}⚠️  Cannot list organizations (may be expected)${NC}"
  fi
else
  echo -e "${RED}❌ User API access failed${NC}"
fi

echo ""

# Test 5: Test repository access (if provided)
if [ -n "$TEST_REPO" ]; then
  echo "Test 5: Testing repository access..."
  echo "   Repository: $TEST_REPO"
  echo ""
  
  REPO_OUTPUT=$(gh repo view "$TEST_REPO" --json name,owner,isPrivate,description 2>&1)
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Repository access successful${NC}"
    
    if command -v jq &> /dev/null; then
      REPO_NAME=$(echo "$REPO_OUTPUT" | jq -r '.name')
      REPO_OWNER=$(echo "$REPO_OUTPUT" | jq -r '.owner.login')
      IS_PRIVATE=$(echo "$REPO_OUTPUT" | jq -r '.isPrivate')
      REPO_DESC=$(echo "$REPO_OUTPUT" | jq -r '.description')
      
      echo "   Name: $REPO_NAME"
      echo "   Owner: @$REPO_OWNER"
      echo "   Private: $IS_PRIVATE"
      if [ "$REPO_DESC" != "null" ] && [ -n "$REPO_DESC" ]; then
        echo "   Description: $REPO_DESC"
      fi
    else
      echo "$REPO_OUTPUT"
    fi
  else
    echo -e "${RED}❌ Repository access failed${NC}"
    echo "   Error: $REPO_OUTPUT"
    echo ""
    echo "   Make sure:"
    echo "   1. The repository exists"
    echo "   2. You have access to it"
    echo "   3. The repository name is correct (format: owner/repo)"
  fi
  
  echo ""
fi

# Test 6: Test PR access (if provided)
if [ -n "$TEST_REPO" ] && [ -n "$TEST_PR" ]; then
  echo "Test 6: Testing PR access..."
  echo "   Repository: $TEST_REPO"
  echo "   PR: #$TEST_PR"
  echo ""
  
  PR_OUTPUT=$(gh pr view "$TEST_PR" --repo "$TEST_REPO" --json number,title,state,author,createdAt,comments,reviews 2>&1)
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ PR access successful${NC}"
    
    if command -v jq &> /dev/null; then
      PR_TITLE=$(echo "$PR_OUTPUT" | jq -r '.title')
      PR_STATE=$(echo "$PR_OUTPUT" | jq -r '.state')
      PR_AUTHOR=$(echo "$PR_OUTPUT" | jq -r '.author.login')
      PR_CREATED=$(echo "$PR_OUTPUT" | jq -r '.createdAt')
      
      echo "   Title: $PR_TITLE"
      echo "   State: $PR_STATE"
      echo "   Author: @$PR_AUTHOR"
      echo "   Created: $PR_CREATED"
      
      # Count comments and reviews
      COMMENT_COUNT=$(echo "$PR_OUTPUT" | jq '.comments | length')
      REVIEW_COUNT=$(echo "$PR_OUTPUT" | jq '.reviews | length')
      
      echo "   Comments: $COMMENT_COUNT"
      echo "   Reviews: $REVIEW_COUNT"
    else
      echo "$PR_OUTPUT"
    fi
    
    echo ""
    echo "   Testing PR comment access..."
    COMMENTS_OUTPUT=$(gh pr view "$TEST_PR" --repo "$TEST_REPO" --json comments 2>&1)
    
    if [ $? -eq 0 ]; then
      echo -e "   ${GREEN}✅ Can fetch PR comments${NC}"
    else
      echo -e "   ${RED}❌ Cannot fetch PR comments${NC}"
    fi
    
    echo ""
    echo "   Testing GraphQL API access (for marking as resolved)..."
    GRAPHQL_TEST=$(gh api graphql -f query='query { viewer { login } }' 2>&1)
    
    if [ $? -eq 0 ]; then
      echo -e "   ${GREEN}✅ GraphQL API access successful${NC}"
      
      if command -v jq &> /dev/null; then
        VIEWER_LOGIN=$(echo "$GRAPHQL_TEST" | jq -r '.data.viewer.login')
        echo "   GraphQL viewer: @$VIEWER_LOGIN"
      fi
      
      echo ""
      echo "   This means you can:"
      echo "   - Fetch PR review threads"
      echo "   - Mark comments as resolved"
      echo "   - Use all /review-my-pr and /fix-my-pr features"
    else
      echo -e "   ${RED}❌ GraphQL API access failed${NC}"
      echo "   Error: $GRAPHQL_TEST"
    fi
  else
    echo -e "${RED}❌ PR access failed${NC}"
    echo "   Error: $PR_OUTPUT"
    echo ""
    echo "   Make sure:"
    echo "   1. The PR exists in the repository"
    echo "   2. You have access to the repository"
    echo "   3. The PR number is correct"
  fi
  
  echo ""
fi

# Summary
echo "═══════════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ GitHub CLI access test complete${NC}"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check if all basic tests passed
if gh auth status &> /dev/null && gh api /rate_limit &> /dev/null; then
  echo -e "${GREEN}Your GitHub CLI is configured correctly!${NC}"
  echo ""
  echo "You can now use:"
  echo "  • /review-my-pr <pr-url>     - Review PR comments"
  echo "  • /fix-my-pr <pr-url>        - Apply fixes automatically"
  echo "  • gh pr create               - Create new PRs"
  echo "  • gh pr view <number>        - View PR details"
  echo ""
  
  if [ -z "$TEST_REPO" ]; then
    echo -e "${BLUE}💡 Tip:${NC} Run this script with arguments to test specific access:"
    echo "   ./test_gh_access.sh owner/repo          # Test repo access"
    echo "   ./test_gh_access.sh owner/repo 123      # Test PR #123 access"
    echo ""
  fi
else
  echo -e "${RED}⚠️  Setup incomplete${NC}"
  echo ""
  echo "Please run: gh auth login"
  echo ""
fi
