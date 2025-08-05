🧩 LLAMA DEV SNAPSHOT — v2025‑07‑26.4 (Part 1 of 4)
💠 Unified Venv Infrastructure • Agent System Status • Memory & Streaming Layer

───────────────────────────────────────────────────────────────────────────────
📌 LATEST HIGHLIGHTS
───────────────────────────────────────────────────────────────────────────────
✅ Python 3.13.5 venvs rebuilt using `.direnv/python-3.13` standard
✅ `.envrc` auto-activation confirmed for `api-prodn`, `llama-scripts`, and all core projects
✅ `fix-all-venvs.sh` fully patched to sync 3.13.x environments
✅ `venv-status.sh` cronjob added to `cron.weekly` (logs to `/var/log/venv-audit.log`)

───────────────────────────────────────────────────────────────────────────────
🧼 PRIOR IMPROVEMENTS
───────────────────────────────────────────────────────────────────────────────
🪚 Secrets scrubbed from Git via BFG
🧪 Fixed hydration/streaming bug in React/Next.js dashboards
🧠 `.envrc` + `sanity-venv-audit.sh` stable across MacBook & VPS environments

───────────────────────────────────────────────────────────────────────────────
✅ STACK STATUS (LIVE)
───────────────────────────────────────────────────────────────────────────────
Layer             │ Port   │ Component         │ Tech / Status
──────────────────┼────────┼───────────────────┼────────────────────────────────
🎯 AoE2HD App     │ —      │ Frontend          │ Next.js ✅ (Flutter legacy live)
🎯 AoE2HD API     │ 8003   │ Betting backend   │ FastAPI ✅
🧠 Metrics API    │ 8005   │ llama-api         │ FastAPI ✅
🧩 Chat Agent     │ 8006   │ llama-chat-api    │ FastAPI ✅ (SSE patched)
💬 Chat UI        │ 3006   │ llama-chat-app    │ Next.js ✅ (Streaming works)
📊 Dashboard UI   │ 3005   │ llama-dashboard   │ Next.js ✅ (Tiles confirmed)
🧠 Ollama LLM     │ —      │ llama3:8b local   │ ✅ `q4_K_M` streaming, local inference
🎭 OpenAI Agent   │ —      │ Agent4oMP         │ ✅ Bootloader injected, memory OK

───────────────────────────────────────────────────────────────────────────────
🧰 PM2 SERVICE SNAPSHOT
───────────────────────────────────────────────────────────────────────────────
Name                │ Port(s)         │ Tech
────────────────────┼─────────────────┼─────────────────────
token_tap_app       │ 3007            │ Next.js
token_tap_api       │ 8007            │ FastAPI
redline-legal-app   │ 3004            │ Next.js
redline-legal-api   │ 8004            │ FastAPI
explorer-prod       │ 4173            │ Vite
wolo-prod           │ 26656 / 26657   │ Cosmos SDK
llama-chat-app      | 3006            |
llama-chat-api      | 8006            |
app-prodn           | 3008            | Next.js
api-prodn           | 8008            | FastAPI
tmail-app           |	3009            |
tmail-api           |	8009            | 

───────────────────────────────────────────────────────────────────────────────
🧩 VENV INFRASTRUCTURE SNAPSHOT — v2025‑07‑26.4
───────────────────────────────────────────────────────────────────────────────

1️⃣ PYENV-VIRTUALENV (Python 3.11.9) — legacy
📁 Repo               │ Env Name        │ Type             │ Auto-activation
─────────────────────┼─────────────────┼──────────────────┼─────────────────────
llama-chat-api       │ api311          │ pyenv‑virtualenv │ layout pyenv ✅
llama-chat-app       │ app311          │ pyenv‑virtualenv │ layout pyenv ✅
llama-api            │ llamaapi311     │ pyenv‑virtualenv │ layout pyenv ✅
llama-dashboard      │ dashboard311    │ pyenv‑virtualenv │ layout pyenv ✅

