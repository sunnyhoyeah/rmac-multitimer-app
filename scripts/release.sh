#!/bin/bash

# Git-Triggered Release Script for RMAC MultiTimer
# Usage: ./scripts/release.sh [patch|minor|major] [release_notes]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

VERSION_TYPE=${1:-patch}
RELEASE_NOTES=${2:-""}
DRY_RUN=${3:-false}

# Show usage
show_usage() {
    echo -e "${BLUE}🚀 Git-Triggered Release Script${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC} ./scripts/release.sh [version_type] [release_notes] [dry_run]"
    echo ""
    echo -e "${YELLOW}Version Types:${NC}"
    echo -e "  ${GREEN}patch${NC}  - Bug fixes (1.0.0 -> 1.0.1)"
    echo -e "  ${GREEN}minor${NC}  - New features (1.0.0 -> 1.1.0)"
    echo -e "  ${GREEN}major${NC}  - Breaking changes (1.0.0 -> 2.0.0)"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  ./scripts/release.sh patch \"Bug fixes and improvements\""
    echo -e "  ./scripts/release.sh minor \"New timer features added\""
    echo -e "  ./scripts/release.sh major \"Complete app redesign\""
    echo ""
    echo -e "${YELLOW}Beta/Alpha Releases:${NC}"
    echo -e "  ./scripts/release.sh patch \"Beta release\" --beta"
    echo -e "  ./scripts/release.sh minor \"Alpha testing\" --alpha"
    echo ""
    echo -e "${YELLOW}Dry Run (preview changes):${NC}"
    echo -e "  ./scripts/release.sh patch \"Test changes\" true"
    echo ""
    echo -e "${YELLOW}What this script does:${NC}"
    echo -e "  1. ✅ Validates git repository state"
    echo -e "  2. 📦 Bumps version in pubspec.yaml"
    echo -e "  3. 💾 Commits version changes"
    echo -e "  4. 🏷️  Creates git tag"
    echo -e "  5. 📤 Pushes to GitHub"
    echo -e "  6. 🤖 Triggers GitHub Actions deployment"
}

# Handle help command
if [[ "$1" == "help" || "$1" == "--help" || "$1" == "-h" ]]; then
    show_usage
    exit 0
fi

echo -e "${BLUE}🚀 RMAC MultiTimer - Git Release Automation${NC}"
echo -e "${BLUE}Version Type: $VERSION_TYPE${NC}"
echo ""

# Check for beta/alpha flags
PRERELEASE=""
if [[ "$3" == "--beta" || "$4" == "--beta" ]]; then
    PRERELEASE="-beta"
    echo -e "${YELLOW}🧪 Creating BETA release${NC}"
elif [[ "$3" == "--alpha" || "$4" == "--alpha" ]]; then
    PRERELEASE="-alpha"
    echo -e "${YELLOW}🧪 Creating ALPHA release${NC}"
fi

