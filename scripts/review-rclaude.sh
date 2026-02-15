#!/bin/bash
# Script to open r/claude search queries for manual review

echo "Opening r/claude search queries for review..."
echo ""

# Search queries
queries=(
    "https://www.reddit.com/r/claude/search?q=cost%20optimization&restrict_sr=1&sort=new&t=month"
    "https://www.reddit.com/r/claude/search?q=parallel%20agents&restrict_sr=1&sort=new&t=month"
    "https://www.reddit.com/r/claude/search?q=worktree&restrict_sr=1&sort=new&t=month"
    "https://www.reddit.com/r/claude/search?q=CLAUDE.md&restrict_sr=1&sort=new&t=month"
    "https://www.reddit.com/r/claude/search?q=agent%20teams&restrict_sr=1&sort=new&t=month"
    "https://www.reddit.com/r/claude/search?q=haiku%20sonnet&restrict_sr=1&sort=new&t=month"
    "https://www.reddit.com/r/claudeai/search?q=cost&restrict_sr=1&sort=new&t=month"
)

# Detect OS and open URLs
for url in "${queries[@]}"; do
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$url"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        xdg-open "$url" 2>/dev/null || echo "Open: $url"
    else
        echo "Open: $url"
    fi
    sleep 1  # Prevent browser overload
done

echo ""
echo "Review checklist:"
echo "  [ ] Look for new cost optimization techniques"
echo "  [ ] Check for new parallel agent patterns"
echo "  [ ] Note any new tools mentioned"
echo "  [ ] Update PARALLEL_CODING_BEST_PRACTICES.md"
echo ""
echo "Official docs to check:"
echo "  - https://code.claude.com/docs/en/best-practices"
echo "  - https://code.claude.com/docs/en/agent-teams"
echo "  - https://code.claude.com/docs/en/costs"
