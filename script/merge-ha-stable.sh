#!/bin/bash
# Merge Strategy: Integrate new HA stable release into eq-dev
# 
# This script helps merge a new Home Assistant stable release into your eq-dev branch
# while preserving all eq cube customizations.
#
# WORKFLOW:
# 1. New HA stable release appears (e.g., 2024.12.0)
# 2. Update ha-master branch to that tag
# 3. Merge ha-master into eq-dev
# 4. Resolve conflicts (keep eq customizations!)
# 5. Test thoroughly
# 6. Build and deploy to eq-main

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

set -e  # Exit on error

# Check if HA version tag is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Please provide HA version tag${NC}"
    echo "Usage: ./merge-ha-stable.sh <version-tag>"
    echo "Example: ./merge-ha-stable.sh 2024.12.0"
    exit 1
fi

HA_VERSION=$1
BASE_COMMIT="ccc48d158"  # Last HA commit before eq customizations

echo -e "${GREEN}=== Merging Home Assistant $HA_VERSION into eq-dev ===${NC}\n"

# Step 1: Ensure we're on eq-dev
echo -e "${BLUE}Step 1: Checking out eq-dev branch...${NC}"
git checkout eq-dev
git pull origin eq-dev
echo ""

# Step 2: Update ha-master branch
echo -e "${BLUE}Step 2: Updating ha-master branch to $HA_VERSION...${NC}"
cd /workspaces/ha-master
git fetch origin
git checkout ha-master
git pull origin ha-master
git fetch upstream tag $HA_VERSION
git merge $HA_VERSION --no-edit
git push origin ha-master
cd /workspaces/frontend
echo ""

# Step 3: Show what will be merged
echo -e "${BLUE}Step 3: Preview of changes from HA...${NC}"
git fetch ../ha-master ha-master:ha-master-temp
git log --oneline eq-dev..ha-master-temp --max-count=20
echo ""

# Step 4: Create backup branch
BACKUP_BRANCH="eq-dev-backup-$(date +%Y%m%d-%H%M%S)"
echo -e "${BLUE}Step 4: Creating backup branch: $BACKUP_BRANCH${NC}"
git branch $BACKUP_BRANCH
echo ""

# Step 5: Attempt merge
echo -e "${BLUE}Step 5: Starting merge...${NC}"
echo -e "${YELLOW}If conflicts occur, you'll need to resolve them manually.${NC}"
echo -e "${YELLOW}Key files to watch for conflicts:${NC}"
echo "  - src/components/ha-logo-svg.ts (eq logo)"
echo "  - src/resources/theme/color/*.ts (green theme)"
echo "  - src/util/documentation-url.ts (equicrew links)"
echo "  - src/translations/en.json (eq cube text)"
echo "  - src/panels/config/info/ha-config-info.ts (about page)"
echo ""

if git merge ha-master-temp --no-edit; then
    echo -e "${GREEN}✓ Merge completed successfully without conflicts!${NC}"
    git branch -D ha-master-temp
else
    echo -e "${RED}✗ Merge has conflicts!${NC}"
    echo -e "${YELLOW}To resolve:${NC}"
    echo "  1. git status  # See conflicted files"
    echo "  2. Edit conflicted files (keep eq customizations!)"
    echo "  3. git add <resolved-files>"
    echo "  4. git merge --continue"
    echo ""
    echo -e "${YELLOW}To see your original eq customizations:${NC}"
    echo "  git diff $BASE_COMMIT $BACKUP_BRANCH -- <file-path>"
    echo ""
    echo -e "${YELLOW}To abort the merge:${NC}"
    echo "  git merge --abort"
    echo "  git checkout $BACKUP_BRANCH"
    exit 1
fi

# Step 6: Show summary
echo ""
echo -e "${GREEN}=== Merge Summary ===${NC}"
echo -e "${BLUE}Merged commits:${NC}"
git log --oneline $BACKUP_BRANCH..HEAD --max-count=10
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Test the merged code: script/develop"
echo "  2. Check all eq customizations are intact: ./script/show-eq-changes.sh"
echo "  3. Run build: script/build_frontend"
echo "  4. If all good: git push origin eq-dev"
echo "  5. Then merge to eq-main and create release"
