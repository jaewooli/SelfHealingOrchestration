Terraform folder infrastructure.

terraform/
├── provider.tf
├── variables.tf
├── locals.tf
├── data.tf
├── outputs.tf
│
├── network_vpc1.tf
├── network_vpc2.tf
├── s3.tf
├── iam.tf
├── alb_ec2_vpc1.tf
├── waf.tf
├── detect.tf
├── ecs_vpc2.tf
├── ssm.tf
├── lambda.tf
├── eventbridge.tf
├── stepfunctions.tf
├── secrets.tf
│
└── lambda_src/
    ├── ingest_finding.py
    └── notify_slack.py
