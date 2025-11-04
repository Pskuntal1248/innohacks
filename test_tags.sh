#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:8080"

echo "=========================================="
echo "TAG SYSTEM TESTING"
echo "=========================================="
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
        response=$(curl -s -w "\n%{http_code}" -X POST "$url" \
            -H "Content-Type: application/json" \
            -d "$data")
    elif [ "$method" = "DELETE" ]; then
        response=$(curl -s -w "\n%{http_code}" -X DELETE "$url")
    fi
    
    status_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "${GREEN}✓ PASSED${NC} (Status: $status_code)"
        if [[ $body != "" ]] && [[ ${#body} -lt 200 ]]; then
            echo "  Response: $body"
        fi
    else
        echo -e "${RED}✗ FAILED${NC} (Expected: $expected_status, Got: $status_code)"
        echo "  Response: ${body:0:300}"
    fi
    echo ""
}

echo "=== PART 1: GET ALL TAGS ==="
echo ""
test_endpoint "GET /api/tags" "GET" "$BASE_URL/api/tags" "" "200"

echo "=== PART 2: CREATE NEW TAGS ==="
echo ""
test_endpoint "POST /api/tags (Technology)" "POST" "$BASE_URL/api/tags" '{"name":"Technology"}' "200"
test_endpoint "POST /api/tags (Science)" "POST" "$BASE_URL/api/tags" '{"name":"Science"}' "200"
test_endpoint "POST /api/tags (Education)" "POST" "$BASE_URL/api/tags" '{"name":"Education"}' "200"
test_endpoint "POST /api/tags (Programming)" "POST" "$BASE_URL/api/tags" '{"name":"Programming"}' "200"
test_endpoint "POST /api/tags (AI/ML)" "POST" "$BASE_URL/api/tags" '{"name":"AI/ML"}' "200"

echo "=== PART 3: CHECK FOR DUPLICATES ==="
echo ""
test_endpoint "POST /api/tags (Duplicate)" "POST" "$BASE_URL/api/tags" '{"name":"Technology"}' "409"

echo "=== PART 4: GET ALL TAGS AGAIN ==="
echo ""
echo "Fetching all tags..."
all_tags=$(curl -s "$BASE_URL/api/tags")
tag_count=$(echo "$all_tags" | grep -o '"id"' | wc -l | tr -d ' ')
echo -e "${BLUE}Total tags: $tag_count${NC}"
echo ""

# Get a tag ID for further testing
TAG_ID=$(echo $all_tags | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Using Tag ID: $TAG_ID for testing"
echo ""

echo "=== PART 5: GET SINGLE TAG ==="
echo ""
test_endpoint "GET /api/tags/{id}" "GET" "$BASE_URL/api/tags/$TAG_ID" "" "200"

echo "=== PART 6: UPDATE TAG ==="
echo ""
test_endpoint "POST /api/tags/{id} (Update name)" "POST" "$BASE_URL/api/tags/$TAG_ID" '{"name":"Tech & Innovation"}' "200"

echo "=== PART 7: TAG RESOURCES ==="
echo ""

# Get a resource ID for tagging
echo "Fetching resources..."
resources=$(curl -s "$BASE_URL/api/test/resources")
RESOURCE_ID=$(echo $resources | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "Using Resource ID: $RESOURCE_ID"
echo ""

# Create a tag specifically for this resource
echo "Creating a specific tag for testing..."
tag_response=$(curl -s -X POST "$BASE_URL/api/tags" \
    -H "Content-Type: application/json" \
    -d '{"name":"TestTag123"}')
TEST_TAG_ID=$(echo $tag_response | grep -o '"id":[0-9]*' | cut -d':' -f2)
echo "Created tag with ID: $TEST_TAG_ID"
echo ""

test_endpoint "POST /api/tags/{tagId}/resources/{resourceId}" "POST" "$BASE_URL/api/tags/$TEST_TAG_ID/resources/$RESOURCE_ID" "" "200"

echo "=== PART 8: GET RESOURCES BY TAG ==="
echo ""
test_endpoint "GET /api/tags/{id}/resources" "GET" "$BASE_URL/api/tags/$TEST_TAG_ID/resources" "" "200"

echo "=== PART 9: GET TAGS FOR A RESOURCE ==="
echo ""
test_endpoint "GET /api/resources/{id}/tags" "GET" "$BASE_URL/api/resources/$RESOURCE_ID/tags" "" "200"

echo "=== PART 10: REMOVE TAG FROM RESOURCE ==="
echo ""
test_endpoint "DELETE /api/tags/{tagId}/resources/{resourceId}" "DELETE" "$BASE_URL/api/tags/$TEST_TAG_ID/resources/$RESOURCE_ID" "" "200"

echo "=== PART 11: VERIFY TAG WAS REMOVED ==="
echo ""
echo "Checking resources for this tag..."
tag_resources=$(curl -s "$BASE_URL/api/tags/$TEST_TAG_ID/resources")
if [[ $tag_resources == "[]" ]]; then
    echo -e "${GREEN}✓ VERIFIED${NC} - Tag has no resources"
else
    echo -e "${YELLOW}⚠ WARNING${NC} - Tag still has resources"
fi
echo ""

echo "=== PART 12: DELETE TAG ==="
echo ""
test_endpoint "DELETE /api/tags/{id}" "DELETE" "$BASE_URL/api/tags/$TEST_TAG_ID" "" "200"

echo "=== PART 13: SEARCH TAGS ==="
echo ""
test_endpoint "GET /api/tags/search?query=tech" "GET" "$BASE_URL/api/tags/search?query=tech" "" "200"

echo "=========================================="
echo "TAG SYSTEM TESTING COMPLETE"
echo "=========================================="
echo ""
echo "Summary:"
echo "✅ All tag management endpoints tested"
echo "✅ Tag-resource association tested"
echo "✅ Duplicate prevention tested"
echo "✅ Search functionality tested"
echo "=========================================="
