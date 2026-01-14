# 새 플러그인 추가 시

플러그인 구조, `plugin.json` 스키마, `marketplace.json` 스키마 등은 [claude-marketplace.md](claude-marketplace.md)를 참조하라.

새 플러그인 추가 후 [marketplace.json](../.claude-plugin/marketplace.json)에서 적절하게 버전을 업데이트하라.

## 스크립트 작성 원칙

### 크로스 플랫폼 호환

macOS와 Linux 모두에서 동작해야 한다:

```bash
# Bad: macOS only
sed -i '' 's/foo/bar/' file.txt

# Good: cross-platform
sed 's/foo/bar/' file.txt > file.tmp && mv file.tmp file.txt
# or
grep -v 'pattern' file.txt > file.tmp && mv file.tmp file.txt
```

### 최소한의 의존성

가능하면 bash, curl 등 기본 도구만으로 해결. 외부 의존성(python3 등)을 최소화하는 방향으로 구현할 것.

## AI_NATIVE_PRODUCT_TEAM.md 링크 검토

새로운 플러그인을 추가할 때는 `AI_NATIVE_PRODUCT_TEAM.md`에 해당 플러그인 링크를 추가할 수 있는지 검토해야 한다.

이 문서는 AI 네이티브 팀의 워크플로우를 설명하며, 관련 도구들을 예시로 링크하고 있다:
- 자료 조사 도구 (예: slack-to-md)
- 스펙 정교화 도구 (예: Clarify)
- 코드 품질 도구 (예: suggest-tidyings)

새 플러그인이 위 카테고리에 해당하거나 문서의 다른 맥락에서 좋은 예시가 될 수 있다면 링크를 추가하라.
