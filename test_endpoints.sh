#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:8080"
TEST_USER_EMAIL="testuser@example.com"

echo "=================================="
echo "API ENDPOINT TESTING REPORT"
echo "=================================="
echo ""

# Function to test an endpoint
test_endpoint() {
    local name=$1
    local method=$2
    local url=$3
    local data=$4
    local expected_status=$5
    
    echo -n "Testing: $name... "
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$url")
    elif [ "$method" = "POST" ]; then
        if [[ $data == *"multipart"* ]]; then
            # Handle file upload
            response=$(curl -s -w "\n%{http_code}" -X POST "$url" \
                -F "file=@uploads/6b58b35e-cc72-4323-9a5f-cb49b2a6090c_oauth-test.txt" \
                -F "title=Test Resource" \
                -F "description=Test Description" \
                -F "userEmail=$TEST_USER_EMAIL")
        else
            response=$(curl -s -w "\n%{http_code}" -X POST "$url" \
                -H "Content-Type: application/json" \
                -d "$data")
        fi
    fi
    
    status_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "${GREEN}✓ PASSED${NC} (Status: $status_code)"
    else
        echo -e "${RED}✗ FAILED${NC} (Expected: $expected_status, Got: $status_code)"
        echo "Response: $body"
    fi
}

echo "=== TEST CONTROLLER ENDPOINTS (No Auth Required) ==="
echo ""

# 1. List all resources
test_endpoint "GET /api/test/resources" "GET" "$BASE_URL/api/test/resources" "" "200"

# 2. Create test user
test_endpoint "POST /api/test/users" "POST" "$BASE_URL/api/test/users?email=$TEST_USER_EMAIL&name=Test%20User" "" "200"

# 3. List all users
test_endpoint "GET /api/test/users" "GET" "$BASE_URL/api/test/users" "" "200"

# 4. Upload a resource
test_endpoint "POST /api/test/resources (Upload)" "POST" "$BASE_URL/api/test/resources" "multipart" "200"

# Get the resource ID from the list (we'll use ID 1 for testing)
echo ""
echo "Fetching resource ID for further tests..."
resources_response=$(curl -s "$BASE_URL/api/test/resources")
RESOURCE_ID=$(echo $resources_response | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -z "$RESOURCE_ID" ]; then
    echo -e "${YELLOW}No resources found. Some tests will be skipped.${NC}"
    RESOURCE_ID=1
else
    echo "Using Resource ID: $RESOURCE_ID"
fi
echo ""

# 5. Get single resource
test_endpoint "GET /api/test/resources/{id}" "GET" "$BASE_URL/api/test/resources/$RESOURCE_ID" "" "200"

# 6. Rate a resource
test_endpoint "POST /api/test/resources/{id}/rate" "POST" "$BASE_URL/api/test/resources/$RESOURCE_ID/rate?userEmail=rater@example.com" '{"rating":5}' "200"

# 7. Get resource ratings
test_endpoint "GET /api/test/resources/{id}/ratings" "GET" "$BASE_URL/api/test/resources/$RESOURCE_ID/ratings" "" "200"

# 8. Download a file (if exists)
if [ -f "uploads/6b58b35e-cc72-4323-9a5f-cb49b2a6090c_oauth-test.txt" ]; then
    test_endpoint "GET /api/test/resources/download/{filename}" "GET" "$BASE_URL/api/test/resources/download/6b58b35e-cc72-4323-9a5f-cb49b2a6090c_oauth-test.txt" "" "200"
fi

echo ""
echo "=== RESOURCE CONTROLLER ENDPOINTS (May Require Auth) ==="
echo ""

# 9. List all resources (public)
test_endpoint "GET /api/resources" "GET" "$BASE_URL/api/resources" "" "200"

# 10. Get resource details
test_endpoint "GET /api/resources/{id}/details" "GET" "$BASE_URL/api/resources/$RESOURCE_ID/details" "" "200"

