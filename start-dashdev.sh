#!/usr/bin/env bash
set -euo pipefail

SESSION="dashdev"
DASHBOARD_DIR="$HOME/projects/llama-dashboard/frontend"
API_DIR="$HOME/projects/llama-api"
VENV_ACTIVATE="$API_DIR/venv/bin/activate"
UVICORN_BIN="$API_DIR/venv/bin/uvicorn"

# 1️⃣ Tear down any existing session & stray Uvicorn
tmux kill-session -t "$SESSION" 2>/dev/null || true
pkill -f "uvicorn backend.main" 2>/dev/null || true

# 2️⃣ Start tmux session with frontend in left pane
tmux new-session -d -s "$SESSION" -c "$DASHBOARD_DIR" \
  'echo "✨ Dashboard frontend starting on :3005…"; \
   PORT=3005 npm run dev; exec zsh'

# 3️⃣ Split and launch the API on the right
tmux split-window -h -c "$API_DIR" \
  "echo '🚀 Dashboard API starting on :8005…'; \
   source \"$VENV_ACTIVATE\"; \
   \"$UVICORN_BIN\" backend.main:app \
     --host 0.0.0.0 \
     --port 8005 \
     --reload \
     --log-level debug; \
   exec zsh"

# 4️⃣ Return focus to the frontend pane
tmux select-pane -t 0

# 5️⃣ Enable mouse and attach
tmux set-option -g mouse on
tmux attach -t "$SESSION"