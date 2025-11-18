# Cloud Agent Lab

A neutral, multi-agent VM setup for running CLI AI agents (e.g., Gemini CLI, others) on a cloud VM. This repo provides GCP VM provisioning steps, agent install/run scripts, and security guidance — separate from any specific application codebases.

## Contents
- docs/VM_MULTI_AGENT_SETUP_PLAN.md — End-to-end setup and usage plan
- docs/VM_SETUP_GCP.md — Provision a GCP VM and SSH in
- docs/SECURITY.md — Secrets, least privilege, and ops guidance
- scripts/start-agent.sh — Generic launcher that loads env and runs a chosen agent
- scripts/bootstrap.sh — One-shot setup on VM (Node 22, symlink, test)
- scripts/install-agents.sh — Optional install for Codex/Claude when ready
- (MCP optional) No MCP tooling included yet
- .env.example — Environment variables template

## Quickstart
1. Create a VM (see docs/VM_SETUP_GCP.md)
2. Copy `.env.example` to `~/.agents.env`, fill values, then `chmod 600 ~/.agents.env`
3. (Optional) Run bootstrap on the VM: `scripts/bootstrap.sh`
4. Install desired agents when ready: `scripts/install-agents.sh {codex|claude|all}`
5. Launch examples:
   - `scripts/start-agent.sh --agent gemini -p "Your question"`
   - `scripts/start-agent.sh --agent claude -p "Review this function"`
   - `scripts/start-agent.sh --agent codex -p "Write a bash one-liner"`

## Notes
- Keep secrets out of git. Prefer `~/.agents.env` or Secret Manager.
- Node requirements: Codex CLI needs Node ≥22; Claude Code needs Node ≥18.
