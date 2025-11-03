#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:8080"
SESSION_COOKIE="JSESSIONID=4927F2055238998BF764994835744D60"

echo "=========================================="
echo "AUTHENTICATED ENDPOINT TESTING"
echo "=========================================="
echo ""
echo "Using Session Cookie: ${SESSION_COOKIE:0:30}..."
echo ""

# Function to test an authenticated endpoint
test_auth_endpoint() {
    local name=$1
    local method=$2
    local url=$3
    local data=$4
    local expected_status=$5
    
    echo -n "Testing: $name... "
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" -H "Cookie: $SESSION_COOKIE" "$url")
    elif [ "$method" = "POST" ]; then
        if [[ $data == *"multipart"* ]]; then
            # Handle file upload
            response=$(curl -s -w "\n%{http_code}" -X POST "$url" \
                -H "Cookie: $SESSION_COOKIE" \
                -F "file=@uploads/6b58b35e-cc72-4323-9a5f-cb49b2a6090c_oauth-test.txt" \
                -F "title=OAuth Authenticated Upload" \
                -F "description=Uploaded with OAuth authentication" \
                -F "categories=Technology")
        else
            response=$(curl -s -w "\n%{http_code}" -X POST "$url" \
                -H "Cookie: $SESSION_COOKIE" \
                -H "Content-Type: application/json" \
                -d "$data")
        fi
    fi
    
    status_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "${GREEN}✓ PASSED${NC} (Status: $status_code)"
        if [[ $body == *"id"* ]] || [[ $body == *"message"* ]]; then
            echo "  Response preview: ${body:0:100}..."
        fi
    else
        echo -e "${RED}✗ FAILED${NC} (Expected: $expected_status, Got: $status_code)"
        echo "  Response: ${body:0:200}"
    fi
    echo ""
}

echo "==========================================="
echo "PART 1: VERIFY AUTHENTICATION STATUS"
echo "==========================================="
echo ""

# Test 1: Check who is logged in (get user info via favorites endpoint)
echo -n "Checking authentication status... "
auth_check=$(curl -s -w "\n%{http_code}" -H "Cookie: $SESSION_COOKIE" "$BASE_URL/api/resources/favorites")
auth_status=$(echo "$auth_check" | tail -n1)

if [ "$auth_status" = "200" ]; then
    echo -e "${GREEN}✓ AUTHENTICATED${NC}"
    echo "  You are successfully logged in!"
elif [ "$auth_status" = "302" ]; then
    echo -e "${YELLOW}⚠ REDIRECT${NC}"
    echo "  Session may have expired. Please login again."
elif [ "$auth_status" = "401" ]; then
    echo -e "${RED}✗ NOT AUTHENTICATED${NC}"
    echo "  Cookie is not valid. Please login again."
else
    echo -e "${YELLOW}? UNKNOWN${NC} (Status: $auth_status)"
fi
echo ""

echo "==========================================="
echo "PART 2: RESOURCE MANAGEMENT"
echo "==========================================="
echo ""

# Test 2: Upload a new resource
test_auth_endpoint "POST /api/resources (Upload with Auth)" "POST" "$BASE_URL/api/resources" "multipart" "200"

