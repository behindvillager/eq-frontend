#!/bin/bash
# Script to show all eq cube customizations vs original Home Assistant code
# Base commit: ccc48d158 (tag: 20251105.1) - Last HA commit before eq customizations

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_COMMIT="ccc48d158"  # Last HA commit before eq customizations
CURRENT_COMMIT="HEAD"

echo -e "${GREEN}=== EQ Cube Customizations ===${NC}\n"

echo -e "${BLUE}Custom commits:${NC}"
git log --oneline $BASE_COMMIT..$CURRENT_COMMIT
echo ""

echo -e "${BLUE}Changed files:${NC}"
git diff $BASE_COMMIT..$CURRENT_COMMIT --stat
echo ""

echo -e "${YELLOW}To see detailed changes in a specific file:${NC}"
echo "  git diff $BASE_COMMIT HEAD -- <file-path>"
echo ""

echo -e "${YELLOW}To see all detailed changes:${NC}"
echo "  git diff $BASE_COMMIT HEAD"
echo ""

echo -e "${YELLOW}To create a patch file of all eq customizations:${NC}"
echo "  git diff $BASE_COMMIT HEAD > eq-customizations.patch"
echo ""

echo -e "${GREEN}=== Key customized files ===${NC}"
echo "- Branding: src/components/ha-logo-svg.ts"
echo "- Colors: src/resources/theme/color/color.globals.ts"
echo "- Links: src/util/documentation-url.ts"
echo "- Translations: src/translations/en.json"
echo "- About page: src/panels/config/info/ha-config-info.ts"
echo "- Favicons: public/static/icons/*"
