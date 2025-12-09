#!/bin/bash
# Script to commit and push the eq-frontend container setup

set -e

echo "=== Equicrew Frontend Container Setup - Commit & Push ==="
echo ""

# Check if we're on eq-dev branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "eq-dev" ]; then
    echo "❌ Error: Not on eq-dev branch (currently on: $CURRENT_BRANCH)"
    echo "Switch to eq-dev first: git checkout eq-dev"
    exit 1
fi

echo "✓ On eq-dev branch"
echo ""

# Show what will be committed
echo "Files to be committed:"
git status --short addon/ .github/workflows/build-container.yml .gitignore docs/CONTAINER-BUILD.md

echo ""
echo "Do you want to commit and push these files? (y/n)"
read -r CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Aborted."
    exit 0
fi

# Add files
echo ""
echo "Adding files..."
git add addon/
git add .github/workflows/build-container.yml
git add .gitignore
git add docs/CONTAINER-BUILD.md

# Commit
echo ""
echo "Committing..."
git commit -m "Add eq-frontend container build setup

- Multi-stage Dockerfile (Node.js build + Alpine runtime)
- GitHub Actions workflow for multi-arch builds (aarch64, amd64, armv7, armhf, i386)
- Add-on configuration (config.yaml, build.yaml)
- Documentation for container build process
- Images will be pushed to ghcr.io/behindvillager/eq-frontend-{arch}"

# Push
echo ""
echo "Pushing to origin/eq-dev..."
git push origin eq-dev

echo ""
echo "✅ Done!"
echo ""
echo "Next steps:"
echo "1. Go to https://github.com/behindvillager/eq-frontend/actions"
echo "2. Watch the build progress (takes ~30-45 minutes)"
echo "3. Verify images on GHCR:"
echo "   docker pull ghcr.io/behindvillager/eq-frontend-amd64:latest"
echo "4. Test locally:"
echo "   docker run -d -p 8099:8099 ghcr.io/behindvillager/eq-frontend-amd64:latest"
echo "5. Update OS build configuration to use your container"
