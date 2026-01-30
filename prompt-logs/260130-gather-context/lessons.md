# Lessons

### 훅 발동 확인의 어려움

- **Expected**: `PreToolUse: EnterPlanMode` 훅이 발동되면 plan-and-lessons 프로토콜을 즉시 따를 것
- **Actual**: 훅 발동 여부를 확인하지 못하고, CLAUDE.md에 명시된 프로토콜도 따르지 않음
- **Takeaway**: 훅에 의존하지 말고, plan mode 진입 시 CLAUDE.md의 프로토콜 섹션을 능동적으로 확인할 것

When plan mode 진입 → `.claude/settings.json` 훅 확인 + `docs/plan-and-lessons.md` 읽기를 먼저 수행

### 목적 중심 네이밍 vs 행위 중심 네이밍

- **Expected**: url-export라는 행위 중심 이름이 적절할 것
- **Actual**: 사용자의 실제 의도는 "외부 콘텐츠를 컨텍스트로 가져오기"이며, 행위(export)보다 목적(gather context)이 더 중요
- **Takeaway**: 스킬 이름은 사용자의 의도/목적을 반영해야 함. 수단이 아닌 목적으로 이름 짓기

### 의존성 내재화 결정 (옵션 B)

- **Expected**: url-export가 g-export, slack-to-md, notion-to-md를 호출하는 라우터 구조
- **Actual**: 사용자가 의존 스킬을 각각 설치해야 하는 부담. 스코프 폭발 vs 자체 완결 trade-off 논의
- **Takeaway**: 옵션 B (스크립트 번들링 + web-search 독립 유지)가 의존성 제거와 관심사 분리의 균형점

When 통합 스킬 설계 → 스크립트 복사로 의존성 내재화하되, 트리거가 다른 스킬은 독립 유지
