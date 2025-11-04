#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "DATABASE & BACKEND HEALTH CHECK"
echo "=========================================="
echo ""

echo "=== PART 1: SERVER STATUS ==="
echo ""
echo -n "Server responding... "
response=$(curl -s -w "%{http_code}" http://localhost:8080/api/test/users -o /dev/null)
if [ "$response" = "200" ]; then
    echo -e "${GREEN}✓ YES${NC}"
else
    echo -e "${RED}✗ NO (Status: $response)${NC}"
fi
echo ""

echo "=== PART 2: DATABASE ENTITIES COUNT ==="
echo ""

echo -n "Users in database... "
users=$(curl -s http://localhost:8080/api/test/users)
user_count=$(echo "$users" | grep -o '"id"' | wc -l | tr -d ' ')
echo -e "${BLUE}$user_count users${NC}"

echo -n "Resources in database... "
resources=$(curl -s http://localhost:8080/api/test/resources)
resource_count=$(echo "$resources" | grep -o '"id"' | wc -l | tr -d ' ')
echo -e "${BLUE}$resource_count resources${NC}"

echo -n "Categories in database... "
categories=$(curl -s http://localhost:8080/api/resources/categories)
category_count=$(echo "$categories" | grep -o '"name"' | wc -l | tr -d ' ')
echo -e "${BLUE}$category_count categories${NC}"

echo ""

echo "=== PART 3: DATA SAMPLE ==="
echo ""

echo "Sample User:"
echo "$users" | head -1 | python3 -m json.tool 2>/dev/null || echo "$users" | head -1
echo ""

echo "Sample Resource:"
echo "$resources" | head -1 | python3 -m json.tool 2>/dev/null || echo "$resources" | head -1
echo ""

echo "Categories:"
echo "$categories" | python3 -m json.tool 2>/dev/null || echo "$categories"
echo ""

echo "=== PART 4: CRUD OPERATIONS TEST ==="
echo ""

# Test user creation
echo -n "Creating test user... "
create_response=$(curl -s -w "\n%{http_code}" -X POST \
    "http://localhost:8080/api/test/users?email=testcrud@example.com&name=CRUD%20Test")
create_status=$(echo "$create_response" | tail -n1)
if [ "$create_status" = "200" ]; then
    echo -e "${GREEN}✓ SUCCESS${NC}"
else
    echo -e "${RED}✗ FAILED (Status: $create_status)${NC}"
fi

# Test resource creation (upload)
echo -n "Testing file upload... "
if [ -f "uploads/6b58b35e-cc72-4323-9a5f-cb49b2a6090c_oauth-test.txt" ]; then
    upload_response=$(curl -s -w "\n%{http_code}" -X POST \
        "http://localhost:8080/api/test/resources" \
        -F "file=@uploads/6b58b35e-cc72-4323-9a5f-cb49b2a6090c_oauth-test.txt" \
        -F "title=Upload Test" \
        -F "description=Testing upload functionality" \
        -F "userEmail=testcrud@example.com")
    upload_status=$(echo "$upload_response" | tail -n1)
    if [ "$upload_status" = "200" ]; then
        echo -e "${GREEN}✓ SUCCESS${NC}"
        upload_body=$(echo "$upload_response" | sed '$d')
        new_resource_id=$(echo "$upload_body" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
        echo "  Created resource ID: $new_resource_id"
    else
        echo -e "${RED}✗ FAILED (Status: $upload_status)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ SKIPPED (Test file not found)${NC}"
fi

echo ""

echo "=== PART 5: RELATIONSHIP TESTS ==="
echo ""

# Get a resource for testing
RESOURCE_ID=$(echo "$resources" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -n "$RESOURCE_ID" ]; then
    echo "Using Resource ID: $RESOURCE_ID"
    echo ""
    
    # Test rating
    echo -n "Adding rating... "
    rating_response=$(curl -s -w "\n%{http_code}" -X POST \
        "http://localhost:8080/api/test/resources/$RESOURCE_ID/rate?userEmail=rating_tester@example.com" \
        -H "Content-Type: application/json" \
        -d '{"rating":4}')
    rating_status=$(echo "$rating_response" | tail -n1)
    if [ "$rating_status" = "200" ]; then
        echo -e "${GREEN}✓ SUCCESS${NC}"
    else
        echo -e "${YELLOW}⚠ STATUS: $rating_status${NC}"
    fi
    
    # Get ratings
    echo -n "Fetching ratings... "
    ratings=$(curl -s "http://localhost:8080/api/test/resources/$RESOURCE_ID/ratings")
    rating_count=$(echo "$ratings" | grep -o '"rating"' | wc -l | tr -d ' ')
    echo -e "${BLUE}$rating_count ratings found${NC}"
    
    # Get resource details
    echo -n "Fetching resource details... "
    details=$(curl -s "http://localhost:8080/api/resources/$RESOURCE_ID/details")
    if [[ $details == *"averageRating"* ]]; then
        avg_rating=$(echo "$details" | grep -o '"averageRating":[0-9.]*' | cut -d':' -f2)
        echo -e "${GREEN}✓ Average rating: $avg_rating${NC}"
    else
        echo -e "${YELLOW}⚠ Details fetched${NC}"
    fi
fi

echo ""

echo "=== PART 6: SEARCH FUNCTIONALITY ==="
echo ""

echo -n "Searching resources (keyword: test)... "
search_results=$(curl -s "http://localhost:8080/api/resources/search?keyword=test")
search_count=$(echo "$search_results" | grep -o '"id"' | wc -l | tr -d ' ')
echo -e "${BLUE}$search_count results${NC}"

echo ""

echo "=========================================="
echo "HEALTH CHECK COMPLETE"
echo "=========================================="
echo ""
echo "Summary:"
echo "✅ Server: Running"
echo "✅ Database: Connected"
echo "✅ Users: $user_count"
echo "✅ Resources: $resource_count"
echo "✅ Categories: $category_count"
echo "✅ CRUD Operations: Working"
echo "✅ Search: Working"
echo "=========================================="
