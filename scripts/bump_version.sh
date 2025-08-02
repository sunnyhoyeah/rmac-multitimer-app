#!/bin/bash

# Version bump script for RMAC MultiTimer
# Usage: ./scripts/bump_version.sh [major|minor|patch]

set -e

# Default to patch if no argument provided
BUMP_TYPE=${1:-patch}

# Validate bump type
if [[ ! "$BUMP_TYPE" =~ ^(major|minor|patch)$ ]]; then
    echo "Error: Invalid bump type. Use 'major', 'minor', or 'patch'"
    exit 1
fi

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | cut -d' ' -f2 | cut -d'+' -f1)
CURRENT_BUILD=$(grep '^version:' pubspec.yaml | cut -d'+' -f2)

echo "Current version: $CURRENT_VERSION+$CURRENT_BUILD"

# Parse version parts
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Calculate new version
case "$BUMP_TYPE" in
    "major")
        NEW_VERSION="$((MAJOR + 1)).0.0"
        ;;
    "minor")
        NEW_VERSION="$MAJOR.$((MINOR + 1)).0"
        ;;
    "patch")
        NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
        ;;
esac

# Increment build number
NEW_BUILD=$((CURRENT_BUILD + 1))

echo "New version: $NEW_VERSION+$NEW_BUILD"

# Update pubspec.yaml
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^version:.*/version: $NEW_VERSION+$NEW_BUILD/" pubspec.yaml
else
    # Linux
    sed -i "s/^version:.*/version: $NEW_VERSION+$NEW_BUILD/" pubspec.yaml
fi

echo "✅ Version updated successfully!"
echo "📝 Don't forget to commit your changes:"
echo "   git add pubspec.yaml"
echo "   git commit -m \"chore: bump version to $NEW_VERSION+$NEW_BUILD\""
echo "   git tag v$NEW_VERSION"
echo "   git push origin main --tags"
