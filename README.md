# AI Agents Course — ZeroClaw on Hetzner Cloud

Infrastructure-as-code setup for deploying personal AI agents (ZeroClaw) for students on Hetzner Cloud using OpenTofu. Each student gets their own $4/month cloud server with ZeroClaw running bare-metal (no Docker overhead).

## How It Works

1. **Parent** creates a [Hetzner Cloud](https://console.hetzner.cloud) account (~$4/month)
2. **Parent** generates an API token and shares it with the instructor
3. **Instructor** runs one command to deploy the student's server
4. **Student** talks to their AI agent on Telegram and customizes it

## Prerequisites (Instructor)

- [OpenTofu](https://opentofu.org/docs/intro/install/) installed (`brew install opentofu` on macOS)
- An SSH key pair for remote access to student servers

## Quick Start

### 1. Initialize OpenTofu

```bash
cd infra
tofu init
```

### 2. Create a Student Config

```bash
cp students/example.tfvars students/alice.tfvars
```

Edit `students/alice.tfvars`:

```hcl
hcloud_token       = "hc_API_TOKEN_FROM_PARENT"
student_name       = "alice"
telegram_bot_token = "123456789:ABCdef..."
telegram_user_id   = "987654321"

# OpenRouter is cheapest — see "Choosing an LLM Provider" below
llm_provider       = "openrouter"
llm_model          = "openai/gpt-4o"
openrouter_api_key = "sk-or-v1-..."

server_type = "cax11"   # ARM 2vCPU/4GB — $4/mo
location    = "ash"     # Ashburn, Virginia

instructor_ssh_public_key = "ssh-ed25519 AAAA..."
```

### 3. Deploy

```bash
./scripts/deploy-student.sh students/alice.tfvars
```

In ~4 minutes the server is live. The script auto-generates an SSH key pair for the student, saves it to `students/<name>/id_ed25519`, and prints setup instructions.

### 4. Verify

```bash
ssh root@<SERVER_IP> 'tail -f /var/log/cloud-init-output.log'
```

Wait until you see `Cloud-init finished`. Then check:

```bash
ssh root@<SERVER_IP> 'systemctl status zeroclaw'
```

The student can now open Telegram and message their bot.

## Managing Students

```bash
# List all deployed student servers
./scripts/list-students.sh

# Destroy a student's server
./scripts/teardown-student.sh alice students/alice.tfvars
```

## What Gets Deployed

Each student server (Ubuntu 24.04) is provisioned automatically via cloud-init:

- ZeroClaw v0.3.0 binary (auto-detects ARM/x86)
- Node.js 22 + agent-browser + Playwright + Chromium
- Xvfb virtual framebuffer for headless browser
- systemd service that starts ZeroClaw on boot
- Firewall allowing only SSH (22) and dashboard (42617)
- Config generated from the student's credentials
- Default workspace files for agent personality

## Choosing an LLM Provider

Your agent needs a "brain" — a large language model. Three options, ranked by cost:

### Option A: OpenRouter (Recommended)

The cheapest and most flexible option. One API key gives access to 300+ models. Comes with **$1 free credit** on signup — enough for hundreds of messages.

| Model | Input / Output per 1M tokens | Best For |
|-------|------------------------------|----------|
| `deepseek/deepseek-chat` | $0.32 / $0.89 | Cheapest capable model |
| `google/gemini-2.5-flash` | $0.30 / $2.50 | Fast and cheap |
| `openai/gpt-4o` | $2.50 / $10.00 | Best quality |

**Estimated cost:** A student sending ~50 messages/day uses roughly $0.50–2.00/month with `deepseek/deepseek-chat` or `google/gemini-2.5-flash`.

**Setup:**
1. Go to [openrouter.ai](https://openrouter.ai) and sign up (Google/GitHub login works)
2. Go to [Keys](https://openrouter.ai/settings/keys) → **Create Key** → copy it (starts with `sk-or-v1-`)
3. Optionally add $5 credit under [Credits](https://openrouter.ai/settings/credits) (the $1 free is enough to start)

**In the student's `.tfvars`:**
```hcl
llm_provider       = "openrouter"
llm_model          = "openai/gpt-4o"        # or deepseek/deepseek-chat, google/gemini-2.5-flash
openrouter_api_key = "sk-or-v1-..."
```

### Option B: OpenAI Direct

Better if the parent/student already has an OpenAI account. Slightly more expensive but the most mature API.

| Model | Input / Output per 1M tokens |
|-------|------------------------------|
| `gpt-4o` | $2.50 / $10.00 |
| `gpt-4o-mini` | $0.15 / $0.60 |

**Setup:**
1. Go to [platform.openai.com](https://platform.openai.com) and sign up or log in
2. Go to **API Keys** → **Create new secret key** → copy it (starts with `sk-`)
3. Go to **Settings → Limits** → set a **monthly spending limit of $5–10**
4. Add $5–10 in **Billing → Add payment method**

**In the student's `.tfvars`:**
```hcl
llm_provider   = "openai"
llm_model      = "gpt-4o"                   # or gpt-4o-mini for cheaper
openai_api_key = "sk-..."
```

### Option C: GitHub Copilot

Free for students with [GitHub Education](https://education.github.com/pack), but requires an OAuth flow after the server is deployed.

**Setup:**
1. Student signs up for [GitHub Education](https://education.github.com/pack) (free with a school email)
2. Deploy the server with `llm_provider = "copilot"` and both API keys empty
3. After deploy, SSH in and run the OAuth flow:
   ```bash
   ssh zeroclaw@SERVER_IP
   zeroclaw auth login copilot
   ```
4. Follow the URL, enter the device code, authorize
5. Restart: `sudo systemctl restart zeroclaw`

### LLM Cost Summary

| Provider | Cheapest Model | ~Cost for 50 msgs/day | Setup Difficulty |
|----------|---------------|----------------------|-----------------|
| **OpenRouter** | deepseek-chat | ~$0.50–1/mo | Easy (1 key) |
| **OpenAI** | gpt-4o-mini | ~$1–2/mo | Medium (key + billing) |
| **GitHub Copilot** | gpt-4o | Free (students) | Harder (OAuth flow) |

## Variables Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `hcloud_token` | Yes | — | Hetzner API token (from parent) |
| `student_name` | Yes | — | Lowercase name, no spaces |
| `telegram_bot_token` | Yes | — | From @BotFather on Telegram |
| `telegram_user_id` | Yes | — | From @userinfobot on Telegram |
| `llm_provider` | No | `openai` | `openai`, `openrouter`, or `copilot` |
| `llm_model` | No | `gpt-4o` | Model name (provider-specific) |
| `openai_api_key` | For OpenAI | `""` | From platform.openai.com |
| `openrouter_api_key` | For OpenRouter | `""` | From openrouter.ai |
| `server_type` | No | `cax11` | Hetzner server type |
| `location` | No | `ash` | Hetzner data center |

## File Structure

```
infra/
├── providers.tf              # Hetzner Cloud provider
├── variables.tf              # All input variables
├── main.tf                   # Server, firewall, SSH key
├── outputs.tf                # IP, dashboard URL, SSH commands
├── cloud-init.yaml.tpl       # Bare-metal setup script
├── scripts/
│   ├── deploy-student.sh     # Deploy one student
│   ├── teardown-student.sh   # Destroy one student's server
│   └── list-students.sh      # Show all deployed students
└── students/
    └── example.tfvars        # Copy per student
```

## Server Costs

| Server Type | Specs | Monthly Cost | Notes |
|-------------|-------|-------------|-------|
| `cax11` (ARM) | 2 vCPU, 4GB RAM, 40GB SSD | ~$4/mo | Recommended |
| `cpx11` (x86) | 2 vCPU, 2GB RAM, 40GB SSD | ~$4.50/mo | If ARM causes issues |

10 students = ~$40/month total.

## Student Instructions

**Share everything below this line with students.**

---

### Set Up Your AI Agent

You'll get a personal AI agent that lives on a cloud server and talks to you on Telegram. It can search the web, browse websites, and remember things.

#### 1. Create a Telegram Bot

1. Open Telegram and search for **@BotFather**
2. Send `/newbot`
3. Pick a display name (anything you like)
4. Pick a username (must end in `bot`, e.g. `my_helper_bot`)
5. BotFather replies with a **bot token** — send it to your instructor

#### 2. Get Your Telegram User ID

1. Search for **@userinfobot** on Telegram
2. Send it any message
3. It replies with your **user ID** (a number like `123456789`) — send it to your instructor

#### 3. Get an LLM API Key

Your agent needs access to an AI model. Your instructor will tell you which option to use.

**Option A — OpenRouter (cheapest):**
1. Go to [openrouter.ai](https://openrouter.ai) and sign up (Google or GitHub login)
2. You get **$1 free credit** immediately
3. Go to [Keys](https://openrouter.ai/settings/keys) → **Create Key**
4. Send the key to your instructor (starts with `sk-or-v1-`)

**Option B — OpenAI:**
1. Go to [platform.openai.com](https://platform.openai.com) and sign up
2. Go to **API Keys** → **Create new secret key**
3. Set a **monthly spending limit** of $5–10 under Settings → Limits
4. Send the key to your instructor (starts with `sk-`)

**Option C — GitHub Copilot (free for students):**
1. Sign up for [GitHub Education](https://education.github.com/pack) with your school email
2. Tell your instructor you're using Copilot — no key needed upfront
3. After your server is set up, you'll authorize via a link

#### 4. Wait for Deployment

Your instructor will set up your server. Once it's ready, you'll get:
- An SSH key file (`id_ed25519`)
- Your server's IP address
- An SSH config snippet

#### 5. Set Up SSH Access

Your instructor gives you a key file. Copy it and add the config:

**macOS / Linux:**

```bash
cp ~/Downloads/id_ed25519 ~/.ssh/zc-YOURNAME
chmod 600 ~/.ssh/zc-YOURNAME
```

Add this to `~/.ssh/config` (create the file if it doesn't exist):

```
Host zc-YOURNAME
  HostName YOUR_SERVER_IP
  User zeroclaw
  IdentityFile ~/.ssh/zc-YOURNAME
  StrictHostKeyChecking no
```

**Windows PowerShell:**

```powershell
Copy-Item ~\Downloads\id_ed25519 $env:USERPROFILE\.ssh\zc-YOURNAME
icacls $env:USERPROFILE\.ssh\zc-YOURNAME /inheritance:r /grant:r "$($env:USERNAME):R"
```

Add this to `C:\Users\YOURNAME\.ssh\config` (create the file if it doesn't exist):

```
Host zc-YOURNAME
  HostName YOUR_SERVER_IP
  User zeroclaw
  IdentityFile ~/.ssh/zc-YOURNAME
  StrictHostKeyChecking no
```

Replace `YOURNAME` and `YOUR_SERVER_IP` with the values your instructor gives you.

#### 6. Talk to Your Agent

Open Telegram, find your bot by its username, and send it a message!

The web dashboard is at `http://YOUR_SERVER_IP:42617`.

### Editing with VS Code (Recommended)

The easiest way to customize your agent is with VS Code connected directly to your server.

1. Install [VS Code](https://code.visualstudio.com/)
2. Install the **Remote - SSH** extension (search "Remote SSH" in the Extensions tab)
3. Press `Cmd+Shift+P` (macOS) or `Ctrl+Shift+P` (Windows) and type **Remote-SSH: Connect to Host**
4. Select `zc-YOURNAME`
5. VS Code opens on your server — click **Open Folder** and enter `~/.zeroclaw/workspace/`
6. Edit any file, save, and restart from the VS Code terminal:
   ```bash
   sudo systemctl restart zeroclaw
   ```

### Customizing Your Agent

| File | What it controls |
|------|-----------------|
| `AGENTS.md` | Rules the agent follows (e.g. "always cite sources") |
| `SOUL.md` | Personality and communication style |
| `TOOLS.md` | Guidance on when to use which tools |
| `IDENTITY.md` | Agent name and role |
| `USER.md` | Info about you (timezone, preferences) |

After editing, restart to apply:

```bash
sudo systemctl restart zeroclaw
```

### Useful Commands

```bash
sudo systemctl status zeroclaw        # Is it running?
sudo journalctl -u zeroclaw -f        # View live logs
sudo systemctl restart zeroclaw       # Restart after editing
sudo systemctl stop zeroclaw          # Stop the agent
sudo systemctl start zeroclaw         # Start it again
```

### Troubleshooting

**Bot doesn't respond on Telegram**
- Check logs: `sudo journalctl -u zeroclaw --no-pager -n 50`
- Make sure you sent `/start` to your bot at least once
- Ask your instructor to verify the bot token

**Agent crashes or restarts**
- Check the service: `sudo systemctl status zeroclaw`
- View recent logs: `sudo journalctl -u zeroclaw --no-pager -n 100`

**LLM / API key errors**
- Ask your instructor to verify your API key
- OpenAI: check credits at [platform.openai.com](https://platform.openai.com)
- OpenRouter: check credits at [openrouter.ai/settings/credits](https://openrouter.ai/settings/credits)

### Using GitHub Copilot Instead of OpenAI

If your instructor set up Copilot as the LLM provider, you'll need to authorize it once:

```bash
ssh zc-YOURNAME
zeroclaw auth login copilot
```

Follow the URL shown and enter the device code to authorize. Then restart:

```bash
sudo systemctl restart zeroclaw
```
