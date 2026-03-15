# ZeroClaw Course — Docker Image

Source files for building and publishing the ZeroClaw agent Docker image used in the AI course.

## Building and Publishing

```bash
# Build
docker build -t byrash/agents-course:latest .

# Push to Docker Hub
docker login
docker push byrash/agents-course:latest
```

For multi-platform (students on Mac ARM + Linux VPS):

```bash
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 \
  -t byrash/agents-course:latest --push .
```

## What's in the Image

- ZeroClaw v0.3.0 (prebuilt binary)
- Node.js 22 + agent-browser + Playwright + Chromium
- Xvfb virtual framebuffer for headless browser automation
- Config auto-generated from environment variables on first run
- Default workspace files copied into mounted volume on first run

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `TELEGRAM_BOT_TOKEN` | Yes | — | Bot token from @BotFather |
| `TELEGRAM_USER_ID` | Yes | — | Your numeric user ID from @userinfobot |
| `OPENAI_API_KEY` | Yes (for OpenAI) | — | API key from platform.openai.com |
| `LLM_PROVIDER` | No | `openai` | `openai` or `copilot` |
| `LLM_MODEL` | No | `gpt-4o` | Model name |

## File Structure

```
├── Dockerfile              # Image definition
├── entrypoint.sh           # Config generation + daemon startup
├── config.template.toml    # ZeroClaw config with env var placeholders
├── .env.example            # Template for testing locally
├── .dockerignore
└── workspace-defaults/     # Copied into workspace volume on first run
    ├── AGENTS.md
    ├── SOUL.md
    ├── TOOLS.md
    ├── IDENTITY.md
    └── USER.md
```

---

# Student Instructions

**Everything below this line is what you share with students.**

---

## Set Up Your Own AI Agent

You'll build a personal AI agent that you can talk to on Telegram. It can search the web, browse websites, and remember things across conversations.

### What You Need

- **Docker Desktop** — [mac](https://docs.docker.com/desktop/setup/install/mac-install/) · [windows](https://docs.docker.com/desktop/setup/install/windows-install/) · [linux](https://docs.docker.com/desktop/setup/install/linux/)
- **Telegram** on your phone or computer
- **OpenAI API key** (your instructor will help you with this)

### 1. Create a Telegram Bot

1. Open Telegram and search for **@BotFather**
2. Send `/newbot`
3. Pick a display name (anything you like)
4. Pick a username (must end in `bot`, e.g. `my_helper_bot`)
5. BotFather replies with a **bot token** — save it

### 2. Get Your Telegram User ID

1. Search for **@userinfobot** on Telegram
2. Send it any message
3. It replies with your **user ID** (a number like `123456789`) — save it

### 3. Get an OpenAI API Key

1. Go to [platform.openai.com](https://platform.openai.com) and sign up or log in
2. Navigate to API Keys and create a new key
3. Set a **monthly spending limit** of $5–10 under Settings → Limits
4. Save the key (starts with `sk-`)

### 4. Create a Project Folder

**Mac / Linux** — open Terminal:

```bash
mkdir zeroclaw && cd zeroclaw
mkdir -p workspace memory
```

**Windows** — open PowerShell:

```powershell
mkdir zeroclaw; cd zeroclaw
mkdir workspace, memory
```

### 5. Create Your Config File

Create a file called `.env` in your `zeroclaw` folder with this content, filling in your three values:

```
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_USER_ID=your_user_id_here
OPENAI_API_KEY=sk-your-key-here
LLM_PROVIDER=openai
LLM_MODEL=gpt-4o
```

### 6. Start Your Agent

**Mac / Linux:**

```bash
docker run -d \
  --name agents-course \
  --env-file .env \
  -v ./workspace:/home/zeroclaw/.zeroclaw/workspace \
  -v ./memory:/home/zeroclaw/.zeroclaw/memory \
  -p 42617:42617 \
  --restart unless-stopped \
  byrash/agents-course:latest
```

**Windows PowerShell:**

```powershell
docker run -d `
  --name agents-course `
  --env-file .env `
  -v ./workspace:/home/zeroclaw/.zeroclaw/workspace `
  -v ./memory:/home/zeroclaw/.zeroclaw/memory `
  -p 42617:42617 `
  --restart unless-stopped `
  byrash/agents-course:latest
```

### 7. Talk to Your Agent

Open Telegram, find your bot by its username, and send it a message.

The web dashboard is at [http://localhost:42617](http://localhost:42617).

### Customizing Your Agent

The `workspace/` folder contains files that control your agent's behavior. Open them in any text editor.

| File | What it controls |
|------|-----------------|
| `AGENTS.md` | Rules the agent follows (e.g. "always cite sources") |
| `SOUL.md` | Personality and communication style |
| `TOOLS.md` | Guidance on when to use which tools |
| `IDENTITY.md` | Agent name and role |
| `USER.md` | Info about you (timezone, preferences) |

After editing, restart to apply:

```bash
docker restart agents-course
```

### Useful Commands

```bash
docker ps                      # Is it running?
docker logs -f agents-course        # View live logs
docker stop agents-course           # Stop the agent
docker start agents-course          # Start it again
docker restart agents-course        # Restart after editing workspace files
docker rm -f agents-course          # Remove completely
```

### Troubleshooting

**Bot doesn't respond on Telegram**
- Check logs: `docker logs agents-course`
- Make sure you sent `/start` to your bot at least once
- Verify `TELEGRAM_BOT_TOKEN` in your `.env` file

**Container stops immediately**
- Run `docker logs agents-course` to see the error
- Usually a missing or empty value in `.env`

**OpenAI errors**
- Verify `OPENAI_API_KEY` in `.env`
- Check you have credits at [platform.openai.com](https://platform.openai.com)

**Start fresh**

Mac / Linux:

```bash
docker rm -f agents-course
rm -rf workspace memory
mkdir -p workspace memory
docker run -d \
  --name agents-course \
  --env-file .env \
  -v ./workspace:/home/zeroclaw/.zeroclaw/workspace \
  -v ./memory:/home/zeroclaw/.zeroclaw/memory \
  -p 42617:42617 \
  --restart unless-stopped \
  byrash/agents-course:latest
```

Windows PowerShell:

```powershell
docker rm -f agents-course
Remove-Item -Recurse -Force workspace, memory
mkdir workspace, memory
docker run -d `
  --name agents-course `
  --env-file .env `
  -v ./workspace:/home/zeroclaw/.zeroclaw/workspace `
  -v ./memory:/home/zeroclaw/.zeroclaw/memory `
  -p 42617:42617 `
  --restart unless-stopped `
  byrash/agents-course:latest
```
