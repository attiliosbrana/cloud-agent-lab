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

case "$AGENT" in
  gemini)
    if ! command -v gemini >/dev/null 2>&1; then
      echo "[error] 'gemini' CLI not found. Install per docs/AGENT_INSTALLS.md" >&2
      exit 1
    fi
    if [[ -n "$PROMPT" ]]; then
      exec gemini -p "$PROMPT" "${ARGS[@]}"
    else
      exec gemini "${ARGS[@]}"
    fi
    ;;
  *)
    echo "[error] Unsupported agent: $AGENT" >&2
    echo "Usage: $0 --agent gemini [-p 'question'] [extra args...]" >&2
    exit 2
    ;;
esac
