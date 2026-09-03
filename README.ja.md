<img src="assets/solari.png" alt="SOLARI" width="100%" />

[English](README.md) · [한국어](README.ko.md) · **日本語**

[SOLARI](https://solari.brandazine.com)はBrandazineのクリエイター/ブランドデータサービスです。このリポジトリは、そのデータをターミナルやAIアシスタントから使うための配布リポジトリです。現在はInstagramに対応しており、TikTokやYouTubeなどは準備中です。

```
$ solari get instagram account search query=nike
$ solari get instagram content trending region=JP limit=10 --json
```

ここで配布しているもの:

- `solari` CLI (推奨): バイナリは[Releases](https://github.com/brandazine/solari/releases)からダウンロード
- SOLARIコネクタ: Claudeなどで使うremote MCPサーバー
- Claude Codeプラグイン: コネクタとスキルをまとめてインストール

## インストール

macOS / Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/brandazine/solari/main/install.sh | sh
```

Windows (PowerShell):

```powershell
irm https://raw.githubusercontent.com/brandazine/solari/main/install.ps1 | iex
```

スクリプトが環境に合ったファイルを選び、チェックサムを検証してからインストールします。バージョンを固定するなら`SOLARI_VERSION=1.0.0-alpha.1`、インストール先を変えるなら`SOLARI_INSTALL_DIR`を指定してください。

手動で入れる場合は[Releases](https://github.com/brandazine/solari/releases)からダウンロードしてPATHに置くだけです。macOSでブラウザからダウンロードしたファイルは、初回実行時にシステム設定のプライバシーとセキュリティで許可が必要なことがあります。

対応プラットフォーム: macOS (Apple Silicon, Intel) / Linux (x64, arm64, x64-musl) / Windows (x64, arm64)

### AIエージェントでインストール

Claude CodeやCursorなどのコーディングエージェントを使っているなら、次の1行を貼り付けるだけです。インストールとセットアップはエージェントが代わりに行います:

```
Read https://raw.githubusercontent.com/brandazine/solari/main/llms-install.md and follow the steps to install and set up the SOLARI CLI.
```

## はじめる

```
solari auth login          # ブラウザでSOLARIアカウントにサインイン
solari list                # カタログ全体
solari instagram account   # グループ内のツール一覧
solari list account search # ツールのパラメータを確認
solari instagram account search query=nike
solari auth status
```

サインインはブラウザで一度だけです。APIキーを発行したり、どこかに貼り付けたりする必要はありません。

## できること

- 名前の一部からブランド/クリエイターのアカウントを検索
- 似ているアカウントを探す
- 投稿のキーワード検索(キャプション、プロフィール、動画の文字起こしまで。KR/JP/US/TWリージョン)
- アカウントの投稿、クリエイターが投稿したスポンサー投稿、ブランドが受けたスポンサー投稿をrawデータで取得
- ブランドの広告コラボ統計と、よく協業するクリエイターのランキング
- 投稿idで最大100件を一括取得
- リージョン別のトレンド/急上昇コンテンツとトレンドまとめ

ツール一覧はサーバーから配信されます。`solari list`で確認してください。新しいツールやプラットフォームはCLIの更新なしで現れます。

## AIエージェントで使う (Claude Code, Codex, Cursorなど)

`solari init`を一度実行すると、Claude Codeスキル、Codexの設定、zsh補完がインストールされます。以降、Instagram関連の質問が出るとエージェントが自分で`solari`を使うようになります。`solari init --remove`で元に戻せます。

エージェントが使う機能:

- `solari help all`: 全コマンド/ツール/パラメータを1ページで出力
- すべてのコマンドに`--json`があります。`solari list --json`にはツールごとの入力スキーマも含まれます。
- `--ndjson`は結果を1行1件で出力し、そのままjqにつなげられます:

  ```console
  $ solari instagram brand ad posts username=arenciaofficial months=24 limit=200 --ndjson >> ads.ndjson
  $ jq -s 'group_by(.username) | map({creator: .[0].username, posts: length})' ads.ndjson
  ```

- 配列パラメータはJSONでもcomma区切りでも受け付けます。`post_ids=a,b`のように。
- ツール呼び出しのパスにはプラットフォームが必要です。`solari instagram account posts ...`のように。プラットフォームなしのパスは探索用です。
- exit code: 0 成功、1 サーバーエラー、2 使い方の誤り、3 サインイン必要
- SSHやコンテナなど、ブラウザがCLIに戻れない環境ではサインインURLが出力されます。ブラウザでサインインした後、アドレスバーのURLをプロンプトに貼り付ければ完了です。

## Claudeコネクタ

CLIなしでコネクタだけ接続することもできます。アドレスは`https://solari.sh/mcp`で、SOLARIアカウントでサインインして使います。

Claude Codeではプラグインが一番簡単です。コネクタとスキルが一緒にインストールされます:

```
/plugin marketplace add brandazine/solari
/plugin install solari@brandazine
```

コネクタだけ追加する場合:

```sh
claude mcp add --transport http solari https://solari.sh/mcp
```

claude.aiとClaude Desktopでは、設定のコネクタから上記アドレスをカスタムコネクタとして追加してください。他のMCPホストもstreamable HTTPとOAuthに対応していれば接続できます。

## 設定

- `--server <url>` または `SOLARI_SERVER`: 別のSOLARIサーバーを指定。最後にサインインしたサーバーが`~/.solari/config.json`に保存されます。
- `SOLARI_HOME`: `~/.solari`の場所を変更
- `SOLARI_CACHE_TTL`: カタログキャッシュのTTL(秒)。デフォルト900、0なら常にライブ。`--refresh`で強制更新。
- `SOLARI_CATALOG_TIMEOUT` / `SOLARI_CALL_TIMEOUT`: タイムアウト(秒)。デフォルト 8 / 150。
- `--verbose`: stderrに詳細ログ

## シェル補完

`solari init zsh`が`~/.zshrc`に補完を追加します。Bashは`solari completion bash`の出力をsourceしてください。候補はキャッシュされたカタログから生成されるので、新しいツールも自動で補完されます。

## お問い合わせ

バグや機能要望は[GitHub Issues](https://github.com/brandazine/solari/issues)へ。セキュリティの問題は公開Issueではなく[SECURITY.md](SECURITY.md)をご覧ください。

## ライセンス

[LICENSE](LICENSE)を参照してください。SOLARIはBrandazineの商用サービスです。
