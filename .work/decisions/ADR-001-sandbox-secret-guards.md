# ADR-001: Sandbox & Secret Guards (pre-commit hardening)

- **상태**: accepted
- **날짜**: 2026-04-08
- **세션**: S1
- **관련 태스크**: —

## 맥락

이 템플릿의 기본 pre-commit hook은 **파일 내용**(하드코딩 키 regex, 위험 SQL,
docstring 등)만 검사한다. 두 가지 실제 사고 패턴을 막지 못한다:

### 사고 1 — 에이전트 sandbox 가 repo 를 통째로 복제 + 자동 커밋

Cursor의 Codex 통합 익스텐션은 "AI에게 격리된 사본을 주자"는 선의로 repo 전체를
`/Users/<user>/<repo>-<nanoid>/` 같은 임시 디렉토리로 복제한 뒤 그 안에서 자동
커밋을 수행한다. 사고 당시:

- 원래 repo 경로(`/Users/.../sovereign-ai-system`)가 사라지고 sandbox 경로로 치환
- "Initial workspace sync" 자동 커밋 1건이 생성됨 (356 files, +98,815 lines)
- 그 커밋 안에 `env.sh`(DeepSeek/Telegram/Notion API 키 전부),
  `.openclaw/client_secret_*.json`, 그리고 **다른 프로젝트의 tree 전체**가 같이 섞여 들어감
- push 직전에 발견 → 다행히 GitHub 으로의 leak 은 없었음
- 절대경로 의존(launchd plist, runtime state 디렉토리)이 모두 깨짐

### 사고 2 — `.gitignore` 만으로는 부족

`.gitignore` 는 자동화된 sandbox/IDE 가 우회할 수 있다. 시크릿 파일 이름은
**파일이 스테이지에 올라오는 단계에서** 한 번 더 막아야 한다.

## 결정

`.claude/hooks/pre-commit.sh` 맨 앞에 fail-fast 가드 두 개를 추가한다.

### 1. Canonical path guard

`.project-config` 에 `PROJECT_CANONICAL_PATH=/abs/path/to/repo` 가 설정돼 있고
현재 `git rev-parse --show-toplevel` 가 그 경로와 다르면 커밋을 거부한다.

- sandbox/nanoid 디렉토리에서 도는 자동 커밋을 잡는다
- escape hatch: `ALLOW_FOREIGN_PATH=1 git commit ...`
- `.project-config` 에 키가 없으면 가드는 비활성 (opt-in)

### 2. Secret filename blocklist

스테이지에 올라온 파일 **이름** 을 정규식 셋으로 검사한다:

- `env.sh`, `.env*`
- `*.key`, `*.pem`, `id_rsa`/`id_ed25519`/`id_ecdsa`
- `*client_secret*.json`, `*credentials*.json`
- `.openclaw/`, `.clawhub/`, `secrets/` 하위 전체

매치가 하나라도 있으면 커밋 거부.
- escape hatch: `ALLOW_SECRET=1 git commit ...`

### 3. `.cursorignore` / `.codexignore` (`*` fence)

repo 루트에 두 파일을 넣어 Cursor/Codex 가 인덱싱·sandbox 복제 대상에서 repo
전체를 제외하도록 명시한다.

## 근거

- **Defense in depth**: `.gitignore` (1차) → `.cursorignore`/`.codexignore` (2차,
  툴 레벨) → pre-commit blocklist (3차, git 레벨) → canonical-path guard (4차,
  "여기가 진짜 repo 인가?" 메타 검사). 어떤 단계가 우회돼도 다음 단계가 막는다.
- **Fail-fast**: 새 가드는 hook 의 가장 앞단(섹션 0)에서 돈다. 그 뒤의 lint/타입
  검사 결과를 기다리지 않고 즉시 거부한다.
- **Opt-in canonical-path**: 모든 사용자가 `PROJECT_CANONICAL_PATH` 를 쓰지는
  않으므로 키가 없으면 가드는 침묵한다. 키를 명시한 사람만 보호받는다.
- **Escape hatch 명시**: 둘 다 환경변수 한 줄로 우회 가능하다. 강제력이 아니라
  실수 방지 장치이며, 의도된 운영 작업을 막지 않는다.

### 대안 비교

- **`.gitignore` 보강만**: 사고 1을 못 막는다. 자동화 툴이 `.gitignore` 를
  존중한다는 보장이 없다.
- **GitHub push protection 의존**: leak 후 알림. 본 ADR 의 목적은 leak **이전**
  단계에서 차단.
- **husky / lefthook 같은 별도 hook 매니저**: 이 템플릿은 lean 철학상 외부 의존
  추가를 피한다. 순수 bash 한 파일 유지.

## 결과

### 긍정

- Cursor/Codex sandbox 자동 커밋 시나리오가 자동 차단된다 (canonical-path guard)
- 시크릿 파일이 스테이지에 올라오는 순간 거부된다
- 두 가드 모두 `.gitignore` 와 무관하게 작동 → 우회 곤란

### 비용

- pre-commit 시간이 수 ms 늘어난다 (무시 가능)
- 의도적으로 sandbox/시크릿을 다뤄야 할 때 환경변수 한 줄을 더 쳐야 한다
- `PROJECT_CANONICAL_PATH` 는 사용자가 직접 채워야 함 (`/init` 에서 자동 채우기는
  후속 개선)

### 후속

- `/init` 슬래시 명령에서 `PROJECT_CANONICAL_PATH` 를 자동으로 `pwd` 로 채우기
- pre-commit 외에 PreToolUse hook 으로 `git commit --no-verify` 자체를 차단하는
  옵션도 검토 (현재는 settings.json deny list 에서만)
