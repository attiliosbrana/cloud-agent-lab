#!/usr/bin/env bash
set -euo pipefail

# Install optional agents when you're ready on the VM (no MCP setup here).
# Usage:
#   scripts/install-agents.sh codex
#   scripts/install-agents.sh claude
#   scripts/install-agents.sh all

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 {codex|claude|all}" >&2
  exit 2
fi

target="$1"

get_node_major() {
  if ! command -v node >/dev/null 2>&1; then echo 0; return; fi
  local v; v=$(node -v 2>/dev/null | sed 's/^v//'); echo "${v%%.*}"
}

node_major=$(get_node_major)
if (( node_major < 22 )); then
  echo "[error] Node.js >=22 required (Codex CLI needs >=22; Claude Code >=18). Current: ${node_major}"
  echo "Install Node 22 first (see VM plan or run scripts/bootstrap.sh)." >&2
  exit 1
fi

install_codex() {
  echo "[info] Installing OpenAI Codex CLI (@openai/codex)"
  npm i -g @openai/codex
  echo "[ok] Installed Codex: $(command -v codex || echo 'codex not in PATH')"
  echo "[note] Authenticate per provider guidance when you first run the CLI."
}

install_claude() {
  echo "[info] Installing Anthropic Claude Code (@anthropic-ai/claude-code)"
  npm i -g @anthropic-ai/claude-code
  echo "[ok] Installed Claude: $(command -v claude || echo 'claude not in PATH')"
  echo "[note] Authenticate per provider guidance when you first run the CLI."
}

case "$target" in
  codex) install_codex ;;
  claude) install_claude ;;
  all) install_codex; install_claude ;;
  *) echo "[error] Unknown target: $target" >&2; exit 2 ;;
esac

echo "[done] Install complete. Test with scripts/start-agent.sh --agent {codex|claude} -p 'Hello'"