# Validate prerequisites
validate_prerequisites() {
    echo -e "${YELLOW}🔧 Validating prerequisites...${NC}"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}❌ Not in a git repository${NC}"
        exit 1
    fi
    
    # Check if we're in the right directory
    if [ ! -f "pubspec.yaml" ]; then
        echo -e "${RED}❌ Please run this script from the project root directory${NC}"
        exit 1
    fi
    
    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo -e "${RED}❌ You have uncommitted changes. Please commit or stash them first.${NC}"
        git status --short
        exit 1
    fi
    
    # Check if we're on main/master branch
    CURRENT_BRANCH=$(git branch --show-current)
    if [[ "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "master" ]]; then
        echo -e "${YELLOW}⚠️  You're on branch '$CURRENT_BRANCH', not 'main' or 'master'${NC}"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Check if we can push to origin
    if ! git ls-remote --exit-code origin > /dev/null 2>&1; then
        echo -e "${RED}❌ Cannot connect to origin remote${NC}"
        exit 1
    fi
    
    # Validate version type
    if [[ ! "$VERSION_TYPE" =~ ^(patch|minor|major)$ ]]; then
        echo -e "${RED}❌ Invalid version type. Use 'patch', 'minor', or 'major'${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prerequisites validated!${NC}"
}

# Get current version from pubspec.yaml
get_current_version() {
    CURRENT_VERSION=$(grep '^version:' pubspec.yaml | cut -d ' ' -f 2)
    if [[ -z "$CURRENT_VERSION" ]]; then
        echo -e "${RED}❌ Could not find version in pubspec.yaml${NC}"
        exit 1
    fi
    
    # Split version and build number
    IFS='+' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
    CURRENT_VERSION_NUMBER="${VERSION_PARTS[0]}"
    CURRENT_BUILD_NUMBER="${VERSION_PARTS[1]}"
    
    echo -e "${BLUE}Current version: $CURRENT_VERSION_NUMBER (build $CURRENT_BUILD_NUMBER)${NC}"
}

# Calculate new version
calculate_new_version() {
    IFS='.' read -ra VERSION_ARRAY <<< "$CURRENT_VERSION_NUMBER"
    MAJOR="${VERSION_ARRAY[0]}"
    MINOR="${VERSION_ARRAY[1]}"
    PATCH="${VERSION_ARRAY[2]}"
    
    case "$VERSION_TYPE" in
        "major")
            NEW_MAJOR=$((MAJOR + 1))
            NEW_MINOR=0
            NEW_PATCH=0
            ;;
        "minor")
            NEW_MAJOR=$MAJOR
            NEW_MINOR=$((MINOR + 1))
            NEW_PATCH=0
            ;;
        "patch")
            NEW_MAJOR=$MAJOR
            NEW_MINOR=$MINOR
            NEW_PATCH=$((PATCH + 1))
            ;;
    esac
    
    NEW_VERSION_NUMBER="$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH"
    NEW_BUILD_NUMBER=$((CURRENT_BUILD_NUMBER + 1))
    NEW_FULL_VERSION="$NEW_VERSION_NUMBER+$NEW_BUILD_NUMBER"
    NEW_TAG="v$NEW_VERSION_NUMBER$PRERELEASE"
    
    echo -e "${GREEN}New version: $NEW_VERSION_NUMBER (build $NEW_BUILD_NUMBER)${NC}"
    echo -e "${GREEN}New tag: $NEW_TAG${NC}"
}

# Generate automatic release notes if not provided
generate_release_notes() {
    if [[ -z "$RELEASE_NOTES" ]]; then
        echo -e "${YELLOW}📝 Generating automatic release notes...${NC}"
        
        # Get commit messages since last tag
        LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
        if [[ -n "$LAST_TAG" ]]; then
            COMMITS=$(git log "$LAST_TAG..HEAD" --oneline --pretty=format:"- %s" | head -10)
            if [[ -n "$COMMITS" ]]; then
                RELEASE_NOTES="Changes since $LAST_TAG:\n\n$COMMITS"
            else
                RELEASE_NOTES="Version $NEW_VERSION_NUMBER - automated release"
            fi
        else
            RELEASE_NOTES="Version $NEW_VERSION_NUMBER - initial release"
        fi
    fi
    
    echo -e "${BLUE}📝 Release Notes:${NC}"
    echo -e "$RELEASE_NOTES"
}

# Update version in pubspec.yaml
update_version() {
    echo -e "${YELLOW}📦 Updating version in pubspec.yaml...${NC}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${PURPLE}[DRY RUN] Would update version to: $NEW_FULL_VERSION${NC}"
        return
    fi
    
    # Create backup
    cp pubspec.yaml pubspec.yaml.backup
    
    # Update version
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/^version:.*/version: $NEW_FULL_VERSION/" pubspec.yaml
    else
        # Linux
        sed -i "s/^version:.*/version: $NEW_FULL_VERSION/" pubspec.yaml
    fi
    
    # Verify the change
    NEW_VERSION_CHECK=$(grep '^version:' pubspec.yaml | cut -d ' ' -f 2)
    if [[ "$NEW_VERSION_CHECK" != "$NEW_FULL_VERSION" ]]; then
        echo -e "${RED}❌ Version update failed${NC}"
        mv pubspec.yaml.backup pubspec.yaml
        exit 1
    fi
    
    # Remove backup
    rm pubspec.yaml.backup
    
    echo -e "${GREEN}✅ Version updated successfully!${NC}"
}

