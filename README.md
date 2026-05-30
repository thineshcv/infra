# Infrastructure

Infrastructure as Code for AWS, Kubernetes, and Azure environments. Managed with [OpenTofu](https://opentofu.org/), [Terragrunt](https://terragrunt.gruntwork.io/), and automated quality tooling.

See [`aws-tf/README.md`](aws-tf/README.md) for detailed AWS architecture, modules, and deployment guides.

## Quick Start

### Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| [OpenTofu](https://opentofu.org/) | >= 1.6 | Infrastructure provisioning |
| [Terragrunt](https://terragrunt.gruntwork.io/) | >= 0.50 | Configuration orchestration |
| [tflint](https://github.com/terraform-linters/tflint) | >= 0.50 | Terraform linting |
| [trivy](https://github.com/aquasecurity/trivy) | >= 0.50 | Security scanning |
| [pre-commit](https://pre-commit.com/) | >= 3.0 | Git hook management |
| AWS CLI | >= 2.0 | AWS authentication |

### Setup

```bash
# Clone the repo
git clone <repo-url> && cd infra

# Install pre-commit hooks and tflint plugins
make init

# Configure AWS credentials
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
```

### Deploy

```bash
# Deploy a single stack
cd aws-tf/live/vpc
terragrunt apply

# Deploy everything (respects dependency order)
cd aws-tf/live
terragrunt run-all apply

# Destroy everything
cd aws-tf/live
terragrunt run-all destroy
```

## Development Workflow

### Make Targets

```bash
make help             # Show all available targets
```

| Target | Description |
|--------|-------------|
| `make init` | Install pre-commit hooks and tflint plugins |
| `make fmt` | Format all `.tf` and `.hcl` files |
| `make fmt-check` | Check formatting without modifying (for CI) |
| `make lint` | Run tflint on all modules |
| `make validate` | Run `tofu validate` on all modules |
| `make security` | Run Trivy security scan |
| `make fix` | Format + lint |
| `make check` | All checks without modifications (CI mode) |
| `make all` | Format + lint + validate + security |
| `make pre-commit` | Run pre-commit on staged files |
| `make pre-commit-all` | Run pre-commit on all files |
| `make clean` | Remove `.terragrunt-cache` and `.terraform` directories |
