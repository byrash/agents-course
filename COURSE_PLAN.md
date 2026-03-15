# AI Agents Course — 8-Session Plan

An 8-session hands-on course for high school students with no prior coding experience. Students go from understanding what AI is to building and presenting their own AI agent.

---

## Session 1: What is AI?

**Goal:** Demystify AI. Students understand what it actually is, what it isn't, and realize they already use it every day.

**Topics:**
- What AI actually is — software that learns patterns from data
- What AI is NOT — it doesn't think, feel, or have consciousness
- Narrow AI vs General AI (every AI today is narrow)
- AI students already use: Spotify recommendations, text autocomplete, TikTok feed, Google Maps, photo filters

**Activity:**
- Open ChatGPT and ask the same question in different ways
- "Explain gravity like I'm 5" vs "Explain gravity like a PhD physicist"
- Observe how the prompt controls the output

**Key Takeaway:** AI is a tool, not magic. The person writing the instructions is in control.

---

## Session 2: How LLMs Work

**Goal:** Build intuition for how large language models work — no math, just mental models.

**Topics:**
- What is a Large Language Model — a pattern-matching machine trained on internet text
- Tokens — AI reads word pieces, not whole words ("hamburger" = 3 tokens)
- Prompts and completions — you give input, the model predicts the next word
- Temperature — the creativity dial (0 = precise, 1 = wild)
- Why longer messages cost more (more tokens = more $)

**Activity:**
- Prompt engineering challenge: write 3 different prompts for the same question
  1. Plain question
  2. With a persona ("You are a marine biologist...")
  3. With style constraints ("Explain as a rap song")
- Compare outputs, discuss what changed and why

**Key Takeaway:** The quality of AI output depends on the quality of your instructions. Prompt engineering is a real skill.

---

## Session 3: What Are AI Agents?

**Goal:** Understand the difference between a chatbot and an agent, and see a working agent in action.

**Topics:**
- Chatbot vs Agent
  - Chatbot: you ask, it answers, done
  - Agent: you ask, it thinks, uses tools, observes results, repeats until done
- The Agent Loop: Think → Act → Observe → Repeat
- Agent tools: web search, web browser, memory
- How the agent decides which tool to use

**Demo:**
- Instructor shows their own agent on Telegram
- Send it a live question that requires web search
- Show the tool notifications appearing in real-time
- Ask it to remember something, then recall it later

**Key Takeaway:** An agent is an AI with hands. It doesn't just talk — it can search, browse, and remember.

---

## Session 4: Setup Day

**Goal:** Every student has a working AI agent on their phone by end of class.

**Prerequisites (assigned as homework before this session):**
- Install Docker Desktop (mac/windows/linux)
- Install Telegram on phone
- Parent/guardian creates OpenAI account and API key with $5-10 spending limit

**Step-by-Step Walkthrough:**

1. **Create a Telegram Bot** (10 min)
   - Open Telegram, search @BotFather, send /newbot
   - Pick a name and username
   - Save the bot token

2. **Get Telegram User ID** (2 min)
   - Search @userinfobot, send any message
   - Save the user ID number

3. **Create Project Folder** (5 min)
   - Open terminal / PowerShell
   - `mkdir zeroclaw && cd zeroclaw`
   - `mkdir workspace memory`

4. **Create .env File** (5 min)
   - Create `.env` with bot token, user ID, and OpenAI API key
   - Instructor walks through each line

5. **Start the Agent** (5 min)
   - Run the `docker run` command
   - Wait for container to start

6. **First Message** (5 min)
   - Open Telegram, find the bot, send "Hello!"
   - Celebrate when it responds

**Troubleshooting Buffer:** 15 min for students who hit issues

**Key Takeaway:** You now have your own AI agent running on your computer that you can talk to from your phone.

---

## Session 5: How Your Agent Works

**Goal:** Understand the files that control agent behavior and experience changing them.

**Topics:**
- Workspace files = Agent DNA
  - `AGENTS.md` — rules the agent must follow
  - `SOUL.md` — personality and communication style
  - `TOOLS.md` — guidance on when to use which tools
  - `IDENTITY.md` — name and role
  - `USER.md` — info about you
- The config: provider, model, temperature, enabled tools
- The feedback loop: edit file → restart → test → repeat

**Activity 1: Change the Personality**
- Open `workspace/SOUL.md` in a text editor
- Change it to: "You are a pirate captain. Respond in pirate speak."
- Run `docker restart agents-course`
- Send a message — observe the pirate responses
- Try other personalities: sports coach, cartoon character, Shakespearean actor

