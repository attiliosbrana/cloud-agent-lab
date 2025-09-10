#!/usr/bin/env bash
set -euo pipefail

# Load env from local .env (repo) or fallback to ~/.agents.env
if [[ -f "$(dirname "$0")/../.env" ]]; then
  set -a; source "$(dirname "$0")/../.env"; set +a
elif [[ -f "$HOME/.agents.env" ]]; then
  set -a; source "$HOME/.agents.env"; set +a
fi

AGENT="${DEFAULT_AGENT:-gemini}"
PROMPT=""
ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) AGENT="$2"; shift 2;;
    -p|--prompt) PROMPT="$2"; shift 2;;
    *) ARGS+=("$1"); shift;;
  esac
done

get_node_major() {
  if ! command -v node >/dev/null 2>&1; then
    echo "0"
    return
  fi
  local v
  v=$(node -v 2>/dev/null | sed 's/^v//')
  echo "${v%%.*}"
}

case "$AGENT" in
  gemini)
    if ! command -v gemini >/dev/null 2>&1; then
      echo "[error] 'gemini' CLI not found. See docs/VM_MULTI_AGENT_SETUP_PLAN.md or README.md" >&2
      exit 1
    fi
    if [[ -n "$PROMPT" ]]; then
      exec gemini -p "$PROMPT" "${ARGS[@]}"
    else
      exec gemini "${ARGS[@]}"
    fi
    ;;
  claude)
    if ! command -v claude >/dev/null 2>&1; then
      echo "[error] 'claude' CLI not found. Install with: npm i -g @anthropic-ai/claude-code" >&2
      exit 1
    fi
    # Require Node >=18 for Claude Code
    nm=$(get_node_major)
    if (( nm < 18 )); then
      echo "[error] Node.js >=18 is required for Claude Code (found major $nm)." >&2
      exit 1
    fi
    if [[ -n "$PROMPT" ]]; then
      exec claude -p "$PROMPT" "${ARGS[@]}"
    else
      exec claude "${ARGS[@]}"
    fi
    ;;
  codex)
    if ! command -v codex >/dev/null 2>&1; then
      echo "[error] 'codex' CLI not found. Install with: npm i -g @openai/codex" >&2
      exit 1
    fi
    # Require Node >=22 for Codex CLI
    nm=$(get_node_major)
    if (( nm < 22 )); then
      echo "[error] Node.js >=22 is required for OpenAI Codex CLI (found major $nm)." >&2
      exit 1
    fi
    if [[ -n "$PROMPT" ]]; then
      exec codex -p "$PROMPT" "${ARGS[@]}"
    else
      exec codex "${ARGS[@]}"
    fi
    ;;
  *)
    echo "[error] Unsupported agent: $AGENT" >&2
    echo "Usage: $0 --agent {gemini|claude|codex} [-p 'question'] [extra args...]" >&2
    exit 2
    ;;
esac