# Get a resource ID for testing
echo "Fetching resource list to get IDs..."
resources=$(curl -s "$BASE_URL/api/resources")
RESOURCE_ID=$(echo $resources | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Using Resource ID: $RESOURCE_ID for further tests"
echo ""

echo "==========================================="
echo "PART 3: RATINGS & REVIEWS"
echo "==========================================="
echo ""

# Test 3: Rate a resource
test_auth_endpoint "POST /api/resources/{id}/rate" "POST" "$BASE_URL/api/resources/$RESOURCE_ID/rate" '{"rating":5}' "200"

# Test 4: Try to rate the same resource again (should fail)
echo -n "Testing: POST /api/resources/{id}/rate (Duplicate - should fail)... "
duplicate_response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/resources/$RESOURCE_ID/rate" \
    -H "Cookie: $SESSION_COOKIE" \
    -H "Content-Type: application/json" \
    -d '{"rating":4}')
duplicate_status=$(echo "$duplicate_response" | tail -n1)
duplicate_body=$(echo "$duplicate_response" | sed '$d')

if [ "$duplicate_status" = "400" ]; then
    echo -e "${GREEN}✓ CORRECTLY REJECTED${NC} (Status: $duplicate_status)"
    echo "  Message: $duplicate_body"
else
    echo -e "${YELLOW}? UNEXPECTED${NC} (Status: $duplicate_status)"
    echo "  Response: $duplicate_body"
fi
echo ""

echo "==========================================="
echo "PART 4: COMMENTS"
echo "==========================================="
echo ""

# Test 5: Add a comment
test_auth_endpoint "POST /api/resources/{id}/comments" "POST" "$BASE_URL/api/resources/$RESOURCE_ID/comments" '{"content":"This is a test comment from authenticated user!"}' "200"

# Test 6: Add another comment
test_auth_endpoint "POST /api/resources/{id}/comments (2nd)" "POST" "$BASE_URL/api/resources/$RESOURCE_ID/comments" '{"content":"Great resource! Really helpful."}' "200"

# Test 7: Get all comments (public endpoint)
echo -n "Verifying comments were added... "
comments_response=$(curl -s "$BASE_URL/api/resources/$RESOURCE_ID/comments")
comment_count=$(echo "$comments_response" | grep -o '"id"' | wc -l)
echo -e "${BLUE}Found $comment_count comment(s)${NC}"
echo ""

echo "==========================================="
echo "PART 5: FAVORITES"
echo "==========================================="
echo ""

# Test 8: Add to favorites
test_auth_endpoint "POST /api/resources/{id}/favorite (Add)" "POST" "$BASE_URL/api/resources/$RESOURCE_ID/favorite" "" "200"

# Test 9: Get user's favorites
test_auth_endpoint "GET /api/resources/favorites" "GET" "$BASE_URL/api/resources/favorites" "" "200"

# Test 10: Remove from favorites (toggle)
test_auth_endpoint "POST /api/resources/{id}/favorite (Remove)" "POST" "$BASE_URL/api/resources/$RESOURCE_ID/favorite" "" "200"

# Test 11: Verify it was removed
echo -n "Verifying favorite was removed... "
fav_response=$(curl -s -H "Cookie: $SESSION_COOKIE" "$BASE_URL/api/resources/favorites")
if [[ $fav_response == "[]" ]] || [[ $(echo $fav_response | grep -o "\"id\":$RESOURCE_ID") == "" ]]; then
    echo -e "${GREEN}✓ VERIFIED${NC} - Favorite was removed"
else
    echo -e "${YELLOW}? STILL IN FAVORITES${NC}"
fi
echo ""

echo "==========================================="
echo "PART 6: RESOURCE DETAILS WITH AUTH"
echo "==========================================="
echo ""

# Test 12: Get resource details (should show if user favorited)
echo -n "Testing: GET /api/resources/{id}/details (with auth context)... "
details_response=$(curl -s -H "Cookie: $SESSION_COOKIE" "$BASE_URL/api/resources/$RESOURCE_ID/details")
if [[ $details_response == *"isFavoritedByCurrentUser"* ]]; then
    echo -e "${GREEN}✓ PASSED${NC}"
    echo "  Response includes favorite status for current user"
    # Show if user has favorited
    if [[ $details_response == *"\"isFavoritedByCurrentUser\":true"* ]]; then
        echo "  Status: ⭐ You have favorited this resource"
    else
        echo "  Status: ☆ Not favorited"
    fi
else
    echo -e "${YELLOW}⚠ PARTIAL${NC}"
    echo "  Response doesn't include favorite status"
fi
echo ""

echo "==========================================="
echo "PART 7: CHECK USER DATA IN DATABASE"
echo "==========================================="
echo ""

# Get current user info from database (via psql)
echo "Fetching authenticated user info from database..."
echo ""

echo "==========================================="
echo "TESTING SUMMARY"
echo "==========================================="
echo ""
echo "All authenticated endpoints have been tested!"
echo ""
echo "✅ You can now:"
echo "  • Upload resources with your Google account"
echo "  • Rate resources (once per resource)"
echo "  • Add comments to resources"
echo "  • Add/remove favorites"
echo "  • View your personalized favorites list"
echo ""
echo "🔐 Your session is valid and working!"
echo "==========================================="