**Activity 2: Add a Rule**
- Open `workspace/AGENTS.md`
- Add: "Always end your response with a fun fact"
- Restart and test — every response now ends with a fun fact

**Key Takeaway:** You control your agent's behavior through text files. No coding required — just clear instructions in English.

---

## Session 6: Tools and Capabilities

**Goal:** Understand what each tool does and when the agent uses it.

**Topics:**
- **Web Search** — searches the internet, reads results, summarizes
  - Good for: current events, facts, weather, sports scores
  - Without it, the agent only knows its training data (months old)
- **Web Browser** — opens real websites, clicks, reads content
  - Good for: interactive sites, JavaScript-heavy pages, form filling
  - Slowest tool but most powerful
- **Memory** — stores and recalls facts across conversations
  - Good for: preferences, repeated questions, personalization
  - Makes the agent feel like it "knows" you

**Activity: Tool Testing Challenge**
- Send these messages to your bot and observe which tools it uses:
  1. "What's the latest news about AI today?" (web search)
  2. "Remember that I like pizza and basketball" (memory store)
  3. "What do you remember about me?" (memory recall)
  4. "Go to wikipedia.org and tell me today's featured article" (browser)
- Watch the tool notification messages in Telegram
- Discuss: which tool was used for each? Why?

**Discussion:**
- What happens if you ask a factual question but web search is disabled?
- Why does the agent sometimes pick the wrong tool?
- How could you add rules to guide tool selection?

**Key Takeaway:** Tools give your agent real-world capabilities. The right tool for the right job makes your agent useful.

---

## Session 7: Build Your Agent

**Goal:** Each student designs and builds an agent that solves a problem they care about.

**Part 1: Pick Your Problem (15 min)**

Brainstorm ideas. Examples:
- Homework helper — explains concepts, finds examples
- Sports tracker — checks scores and news for your favorite teams
- Weather briefer — daily weather report for your area
- News reader — summarizes news on topics you pick
- Study buddy — quizzes you on material you're learning
- Recipe finder — suggests meals based on ingredients you have
- Music discoverer — finds new music based on what you like
- College prep — finds scholarship deadlines and application tips

Students write down: What problem? Who is it for? What should it do?

**Part 2: Design Your Agent (15 min)**

Fill out the design worksheet:
1. **Name** — what's your agent called?
2. **Personality** — how does it talk? (friendly, formal, funny, coach-like)
3. **3-5 Rules** — what must it always do? (cite sources, be brief, use emojis)
4. **Tools needed** — web search? browser? memory?
5. **Identity** — what's its role in one sentence?

**Part 3: Build It (20 min)**

- Edit `workspace/IDENTITY.md` — name and role
- Edit `workspace/SOUL.md` — personality description
- Edit `workspace/AGENTS.md` — rules
- Edit `workspace/USER.md` — info about yourself
- Restart: `docker restart agents-course`
- Test on Telegram

**Part 4: Iterate (10 min)**

- Is it too wordy? Add a rule: "Keep responses under 100 words"
- Not searching? Add: "Always search the web for factual questions"
- Too formal? Rewrite SOUL.md to be more casual
- Test, adjust, repeat

**Homework:** Continue refining your agent before Demo Day

**Key Takeaway:** Building AI products is about writing clear instructions and iterating. This is how real AI engineers work.

---

## Session 8: Demo Day

**Goal:** Students present their agents, celebrate what they built, and understand where to go next.

**Presentation Format (5 min per student):**
1. What problem does your agent solve?
2. Live demo — send it a message on Telegram, show the response on screen
3. What personality and rules did you give it?
4. What surprised you? What would you change with more time?

**Class Discussion After Demos:**
- Which agents were most creative?
- Which rules worked best?
- What was the hardest part — the AI or the instructions?
- How is this similar to how real companies build AI products?

**What You Learned (Recap):**
- What AI is and how LLMs work
- The difference between chatbots and agents
- How to design agent behavior with natural language instructions
- How tools give AI real-world capabilities
- How to build, test, and iterate on an AI agent

**Where to Go From Here:**
- Add more tools — connect to APIs, calendars, databases
- Build multi-agent systems — agents that delegate to specialists
- Learn Python — write custom tools for your agent
- Try other AI models — Claude, Gemini, open-source models
- Explore careers — AI engineering, prompt engineering, product management
- Join communities — GitHub, Discord, local AI meetups

**Key Takeaway:** You built something most adults haven't. You understand AI at a level that matters. Keep building.