# Commit and tag changes
commit_and_tag() {
    echo -e "${YELLOW}💾 Committing and tagging changes...${NC}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${PURPLE}[DRY RUN] Would commit and tag:${NC}"
        echo -e "${PURPLE}  git add pubspec.yaml${NC}"
        echo -e "${PURPLE}  git commit -m \"chore: bump version to $NEW_FULL_VERSION\"${NC}"
        echo -e "${PURPLE}  git tag -a $NEW_TAG -m \"Release $NEW_TAG\"${NC}"
        return
    fi
    
    # Add changes
    git add pubspec.yaml
    
    # Commit changes
    git commit -m "chore: bump version to $NEW_FULL_VERSION"
    
    # Create annotated tag with release notes
    git tag -a "$NEW_TAG" -m "Release $NEW_TAG

$RELEASE_NOTES"
    
    echo -e "${GREEN}✅ Changes committed and tagged!${NC}"
}

# Push to remote
push_changes() {
    echo -e "${YELLOW}📤 Pushing to remote repository...${NC}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${PURPLE}[DRY RUN] Would push:${NC}"
        echo -e "${PURPLE}  git push origin $(git branch --show-current)${NC}"
        echo -e "${PURPLE}  git push origin $NEW_TAG${NC}"
        return
    fi
    
    # Push branch
    git push origin "$(git branch --show-current)"
    
    # Push tag
    git push origin "$NEW_TAG"
    
    echo -e "${GREEN}✅ Changes pushed to remote!${NC}"
}

# Show final summary
show_summary() {
    echo ""
    echo -e "${BLUE}🎉 Release $NEW_TAG created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Summary:${NC}"
    echo -e "  Old version: $CURRENT_VERSION"
    echo -e "  New version: $NEW_FULL_VERSION"
    echo -e "  Tag: $NEW_TAG"
    echo -e "  Type: $VERSION_TYPE$PRERELEASE"
    echo ""
    echo -e "${YELLOW}🤖 What happens next:${NC}"
    echo -e "  1. GitHub Actions will automatically trigger"
    echo -e "  2. iOS app will be built and deployed"
    if [[ "$PRERELEASE" == *"beta"* || "$PRERELEASE" == *"alpha"* ]]; then
        echo -e "  3. Beta/Alpha build will go to TestFlight"
    else
        echo -e "  3. Production build will go to App Store Connect"
    fi
    echo -e "  4. GitHub Release will be created with artifacts"
    echo ""
    echo -e "${YELLOW}🔗 Useful links:${NC}"
    echo -e "  GitHub Actions: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/actions"
    echo -e "  Releases: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/releases"
    echo -e "  App Store Connect: https://appstoreconnect.apple.com"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo ""
        echo -e "${PURPLE}🔍 This was a DRY RUN - no actual changes were made${NC}"
        echo -e "${PURPLE}Remove the 'true' parameter to execute for real${NC}"
    fi
}

# Main execution
main() {
    validate_prerequisites
    get_current_version
    calculate_new_version
    generate_release_notes
    
    if [[ "$DRY_RUN" != "true" ]]; then
        echo ""
        echo -e "${YELLOW}⚠️  This will create a new release and trigger deployment!${NC}"
        echo -e "Version: $CURRENT_VERSION -> $NEW_FULL_VERSION"
        echo -e "Tag: $NEW_TAG"
        echo ""
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Release cancelled${NC}"
            exit 0
        fi
    fi
    
    update_version
    commit_and_tag
    push_changes
    show_summary
}

main "$@"
