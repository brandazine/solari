<img src="assets/solari.png" alt="SOLARI" width="100%" />

**English** · [한국어](README.ko.md) · [日本語](README.ja.md)

[SOLARI](https://solari.brandazine.com) is Brandazine's creator and brand data service. This repo is how you use that data from a terminal or an AI assistant. Instagram is supported now; TikTok, YouTube and more are on the way.

```
$ solari get instagram account search query=nike
$ solari get instagram content trending region=US limit=10 --json
```

What ships here:

- The `solari` CLI (recommended): grab the binaries from [Releases](https://github.com/brandazine/solari/releases)
- The SOLARI connector: a remote MCP server for Claude and other MCP hosts
- A Claude Code plugin that installs the connector and skill together

## Install

macOS / Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/brandazine/solari/main/install.sh | sh
```

Windows (PowerShell):

```powershell
irm https://raw.githubusercontent.com/brandazine/solari/main/install.ps1 | iex
```

The script downloads the right file for your machine, checks it against the release checksums, and installs it. Set `SOLARI_VERSION=1.0.0-alpha.1` to pin a version, `SOLARI_INSTALL_DIR` to change where it goes.

Or use a package manager:

```sh
brew install brandazine/solari/solari
npm install -g @brandazine/solari
pip install solari-cli
```

`pnpm add -g`, `bun add -g`, `yarn global add` and `pipx install` work the same way. Every route installs the same prebuilt binary, so nothing is compiled on your machine.

Whichever route you pick, `solari` notices once a day when a newer release is out and tells you the upgrade command for that route. It never prints that notice into `--json` output, a pipe, or a CI log; `SOLARI_NO_UPDATE_CHECK=1` turns it off.

To install by hand, download from [Releases](https://github.com/brandazine/solari/releases) and put the file on your PATH. On macOS, a browser-downloaded binary may need to be allowed once under System Settings, Privacy & Security.

Supported platforms: macOS (Apple Silicon, Intel) / Linux (x64, arm64, x64-musl) / Windows (x64, arm64)

### With an AI agent

Using Claude Code, Cursor or another coding agent? Paste this one line and it handles the install and setup:

```
Read https://raw.githubusercontent.com/brandazine/solari/main/llms-install.md and follow the steps to install and set up the SOLARI CLI.
```

## Getting started

```
solari auth login          # sign in with your SOLARI account in the browser
solari list                # the full catalog
solari instagram account   # tools in a group
solari list account search # a tool's parameters
solari instagram account search query=nike
solari auth status
```

You sign in once in the browser. There are no API keys to create or paste anywhere.

## What it can do

- Find brand and creator accounts from a partial name
- Find accounts similar to one you know
- Keyword-search posts across captions, bios and video transcripts (KR/JP/US/TW regions)
- Pull raw data: an account's posts, the sponsored posts a creator made, the sponsored posts a brand received
- Ad collaboration stats for a brand, and a ranking of its most frequent collaborators
- Fetch up to 100 posts by id in one call
- Trending and rising content by region, with a trend digest

The tool list comes from the server. Run `solari list` to see it. New tools and platforms show up without a CLI update.

## For AI agents (Claude Code, Codex, Cursor, ...)

Run `solari init` once. It installs a Claude Code skill, a Codex section and zsh completion, and after that agents reach for `solari` on their own when a question touches Instagram data. `solari init --remove` undoes it.

Things agents rely on:

- `solari help all` prints every command, tool and parameter on one page.
- Everything takes `--json`. `solari list --json` includes each tool's input schema.
- `--ndjson` prints one item per line, ready for jq:

  ```console
  $ solari instagram brand ad posts username=arenciaofficial months=24 limit=200 --ndjson >> ads.ndjson
  $ jq -s 'group_by(.username) | map({creator: .[0].username, posts: length})' ads.ndjson
  ```

- Array parameters take JSON or a comma-separated list, like `post_ids=a,b`.
- Tool calls need the platform in the path, like `solari instagram account posts ...`. Paths without it are for browsing.
- Exit codes: 0 success, 1 server error, 2 usage error, 3 sign-in needed.
- Over SSH or in a container, login prints a URL instead of opening a browser. Sign in there and paste the final URL from the address bar back into the prompt.

## Claude connector

You can skip the CLI and connect Claude directly. The address is `https://solari.sh/mcp`, and you sign in with your SOLARI account.

In Claude Code the plugin is the easiest path. It installs the connector and the skill together:

```
/plugin marketplace add brandazine/solari
/plugin install solari@brandazine
```

To add just the connector:

```sh
claude mcp add --transport http solari https://solari.sh/mcp
```

On claude.ai and Claude Desktop, add the address as a custom connector in the Connectors settings. Other MCP hosts work too if they support streamable HTTP with OAuth.

## Configuration

- `--server <url>` or `SOLARI_SERVER`: use a different SOLARI server. The last login server is saved in `~/.solari/config.json`.
- `SOLARI_HOME`: move the `~/.solari` directory
- `SOLARI_CACHE_TTL`: catalog cache TTL in seconds. Default 900, 0 means always live. `--refresh` forces a refresh.
- `SOLARI_CATALOG_TIMEOUT` / `SOLARI_CALL_TIMEOUT`: timeouts in seconds. Defaults 8 / 150.
- `--verbose`: detailed logs on stderr

## Shell completion

`solari init zsh` adds completion to `~/.zshrc`. For Bash, source the output of `solari completion bash`. Candidates come from the cached catalog, so new tools complete automatically.

## Support

Bugs and feature requests go to [GitHub Issues](https://github.com/brandazine/solari/issues). For security issues, see [SECURITY.md](SECURITY.md) instead of opening a public issue.

## License

See [LICENSE](LICENSE). SOLARI is a commercial service by Brandazine.
