# Claude Instance Configuration Snippet

Copy the section below to your `~/.claude/CLAUDE.md` or project-level `.claude/CLAUDE.md`:

---

```markdown
## Parallel Coding & Cost Efficiency

### Model Selection for Sub-Agents
- Use `model: haiku` for simple, focused sub-agent tasks
- Use `model: sonnet` for standard implementation work
- Reserve default (opus) for complex reasoning and planning

### Sub-Agent Best Practices
- Always include complete context in sub-agent prompts (they can't ask follow-ups)
- Define "When NOT to use" for custom agents to prevent unnecessary spawning
- Use sequential execution for dependent tasks; parallel only for independent work

### Context Conservation
- Run `/clear` after completing unrelated tasks
- Disable unused MCP servers via `/mcp`
- Prefer CLI tools (gh, aws, gcloud) over MCP equivalents when possible

### Git Worktree Pattern for Parallel Work
When working on parallel features:
```bash
git worktree add ../project-feature feature/name
```
Each agent works in its own worktree to prevent conflicts.

### Shared Planning Document
For multi-agent coordination, maintain a PLAN.md with:
- Current task assignments
- Blockers and dependencies
- Decisions made (to avoid re-discussion)
```

---

## Alternative: Minimal Version

If you prefer brevity:

```markdown
## Cost & Parallel Coding
- Sub-agents: Use haiku/sonnet, not opus
- Context: `/clear` between tasks, disable unused MCP servers
- Parallel: Use git worktrees for isolation
- Planning: Keep shared PLAN.md for coordination
```
