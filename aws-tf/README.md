# AWS Infrastructure (Terraform + Terragrunt)

AWS infrastructure managed with [OpenTofu](https://opentofu.org/) modules and [Terragrunt](https://terragrunt.gruntwork.io/) live configurations.

## Architecture

```mermaid
graph TD
    CF["CloudFront CDN"]:::accent0 --> S3["S3 Bucket<br/>Static Frontend"]:::accent1
    CF -->|/api/*| ALB:::accent2
    Internet:::accent3 --> CF
    Internet --> ALB["Application Load Balancer"]:::accent2
    ALB --> TG["Target Group<br/>IP mode"]:::accent4
    TG --> ECS1["ECS Fargate Task"]:::accent5
    TG --> ECS2["ECS Fargate Task"]:::accent5
    ECS1 --> PrivSub["Private Subnets<br/>3 AZs"]:::accent6
    ECS2 --> PrivSub
    ALB --> PubSub["Public Subnets<br/>3 AZs"]:::accent7
    PrivSub --> NAT["NAT Gateway"]:::accent7
    NAT --> IGW["Internet Gateway"]:::accent3
    PubSub --> IGW
    ACM["ACM Certificate"]:::accent0 -.->|when enabled| ALB

    subgraph VPC
        PubSub
        PrivSub
        NAT
        IGW
    end
```
