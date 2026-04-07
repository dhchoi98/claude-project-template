새 프로젝트를 대화로 초기화한다. 클론 직후 한 번만 실행한다.

다음 절차를 따라 사용자와 대화하며 프로젝트를 셋업한다:

## 1. 사용자에게 질문 (한 번에 모두 묶어서)

다음을 한 메시지로 물어본다:

1. **프로젝트 이름** (예: my-trading-bot)
2. **한 줄 설명** (예: 바이낸스 BTC 자동 매매 봇)
3. **프로젝트 유형** — 다음 중 하나:
   - `general` — 뭘 만들지 모를 때 (`src/ tests/ docs/`)
   - `web` — 웹 서비스 (`backend/ frontend/ shared/ docs/ tests/`)
   - `cli` — CLI 도구 (`cmd/ internal/ docs/ tests/`)
   - `security` — CTF/보안 (`tools/ exploits/ notes/ reports/`)
   - `ml` — ML/AI (`notebooks/ data/ models/ src/ tests/`)
   - `scada` — 산업제어 (`backend/ hmi/ plc/ drivers/ docs/ tests/`)
   - `quant` — 트레이딩 (`core/ strategies/ data/ dashboard/ tests/`)
4. **엔지니어링 깊이 (rigor)** — 다음 중 하나:
   - `mvp` — 빨리 만들기 우선
   - `production` — 실제 서비스용 (Contract-First)
   - `enterprise` — 장기 유지 (Full strict + TDD)
5. **기술스택** — 알면 알려달라 (예: Python 3.12 + FastAPI + Postgres)

답을 못 받으면 합리적 기본값으로 진행: `general` + `mvp`.

## 2. 받은 답으로 다음을 수행

### 2.1 .project-config 생성

```
PROJECT_NAME=<이름>
PROJECT_TYPE=<유형>
PROJECT_RIGOR=<rigor>
```

### 2.2 디렉토리 구조 생성

유형별로 mkdir. 예를 들어 `web`이면:
```
mkdir -p backend frontend shared docs tests
```

`security/ml/scada/quant`는 추가로 도메인별 `.gitignore` 항목 append (이 init 명령 안에 인라인으로 가지고 있어라):

- **security**: `*.pcap *.cap *.dump *.raw *.bin loot/ *.msf4/ *.hashes *.pot wordlists/ *.ovpn`
- **ml**: `*.h5 *.hdf5 *.pkl *.pickle *.parquet *.feather data/raw/ data/processed/ models/checkpoints/ wandb/ mlruns/ *.onnx *.pt *.pth *.safetensors`
- **scada**: `*.db *.sqlite3 plc/configs/production/ *.lic logs/`
- **quant**: `data/cache/ data/raw/ *.csv *.parquet *.feather backtest_results/ logs/ *.db *.sqlite3`

### 2.3 PLAN.md 초기화

기존 PLAN.md가 템플릿이면 그대로 두고, 사용자에게 "Phase 1 첫 3개 태스크를 적어달라"고 한 번 물어본 뒤, 답이 있으면 PLAN.md에 채워넣는다. 답이 없으면 빈 채로 둔다.

### 2.4 README.md 초기화 (있으면)

상단의 `# 프로젝트명` 자리에 받은 이름과 설명을 채운다.

### 2.5 docs/RIGOR.md 안내

선택한 rigor 레벨의 섹션을 사용자에게 짧게 요약해서 보여준다. (전체 출력 금지 — 핵심 3~4줄)

## 3. 검증

생성 직후 다음을 확인하고 보고:

- `.project-config` 존재?
- 디렉토리 생성됨?
- `git status`로 변경사항 확인
- 생성된 디렉토리 트리 (1 depth)

## 4. 다음 단계 안내

마지막에 사용자에게 알려준다:

- "다음 세션부터 SessionStart 훅이 자동으로 PLAN/MISTAKES/Git 상태를 로드한다"
- "작업 시작 전 `.claude/skills/`의 read-first, self-verify를 한 번 읽어라"
- "Git 작업은 사용자가 명시적으로 지시할 때만 한다"

## 절대 하지 말 것

- 사용자가 답하지 않은 질문에 임의값으로 진행 후 무리한 가정 (반드시 기본값으로 진행한다고 명시)
- 한 번에 8개 질문 던지기 (5개를 한 메시지에 묶어서)
- `.git/` 안 건드림
- Git 커밋/푸시 자체를 실행하지 말 것 — 사용자가 직접
