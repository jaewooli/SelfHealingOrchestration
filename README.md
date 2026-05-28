# 🛡️ AWS Self-Healing Orchestration Architecture

[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=flat-square&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/terraform-%235C4EE5.svg?style=flat-square&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=flat-square)](https://opensource.org/licenses/Apache-2.0)

An event-driven, production-grade automated security remediation and self-healing infrastructure managed via Terraform. This project orchestrates AWS native security services, asynchronous Lambda functions, and LLM-powered reasoning to detect, analyze, and remediate cloud security threats with human-in-the-loop validation.

---

## 🏗️ Architecture Overview

The system leverages an event-driven design to ensure robust, scalable, and resilient threat response:

```text
[ Threat Detection ]       [ Intelligent Orchestration ]       [ Remediate & Notify ]
 ┌───────────────┐          ┌─────────────────────────┐          ┌─────────────────┐
 │ AWS GuardDuty │ ───────> │    AWS Step Functions   │ ───────> │  SSM Automation │
 └───────────────┘          │                         │          └─────────────────┘
 ┌───────────────┐          │  ┌───────────────────┐  │          ┌─────────────────┐
 │  Security Hub │ ───────> │  │  Amazon Bedrock   │  │ ───────> │    AWS WAFv2    │
 └───────────────┘          │  │ (Threat Analysis) │  │          └─────────────────┘
                            │  └───────────────────┘  │                  │
                            │  ┌───────────────────┐  │                  v
                            │  │  Slack Approval   │  │ <─────── [ Slack Channel ]
                            │  │   (Task Token)    │  │        (Human-in-the-Loop)
                            │  └───────────────────┘  │
                            └─────────────────────────┘
```

1. Detection & Ingestion: Security findings from AWS GuardDuty and AWS Security Hub trigger EventBridge rules.

2. Analysis & Decision: AWS Step Functions orchestrates the workflow. An asynchronous AWS Lambda invokes Amazon Bedrock to perform contextual threat analysis and determine the appropriate remediation playbook.

3. Human-in-the-Loop (HITL): For critical actions, the state machine pauses using AWS Task Tokens and dispatches an interactive approval message to a dedicated Slack channel.

4. Execution & Self-Healing: Upon approval, AWS Systems Manager (SSM) Automation or Lambda enforces infrastructure changes (e.g., isolating an EC2 instance, updating AWS WAFv2 ACLs) to restore the environment to a secure state.

## ✨ Key Features
- LLM-Powered Remediation: Contextual, intelligent decision-making leveraging Amazon Bedrock rather than static hardcoded rules.

- Asynchronous Callback Pattern: Securely halts execution for manual approvals via Slack, handling potential timeout scenarios gracefully.

- Infrastructure as Code: Fully modularized and packaged using Terraform for seamless multi-account deployment.

- Failure Resilience: Built-in error handling, retries, and dead-letter queues (DLQ) managed within Step Functions to handle high-concurrency API throttles.

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
