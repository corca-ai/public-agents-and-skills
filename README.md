# corca-plugins

코르카에서 유지보수하는, [AI-Native Product Team](AI_NATIVE_PRODUCT_TEAM.md)을 위한 Claude Code 플러그인 마켓플레이스입니다.

## 설치

### 1. Marketplace 추가 및 업데이트

```bash
claude plugin marketplace add https://github.com/corca-ai/claude-plugins.git
```

새 플러그인이 추가되거나 기존 플러그인이 업데이트되면, 먼저 마켓플레이스를 업데이트하세요:
```bash
claude plugin marketplace update corca-plugins
```

그 다음 필요한 플러그인을 설치하거나 업데이트합니다:
```bash
claude plugin install <plugin-name>@corca-plugins  # 새로 설치
claude plugin update <plugin-name>@corca-plugins   # 기존 플러그인 업데이트
```

설치/업데이트 후 Claude Code를 재시작하면 적용됩니다.

터미널 대신 Claude Code 내에서도 동일한 작업이 가능합니다:
```
/plugin marketplace add corca-ai/claude-plugins
/plugin marketplace update
```

### 2. 플러그인 오버뷰

| 플러그인 | 유형 | 설명 |
|---------|------|------|
| [clarify](#clarify) | Skill | 모호한 요구사항을 명확하게 정리 |
| [interview](#interview) | Skill | 구조화된 인터뷰로 요구사항 추출 |
| [g-export](#g-export) | Skill | Google 문서를 로컬 파일로 다운로드 |
| [slack-to-md](#slack-to-md) | Skill | Slack 메시지를 마크다운으로 변환 |
| [suggest-tidyings](#suggest-tidyings) | Skill | 안전한 리팩토링 기회 제안 |
| [attention-hook](#attention-hook) | Hook | 대기 상태일 때 Slack 알림 |

## Skills

### [clarify](plugins/clarify/skills/clarify/SKILL.md)

**설치**:
```bash
claude plugin marketplace add https://github.com/corca-ai/claude-plugins.git
claude plugin install clarify@corca-plugins
```

**갱신**:
```bash
claude plugin marketplace update corca-plugins
claude plugin update clarify@corca-plugins
```

모호하거나 불명확한 요구사항을 반복적인 질문을 통해 명확하고 실행 가능한 사양으로 변환하는 스킬입니다. [Team Attention](https://github.com/team-attention)에서 만든 [Clarify 스킬](https://github.com/team-attention/plugins-for-claude-natives/blob/main/plugins/clarify/SKILL.md)을 가져와서 커스터마이즈했습니다. (사용법 참조: 정구봉님 [링크드인 포스트](https://www.linkedin.com/posts/gb-jeong_%ED%81%B4%EB%A1%9C%EB%93%9C%EC%BD%94%EB%93%9C%EA%B0%80-%EA%B0%9D%EA%B4%80%EC%8B%9D%EC%9C%BC%EB%A1%9C-%EC%A7%88%EB%AC%B8%ED%95%98%EA%B2%8C-%ED%95%98%EB%8A%94-skills%EB%A5%BC-%EC%82%AC%EC%9A%A9%ED%95%B4%EB%B3%B4%EC%84%B8%EC%9A%94-clarify-activity-7413349697022570496-qLts))

**사용법**: "다음 요구사항을 명확하게 해줘", "clarify the following:" 등으로 트리거

**주요 기능**:
- 원본 요구사항 기록 후 체계적인 질문을 통해 모호함 해소
- Before/After 비교로 명확해진 결과 제시
- 명확해진 요구사항을 파일로 저장하는 옵션 제공. 필요시 이 문서를 Plan 모드에 넣어서 구현하면 됨

### [interview](plugins/interview/skills/interview/SKILL.md)

**설치**:
```bash
claude plugin marketplace add https://github.com/corca-ai/claude-plugins.git
claude plugin install interview@corca-plugins
```

**갱신**:
```bash
claude plugin marketplace update corca-plugins
claude plugin update interview@corca-plugins
```

코르카의 AX 컨설턴트 [최정혁님](https://denoiser.club/)이 본인의 취향에 맞게 만드신 스킬입니다. 목적은 Clarify와 유사합니다. 구조화된 인터뷰를 통해 요구사항, 제약사항, 설계 결정을 추출하는 스킬입니다. 대화를 통해 프로젝트의 핵심 요구사항을 발견하고 문서화합니다.

**사용법**:
- `/interview <topic>` - 새 인터뷰 시작 (예: `/interview auth-system`)
- `/interview <topic> --ref <path>` - 참조 파일을 기반으로 인터뷰
- `/interview <topic> --workspace <dir>` - 작업 디렉토리 지정

**주요 기능**:
- 한 번에 하나의 질문으로 집중된 대화 진행
- 실시간으로 SCRATCHPAD.md에 메모 기록
- 인터뷰 종료 시 SYNTHESIS.md로 요약 문서 생성
- 사용자 언어 자동 감지 및 적응 (한국어/영어)

**출력물**:
- `SCRATCHPAD.md` - 인터뷰 중 실시간 메모
- `SYNTHESIS.md` - 정리된 요구사항 종합 문서
- `JUST_IN_CASE.md` - 미래 에이전트를 위한 추가 맥락 (선택)

### [g-export](plugins/g-export/skills/g-export/SKILL.md)

**설치**:
```bash
claude plugin marketplace add https://github.com/corca-ai/claude-plugins.git
claude plugin install g-export@corca-plugins
```

**갱신**:
```bash
claude plugin marketplace update corca-plugins
claude plugin update g-export@corca-plugins
```

공개된 Google 문서(Slides, Docs, Sheets)를 로컬 파일로 다운로드하는 스킬입니다. ([작업 배경 블로그 글](https://www.stdy.blog/1p1w-02-g-export/))

**사용법**:
- 명시적 호출: `/g-export`
- URL 감지: Google 문서 URL을 에이전트가 발견하면 자동으로 다운로드 제안

**지원 포맷**:
- **Google Slides**: pptx, odp, pdf, txt (기본: txt)
- **Google Docs**: docx, odt, pdf, txt, epub, html, md (기본: md)
- **Google Sheets**: xlsx, ods, pdf, csv, tsv, toon (기본: toon)

g-export는 LLM이 문서 내용을 쉽게 파악할 수 있도록 텍스트 기반 포맷을 기본으로 선택합니다. Sheets는 CSV 대신 [TOON](https://github.com/toon-format/toon)을 기본으로 사용하여 LLM 호환성을 높입니다. 설문/세션 형식의 TOON 데이터는 에이전트가 마크다운으로 변환하여 가독성을 높일 수 있습니다.

**저장 위치**: `./g-exports/` 폴더 (원본 문서 제목을 파일명으로 사용)

**주의사항**:
- Sheets의 csv/tsv/toon은 기본적으로 첫 번째 시트만 다운로드 (다른 시트는 `gid` 파라미터 필요)
- md 포맷은 base64 이미지가 자동 제거됨 (이미지가 중요하면 `docx`나 `pdf` 사용)
- TOON 변환 가이드: [references/TOON.md](plugins/g-export/skills/g-export/references/TOON.md)

**추출 예시(Sheet → TOON → Markdown)**:

<img src="assets/g-export-sheet-md-example.png" alt="Sheet → TOON → Markdown" width="400">

### [slack-to-md](plugins/slack-to-md/skills/slack-to-md/SKILL.md)

**설치**:
```bash
claude plugin marketplace add https://github.com/corca-ai/claude-plugins.git
claude plugin install slack-to-md@corca-plugins
```

**갱신**:
```bash
claude plugin marketplace update corca-plugins
claude plugin update slack-to-md@corca-plugins
```

1개 이상의 Slack 메시지 URL을 단일한 마크다운 문서로 변환하는 스킬입니다. ([작업 배경 블로그 글](https://www.stdy.blog/1p1w-01-slack-to-md/))

**사용법**:
- 링크를 이용해 기존 메시지 취합하기: `slack-to-md <slack-message-url1> <slack-message-url2> <...>`
- 기존 문서 업데이트하기(예: 쓰레드에 새로 추가된 메시지를 기존 문서에 추가): `slack-to-md <path-to-file.md>`
- 그 외: `slack-to-md #foo 채널과 #bar 채널에서 이러저러한 내용을 취합해줘`

**주요 기능**:
- Slack 스레드의 모든 메시지를 마크다운으로 변환. 봇은 필요시 자동으로 해당 채널에 join
- 메시지에 첨부된 파일 자동 다운로드 (`slack-outputs/attachments/`에 저장)
- 문서 생성을 위한 bash 스크립트를 이용해 토큰 절약
- 첫 메시지 내용을 기반으로 의미있는 파일명 자동 생성
- `slack-outputs/` 디렉토리에 저장

**필수 조건**:
- Node.js 18+ 필요
- `jq` 설치 필요 (JSON 파싱용)
- Slack Bot 설정 필요 ([생성 가이드](https://api.slack.com/apps)):
  - OAuth scopes: `channels:history`, `channels:join`, `users:read`, `files:read`
  - `~/.claude/.env`에 `SLACK_BOT_TOKEN=xoxb-...` 설정

### [suggest-tidyings](plugins/suggest-tidyings/skills/suggest-tidyings/SKILL.md)

**설치**:
```bash
claude plugin marketplace add https://github.com/corca-ai/claude-plugins.git
claude plugin install suggest-tidyings@corca-plugins
```

**갱신**:
```bash
claude plugin marketplace update corca-plugins
claude plugin update suggest-tidyings@corca-plugins
```

Kent Beck의 "Tidy First?" 철학에 기반하여 최근 커밋들을 분석하고 안전한 리팩토링 기회를 찾아주는 스킬입니다. Sub-agent를 병렬로 활용하여 여러 커밋을 동시에 분석합니다.

**사용법**:
- 현재 브랜치 분석: `/suggest-tidyings`
- 특정 브랜치 분석: `/suggest-tidyings develop`

**주요 기능**:
- 최근 non-tidying 커밋에서 tidying 기회 탐색
- 각 커밋별 병렬 분석 (Task tool + sub-agents)
- Guard Clauses, Dead Code Removal, Extract Helper 등 8가지 tidying 기법 적용
- 안전성 검증: HEAD에서 이미 변경된 코드는 제외
- `파일:라인범위 — 설명 (이유: ...)` 형식의 실행 가능한 제안

**핵심 원칙**:
- 로직 변경 없이 가독성만 개선하는 안전한 변경
- 한 커밋으로 분리 가능한 원자적 수정
- 누구나 쉽게 리뷰할 수 있는 간단한 diff

## Hooks

### [attention-hook](plugins/attention-hook/hooks/hooks.json)

**설치**:
```bash
claude plugin marketplace add https://github.com/corca-ai/claude-plugins.git
claude plugin install attention-hook@corca-plugins
```

**갱신**:
```bash
claude plugin marketplace update corca-plugins
claude plugin update attention-hook@corca-plugins
```

Claude Code가 사용자의 입력을 기다릴 때 Slack으로 푸시 알림을 보내는 훅입니다. 알림에 이미지를 제외한 작업 컨텍스트(사용자 요청, Claude 응답, AskUserQuestion을 통한 질문 내용, Todo 상태)가 포함되어 어떤 작업인지 즉시 파악할 수 있습니다. 원격 서버에 세팅해뒀을 때 유용합니다. ([작업 배경 블로그 글](https://www.stdy.blog/1p1w-03-attention-hook/))


**알림 트리거 조건**:
- `idle_prompt`: 사용자 입력을 60초 이상 기다릴 때 (Claude Code 내부 구현, 변경 불가)
- `AskUserQuestion`: Claude가 질문을 하고 30초 이상 응답이 없을 때 (`CLAUDE_ATTENTION_DELAY` 환경변수로 조정 가능)

> **호환성 주의**: 이 스크립트는 Claude Code의 내부 transcript 구조를 `jq`로 파싱합니다. Claude Code 버전이 업데이트되면 동작하지 않을 수 있습니다. 테스트된 버전 정보는 스크립트 주석을 참조하세요.

**필수 조건**:
- `jq` 설치 필요 (JSON 파싱용)
- Slack 봇 설정 후 알림 받을 채널에 대한 Webhook URL 준비

**설정 방법**:

1. `~/.claude/.env` 파일 생성 후 웹훅 URL 설정:
```bash
# ~/.claude/.env
SLACK_WEBHOOK_URL=""
CLAUDE_ATTENTION_DELAY=30  # AskUserQuestion 알림 지연 시간 (초, 기본값: 30)
```

2. 플러그인 설치 후 `hooks/hooks.json`이 자동으로 적용됩니다.

**알림 내용**:
- 📝 사용자 요청 내용 (처음/끝 5줄씩 truncate)
- 🤖 요청에 대한 Claude의 응답 (처음/끝 5줄씩 truncate)
- ❓ 질문 대기 중: AskUserQuestion의 질문과 선택지 (있을 경우)
- ✅ Todo: 완료/진행중/대기 항목 수 및 각 항목 내용

**알림 예시**:

<img src="assets/attention-hook-normal-response.png" alt="Slack 알림 예시 1 - 일반적인 응답" width="600">

<img src="assets/attention-hook-AskUserQuestion.png" alt="Slack 알림 예시 2 - AskUserQuestion" width="600">

## 라이선스

MIT
