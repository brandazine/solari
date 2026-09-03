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

The script picks the right binary for the machine, verifies it against the release checksums, and installs to `~/.local/bin` (macOS/Linux) or `%LOCALAPPDATA%\Programs\solari` (Windows).

## 2. Check it is on PATH

Run `solari --version`. If the command is not found on macOS/Linux, add the install directory to PATH for this session and suggest the user persist it in their shell profile:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

On Windows the installer adds the directory to the user PATH; a new terminal may be needed.

## 3. Register the CLI with agents on this machine

```sh
solari init --yes
```

This installs a Claude Code skill, a managed section in Codex's AGENTS.md, and zsh completion, for whichever of those exist on the machine. After this, agents (including you, in future sessions) reach for `solari` on their own when a question is about Instagram data. `solari init --remove` undoes it.

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
