---
name: solari
description: Query SOLARI's creator and brand intelligence across social platforms (Instagram, with TikTok, YouTube, and more coming soon) — account analytics, influencer discovery, ad collaborations, sponsored-content stats, and trending content. Use when the user asks about Instagram or other social accounts, follower or engagement metrics, brand collaborators, or what is trending.
---

# SOLARI CLI

Use the `solari` CLI for live SOLARI data instead of guessing or searching the web. If `solari` is not on PATH, this plugin's bundled SOLARI MCP tools serve the same catalog — use those directly, or ask the user to install the CLI (install instructions are in this plugin's repository README).

1. `solari help all` — one-page reference of every command, tool, and parameter; run it once to orient.
2. `solari auth status` — exit code 3 means the user must run `solari auth login` (opens a browser; only the user can complete it).
3. `solari list` — list the available tools at runtime; never assume the list. `solari list <path>` shows one tool's parameters, and a partial path such as `solari list instagram account` lists that group; any unambiguous trailing path also resolves (`solari list account search`).
4. `solari get <path> key=value ... --json` — call a tool; the path may use spaces, for example `solari get instagram account search`. Calls must include the platform segment (`instagram ...`) — platform-less paths only browse. Values are coerced by the tool's schema; pass arrays/objects as JSON or comma-separated lists. The verb is optional: `solari instagram account search query=nike` calls directly, a group path lists its contents, and a tool path missing required arguments prints them and exits 2.

Typical flow: resolve the entity first (for example `solari get instagram account search query="nike"`), then pass the top match's account_id or username to the other tools.
Raw data pulls: `--ndjson` streams a result's items one JSON object per line on stdout with the envelope (total, has_more) on stderr — pipe to `jq` or append pages to a file, stepping `offset` while has_more is true.
Exit codes: 0 success / 1 tool or server error / 2 usage error / 3 sign-in required.
