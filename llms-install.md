# SOLARI CLI: agent install guide

You are an AI agent installing the SOLARI CLI for your user. Follow the steps in order and show the user what you run. Full docs: https://github.com/brandazine/solari

## 1. Install the binary

macOS / Linux:

```sh
curl -fsSL https://solari.sh/install | sh
```

Windows (PowerShell):

```powershell
irm https://solari.sh/install.ps1 | iex
```

The script picks the right binary for the machine, verifies it against the release checksums, installs to `~/.local/bin` (macOS/Linux) or `%USERPROFILE%\.solari\bin` (Windows), and then runs `solari init --detected` so every agent already on this machine gets its skill file. The install writes outside the project folder; if your sandbox blocks it, ask the user to approve rather than skipping.

## 2. Check it is on PATH

Run `solari --version`. If the command is not found, the install directory is not on PATH in this shell yet. Fix it for this session and keep going.

macOS/Linux (suggest the user persist it in their shell profile):

```sh
export PATH="$HOME/.local/bin:$PATH"
```

Windows (the installer already added it to the user PATH, but a shell opened before the install, including the one your host app started, does not see it until the app restarts):

```powershell
$env:Path = "$env:USERPROFILE\.solari\bin;$env:Path"
```

If your shell does not persist between commands, call the binary by its full path: `~/.local/bin/solari` or `& "$env:USERPROFILE\.solari\bin\solari.exe"`.

## 3. Register the CLI with agents on this machine

The installer already did this. Run it again to confirm; it is safe to repeat:

```sh
solari init --detected
```

This writes a skill for Claude Code (`~/.claude/skills/solari/SKILL.md`), a skill plus a managed `AGENTS.md` section for Codex (`~/.agents/skills/solari/SKILL.md`, `~/.codex/AGENTS.md`), and the same for Grok Build, Antigravity CLI, and OpenCode, for whichever exist on the machine or are running you right now. After this, agents (including you, in future sessions) reach for `solari` on their own when a question is about Instagram or TikTok data. If it reports nothing found, name the host: `solari init codex` or `solari init claude`. `solari init --remove` undoes it.

## 4. Sign in (requires the user)

```sh
solari auth status
```

Exit code 3 means sign-in is needed. Run `solari auth login`. In a non-interactive session it prints a sign-in URL instead of opening a browser: relay that URL to the user and wait, because only a human can complete the browser sign-in. If the browser cannot redirect back to this machine (SSH, containers), ask the user to paste the final URL from the browser's address bar into the waiting prompt.

## 5. Verify and orient

```sh
solari auth status
solari help all
```

`solari help all` prints a one-page reference of every command, tool, and parameter. From here, answer questions with live data: resolve accounts first with `solari instagram account search query=...`, then pass the returned account_id or username to the other tools. Use `--json` for structured output and `--ndjson` for one-item-per-line streaming into files or `jq`. Exit codes: 0 success, 1 server error, 2 usage error, 3 sign-in needed.
