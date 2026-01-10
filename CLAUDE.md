## Hooks 수정 시 주의사항

`plugins/attention-hook/hooks/scripts/` 디렉토리의 스크립트(예: `attention.sh`)를 수정할 때:

1. **이 repo의 파일**: `plugins/attention-hook/hooks/scripts/attention.sh`

Marketplace를 통해 설치한 경우 repo 파일만 수정하면 된다.

또한 동작 수정은 언제나 테스트되어야 한다. 테스트(`plugins/attention-hook/hooks/scripts/attention.test.sh`)를 업데이트할 여지가 있는지도 꼭 살펴라.

## 문서 업데이트 필수

코드를 수정할 때는 **반드시 README.md를 읽고** 관련 내용이 있는지 확인해야 한다.

**작업 순서**:
1. `README.md` 읽기 ← 이 단계를 건너뛰지 말 것
2. 코드 수정
3. 수정한 코드와 관련된 문서 내용이 있으면 함께 갱신

문서를 읽지 않고 작업을 완료했다고 하면 안 된다.