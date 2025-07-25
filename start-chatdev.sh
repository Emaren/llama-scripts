#!/usr/bin/env bash
set -euo pipefail

SESSION="chatdev"
API_DIR="$HOME/projects/llama-chat-api"
APP_DIR="$HOME/projects/llama-chat-app"
API_PYTHON="$API_DIR/.direnv/python-3.13/bin/python"
UVICORN_BIN="$API_DIR/.direnv/python-3.13/bin/uvicorn"

direnv allow "$APP_DIR"
direnv allow "$API_DIR"

# 1️⃣ Kill any existing tmux session & stray uvicorn
tmux kill-session -t "$SESSION" 2>/dev/null || true
pkill -f "uvicorn app.main" 2>/dev/null || true

# 2️⃣ Start a new tmux session for the frontend
tmux new-session -d -s "$SESSION" -c "$APP_DIR" \
  'echo "✨ Frontend (chat) starting on :3006…"; PORT=3006 npm run dev; exec zsh'

# 3️⃣ Split a pane for the backend API
tmux split-window -h -c "$API_DIR" \
  "echo '🚀 Backend (API) starting on :8006…'; \
   direnv allow . && \
   \"$UVICORN_BIN\" app.main:app \
     --host 0.0.0.0 \
     --port 8006 \
     --reload \
     --log-level debug; \
   exec zsh"

# 4️⃣ Focus back on the frontend pane
tmux select-pane -t 0

# 5️⃣ Enable mouse + attach session
tmux set-option -g mouse on
tmux attach -t "$SESSION"

