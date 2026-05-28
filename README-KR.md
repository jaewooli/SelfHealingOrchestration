# 🛡️ AWS 자가 치유 보안 오케스트레이션 아키텍처 (Project Antifragile)

[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=flat-square&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/terraform-%235C4EE5.svg?style=flat-square&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=flat-square)](https://opensource.org/licenses/Apache-2.0)

Terraform 기반으로 관리되는 이벤트 직동형(Event-Driven) 엔드투엔드(End-to-End) 자동 보안 침해 예방 및 자가 치유(Self-Healing) 인프라 프로젝트입니다. **Antifragile 팀**(정지민, 김은비, 양태석, 이재우)이 개발한 이 아키텍처는 파편화된 공격 벡터를 개별적으로 처리하는 기존 방식에서 벗어나, 공격의 결과 단계에서 공통적으로 나타나는 이상 행위(C2 통신, 악성 코드 실행, 내부 자원 악용)를 중심으로 통합 대응 체계를 구축하는 데 초점을 맞춥니다.

본 시스템은 **CIS Controls v8.1** 개념 체계를 준수하여, **Respond(대응)** 분류의 대부분의 Safeguards를 충족하고 **Recover(복구)** 분류의 일부 Safeguards를 만족하도록 설계되어 인프라의 유연성과 복구 회복 탄력성을 동시에 확보했습니다.

---

## 🏗️ 아키텍처 개요 (Architecture Overview)

본 파이프라인은 보안 위협의 수명 주기를 `탐지 ➔ 수집 ➔ 정규화 ➔ AI 분석 ➔ 대응 결정 ➔ 자동 대응 실행 ➔ 로그 저장 및 모니터링` 단계로 자동화합니다.

```text
[ 보안 위협 탐지 및 수집 ]                  [ 지능형 오케스트레이션 ]                     [ 자동 조치 및 모니터링 ]
┌──────────────────────────────┐            ┌─────────────────────────┐                  ┌────────────────────┐
│ AWS GuardDuty / Amazon Macie │ ────────>  │    AWS Step Functions   │ ──────────────>  │ AWS Systems Manager│
│ Amazon Inspector / AWS WAF   │            │                         │                  │   (SSM Automation) │
└──────────────────────────────┘            │  ┌───────────────────┐  │                  └────────────────────┘
│                                           │  │  Amazon Bedrock   │  │                            │
v                                           │  │(Claude 3.5 Sonnet)│  │                            v
┌──────────────────────────────┐            │  └───────────────────┘  │                  ┌────────────────────┐
│       AWS Security Hub       │            │  ┌───────────────────┐  │                  │   Amazon Managed   │
└──────────────────────────────┘            │  │  Slack 승인 프로세스| │                  │      Grafana       │
│                                           │  │   (Task Token)    │  │                  └────────────────────┘
v                                           │  └───────────────────┘  │                            ▲
┌──────────────────────────────┐            └─────────────────────────┘                            │
│      Amazon EventBridge      │                         │                                         │
└──────────────────────────────┘                         v                                  [ S3 Loki 파이프라인 ]
│                                             [ Slack 알림 및 관리자 개입 ]                   ┌────────────────────┐
v                                              - 위협 요약 및 위험도 평가                     │  S3 (raw / norm)   │
┌──────────────────────────────┐               - 인터랙티브 대응 가이드라인                   │  ➔ Lambda ➔ Loki   │
│          AWS Lambda          │ ─────────────────────────────────────────────────────────> └────────────────────┘
└──────────────────────────────┘
```

1. **탐지 및 수집:** AWS 기본 보안 서비스에서 발견한 위협 로그가 표준 ASFF(AWS Security Finding Format) 형태로 **AWS Security Hub**에 집계되며, 등록 즉시 **Amazon EventBridge** 규칙이 인프라 내 전처리 Lambda를 트리거합니다.
2. **필터링 및 정규화:** Lambda 함수는 중복 이벤트를 필터링하고 EC2/S3 특정 콘텍스트(`Backdoor:EC2`, `Trojan:EC2`, `CryptoCurrency:EC2`, `SensitiveData:S3` 등)를 추출합니다. 정규화된 최소 데이터는 감사 및 시나리오 테스트를 위해 Amazon S3(`raw-findings/`, `normalized-event/`)에 격리 저장됩니다.
3. **워크플로 오케스트레이션:** 정규화된 위협 심각도가 HIGH 또는 CRITICAL인 경우, 중복 실행 방지를 위한 UUID 식별자가 포함된 **AWS Step Functions** 상태 머신이 시작됩니다.
4. **LLM 기반 AI 분석:** **Amazon Bedrock(Claude 3.5 Sonnet)** 모델을 활용하여 1차 분석(이벤트 요약, 위험도 및 영향도 점수 산정, 대응 후보 생성)과 2차 분석(선택한 대응 조치에 대한 최대 5단계의 실행 구조 가이드라인 수립)을 엄격한 JSON 형식으로 수행합니다.
5. **관리자 개입 및 검열 방지 (HITL):** Step Functions는 `waitForTaskToken` 기능을 이용해 일시 중단되며, 분석된 최종 위협 정보 카드를 **Slack** 채널로 전송합니다. 관리자는 직접 실시간으로 대응 방향을 다중 선택하거나 반려할 수 있습니다. 이 엔드포인트는 외부 접근을 제어하기 위해 **Slack SDK Signing Secret 검증 메커니즘을 포함한 Lambda Function URL**로 안전하게 보호됩니다.
6. **자동 대응 실행:** 관리자 승인이 완료되면 **AWS Systems Manager(SSM)**가 격리 및 포렌식을 위한 임시 IAM 프로필을 부여한 뒤 백엔드 자동 조치 로직을 실행하며, 최종 수행 상태(`SUCCESS`, `PARTIAL SUCCESS`, `FAIL`)를 S3에 기록합니다.

---

## ✨ 핵심 기능 (Key Features)

- **행위 중심의 방어 체계:** 공격 진입 경로가 다르더라도 최종 결과 단계에서 나타나는 공통적인 이상 징후(예: 의심스러운 아웃바운드 C2 통신)를 식별 및 제어하여 고도의 유연성을 제공합니다.
- **2단계 구조화된 Bedrock 파이프라인:**
  - `Analyze 모드`: 위협 심각도와 영향도를 측정하고 내부 보안 문서 및 룰북을 참고해 실질적인 위험도를 정량화합니다.
  - `Plan 모드`: 관리자가 선택한 시나리오가 백엔드 SSM 로직과 즉각 연동될 수 있도록 유기적인 실행 단계를 JSON 구조화합니다.
- **결함 감내형 오케스트레이션:** 정해진 시간(예: 5분) 내에 관리자 답변이 오지 않으면 주기적으로 리마인드 알림을 보내고, 대응 과정 중 특정 태스크가 실패하더라도 Step Functions의 `Catch` 기능을 활용해 에러 로그를 누적하면서 전체 흐름이 중단되지 않도록 보호합니다(최종 `Partial Success` 상태로 전환 및 보고).
- **실시간 구조 변화 추적(Diff):** 관리자 조치 전(Before)과 조치 후(After)의 시스템 topological 구성을 비교하여 인프라의 실제 변화 여부 및 차이 정보를 직관적으로 시각화합니다.
---

## ✨ 핵심 기능 (Key Features)

- **행위 중심의 방어 체계:** 공격 진입 경로가 다르더라도 최종 결과 단계에서 나타나는 공통적인 이상 징후(예: 의심스러운 아웃바운드 C2 통신)를 식별 및 제어하여 고도의 유연성을 제공합니다.
- **2단계 구조화된 Bedrock 파이프라인:**
  - `Analyze 모드`: 위협 심각도와 영향도를 측정하고 내부 보안 문서 및 룰북을 참고해 실질적인 위험도를 정량화합니다.
  - `Plan 모드`: 관리자가 선택한 시나리오가 백엔드 SSM 로직과 즉각 연동될 수 있도록 유기적인 실행 단계를 JSON 구조화합니다.
- **결함 감내형 오케스트레이션:** 정해진 시간(예: 5분) 내에 관리자 답변이 오지 않으면 주기적으로 리마인드 알림을 보내고, 대응 과정 중 특정 태스크가 실패하더라도 Step Functions의 `Catch` 기능을 활용해 에러 로그를 누적하면서 전체 흐름이 중단되지 않도록 보호합니다(최종 `Partial Success` 상태로 전환 및 보고).
- **실시간 구조 변화 추적(Diff):** 관리자 조치 전(Before)과 조치 후(After)의 시스템 topological 구성을 비교하여 인프라의 실제 변화 여부 및 차이 정보를 직관적으로 시각화합니다.
---

## 📊 모니터링 및 시각화 대시보드 (Observability)

S3에 저장된 보안 로그는 **`S3 ➔ Lambda ➔ Loki ➔ Grafana`** 파이프라인을 거쳐 실시간 대시보드로 시각화되며, 단순히 로그를 조회하는 것을 넘어 위협의 전체 인과 흐름을 추적합니다.

- **패널 1 (핵심 숫자 요약):** 총 보안 이벤트 규모, HIGH 위험 이벤트 수, 자동 대응 실행 횟수, SSM 성공 실행율, 위협 유형 및 탐지 제품 분포 현황을 대시보드 상단에 시각적으로 요약합니다.
- **패널 2 (탐지 ➔ 조치 ➔ 결과 타임라인):** 타임스탬프 기반 단계별 시간 정보를 결합하여 보안 위협이 어떤 처리를 거쳐 종결되었는지 타임라인 형태로 흐름을 파악합니다.
- **패널 3 (Before / Action / After 구조 흐름):** 관리자 및 자동 대응 조치가 취해지기 전·후의 인프라 상태 변화와 구조 흐름을 비교하여 조치 실효성을 직관적으로 확인합니다.
- **패널 4 (구조 변화 결과 - Diff Result):** 조치 전후 시스템 상태의 구체적인 Diff 가공 데이터를 시각적으로 제공하여 실제 인프라 변경 상태를 명확히 검증합니다.

---

## 🚀 시뮬레이션 및 검증 결과 (Empirical Validation)

오픈소스 위협 시뮬레이터인 `amazon-guardduty-tester`를 도입하여 **약 10분 동안 총 32개의 공격 시나리오를 재현하고 702건의 보안 이벤트를 발생시켜** 엔드투엔드 자동화 시스템의 실효성을 검증했습니다.

### 기존 대응 방식 vs 본 아키텍처 구현 방식 비교 

| 평가 지표 항목 | 기존 수동 대응 방식  | 프로젝트 구현 솔루션 방식  | 개선율 지표  |
| :--- | :--- | :--- | :--- |
| **실질 대응 필요 이벤트 수** | 35개 (모든 이벤트를 직접 분류)  | **15개** (AI 기반 우선순위 전처리)  | **약 57% 피로도 감소**  |
| **건당 평균 처리 시간(MTTR)**| 15분 이상 (매뉴얼 수동 대조)  | **10분 미만** (원클릭 자동 실행)  | **최소 33% 이상 가속화**  |
| **파이프라인 전달 안정성** | 관리자 가용성에 의존 | **100% 정상 처리** (57건 위협 containment)  | 파이프라인 누락 원천 차단  |

*AI 모델 필터링 및 요약 대시보드 연동을 통해 관리자가 고민해야 할 실질 위협 대상을 압축(35건➔15건)하여 보안 피로도를 획기적으로 낮췄습니다.*
---

## 📁 레포지토리 구조 (Repository Structure)

```text
├── terraform/                   
│   ├── eventbridge.tf           # EventBridge
│   ├── main.tf                  # Root Terraform configuration
│   ├── step_func.tf             # Step Function configuration
│   ├── terrafrom.tfvars         # Variable for Terraform setup
│   └── variables.tf             # Global Variables
├── src/                         
│   ├── lambda/                  # Source for Lambda
│   └── sendrecv/                # Source for send and recv
├── LICENSE
└── README.md

```

## 📄 License

본 오픈소스 프로젝트는 Apache License 2.0 규칙을 따릅니다. 상세한 보장 범위는 LICENSE 파일을 참고하시기 바랍니다.
