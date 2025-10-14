#!/bin/bash
#
# Install Git hooks for Gavrila AI development
#
# This script installs the required Git hooks from scripts/hooks/ to .git/hooks/
# Run this script once after cloning the repository.
#
# Usage: ./scripts/install-hooks.sh
#

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

echo -e "${BLUE}=== Installing Git Hooks for Gavrila AI ===${NC}"
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    echo "Please run this script from the repository root."
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Warning: jq is not installed.${NC}"
    echo "The pre-commit hook requires jq to function."
    echo "Please install jq:"
    echo "  macOS: brew install jq"
    echo "  Ubuntu/Debian: sudo apt-get install jq"
    echo "  Other: https://stedolan.github.io/jq/download/"
    echo ""
    echo -e "${YELLOW}Continuing with installation, but hooks will fail until jq is installed.${NC}"
    echo ""
fi

# Check if hooks directory exists
if [ ! -d "scripts/hooks" ]; then
    echo -e "${RED}Error: scripts/hooks directory not found${NC}"
    exit 1
fi

# Create .git/hooks directory if it doesn't exist
mkdir -p .git/hooks

# Install each hook
installed_count=0
skipped_count=0

for hook_file in scripts/hooks/*; do
    if [ ! -f "$hook_file" ]; then
        continue
    fi
    
    hook_name=$(basename "$hook_file")
    target_path=".git/hooks/$hook_name"
    
    # Check if hook already exists
    if [ -f "$target_path" ]; then
        echo -e "${YELLOW}Hook already exists: $hook_name${NC}"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "  ${BLUE}Skipped${NC}"
            skipped_count=$((skipped_count + 1))
            continue
        fi
    fi
    
    # Copy hook to .git/hooks
    cp "$hook_file" "$target_path"
    
    # Make it executable
    chmod +x "$target_path"
    
    echo -e "${GREEN}✓ Installed: $hook_name${NC}"
    installed_count=$((installed_count + 1))
done

echo ""
echo -e "${BLUE}=== Installation Summary ===${NC}"
echo -e "${GREEN}Hooks installed: $installed_count${NC}"
if [ $skipped_count -gt 0 ]; then
    echo -e "${YELLOW}Hooks skipped: $skipped_count${NC}"
fi
echo ""

if [ $installed_count -gt 0 ]; then
    echo -e "${GREEN}✓ Git hooks successfully installed!${NC}"
    echo ""
    echo "Installed hooks:"
    echo "  - pre-commit: Strips pinData from n8n workflow files before commit"
    echo ""
    echo "You're all set for development!"
else
    echo -e "${YELLOW}No hooks were installed.${NC}"
fi

echo ""
echo "For more information, see DEVELOPMENT.md"

exit 0

