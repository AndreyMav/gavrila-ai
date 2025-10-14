#!/bin/bash
#
# Strip pinData from all n8n workflow JSON files
#
# This script removes the "pinData" field from all n8n workflow files
# in the n8n/ directory. Useful for cleaning up existing files or
# running manually before committing.
#
# Usage: ./scripts/strip-n8n-pindata.sh

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the repository root directory
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo -e "${BLUE}=== Stripping pinData from n8n workflow files ===${NC}"
echo ""

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is not installed.${NC}"
    echo "Please install jq to use this script:"
    echo "  macOS: brew install jq"
    echo "  Ubuntu/Debian: sudo apt-get install jq"
    echo "  Other: https://stedolan.github.io/jq/download/"
    exit 1
fi

# Check if n8n directory exists
if [ ! -d "n8n" ]; then
    echo -e "${RED}Error: n8n directory not found${NC}"
    exit 1
fi

# Find all JSON files in n8n directory
# Use process substitution to handle filenames with spaces
if [ ! "$(find n8n -name "*.json" -type f | wc -l)" -gt 0 ]; then
    echo -e "${YELLOW}No JSON files found in n8n directory${NC}"
    exit 0
fi

modified_count=0
skipped_count=0
total_count=0

# Process files using while loop to handle spaces in filenames
while IFS= read -r -d '' file; do
    total_count=$((total_count + 1))
    
    # Check if the file contains pinData
    if jq -e '.pinData' "$file" > /dev/null 2>&1; then
        has_data=$(jq '.pinData | length' "$file")
        
        if [ "$has_data" -gt 0 ]; then
            echo -e "${YELLOW}Processing: $file${NC}"
            
            # Show what's being removed
            echo -e "  Removing pinData for nodes: $(jq -r '.pinData | keys | join(", ")' "$file")"
            
            # Create a temporary file
            temp_file=$(mktemp)
            
            # Remove pinData and write to temp file
            jq 'del(.pinData)' "$file" > "$temp_file"
            
            # Replace original file
            mv "$temp_file" "$file"
            
            echo -e "  ${GREEN}✓ Stripped pinData${NC}"
            modified_count=$((modified_count + 1))
        else
            echo -e "${GREEN}Skipping: $file (empty pinData)${NC}"
            skipped_count=$((skipped_count + 1))
        fi
    else
        echo -e "${GREEN}Skipping: $file (no pinData)${NC}"
        skipped_count=$((skipped_count + 1))
    fi
done < <(find n8n -name "*.json" -type f -print0)

echo ""
echo -e "${BLUE}=== Summary ===${NC}"
echo -e "Total files processed: $total_count"
echo -e "${GREEN}Files modified: $modified_count${NC}"
echo -e "Files skipped: $skipped_count"
echo ""

if [ $modified_count -gt 0 ]; then
    echo -e "${YELLOW}Note: Modified files need to be staged and committed${NC}"
    echo -e "Run: ${BLUE}git add n8n/*.json && git commit -m 'Remove pinData from n8n workflows'${NC}"
fi

exit 0

