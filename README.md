# Claude Parallel Coding Best Practices

A living repository of best practices for parallel autonomous coding with Claude, sourced from r/claude and the developer community.

## Quick Start

1. **Read the guide:** [PARALLEL_CODING_BEST_PRACTICES.md](./PARALLEL_CODING_BEST_PRACTICES.md)
2. **Copy snippet to your CLAUDE.md:** See [claude-snippet.md](./claude-snippet.md)
3. **Enable GitHub Actions** for monthly review reminders

## Repository Structure

```
claude-best-practices/
├── README.md                          # This file
├── PARALLEL_CODING_BEST_PRACTICES.md  # Main best practices guide
├── claude-snippet.md                  # Copy this to your CLAUDE.md
└── .github/
    └── workflows/
        └── monthly-review-reminder.yml  # Monthly review automation
```

## Monthly Review Process

This repo includes a GitHub Actions workflow that:
- Creates an issue on the 1st of each month
- Provides a checklist for reviewing r/claude
- Links to relevant search queries and documentation

To enable:
1. Push this repo to GitHub
2. Go to Settings → Actions → General
3. Enable "Allow all actions"

## Key Insights Summary

### Cost Efficiency
- Use **Haiku** for orchestration and simple tasks (25x cheaper than Opus)
- Use **Sonnet** for implementation (5x cheaper than Opus)
- Reserve **Opus** for planning and complex reasoning

### Parallel Architecture
- Use **git worktrees** for agent isolation
- Keep a **shared PLAN.md** for coordination
- Include "When NOT to use" in agent definitions

### Context Management
- Use `/clear` between tasks
- Disable unused MCP servers
- Keep CLAUDE.md concise

## Contributing

Found something useful on r/claude? Open a PR!

## License

MIT - Use freely, share knowledge.
