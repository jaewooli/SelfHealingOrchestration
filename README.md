# 🛡️ AWS Self-Healing Orchestration Architecture (Project Antifragile)

[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=flat-square&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/terraform-%235C4EE5.svg?style=flat-square&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=flat-square)](https://opensource.org/licenses/Apache-2.0)

An event-driven, End-to-End automated security remediation and self-healing infrastructure managed via Terraform. Developed by **Team Antifragile** (Jimin Jeong, Eunbi Kim, Taeseok Yang, Jaewoo Lee), this architecture mitigates cloud security threats by focusing on converging post-attack anomalous behaviors (C2 communication, malware execution, resource abuse) rather than handling fragmented attack vectors individually.

Conceptually aligned with **CIS Controls v8.1**, it satisfies most Safeguards under the **Respond** category and key parameters of the **Recover** category, striking an optimal balance between operational flexibility and infrastructure resilience.

---

## 🏗️ Architecture Overview

The pipeline automates the entire lifecycle of a threat: `Detection ➔ Collection ➔ Normalization ➔ AI Analysis ➔ Decision ➔ Automated Remediation ➔ Logging & Monitoring`.

```text
[ Threat Detection & Aggregation ]          [ Intelligent Orchestration ]                [ Remediate & Monitor ]
 ┌──────────────────────────────┐            ┌─────────────────────────┐                  ┌────────────────────┐
 │ AWS GuardDuty / Amazon Macie │ ────────>  │    AWS Step Functions   │ ──────────────>  │ AWS Systems Manager│
 │ Amazon Inspector / AWS WAF   │            │                         │                  │   (SSM Automation) │
 └──────────────────────────────┘            │  ┌───────────────────┐  │                  └────────────────────┘
                 │                           │  │  Amazon Bedrock   │  │                            │
                 v                           │  │(Claude 3.5 Sonnet)│  │                            v
 ┌──────────────────────────────┐            │  └───────────────────┘  │                  ┌────────────────────┐
 │       AWS Security Hub       │            │  ┌───────────────────┐  │                  │   Amazon Managed   │
 └──────────────────────────────┘            │  │  Slack Approval   │  │                  │      Grafana       │
                 │                           │  │   (Task Token)    │  │                  └────────────────────┘
                 v                           │  └───────────────────┘  │                            ▲
 ┌──────────────────────────────┐            └─────────────────────────┘                            │
 │      Amazon EventBridge      │                         │                                         │
 └──────────────────────────────┘                         v                                  [ S3 Loki Pipeline ]
                 │                             [ Slack Notifications ]                       ┌────────────────────┐
                 v                              - Threat Summary & Risk                      │  S3 (raw / norm)   │
 ┌──────────────────────────────┐               - Interactive Playbook Actions               │  ➔ Lambda ➔ Loki   │
 │          AWS Lambda          │ ─────────────────────────────────────────────────────────> └────────────────────┘
 └──────────────────────────────┘
```

1. Ingestion & Filtering: AWS native security tools route standard ASFF (AWS Security Finding Format) logs into AWS Security Hub. An Amazon EventBridge rule triggers an ingestion Lambda function.

2. De-duplication & Normalization: Lambda filters duplicate findings and isolates EC2/S3 specific contexts (Prefixes: Backdoor:EC2, Trojan:EC2, CryptoCurrency:EC2, SensitiveData:S3). The logs are archived into Amazon S3 partitions (raw-findings/ and normalized-event/).

3. Orchestration Workflow: High/Critical severity events initiate an AWS Step Functions state machine (uniquely identified via UUID tokens).

4. LLM Reasoning (Analyze & Plan): Amazon Bedrock (Claude 3.5 Sonnet) generates a 1st-stage context breakdown (Summary, Risk Assessment, Blast Radius Impact Score) and a 2nd-stage execution blueprint (Up to 5 actionable steps structured in strict JSON format).

5. Human-in-the-Loop Validation: Step Functions halts execution via the waitForTaskToken pattern, dispatching an interactive approval card to Slack. Administrators can multi-select playbooks or reject actions. Security is guaranteed via a Lambda Function URL Secured with Slack SDK Signing Secret Verification.

6. Self-Healing Enforcement: Upon administrator consent, AWS Systems Manager (SSM) executes underlying host and network operations, writing final execution states (SUCCESS, PARTIAL SUCCESS, FAIL) back to S3.

---

## ✨ Key Features

- Behavior-Centric Defense: Bypasses static rule constraints by focusing on universal post-exploitation anomalies (e.g., rogue outbound C2 traffic).

- Dual-Stage Bedrock Pipeline:

-    - Analyze Mode: Quantifies impact metrics and cross-references finding context against internal organizational Security Rule Books.

-    - Plan Mode: Generates dynamically structured JSON step-arrays mapping directly to backend automation scripts.

- Fail-Safe Orchestration: Implements an automated timeout-escalation loop. If an operator fails to approve a Slack notification within 5 minutes, recurring reminders trigger. Step Functions natively leverages Catch blocks to capture component failures, converting execution errors into gracefully packaged Partial Success states for forensic review.

- Comprehensive State Diffing: Tracks configuration baselines before and after remediation to visually measure infrastructure mutations.

---

## 🛠️ Automated Remediation Playbooks

Executed conditionally through AWS Systems Manager (SSM) using isolated temporary IAM profiles:

| Playbook Action | Technical Remediation Mechanism |
| :--- | :--- |
| **`ISOLATE_INSTANCE`** | Detaches current network descriptors, creates a backup AMI, and provisions instance within an isolated forensic VPC. |
| **`SNAPSHOT_INSTANCE`** | Triggers host-level volatile memory acquisition utilities (`LiME` for Linux / `WinPmem` for Windows) and ships dumps to S3. |
| **`REVOKE_IAM_ROLE`** | Instantly detaches compromised IAM Instance Profiles and invalidates temporary STS tokens. |
| **`BLOCK_IP`** | Hard-redefines EC2 Security Groups, ripping out active inbound/outbound rules (e.g., dropping `0.0.0.0/0` vectors). |

---

## 📊 Observability & Monitoring Dashboard

Logs inside S3 undergo real-time transformation through an automated ETL flow: **`S3 ➔ Lambda ➔ Loki ➔ Grafana`**. The Grafana dashboard visualizes operations across 4 core panels:

- **Panel 1 (KPI Metrics Summary):** Aggregates Total Security Events, Active HIGH-Risk Events, Automated Execution Count, SSM Success Rate, and Target Distribution Charts (Findings by Product/Type).
- **Panel 2 (End-to-End Timeline Flows):** Tracks timestamped transitions mapping exactly when a finding moved from Detection ➔ Action ➔ Result.
- **Panel 3 (Before / Action / After Structural Diff):** Compares topological mutations of resources side-by-side to verify if automated playbooks effectively contained the threat.
- **Panel 4 (Remediation Execution Summaries):** Details execution output metadata and historical Diff Trends.

---

## 🚀 Simulation & Empirical Validation

System capability was rigorously evaluated utilizing the `amazon-guardduty-tester`. Over a continuous **10-minute automated window**, the architecture simulated **32 distinct attack scenarios**, processing a total of **702 incoming security events**.

### Performance Metrics Comparison

| Benchmark Metric | Legacy Manual Operations | Antifragile Orchestration | Improvement Rate |
| :--- | :--- | :--- | :--- |
| **Actionable Findings Handled** | 35 events | **15 events** | **~57% Reduction** (Fatigue Mitigation) |
| **Mean Time to Remediate (MTTR)**| 15+ Minutes / event | **< 10 Minutes** | **> 150% Velocity Increase** |
| **Pipeline Reliability Rate** | Host Dependent | **100% Success** | 57 HIGH-Risk Events safely contained |

*AI-assisted context parsing reduced operator cognitive load by filtering low-level ambient telemetry down to 15 actionable, high-signal alerts.*

---

## 📁 Repository Structure

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

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.
