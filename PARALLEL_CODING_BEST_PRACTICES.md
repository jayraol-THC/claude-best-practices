# Parallel Autonomous Coding with Claude: Best Practices

> **Last Updated:** 2026-02-15
> **Source:** Community insights from r/claude, r/claudeai, and developer blogs
> **Review Schedule:** Monthly (see [Review Process](#review-process))

---

## Table of Contents

1. [Cost-Efficient Model Routing](#cost-efficient-model-routing)
2. [Parallel Agent Architecture](#parallel-agent-architecture)
3. [Git Worktree Isolation](#git-worktree-isolation)
4. [CLAUDE.md Optimization](#claudemd-optimization)
5. [Context Management](#context-management)
6. [Subscription vs API Strategy](#subscription-vs-api-strategy)
7. [Review Process](#review-process)

---

## Cost-Efficient Model Routing

### The Hybrid Model Strategy

Reserve expensive models for critical tasks; use cheaper models for volume work:

| Task Type | Recommended Model | Cost Ratio |
|-----------|-------------------|------------|
| High-level planning, architecture | Opus | 1x (baseline) |
| Complex reasoning, final review | Opus | 1x |
| Standard implementation | Sonnet | ~5x cheaper |
| Focused sub-agent tasks | Sonnet | ~5x cheaper |
| Orchestration, routing, simple tasks | Haiku | ~25x cheaper |
| Syntax validation, linting | Haiku | ~25x cheaper |

### Intelligent Routing Rules

```
IF prompt_length > threshold OR tool_depth > 3 OR uncertainty_high:
    USE Sonnet/Opus
ELSE:
    USE Haiku
```

**Key insight from community:** "Use the cheap, fast model until it hurts; use the careful, pricier one where it matters; measure everything; route accordingly."

### Metrics to Track

- p95 latency per model
- Token counts per task type
- Validation pass rates
- Escalation frequency from Haiku → Sonnet → Opus

---

## Parallel Agent Architecture

### When to Use Multi-Agent vs Single Session

| Scenario | Recommendation |
|----------|----------------|
| Sequential tasks, same-file edits | Single session |
| Tight dependencies between tasks | Single session or sequential sub-agents |
| Independent, parallelizable work | Multi-agent teams |
| Workers don't need to communicate | Single agents, not Agent Teams |

### Role-Based Agent Configuration

Effective parallel setups from r/claude discussions:

```
┌─────────────────────────────────────────────────────┐
│                  LEAD AGENT (Opus)                  │
│         Strategic coordination, planning            │
└─────────────────┬───────────────────────────────────┘
                  │
    ┌─────────────┼─────────────┬─────────────┐
    ▼             ▼             ▼             ▼
┌────────┐  ┌────────┐   ┌────────┐   ┌────────┐
│ Worker │  │ Worker │   │ Worker │   │ Worker │
│(Sonnet)│  │(Sonnet)│   │(Sonnet)│   │(Sonnet)│
│Frontend│  │Backend │   │ Tests  │   │  Docs  │
└────────┘  └────────┘   └────────┘   └────────┘
```

### Agent Definition Best Practices

Always include in agent configs:
- Clear role description
- **"When NOT to use" section** - prevents unnecessary sub-agent spawning
- Complete context in invocation (sub-agents can't ask clarifying questions)

### Communication Hub Pattern

Instead of complex orchestration frameworks, use a **shared planning document**:

```markdown
# PLAN.md (shared between agents)

## Current Sprint
- [ ] Task 1 - assigned: frontend-agent
- [ ] Task 2 - assigned: backend-agent
- [x] Task 3 - completed by: test-agent

## Blockers
- Backend API not ready (blocks frontend task 4)

## Decisions Made
- Using REST over GraphQL (decided 2026-02-14)
```

---

## Git Worktree Isolation

### Why Worktrees for Parallel Agents

Each agent gets an isolated workspace, preventing:
- File conflicts
- Lock contention
- State pollution between agents

### Setup Pattern

```bash
# Create worktrees for parallel agents
git worktree add ../project-frontend feature/frontend
git worktree add ../project-backend feature/backend
git worktree add ../project-tests feature/tests

# Each Claude instance works in its own worktree
cd ../project-frontend && claude
cd ../project-backend && claude
cd ../project-tests && claude
```

### Tools from Community

| Tool | Description |
|------|-------------|
| **Conductor** | macOS app for orchestrating multiple Claude Code agents with worktree isolation |
| **ccswarm** | Multi-agent orchestration using Claude Code CLI with Git worktree isolation |
| **worktree-cli** | MCP server integration for AI workflows |
| **agentree** | Lightweight worktree management for AI agents |

---

## CLAUDE.md Optimization

### Core Principles

1. **Keep it concise** - For each line, ask "Would removing this cause Claude to make mistakes?" If not, cut it.
2. **Human-readable** - No special format required
3. **Project-specific** - Focus on YOUR project's patterns

### Recommended Structure

```markdown
# Project: [Name]

## Architecture
- Frontend: [framework] at /src/client
- Backend: [framework] at /src/server
- Database: [type]

## Code Standards
- Naming: camelCase for functions, PascalCase for components
- Pattern: [your patterns]
- Never: [anti-patterns to avoid]

## Key Commands
- `npm run dev` - Start development
- `npm test` - Run tests
- `npm run lint` - Check code style

## Common Gotchas
- [Project-specific pitfalls]
```

### Anti-Patterns to Avoid

- Bloated files that Claude ignores
- Duplicating what's obvious from code
- Including entire style guides
- Repeating language documentation

---

## Context Management

### Token Conservation Techniques

1. **Use `/clear` frequently** - Wipe context when switching tasks
2. **Disable unused MCP servers** - Each adds tool definitions to context (`/mcp` to manage)
3. **Prefer CLI over MCP** - `gh`, `aws`, `gcloud` don't add context overhead
4. **Enable sandbox mode** - Reduces permission prompts (`/sandbox`)

### Context Cost Comparison

| Approach | Token Usage |
|----------|-------------|
| Direct CLI commands | Low |
| MCP server tools | Medium-High (tool definitions in context) |
| Long conversation history | Very High |
| Fresh session with good CLAUDE.md | Low |

### Sub-Agent Context Strategy

Sub-agents have **temporary context windows**. Craft invocations that are:
- Complete (all necessary information included)
- Self-contained (no need for follow-up questions)
- Scoped (focused on specific task)

---

## Subscription vs API Strategy

### When to Use Max Plan ($100-200/mo)

- Heavy daily usage (multiple hours)
- Predictable workload
- Cost predictability more important than flexibility

### When to Use API

- Burst usage patterns
- Need for programmatic access
- Building custom orchestration
- Cost: ~$100-200/hour for heavy parallel sessions

### Hybrid Approach

```
Interactive work → Max subscription
Automated pipelines → API with Haiku/Sonnet
Batch processing → API with smart routing
```

---

## Review Process

### Monthly r/claude Review Checklist

Run this review on the **1st of each month**:

1. **Search r/claude for new tips:**
   ```
   Search queries:
   - "cost optimization" site:reddit.com/r/claude
   - "parallel agents" site:reddit.com/r/claude
   - "worktree" site:reddit.com/r/claudeai
   - "CLAUDE.md tips" site:reddit.com/r/claude
   ```

2. **Check official docs for updates:**
   - https://code.claude.com/docs/en/best-practices
   - https://code.claude.com/docs/en/agent-teams
   - https://code.claude.com/docs/en/costs

3. **Review community tools:**
   - Check GitHub stars/activity for mentioned tools
   - Look for new orchestration frameworks

4. **Update this document:**
   - Add new techniques with source attribution
   - Remove outdated practices
   - Update cost ratios if pricing changes

### Tracking Changes

Use git history to track evolution:

```bash
git log --oneline -- PARALLEL_CODING_BEST_PRACTICES.md
```

---

## Sources

- [Claude Code Reddit Usage Patterns](https://www.aitooldiscovery.com/guides/claude-code-reddit)
- [Managing Costs in Claude Code - Steve Kinney](https://stevekinney.com/courses/ai-development/cost-management)
- [32 Claude Code Tips - Agentic Coding](https://agenticcoding.substack.com/p/32-claude-code-tips-from-basics-to)
- [Official Claude Code Cost Docs](https://code.claude.com/docs/en/costs)
- [Multi-Agent Orchestration Guide](https://sjramblings.io/multi-agent-orchestration-claude-code-when-ai-teams-beat-solo-acts/)
- [Git Worktrees for AI Agents - Upsun](https://devcenter.upsun.com/posts/git-worktrees-for-parallel-ai-coding-agents/)
- [Claude Code Agent Teams Docs](https://code.claude.com/docs/en/agent-teams)
- [Haiku vs Sonnet Cost Analysis](https://medium.com/@cognidownunder/claude-haiku-4-5-matches-sonnets-coding-skills-at-80-less-cost-changes-everything-297f4b163d4e)
- [Building a C Compiler with Parallel Claudes - Anthropic](https://www.anthropic.com/engineering/building-c-compiler)

---

## Contributing

Found a new tip on r/claude? Open a PR with:
1. The technique/tip
2. Source link
3. Your experience using it (optional)
