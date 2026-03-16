# ──────────────────────────────────────────────────
# Student config — copy this file for each student
# e.g.  cp example.tfvars alice.tfvars
# ──────────────────────────────────────────────────

# Parent provides this (Hetzner Cloud Console → Security → API Tokens → Generate)
hcloud_token = "PASTE_HETZNER_API_TOKEN_HERE"

# Lowercase, no spaces, hyphens OK
student_name = "alice"

# Student creates bot via @BotFather on Telegram, gets token
telegram_bot_token = "123456789:ABCdef..."

# Student sends /start to @userinfobot on Telegram, gets their numeric ID
telegram_user_id = "987654321"

# ── LLM Configuration (pick ONE option) ──

# Option A: OpenRouter (RECOMMENDED — cheapest, $1 free credit to start)
#   Sign up at https://openrouter.ai → Keys → Create Key
#   Models: openai/gpt-4o, google/gemini-2.5-flash, deepseek/deepseek-chat, etc.
llm_provider       = "openrouter"
llm_model          = "openai/gpt-4o"
openrouter_api_key = "sk-or-v1-..."
openai_api_key     = ""

# Option B: OpenAI directly
#   Sign up at https://platform.openai.com → API Keys → Create
# llm_provider       = "openai"
# llm_model          = "gpt-4o"
# openai_api_key     = "sk-..."
# openrouter_api_key = ""

# Option C: GitHub Copilot (leave both keys empty, do OAuth after deploy)
# llm_provider       = "copilot"
# llm_model          = "gpt-4o"
# openai_api_key     = ""
# openrouter_api_key = ""

# ── Server ──

# cax11 = ARM 2vCPU/4GB ~$4/mo (recommended)
# cpx11 = x86 2vCPU/2GB ~$4.50/mo (if ARM has issues)
server_type = "cax11"

# ash = Virginia, hil = Oregon, nbg1 = Germany, fsn1 = Germany, hel1 = Finland
location = "ash"

# ── Instructor SSH access (optional) ──
# Paste your public key here to be able to SSH into the student's server
# instructor_ssh_public_key = "ssh-ed25519 AAAA..."