2️⃣ AUTO-BOOTSTRAPPED (Python 3.12.3) — via `direnv-bootstrap-all.sh`
📁 Repo               │ Env Name
─────────────────────┼─────────────────────
aoe2hd-parsing       │ aoe2hdparsing312
api-prod             │ apiprod312
api-prodf            │ apiprodf312
api-prodn            │ apiprodn312
api-staging          │ apistaging312
llama-api            │ llamaapi312
llama-backend        │ llamabackend312
llama-chat-api       │ llamachatapi312
llama-chat-app       │ llamachatapp312
llama                │ llama312
token_tap_api        │ tokentapapi312

3️⃣ MODULAR DIR-LOCAL VIRTUALENVS (Python 3.13.x)
📁 Repo               │ Venv Path
─────────────────────┼────────────────────────────
llama-scripts        │ .direnv/python-3.13
api-prodn            │ .direnv/python-3.13
(api-prod pending…)  │ (as you cd into them)

🧠 Activation Chain
- direnv auto-triggers via `.envrc`
- Python version controlled via `.python-version` or venv path
- Resolved via `~/.pyenv/shims/python`

───────────────────────────────────────────────────────────────────────────────
🪝 SYMLINKS (DRY Propagation Across Repos)
───────────────────────────────────────────────────────────────────────────────
File Name              │ Linked In                │ Notes
───────────────────────┼──────────────────────────┼────────────────────────────
LLAMA_SNAPSHOT.md      │ llama-chat-*, others     │ Global visibility of stack
direnv-bootstrap.sh    │ all projects             │ Standardized venv creation
direnv-bootstrap-all.sh│ ~/projects top-level     │ Bulk init/fix automation


───────────────────────────────────────────────────────────────────────────────
🐚 INFRA & DEV HYGIENE — CROSS-PLATFORM STATUS
───────────────────────────────────────────────────────────────────────────────

Feature                         │ Status   │ Notes
────────────────────────────────┼──────────┼──────────────────────────────────────
PM2 (frontend)                  │ ✅       │ Next.js apps autoload with venvs
PM2 (backend)                   │ ✅       │ FastAPI + Uvicorn mapped via venv/bin/python
.envrc auto-activation          │ ✅       │ Every repo activates cleanly
Python 3.13.5 build (Mac)       │ ✅       │ Custom Boost flags, pip rebuilt cleanly
Python 3.12.3 build (VPS)       │ ✅       │ Reproducible clean envs across stack
Aliases fix                     │ ✅       │ `unalias python` + `exec zsh` resolves pyenv shims
Git hygiene                     │ ✅       │ Ignores: `venv/`, `.env`, `.idea/`, `__pycache__`
Helper scripts (symlinked)      │ ✅       │ `~/projects/llama-scripts/bin/*` linked across repos

───────────────────────────────────────────────────────────────────────────────
🧪 LAUNCH & MAINTENANCE SCRIPTS
───────────────────────────────────────────────────────────────────────────────

Script Name             │ Status   │ Notes
────────────────────────┼──────────┼────────────────────────────────────────────
start-chatdev.sh        │ ✅       │ tmux, venv, autoports all working
start-dashdev.sh        │ 🔜       │ prepped; will mirror chatdev
fix-all-venvs.sh        │ ✅       │ regenerates, syncs, re-freezes, logs
sanity-venv-audit.sh    │ ✅       │ VPS-compatible; logs missing to /tmp/venv-missing-*

───────────────────────────────────────────────────────────────────────────────
🔌 CHAT SYSTEM — FRONTEND STREAMING ARCHITECTURE
───────────────────────────────────────────────────────────────────────────────

Framework:     React 19.1 + Next.js 15.3.4 + TailwindCSS
SSE Stream:    ✅ `streamChat()` → FastAPI `StreamingResponse` → DOM
Markdown:      ✅ `ReactMarkdown`
Agent memory:  ✅ local JSON w/ injectors
SSR fixes:     ✅ hydration bugs patched (_app.tsx wrapped)