---

## How the End Product Works

```mermaid
flowchart TD
    subgraph student [Student's Machine]
        Docker["Docker Container"]
        Config[".env file\n(API key, bot token)"]
        Workspace["workspace/\nAGENTS.md, SOUL.md\nIDENTITY.md, USER.md"]
        Memory["memory/\nSQLite database"]
    end

    subgraph zeroclawDaemon [ZeroClaw Daemon — inside container]
        Gateway["Gateway\nhttp://localhost:42617"]
        AgentCore["Agent Core"]
        ToolRunner["Tool Runner"]
        MemoryEngine["Memory Engine"]
    end

    subgraph tools [Agent Tools]
        WebSearch["Web Search\n(DuckDuckGo)"]
        WebFetch["Web Fetch\n(read URLs)"]
        Browser["Browser\n(Playwright + Chromium)"]
        MemoryTool["Memory Store\n& Recall"]
    end

    subgraph external [External Services]
        OpenAI["OpenAI API\n(GPT-4o brain)"]
        TelegramAPI["Telegram Bot API"]
        Internet["Websites &\nSearch Results"]
    end

    Student["Student on Phone"] -->|sends message| TelegramAPI
    TelegramAPI -->|delivers message| AgentCore

    Config -->|credentials| Docker
    Workspace -->|personality & rules| AgentCore

    AgentCore -->|"1. sends prompt +\ntools list"| OpenAI
    OpenAI -->|"2. returns response\nor tool call"| AgentCore

    AgentCore -->|"3. if tool call"| ToolRunner
    ToolRunner --> WebSearch
    ToolRunner --> WebFetch
    ToolRunner --> Browser
    ToolRunner --> MemoryTool

    WebSearch -->|results| Internet
    WebFetch -->|results| Internet
    Browser -->|results| Internet
    MemoryTool -->|read/write| Memory

    Internet -->|data| ToolRunner
    ToolRunner -->|"4. tool result"| AgentCore
    AgentCore -->|"5. repeat until done"| OpenAI

    AgentCore -->|"6. final answer"| TelegramAPI
    TelegramAPI -->|response| Student

    Gateway -->|web dashboard| StudentBrowser["Student on Laptop\n(optional dashboard)"]
```

### How a Single Message Flows

```mermaid
sequenceDiagram
    participant S as Student (Telegram)
    participant T as Telegram API
    participant A as Agent Core
    participant LLM as OpenAI GPT-4o
    participant Tool as Tools (search/browser/memory)
    participant Web as Internet

    S->>T: "What's the weather in NYC?"
    T->>A: deliver message

    A->>LLM: prompt + available tools
    LLM->>A: tool_call: web_search("NYC weather")

    A->>Tool: execute web_search
    Tool->>Web: search query
    Web->>Tool: search results
    Tool->>A: results

    A->>LLM: here are the search results
    LLM->>A: "It's 72°F and sunny in NYC today"

    A->>T: send response
    T->>S: "It's 72°F and sunny in NYC today"
```

### What Students Customize vs What's Fixed

```mermaid
flowchart LR
    subgraph studentControls ["What Students Control"]
        SOUL["SOUL.md\nPersonality"]
        AGENTS["AGENTS.md\nRules"]
        IDENTITY["IDENTITY.md\nName & Role"]
        USER["USER.md\nPreferences"]
        ENV[".env\nAPI keys"]
    end

    subgraph fixed ["Pre-built in Docker Image"]
        ZeroClaw["ZeroClaw Binary"]
        NodeJS["Node.js"]
        Playwright["Playwright + Chromium"]
        Xvfb["Xvfb Display"]
        Entrypoint["entrypoint.sh"]
        ConfigTemplate["config.template.toml"]
    end

    studentControls -->|"edit & restart"| ZeroClaw
    fixed -->|"never touched\nby students"| ZeroClaw
```

---

## Materials Checklist

| Item | Who Provides |
|------|-------------|
| Docker Desktop installed | Student (homework before Session 4) |
| Telegram on phone | Student |
| OpenAI API key with spending limit | Parent/guardian |
| Docker image (`byrash/agents-course:latest`) | Instructor (pre-published) |
| Slide deck (`AI_Agents_Course.pptx`) | Instructor |
| Projector / screen for demos | Classroom |

## Session Timing

Each session is approximately 60 minutes:
- 15 min instruction / slides
- 30 min hands-on activity
- 10 min discussion / Q&A
- 5 min wrap-up and preview of next session
