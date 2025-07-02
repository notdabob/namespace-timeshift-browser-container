#!/bin/bash
# claude-commit.sh - Smart commit with automatic version management and changelog updates
# Generates appropriate commit messages and handles version increments

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCS_DIR="${PROJECT_DIR}/docs"
VERSION_FILE="${DOCS_DIR}/VERSION"
CHANGELOG_FILE="${DOCS_DIR}/CHANGELOG.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_help() {
    cat << EOF
Smart Commit Tool with Version Management

Usage: $0 [OPTIONS] [COMMIT_TYPE]

COMMIT_TYPE:
  patch   - Bug fixes, small improvements (x.y.Z)
  minor   - New features, enhancements (x.Y.0)  
  major   - Breaking changes, major updates (X.0.0)
  
  If not specified, automatically determines type from changes.

OPTIONS:
  -m, --message MSG    Custom commit message
  -d, --dry-run       Show what would be done without committing
  -h, --help          Show this help

Examples:
  $0                  # Auto-detect changes and commit
  $0 minor            # Force minor version bump
  $0 -m "Fix SSL issue" patch  # Custom message with patch bump
  $0 --dry-run        # Preview changes

EOF
}

# Parse command line arguments
COMMIT_TYPE=""
CUSTOM_MESSAGE=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--message)
            CUSTOM_MESSAGE="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        patch|minor|major)
            COMMIT_TYPE="$1"
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Get current version
get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE" | tr -d '\n'
    else
        echo "0.0.0"
    fi
}

# Increment version based on type
increment_version() {
    local current_version="$1"
    local bump_type="$2"
    
    IFS='.' read -r major minor patch <<< "$current_version"
    
    case "$bump_type" in
        major)
            echo "$((major + 1)).0.0"
            ;;
        minor)
            echo "${major}.$((minor + 1)).0"
            ;;
        patch)
            echo "${major}.${minor}.$((patch + 1))"
            ;;
        *)
            print_error "Invalid version type: $bump_type"
            exit 1
            ;;
    esac
}

# Auto-detect commit type from changes
detect_commit_type() {
    local git_status
    git_status=$(git status --porcelain)
    
    # Check for new files or major structural changes
    if echo "$git_status" | grep -q "^??.*\.sh$" || \
       echo "$git_status" | grep -q "^A.*\.sh$" || \
       echo "$git_status" | grep -q "docs/.*\.md$"; then
        echo "minor"
        return
    fi
    
    # Check for modifications to key files
    if echo "$git_status" | grep -q "^M.*launch.*\.sh$" || \
       echo "$git_status" | grep -q "^M.*CLAUDE\.md$"; then
        echo "minor"
        return
    fi
    
    # Default to patch for other changes
    echo "patch"
}

# Generate commit message based on changes
generate_commit_message() {
    local version="$1"
    local git_diff_output
    local git_status_output
    
    git_diff_output=$(git diff --name-only --cached)
    git_status_output=$(git status --porcelain)
    
    # Custom message takes precedence
    if [[ -n "$CUSTOM_MESSAGE" ]]; then
        echo "$CUSTOM_MESSAGE"
        return
    fi
    
    # Analyze changes and generate appropriate message
    local message=""
    
    if echo "$git_status_output" | grep -q "^R.*VERSION"; then
        message="Reorganize project structure and move VERSION to docs/"
    elif echo "$git_status_output" | grep -q "^??.*sync_shell_aliases\.sh"; then
        message="Add shell alias management and smart commit workflow"
    elif echo "$git_status_output" | grep -q "^??.*claude-commit\.sh"; then
        message="Add automated commit tool with version management"
    elif echo "$git_status_output" | grep -q "^M.*generate_easy_buttons\.sh"; then
        message="Update easy button generation script"
    elif echo "$git_status_output" | grep -q "^??.*CHANGELOG\.md"; then
        message="Add comprehensive changelog and version history"
    else
        # Generic message based on file types
        local modified_files
        modified_files=$(echo "$git_diff_output" | wc -l | tr -d ' ')
        
        if [[ $modified_files -eq 1 ]]; then
            local file_name
            file_name=$(basename "$git_diff_output")
            message="Update $file_name"
        else
            message="Update multiple project files and configurations"
        fi
    fi
    
    echo "$message"
}

# Update changelog
update_changelog() {
    local version="$1"
    local commit_message="$2"
    local current_date
    current_date=$(date +%Y-%m-%d)
    
    if [[ ! -f "$CHANGELOG_FILE" ]]; then
        print_error "CHANGELOG.md not found at $CHANGELOG_FILE"
        return 1
    fi
    
    # Create temporary file with new entry
    local temp_file
    temp_file=$(mktemp)
    
    # Add new version entry after the main header
    {
        head -n 3 "$CHANGELOG_FILE"
        echo ""
        echo "## [$version] - $current_date"
        echo ""
        echo "### Changed"
        echo "- $commit_message"
        echo ""
        tail -n +4 "$CHANGELOG_FILE"
    } > "$temp_file"
    
    mv "$temp_file" "$CHANGELOG_FILE"
}

# Main execution
main() {
    # Change to project directory
    cd "$PROJECT_DIR"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
    
    # Check for staged or unstaged changes
    if ! git diff --quiet || ! git diff --cached --quiet || [[ -n $(git ls-files --others --exclude-standard) ]]; then
        print_status "Found changes to commit"
    else
        print_warning "No changes to commit"
        exit 0
    fi
    
    # Auto-detect commit type if not specified
    if [[ -z "$COMMIT_TYPE" ]]; then
        COMMIT_TYPE=$(detect_commit_type)
        print_status "Auto-detected commit type: $COMMIT_TYPE"
    fi
    
    # Get current and new version
    local current_version
    local new_version
    current_version=$(get_current_version)
    new_version=$(increment_version "$current_version" "$COMMIT_TYPE")
    
    print_status "Version: $current_version → $new_version"
    
    # Generate commit message
    local commit_message
    commit_message=$(generate_commit_message "$new_version")
    
    print_status "Commit message: $commit_message"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_warning "DRY RUN - No changes will be made"
        echo "Would update version to: $new_version"
        echo "Would commit with message: $commit_message"
        exit 0
    fi
    
    # Stage all changes
    git add -A
    
    # Update version file
    echo "$new_version" > "$VERSION_FILE"
    git add "$VERSION_FILE"
    
    # Update changelog
    update_changelog "$new_version" "$commit_message"
    git add "$CHANGELOG_FILE"
    
    # Create commit
    git commit -m "$(cat <<EOF
$commit_message

Version bump to $new_version

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
    
    print_success "Committed successfully!"
    print_success "New version: $new_version"
    
    # Show final status
    git log --oneline -1
}

# Run main function
main "$@"