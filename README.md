# 📊 Claude Code Status Line

A custom status line script for [Claude Code](https://claude.ai/code) that gives you a rich, colorized HUD right in your terminal.

## ✨ What it shows

| Section | Color | Description |
|---------|-------|-------------|
| 🤖 **Model** | 🟠 Orange | Active Claude model name |
| 📥 **Input tokens** | 🔴 Red | Total input tokens used (↑) |
| 📤 **Output tokens** | 🟢 Green | Total output tokens generated (↓) |
| 📏 **Context usage** | 🔵 Blue | Context window usage percentage |
| 💰 **Cost & duration** | 🟡 Yellow | Session cost in USD + elapsed time |
| ⏱️ **5h rate limit** | 🟠 Orange | 5-hour rate limit usage % + reset time |
| 📅 **7d rate limit** | 🔴 Red | 7-day rate limit usage % + reset time |
| 📧 **Email** | Dim | Logged-in Claude account email |

### 🖥️ Example output

```
Opus 4.6 │ 450↑ input │ 2480↓ output │ 4% context │ $0.57 in 40min │ 5h: 25% (14:30) │ 7d: 1% (Wed 14:30) │ user@example.com
```

## 🚀 Installation

### 1. Copy the script

```bash
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

### 2. Configure Claude Code

Add the following to your `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

### 3. Restart Claude Code

The status line will appear on your next session. 🎉

## 📋 Requirements

- [Claude Code](https://claude.ai/code) CLI
- [`jq`](https://jqlang.github.io/jq/) for JSON parsing
- Bash 4+
- A terminal with ANSI color support

## 🛠️ How it works

Claude Code pipes a JSON payload to the status line command via stdin on each refresh. The script parses it with `jq` and formats a single colorized line with all the session metrics.

The logged-in email is fetched via `claude auth status` since it's not included in the status line payload.

## 📄 License

MIT — use it, fork it, make it yours.
