# Claude Parallel Coding Best Practices

[![Monthly Review](https://github.com/jayraol-THC/claude-best-practices/actions/workflows/monthly-review-reminder.yml/badge.svg)](https://github.com/jayraol-THC/claude-best-practices/actions/workflows/monthly-review-reminder.yml)
[![Last Updated](https://img.shields.io/badge/last%20updated-February%202026-blue)](./PARALLEL_CODING_BEST_PRACTICES.md)
[![Source](https://img.shields.io/badge/source-r%2Fclaude-orange)](https://reddit.com/r/claude)

A living repository of best practices for parallel autonomous coding with Claude, sourced from **r/claude**, **r/claudeai**, and the developer community.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Key Insights](#key-insights)
- [Repository Structure](#repository-structure)
- [Installation](#installation)
- [Auto-Review Setup](#auto-review-setup)
- [Monthly Review Process](#monthly-review-process)
- [Cost Comparison](#cost-comparison)
- [Tools & Resources](#tools--resources)
- [Contributing](#contributing)
- [License](#license)

---

## Quick Start

### 1. Add to Your CLAUDE.md

Copy the snippet to your global Claude configuration:

```bash
cat claude-snippet.md >> ~/.claude/CLAUDE.md
```

### 2. Enable Monthly Reviews

The GitHub Actions workflow automatically creates review issues on the 1st of each month.

### 3. Read the Full Guide

See [PARALLEL_CODING_BEST_PRACTICES.md](./PARALLEL_CODING_BEST_PRACTICES.md) for detailed strategies.

---

## Key Insights

### Cost-Efficient Model Routing

| Model | Use Case | Cost vs Opus |
|-------|----------|--------------|
| **Opus** | Planning, architecture, complex reasoning | 1x (baseline) |
| **Sonnet** | Standard implementation, focused tasks | ~5x cheaper |
| **Haiku** | Orchestration, simple tasks, routing | ~25x cheaper |

> **Community insight:** "Use the cheap, fast model until it hurts; use the careful, pricier one where it matters."

### Parallel Agent Architecture

```
┌─────────────────────────────────────┐
│        LEAD AGENT (Opus)            │
│    Strategic coordination           │
└──────────────┬──────────────────────┘
               │
   ┌───────────┼───────────┐
   ▼           ▼           ▼
┌────────┐ ┌────────┐ ┌────────┐
│ Worker │ │ Worker │ │ Worker │
│(Sonnet)│ │(Sonnet)│ │(Sonnet)│
└────────┘ └────────┘ └────────┘
```

### Git Worktree Isolation

Each parallel agent gets its own isolated workspace:

```bash
# Create isolated worktrees
git worktree add ../feature-frontend feature/frontend
git worktree add ../feature-backend feature/backend

# Run agents in separate terminals
cd ../feature-frontend && claude
cd ../feature-backend && claude
```

### Context Conservation

| Action | Impact |
|--------|--------|
| `/clear` between tasks | Significant token savings |
| Disable unused MCP servers | Reduces context overhead |
| CLI tools over MCP | No tool definitions in context |
| Concise CLAUDE.md | Better instruction adherence |

---

## Repository Structure

```
claude-best-practices/
├── README.md                           # This file
├── PARALLEL_CODING_BEST_PRACTICES.md   # Comprehensive guide
├── claude-snippet.md                   # Ready-to-copy CLAUDE.md config
├── requirements.txt                    # Python dependencies
├── scripts/
│   ├── auto_review.py                  # Gemini-powered auto-review
│   └── review-rclaude.sh               # Opens r/claude searches
└── .github/
    └── workflows/
        └── monthly-review-reminder.yml # Auto-review + PR creation
```

---

## Installation

### Option 1: Clone and Configure

```bash
# Clone the repo
git clone https://github.com/jayraol-THC/claude-best-practices.git
cd claude-best-practices

# Add snippet to your CLAUDE.md
cat claude-snippet.md >> ~/.claude/CLAUDE.md
```

### Option 2: Just the Snippet

Add this to `~/.claude/CLAUDE.md`:

```markdown
## Parallel Coding & Cost Efficiency

### Model Selection for Sub-Agents
- Use `model: haiku` for simple, focused sub-agent tasks
- Use `model: sonnet` for standard implementation work
- Reserve default (opus) for complex reasoning and planning

### Context Conservation
- Run `/clear` after completing unrelated tasks
- Disable unused MCP servers via `/mcp`
- Prefer CLI tools (gh, aws, gcloud) over MCP equivalents
```

---

## Auto-Review Setup

The repository includes automated r/claude scanning powered by **Gemini 2.5 Flash with Google Search grounding**.

### How It Works

```
┌─────────────────────────────────────────────────┐
│  GitHub Action (1st of month or manual)         │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│  Gemini 2.5 Flash + Google Search                   │
│  Searches r/claude, r/claudeai for:             │
│  • Cost optimization tips                       │
│  • Parallel agent patterns                      │
│  • New tools and techniques                     │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│  Creates PR with MONTHLY_UPDATE.md              │
│  containing structured findings                 │
└─────────────────────────────────────────────────┘
```

### Setup (One-Time)

1. **Get a Gemini API Key:**
   - Go to [Google AI Studio](https://aistudio.google.com/apikey)
   - Create a new API key

2. **Add to GitHub Secrets:**
   ```
   Repository → Settings → Secrets and variables → Actions → New repository secret

   Name: GEMINI_API_KEY
   Value: <your-api-key>
   ```

3. **Done!** The workflow will run automatically on the 1st of each month.

### Manual Trigger

To run immediately:
```
Repository → Actions → "Monthly r/claude Auto-Review" → Run workflow
```

### Cost

~$0.01-0.05 per monthly run (Gemini 2.5 Flash pricing)

---

## Monthly Review Process

### Automated (GitHub Actions)

The workflow runs on the 1st of each month and:
1. Searches r/claude and r/claudeai using Gemini + Google Search
2. Summarizes findings into structured categories
3. Creates a PR with `MONTHLY_UPDATE.md`
4. You review and merge valuable insights

### Manual Review

Run the helper script to open all search queries manually:

```bash
./scripts/review-rclaude.sh
```

This opens browser tabs for:
- Cost optimization discussions
- Parallel agent patterns
- Worktree setups
- CLAUDE.md tips
- New tools and frameworks

---

## Cost Comparison

Based on community reports and official pricing:

| Strategy | Estimated Savings |
|----------|-------------------|
| Haiku for orchestration | 25x per orchestration call |
| Sonnet for implementation | 5x per implementation task |
| Smart model routing | Up to 65% overall reduction |
| Context management (`/clear`) | 30-50% token reduction |
| Disabled unused MCP servers | Variable |

---

## Tools & Resources

### Orchestration Tools

| Tool | Description | Link |
|------|-------------|------|
| **Conductor** | macOS app for multi-agent orchestration | [ChatGate](https://chatgate.ai/post/conductor) |
| **ccswarm** | Git worktree isolation with Claude CLI | [GitHub](https://github.com/nwiizo/ccswarm) |
| **claude-flow** | Enterprise-grade agent orchestration | [GitHub](https://github.com/ruvnet/claude-flow) |

### Official Documentation

- [Best Practices](https://code.claude.com/docs/en/best-practices)
- [Agent Teams](https://code.claude.com/docs/en/agent-teams)
- [Cost Management](https://code.claude.com/docs/en/costs)

### Community Resources

- [r/claude](https://reddit.com/r/claude)
- [r/claudeai](https://reddit.com/r/claudeai)
- [Claude Code Tips - Agentic Coding](https://agenticcoding.substack.com/p/32-claude-code-tips-from-basics-to)

---

## Contributing

Found a useful tip on r/claude? Contributions welcome!

1. Fork this repository
2. Add your finding to the appropriate section
3. Include the source link
4. Open a PR

### What to Contribute

- New cost optimization techniques
- Parallel agent patterns
- Tool recommendations
- CLAUDE.md snippets
- Workflow improvements

---

## License

MIT License - Use freely, share knowledge.

---

<p align="center">
  <i>Maintained with insights from the Claude community</i><br>
  <a href="https://reddit.com/r/claude">r/claude</a> ·
  <a href="https://reddit.com/r/claudeai">r/claudeai</a> ·
  <a href="https://code.claude.com/docs">Official Docs</a>
</p>
