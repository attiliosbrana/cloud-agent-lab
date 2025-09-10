# Cloud Agent Lab

A neutral, multi-agent VM setup for running CLI AI agents (e.g., Gemini CLI, others) on a cloud VM. This repo provides GCP VM provisioning steps, agent install/run scripts, and security guidance — separate from any specific application codebases.

## Contents
- docs/VM_SETUP_GCP.md — Provision a GCP VM and SSH in
- docs/AGENT_INSTALLS.md — Install/configure multiple agents
- docs/SECURITY.md — Secrets, least privilege, and ops guidance
- scripts/start-agent.sh — Generic launcher that loads env and runs a chosen agent
- .gemini/settings.example.json — Example MCP server mapping (no secrets)
- .env.example — Environment variables template

## Quickstart
1. Create a VM (see docs/VM_SETUP_GCP.md)
2. Copy .env.example to .env and fill values
3. Install desired agents (docs/AGENT_INSTALLS.md)
4. Launch: scripts/start-agent.sh --agent gemini -p "Your question"

## Notes
- Keep secrets out of git. Use .env (local) or Secret Manager.
- For app integration (MCP service etc.), see your application repo documentation.