# 11. Get comments for resource
test_endpoint "GET /api/resources/{id}/comments" "GET" "$BASE_URL/api/resources/$RESOURCE_ID/comments" "" "200"

# 12. Search resources (no params)
test_endpoint "GET /api/resources/search" "GET" "$BASE_URL/api/resources/search" "" "200"

# 13. Search resources (with keyword)
test_endpoint "GET /api/resources/search?keyword=test" "GET" "$BASE_URL/api/resources/search?keyword=test" "" "200"

# 14. Get all categories
test_endpoint "GET /api/resources/categories" "GET" "$BASE_URL/api/resources/categories" "" "200"

# 15. Increment download count
test_endpoint "POST /api/resources/download/{id}/increment" "POST" "$BASE_URL/api/resources/download/$RESOURCE_ID/increment" "" "200"

echo ""
echo "=== ENDPOINTS REQUIRING AUTHENTICATION (Expected to fail without OAuth) ==="
echo ""

# 16. Upload resource (requires auth)
echo -n "Testing: POST /api/resources (Upload - Auth Required)... "
response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/resources" \
    -F "file=@uploads/6b58b35e-cc72-4323-9a5f-cb49b2a6090c_oauth-test.txt" \
    -F "title=Test" \
    -F "description=Test")
status_code=$(echo "$response" | tail -n1)
if [ "$status_code" = "401" ] || [ "$status_code" = "302" ]; then
    echo -e "${GREEN}✓ CORRECTLY PROTECTED${NC} (Status: $status_code)"
else
    echo -e "${YELLOW}? UNEXPECTED${NC} (Status: $status_code)"
fi

# 17. Rate resource (requires auth)
echo -n "Testing: POST /api/resources/{id}/rate (Auth Required)... "
response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/resources/$RESOURCE_ID/rate" \
    -H "Content-Type: application/json" \
    -d '{"rating":5}')
status_code=$(echo "$response" | tail -n1)
if [ "$status_code" = "401" ] || [ "$status_code" = "302" ]; then
    echo -e "${GREEN}✓ CORRECTLY PROTECTED${NC} (Status: $status_code)"
else
    echo -e "${YELLOW}? UNEXPECTED${NC} (Status: $status_code)"
fi

# 18. Add comment (requires auth)
echo -n "Testing: POST /api/resources/{id}/comments (Auth Required)... "
response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/resources/$RESOURCE_ID/comments" \
    -H "Content-Type: application/json" \
    -d '{"content":"Test comment"}')
status_code=$(echo "$response" | tail -n1)
if [ "$status_code" = "401" ] || [ "$status_code" = "302" ]; then
    echo -e "${GREEN}✓ CORRECTLY PROTECTED${NC} (Status: $status_code)"
else
    echo -e "${YELLOW}? UNEXPECTED${NC} (Status: $status_code)"
fi

# 19. Toggle favorite (requires auth)
echo -n "Testing: POST /api/resources/{id}/favorite (Auth Required)... "
response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/resources/$RESOURCE_ID/favorite")
status_code=$(echo "$response" | tail -n1)
if [ "$status_code" = "401" ] || [ "$status_code" = "302" ]; then
    echo -e "${GREEN}✓ CORRECTLY PROTECTED${NC} (Status: $status_code)"
else
    echo -e "${YELLOW}? UNEXPECTED${NC} (Status: $status_code)"
fi

# 20. Get user favorites (requires auth)
echo -n "Testing: GET /api/resources/favorites (Auth Required)... "
response=$(curl -s -w "\n%{http_code}" "$BASE_URL/api/resources/favorites")
status_code=$(echo "$response" | tail -n1)
if [ "$status_code" = "401" ] || [ "$status_code" = "302" ]; then
    echo -e "${GREEN}✓ CORRECTLY PROTECTED${NC} (Status: $status_code)"
else
    echo -e "${YELLOW}? UNEXPECTED${NC} (Status: $status_code)"
fi

echo ""
echo "=================================="
echo "TESTING COMPLETE"
echo "=================================="
