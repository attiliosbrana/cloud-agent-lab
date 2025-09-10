#!/usr/bin/env bash
set -euo pipefail

# Bootstrap this repo on a fresh Ubuntu VM for single-agent (Gemini) use now,
# with Node 22 ready for Codex/Claude later. No MCP setup.

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"

echo "[info] Repo: $REPO_DIR"

# 1) Ensure env is present and readable
ENV_FILE=".env"
HOME_ENV="$HOME/.agents.env"
if [[ -f "$ENV_FILE" ]]; then
  echo "[ok] Found $ENV_FILE (repo-local)."
elif [[ -f "$HOME_ENV" ]]; then
  echo "[ok] Found $HOME_ENV."
else
  echo "[warn] No env file found. Create $ENV_FILE or $HOME_ENV with GEMINI_API_KEY." >&2
fi

# 2) Ensure Node.js 22+ (for future Codex/Claude use)
need_node=0
if command -v node >/dev/null 2>&1; then
  node_major=$(node -v | sed 's/^v//' | awk -F. '{print $1}')
  if (( node_major < 22 )); then
    need_node=1
  fi
else
  need_node=1
fi

if (( need_node == 1 )); then
  echo "[info] Installing Node.js 22 (requires sudo)"
  if command -v apt-get >/dev/null 2>&1; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
  else
    echo "[warn] Non-APT system detected. Please install Node 22 manually." >&2
  fi
else
  echo "[ok] Node $(node -v) present"
fi

# 3) Create convenience symlink
if [[ ! -e "$HOME/start-agent" ]]; then
  ln -sf "$REPO_DIR/scripts/start-agent.sh" "$HOME/start-agent"
  echo "[ok] Created symlink: ~/start-agent -> scripts/start-agent.sh"
else
  echo "[info] Symlink ~/start-agent already exists (or path in use)."
fi

# 4) Verify Gemini is callable and run a test prompt
if ! command -v gemini >/dev/null 2>&1; then
  echo "[warn] 'gemini' CLI not found. Install it on the VM, then re-run this script." >&2
  exit 0
fi

echo "[info] Testing Gemini..."
set +e
"$REPO_DIR/scripts/start-agent.sh" --agent gemini -p "Hello from Cloud Agent Lab; what's the current UTC time?" || test_rc=$?
set -e
if [[ "${test_rc:-0}" != "0" ]]; then
  echo "[warn] Gemini test returned non-zero exit ($test_rc). Check your GEMINI_API_KEY and CLI install." >&2
else
  echo "[ok] Gemini test command executed"
fi

echo "[done] Bootstrap complete. Codex/Claude can be installed later via npm (Node 22 ready)."