🔑 Key Routes:
POST   /api/chat/send
GET    /chat/messages/{agent}
GET    /api/chat/agents
GET    /api/chat/responses

───────────────────────────────────────────────────────────────────────────────
📊 DASHBOARD SYSTEM — LLAMA VISUAL METRICS LAYER
───────────────────────────────────────────────────────────────────────────────

Frontend: llama-dashboard (Next.js 15.3.4) → port 3005  
Backend:  llama-api (FastAPI) → port 8005

Endpoints:
  • /stats/tokens
  • /system-vitals
  • /agents/health

Auto-refresh: ✅ `refetchInterval` in place, works for live polling

───────────────────────────────────────────────────────────────────────────────
🧠 OLLAMA LLM — LOCAL INFERENCE + MEMORY SYSTEM
───────────────────────────────────────────────────────────────────────────────

🧠 Model Inference Layer
────────────────────────
Model used:            ✅ llama3:8b-instruct-q4_K_M
Streaming response:    ✅ FastAPI `StreamingResponse` → frontend DOM
Container settings:    ✅ keep_alive: false (prevents container stall)
Persona preprompt:     ✅ Injected into initial messages per agent
System prompt cap:     ✅ ~12K char cap enforced on history

🧠 Memory Subsystem
────────────────────
Format:                ✅ JSON files under `./memory/{agent}.json`
Memory injection:      ✅ Chat memory injected into prompts
Scoped filters:        🟡 In prototype (inline token filtering)
FAISS embeddings:      🟡 Scaffolding added; vector search pending
GPT summarization:     🟡 First-pass chunker in development
Pruning logic:         🔜 To be added (heuristic overflow guards)
Manual validation:     ✅ All agents pass memory load/parse

───────────────────────────────────────────────────────────────────────────────
🧬 MEMORY ROADMAP — Q3 2025
───────────────────────────────────────────────────────────────────────────────

• Scoped tagging + replay filters per agent
• Vector embedding via `vector_memory.py` → FAISS search
• Memory pruning via size/recency heuristics
• GPT summaries + rollups for long sessions
• Memory mutation audit trail + drift detection
• Injector system: LLAMA_SNAPSHOT.md auto-pins context
• Snapshots track divergence between memory vs runtime

───────────────────────────────────────────────────────────────────────────────
📱 MOBILE + NGROK ACCESS
───────────────────────────────────────────────────────────────────────────────

iOS Safari support:      ❌ Blocked due to localhost/CORS
ngrok proxy:             ✅ Use `NEXT_PUBLIC_API_BASE=https://<ngrok-sub>.ngrok-free.app`
Streaming via ngrok:     ✅ Confirmed working for `/send` route

───────────────────────────────────────────────────────────────────────────────
🧩 FINAL CONTEXT LOCK
───────────────────────────────────────────────────────────────────────────────

Snapshot ID:     🧩 LLAMA DEV SNAPSHOT — v2025‑07‑26.1  
Synced Agents:   ✅ Agent4oMP (OpenAI) + all Ollama agents
Live Stack:      ✅ All PM2 services mapped to venvs  
Platform:        ✅ Mac (local) + VPS (Hetzner)  

───────────────────────────────────────────────────────────────────────────────
📋 SANITY / LOGGING / CLI TOOLS — Root-Safe Compatibility
───────────────────────────────────────────────────────────────────────────────

sanity script path:         ✅ `/var/www/llama-scripts/bin/sanity`
Root execution:             ✅ Works with `.direnv` + `python-3.13.0`
Stream display:             ✅ `watch -n 5 sanity` confirmed working in tmux
Live logs:                  ✅ Sed transforms `\r` → `\r\n` for terminal display
Tool inspection:            ✅ `wc -l`, `sed -n`, `less -R` used for CLI insight
