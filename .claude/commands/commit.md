# Smart Commit with Version Management

Execute the smart commit script that automatically handles version bumps and changelog updates.

This command runs the `src/claude-commit.sh` script which:

- Auto-detects commit type (patch/minor/major) from file changes
- Increments version numbers appropriately
- Updates CHANGELOG.md with new version entry
- Creates properly formatted git commits with Claude Code attribution
- Supports custom commit messages and dry-run mode

Usage examples:
- Auto-commit with detected changes: `./src/claude-commit.sh`
- Force version bump type: `./src/claude-commit.sh minor`
- Custom message with patch: `./src/claude-commit.sh -m "Fix SSL issue" patch`
- Preview changes: `./src/claude-commit.sh --dry-run`

The script intelligently determines whether changes warrant patch (bug fixes), minor (new features), or major (breaking changes) version increments based on the files modified.