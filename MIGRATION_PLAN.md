# AI Agents VM Migration Plan

## Goal

Extract all Google Cloud VM + CLI agent setup (currently Gemini-centric) into a new, neutral repo for a multi‑agent environment. Sanitize secrets, update references here, and keep this app repo focused on the frontend/backend only.

## Assets To Migrate

- `GEMINI_CLOUD_SETUP.md` — VM provisioning/runbook for GCP.
- `CLOUD_GEMINI_SUPABASE_GUIDE.md` — VM usage guide (contains credentials and VM IP; must be sanitized).
- `.gemini/settings.json` — Local MCP server mapping (move as example; rename to `.gemini/settings.example.json`).
- Any VM helper scripts referenced in docs (e.g., `start-gemini-with-env.sh`) — create sanitized templates.

Related in‑repo documentation to keep (architecture) but update to link to the new repo:
- `docs/MCP_SERVICE_ARCHITECTURE.md`
- `docs/MCP_INTEGRATION.md`
- `docs/DEVELOPMENT.md` (sections referencing AI/MCP service)

Sensitive/tracked files to remediate:
- `.env` is tracked. Remove from tracking and purge from history; rotate keys/tokens.

## New Repo (Neutral Name)

Placeholder: cloud-agent-lab

Suggested neutral names:
- `ai-agents-cloud-setup`
- `cloud-ai-agents-vm`
- `ai-agent-workbench`
- `cloud-agent-lab`
- `agentops-vm`

### Proposed Structure

```
README.md                  # Overview, quickstart for VM + agents
MIGRATION_PLAN.md          # This plan (copied & maintained in the new repo)
docs/
  VM_SETUP_GCP.md          # GCP VM creation, firewall, SSH, management
  AGENT_INSTALLS.md        # Install + configure multiple agents (Gemini CLI, others)
  SECURITY.md              # Secrets handling, rotation, least privilege
scripts/
  start-agent.sh           # Generic env loader + agent launcher (template)
.gemini/
  settings.example.json    # Example MCP server mapping (no secrets)
.env.example               # Placeholder env vars (no secrets)
```

## Migration Steps

1) Inventory (done)
   - Verified Gemini/GCP docs and `.gemini` config in current repo.

2) Decide new repo name
   - Pick one of the suggested names or provide your own.

3) Scaffold new repo in `~/gits/<CHOSEN_NAME>`
   - Initialize Git; add baseline files from Proposed Structure.
   - Copy and sanitize `GEMINI_CLOUD_SETUP.md` and `CLOUD_GEMINI_SUPABASE_GUIDE.md` (replace IP, tokens, project refs with placeholders).
   - Convert `.gemini/settings.json` to `.gemini/settings.example.json` with no secrets.

4) Sanitize & redact
   - Replace hardcoded secrets and IPs with placeholders.
   - Add notes on using env vars or Secret Manager.

5) Update this repo
   - Remove: `GEMINI_CLOUD_SETUP.md`, `CLOUD_GEMINI_SUPABASE_GUIDE.md`, and `.gemini/` directory.
   - Add `.gemini/` to `.gitignore`.
   - Stop tracking `.env` (`git rm --cached .env`).
   - Update links in `README.md`, `docs/MCP_SERVICE_ARCHITECTURE.md`, and `docs/DEVELOPMENT.md` to point to the new repo.

6) Purge secrets from history (after rotation)
   - Rotate: Google API key, Supabase tokens/keys.
   - Use `git filter-repo` (or BFG) to remove `.env` and `CLOUD_GEMINI_SUPABASE_GUIDE.md` from history.
   - Force‑push if applicable.

7) Validate
   - Build app (`npm run build`).
   - Confirm docs reference the new repo.
   - SSH to VM (optional) and validate agent runs with sanitized templates.

## Secrets & Security Notes

- Rotate all exposed credentials before history rewrite.
- Keep secrets out of repos (.env only locally or in CI secrets). For VM, prefer OS‑level env files or Secret Manager.
- Supabase anon key is intended for client use but still apply strict RLS.

## Multi‑Agent VM Notes

- Standardize env file: `~/.agents.env` with keys for all providers (Google, OpenAI, Anthropic, etc.).
- Provide per‑agent launcher wrappers (e.g., `scripts/start-agent.sh --agent gemini`), mapping to correct binaries/configs.
- Optional containerized agents for isolation.
- Log locations and health checks documented in `AGENT_INSTALLS.md`.

## Checklist (to track completion)

- [ ] Choose repo name
- [ ] Scaffold new repo in `~/gits/`
- [ ] Sanitize & copy docs
- [ ] Add example configs/scripts
- [ ] Remove assets from this repo
- [ ] Update .gitignore and references
- [ ] Rotate credentials
- [ ] Rewrite git history
- [ ] Validate build and VM usage

