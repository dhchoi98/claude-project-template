---
name: tdd-loop
description: Red→Green→Refactor TDD 사이클 표준 절차 (production/enterprise rigor에서 권장)
when_to_use: 새 기능을 추가하거나 버그 수정 시 (특히 핵심 모듈 core/)
---

# TDD Loop (Red → Green → Refactor)

## 핵심 원칙

> **테스트가 곧 명세서다.** 구현보다 먼저 "이 코드가 어떻게 쓰여야 하는가"를 적는다.

production/enterprise rigor에서 핵심 모듈에 적용. mvp에서는 핵심 비즈니스 로직에만 선택적으로 적용.

## 사이클

### 🔴 RED — 실패하는 테스트 먼저

1. **사용자 관점**에서 이 함수/클래스가 어떻게 호출되어야 하는지 적는다
2. 가장 단순한 1개 케이스만 (정상 입력 → 정상 출력)
3. 테스트를 실행 → **반드시 실패해야 함** (구현이 없으니까)
4. 실패 메시지가 "이 함수가 없음"인지 확인 (다른 이유로 실패하면 테스트 자체가 잘못됨)

```python
# tests/core/test_engine.py
def test_engine_processes_simple_signal():
    engine = SignalEngine()
    result = engine.process(input_data=[1, 2, 3])
    assert result.confidence > 0.5
```

→ `pytest tests/core/test_engine.py::test_engine_processes_simple_signal -x`
→ `ImportError: cannot import name 'SignalEngine'` ✅ 정상

### 🟢 GREEN — 통과하는 가장 단순한 구현

1. **테스트를 통과시키는 가장 단순한 코드만** 작성
2. "나중에 필요할 것 같은 것"은 절대 추가하지 않는다 (YAGNI)
3. 하드코딩이라도 OK — 다음 사이클에서 일반화한다
4. 테스트 다시 실행 → **통과해야 함**

```python
# core/engine.py
class SignalEngine:
    def process(self, input_data: list[int]) -> Signal:
        return Signal(confidence=0.6)  # 하드코딩, 일단 통과
```

### 🔵 REFACTOR — 통과 상태에서만 정리

1. 테스트가 통과하는 동안에만 리팩토링 (안전망 확보 상태)
2. 중복 제거, 이름 개선, 구조 정리
3. 매 변경 후 테스트 다시 실행
4. **새 기능 추가 금지** (그건 다음 RED 단계)

### 다음 사이클

다음 케이스로 넘어간다 (엣지 케이스, 에러 케이스 등). 각 사이클마다 RED → GREEN → REFACTOR 반복.

## 테스트 작성 기준

| 모듈 종류 | TDD 강제? | 커버해야 할 케이스 |
|-----------|-----------|-------------------|
| `core/` (도메인 로직) | ✅ 필수 | 정상, 엣지, 에러 |
| `adapters/` (외부 연동) | ⚠️ 권장 | 파싱 정확성, 에러 핸들링 |
| `api/` (진입점) | 선택 | 스모크 테스트 |
| `services/` (오케스트레이션) | ⚠️ 권장 | 주요 시나리오 |
| UI | ❌ 불필요 | (수동 확인) |

## 안티 패턴

- 구현부터 짜고 나중에 테스트 추가 — TDD 아님 (사실상 그냥 테스트 작성)
- RED 단계 건너뛰기 — 테스트가 실제로 실패하는지 확인 안 하면 false positive 위험
- GREEN에서 과한 일반화 — 다음 케이스가 강제하기 전에는 일반화하지 말 것
- REFACTOR 단계에서 새 기능 추가 — 사이클 깨짐
- 통과 안 되는 테스트를 주석/skip 처리 — **절대 금지**

## Contract-First와의 결합 (production/enterprise)

```
1. CC: 인터페이스 정의 (ABC/Protocol)
2. CC: 계약 테스트 작성 (RED 상태)
3. Auto/CC: 구현체 작성 (GREEN)
4. CC/Auto: 리팩토링 (REFACTOR)
```

CC가 1~2를 잡아두면 Auto가 테스트라는 정답지를 보고 구현할 수 있다.
