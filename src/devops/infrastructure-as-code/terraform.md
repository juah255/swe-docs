# Terraform

Terraform is an infrastructure provisioning tool that uses HCL to define and
manage cloud resources declaratively.

## Providers and Resources

Providers connect Terraform to cloud platforms. Resources define infrastructure.

```hcl
provider "aws" { region = "us-east-1" }

resource "aws_s3_bucket" "data" {
  bucket = "my-app-data-bucket"
  tags   = { Environment = "production" }
}
```

## Variables, Locals, and Outputs

```hcl
variable "environment" { type = string }
locals { prefix = "${var.environment}-app" }
output "bucket_id" { value = aws_s3_bucket.data.id }
```

## State and Remote Backends

State maps configuration to real resources. Remote backends store state
centrally with locking and encryption.

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

## Modules and Data Sources

Modules package reusable configuration. Data sources query existing
infrastructure for reference.

```hcl
module "vpc" {
  source = "./modules/vpc"
  cidr   = "10.0.0.0/16"
  env    = var.environment
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
}
```

## Plans, Applies, Importing, and Drift

`terraform plan` previews changes. `terraform apply` executes them.
`terraform import` brings existing resources under management. Run plan
periodically to detect drift.

```bash
terraform plan -out=tfplan && terraform apply tfplan
terraform import aws_s3_bucket.legacy legacy-bucket-name
terraform plan -detailed-exitcode
```

## Practical Examples

### S3 Bucket

```hcl
resource "aws_s3_bucket" "logs" { bucket = "${local.prefix}-logs" }
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration { status = "Enabled" }
}
```

### EC2 Instance

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = module.vpc.public_subnet_id
  tags          = { Name = "${local.prefix}-web" }
}
```

### VPC

```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}
```

## Interview Questions and Answers

### 1. Why must Terraform state be protected and locked?

State maps configuration to real resources and may contain sensitive outputs.
If state is lost or exposed, infrastructure changes become risky and secrets
may leak. Locking prevents concurrent applies on the same infrastructure.
Remote state with encryption, access control, backups, and locking is
standard for production.

### 2. What is the difference between `terraform plan` and `terraform apply`?

`terraform plan` computes what resources will be created, modified, or
destroyed without making changes. `terraform apply` executes that plan. Always
use `-out` to capture the plan and apply that exact plan to avoid drift
between plan and apply.

### 3. How do you manage Terraform across multiple environments?

Use directory structures or Terragrunt to separate state files per
environment. Parameterize shared modules with variables so the same
configuration produces different infrastructure for dev, staging, and
production. Keep state in separate remote backends or prefixes to prevent
cross-environment interference.
