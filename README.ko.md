<img src="assets/solari.png" alt="SOLARI" width="100%" />

[English](README.md) · **한국어** · [日本語](README.ja.md)

[SOLARI](https://solari.brandazine.com)는 Brandazine의 크리에이터/브랜드 데이터 서비스입니다. 이 repo는 그 데이터를 터미널과 AI 어시스턴트에서 쓰기 위한 배포 저장소입니다. 지금은 Instagram을 지원하고, TikTok과 YouTube 등은 준비 중입니다.

```
$ solari get instagram account search query=nike
$ solari get instagram content trending region=KR limit=10 --json
```

여기서 배포하는 것:

- `solari` CLI (권장): 바이너리는 [Releases](https://github.com/brandazine/solari/releases)에서 받습니다.
- SOLARI 커넥터: Claude 등에서 쓰는 remote MCP 서버
- Claude Code 플러그인: 커넥터와 스킬을 한 번에 설치

## 설치

macOS / Linux:

```sh
curl -fsSL https://solari.sh/install | sh
```

Windows (PowerShell):

```powershell
irm https://solari.sh/install.ps1 | iex
```

스크립트가 컴퓨터에 맞는 파일을 받아서 체크섬 검증 후 설치합니다. 버전을 고정하려면 `SOLARI_VERSION=1.0.0-alpha.10`, 설치 위치를 바꾸려면 `SOLARI_INSTALL_DIR`를 지정하세요.

직접 설치하려면 [Releases](https://github.com/brandazine/solari/releases)에서 받아 PATH에 두면 됩니다. macOS에서 브라우저로 받은 파일은 처음 실행할 때 시스템 설정의 개인정보 보호 및 보안에서 한 번 허용해야 할 수 있습니다.

지원 플랫폼: macOS (Apple Silicon, Intel) / Linux (x64, arm64, x64-musl) / Windows (x64, arm64)

### AI 에이전트로 설치

Claude Code, Cursor 같은 코딩 에이전트를 쓰고 있다면 아래 한 줄만 붙여넣으세요. 설치와 세팅을 에이전트가 대신 합니다:

```
Read https://raw.githubusercontent.com/brandazine/solari/main/llms-install.md and follow the steps to install and set up the SOLARI CLI.
```

## 시작하기

```
solari auth login          # 브라우저에서 SOLARI 계정으로 로그인
solari list                # 전체 카탈로그 보기
solari instagram account   # 그룹 안의 툴 목록
solari list account search # 툴의 파라미터 확인
solari instagram account search query=nike
solari auth status
```

로그인은 브라우저에서 한 번만 하면 됩니다. API 키를 발급받거나 어딘가에 붙여넣을 일은 없습니다.

## 할 수 있는 것

- 이름 일부만 알아도 브랜드/크리에이터 계정 찾기
- 특정 계정과 비슷한 계정 찾기
- 게시물 키워드 검색 (캡션, 프로필 소개, 영상 자막까지. KR/JP/US/TW 리전)
- 계정의 게시물, 크리에이터가 올린 스폰서 게시물, 브랜드가 받은 스폰서 게시물을 raw 데이터로 인출
- 브랜드의 광고 협업 통계, 가장 많이 협업한 크리에이터 랭킹
- 게시물 id로 최대 100건 일괄 조회
- 리전별 트렌딩/급상승 콘텐츠와 트렌드 요약

툴 목록은 서버가 내려줍니다. `solari list`로 확인하세요. 서버에 새 툴이나 플랫폼이 추가되면 CLI 업데이트 없이 바로 나타납니다.

## AI 에이전트에서 쓰기 (Claude Code, Codex, Cursor 등)

`solari init`을 실행하면 Claude Code 스킬, Codex 설정, zsh 자동완성이 설치됩니다. 이후에는 Instagram 관련 질문이 나올 때 에이전트가 알아서 `solari`를 씁니다. `solari init --remove`로 되돌립니다.

에이전트가 기대는 기능 몇 가지:

- `solari help all`: 전체 커맨드/툴/파라미터를 한 페이지로 출력
- 모든 커맨드에 `--json`이 있습니다. `solari list --json`에는 툴별 입력 스키마도 들어 있습니다.
- `--ndjson`은 결과를 한 줄에 한 건씩 출력해서 jq로 바로 이어 쓸 수 있습니다:

  ```console
  $ solari instagram brand ad posts username=arenciaofficial months=24 limit=200 --ndjson >> ads.ndjson
  $ jq -s 'group_by(.username) | map({creator: .[0].username, posts: length})' ads.ndjson
  ```

- 배열 파라미터는 JSON이든 comma 구분이든 받습니다. `post_ids=a,b` 처럼.
- 툴을 호출할 때는 경로에 플랫폼이 들어가야 합니다. `solari instagram account posts ...` 처럼요. 플랫폼 없는 경로는 탐색용입니다.
- exit code: 0 성공, 1 서버 에러, 2 사용법 오류, 3 로그인 필요
- SSH나 컨테이너처럼 브라우저가 CLI로 돌아올 수 없는 환경에서는 로그인 URL이 출력됩니다. 브라우저에서 로그인한 뒤 주소창의 URL을 프롬프트에 붙여넣으면 끝입니다.

## Claude 커넥터

CLI 없이 커넥터만 붙여도 됩니다. 주소는 `https://solari.sh/mcp`이고, SOLARI 계정으로 로그인해서 씁니다.

Claude Code에서는 플러그인이 제일 간단합니다. 커넥터에 스킬까지 같이 설치됩니다:

```
/plugin marketplace add brandazine/solari
/plugin install solari@brandazine
```

커넥터만 붙이려면:

```sh
claude mcp add --transport http solari https://solari.sh/mcp
```

claude.ai와 Claude Desktop에서는 설정의 커넥터 메뉴에서 위 주소를 커스텀 커넥터로 추가하면 됩니다. 다른 MCP 호스트도 streamable HTTP와 OAuth를 지원하면 연결됩니다.

## 설정

- `--server <url>` 또는 `SOLARI_SERVER`: 다른 SOLARI 서버 지정. 마지막 로그인 서버가 `~/.solari/config.json`에 저장됩니다.
- `SOLARI_HOME`: `~/.solari` 위치 변경
- `SOLARI_CACHE_TTL`: 카탈로그 캐시 TTL(초). 기본 900, 0이면 항상 라이브. `--refresh`는 강제 갱신.
- `SOLARI_CATALOG_TIMEOUT` / `SOLARI_CALL_TIMEOUT`: 타임아웃(초). 기본 8 / 150.
- `--verbose`: stderr에 상세 로그

## 셸 자동완성

`solari init zsh`가 `~/.zshrc`에 자동완성을 추가합니다. Bash는 `solari completion bash` 출력을 source 하세요. 후보가 캐시된 카탈로그에서 나오기 때문에 새로 추가된 툴도 자동으로 완성됩니다.

## 문의

버그와 기능 요청은 [GitHub Issues](https://github.com/brandazine/solari/issues)로 보내주세요. 보안 문제는 공개 이슈 대신 [SECURITY.md](SECURITY.md)를 봐 주세요.

## 라이선스

[LICENSE](LICENSE) 참고. SOLARI는 Brandazine의 상용 서비스입니다.
