🧩 LLAMA DEV SNAPSHOT — v2025-07-23.3
📌 Recent Highlights
✅ Clean venv rebuild (3.11.9)

✅ .envrc + pyenv auto-activation

✅ LLAMA_SNAPSHOT.md symlinked

🧼 GitHub secret cleanup

🪟 Tile polling + Next.js metadata bug resolved

✅ STACK STATUS (LIVE)
Layer	Port	Component	Tech / Status
🎯 AoE2HD App	—	Frontend	Next.js ✅ (Flutter live)
🎯 AoE2HD API	8003	Betting backend	FastAPI ✅
🧠 Metrics API	8005	llama-api	FastAPI ✅
🧩 Chat Agent API	8006	llama-chat-api	FastAPI ✅ (SSE patched)
💬 Chat UI	3006	llama-chat-app	Next.js ✅ (streams OK)
📊 Dashboard UI	3005	llama-dashboard	Next.js ✅ (metrics flow)
🧠 Ollama LLM	—	LLaMA 3 8b Q4_K_M	✅ Local inference
🎭 OpenAI Agent	—	Agent4oMP	✅ Prompt-Mgmt injected

🧰 PM2 SERVICES SNAPSHOT
Name	Port(s)	Tech
token_tap_app	3007	Next.js
token_tap_api	8007	FastAPI
redline-legal-app	3004	Next.js
redline-legal-api	8004	FastAPI
explorer-prod	4173	Vite
wolo-prod	26656/26657	Cosmos SDK

🧩 VENV INFRASTRUCTURE SNAPSHOT — v2025-07-24

📁 Repo              | 🧪 Env Name     | Python Ver | Env Type         | Auto-activation
--------------------|----------------|------------|------------------|-----------------
llama-chat-api      | api311         | 3.11.9     | pyenv-virtualenv | layout pyenv ✅
llama-chat-app      | app311         | 3.11.9     | pyenv-virtualenv | layout pyenv ✅
llama-api           | llamaapi311    | 3.11.9     | pyenv-virtualenv | layout pyenv ✅
llama-dashboard     | dashboard311   | 3.11.9     | pyenv-virtualenv | layout pyenv ✅

🧠 Activated by: direnv (.envrc) + .python-version
🧩 Shims route to: ~/.pyenv/shims/python

🪝 SYMLINKS
File	Linked In	Notes
LLAMA_SNAPSHOT.md	llama-chat-api, llama-chat-app	✅ Global visibility

🐚 INFRA & DEV HYGIENE
✅ PM2 frontend: start-llama.sh

✅ PM2 backend: venv/bin/python -m uvicorn …

✅ Auto-activation: .envrc + pyenv local 3.11.9

✅ Python: Clean 3.11.9 build

✅ Alias fix: unalias python && exec zsh

✅ Git hygiene: ignores venv/, .env, .idea/, .pyc

✅ iOS testing via *.ngrok-free.app

🧪 LAUNCH SCRIPTS
Script	Status	Notes
start-chatdev.sh	✅	Tmux, clean venv start, envs autoload
start-dashdev.sh	🔜	Align structure & hygiene

🔌 CHAT SYSTEM
Framework: React 19.1 + Next.js 15.3.4 + Tailwind ✅

Markdown: via ReactMarkdown ✅

Streaming: via streamChat() ✅

Key Routes: /api/chat/send, /chat/messages/{agent}, /responses ✅

📊 DASHBOARD SYSTEM
Frontend: Next.js 15.3.4 @ :3005

Backend: FastAPI @ :8005

Live Endpoints: /stats/tokens, /system-vitals, /agents/health

🔄 Auto-refresh: In progress

🧠 OLLAMA LLM (LOCAL)
Model: llama3:8b-instruct-q4_K_M

✅ Persona injection + streaming

✅ Memory: ./memory/{agent}.json (12K cap)

⚠️ keep_alive: false patch to avoid stale containers

⚠️ BUG FIXES
Issue	Resolution
❌ Stream reply invisible	logRef[idx] = {…} + flushSync()
❌ Token tile stale	refetchInterval + invalidate()
❌ SSE fallback	<prompt:…> + client.responses

🧱 NEXT.JS & ENV FIXES
✅ .env secrets removed & rotated (via BFG)

✅ Hydration: wrapped in <ClientProviders>

🧠 MEMORY SYSTEM STATUS
Feature	Status	Notes
Persistent JSON	✅	Per-agent memory
GPT Pre-injection	✅	Injected at start
Tagging	🟡	Inline scoped tags
FAISS search	🟡	Scaffolded
Scoped filters	🟡	Token-fit filtering
GPT summaries	🟡	Auto-chunking in dev
Pruning	🔜	Next pass
Manual validation	✅	All agents validated

🔬 MEMORY ROADMAP — Q3 2025
🥇 🔖 Tagging + 🧠 Embeddings

🥇 📁 Scoped filters

🥇 💬 GPT summaries

🥈 🧹 Pruning

🥉 🧬 Mutation / Replay

📂 Next: vector_memory.py

🐚 VENV STATUS
Project	Activated Via
llama-chat-api	✅ source venv/bin/activate
llama-chat-app	✅ .envrc + direnv
llama-dashboard	✅ .envrc + direnv
llama-api	✅ .envrc + direnv

📋 FEATURE SNAPSHOT
✅ SSE backend

✅ Markdown rendering

✅ Agent-based memory

✅ Stream isolation per agent

⚠️ Prompt-Mgmt SSE fix pending

🔄 Token tile auto-refresh pending

📱 MOBILE / NGROK
❌ iOS Safari fails on localhost

✅ Use:

NEXT_PUBLIC_API_BASE=https://<your-subdomain>.ngrok-free.app