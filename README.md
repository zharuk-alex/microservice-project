# Installation

```
git clone https://github.com/zharuk-alex/microservice-project.git
```

Init Terraform:

```
terraform init
terraform apply
```

Uncomment `backend.tf`:

```
# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-bucket-goit"
#     key            = "lesson-5/terraform.tfstate"
#     region         = "eu-central-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }
```

Reconfigure terraform:

```
terraform init -reconfigure
```

Then:

```
terraform plan
terraform apply
```

Destroy resources:

```
terraform destroy
```

#### modules:

- s3-backend: creates an S3 bucket for storing the tfstate file and a DynamoDB table for state locking.
- vpc: builds a virtual network (VPC) with subnets, gateway, and routing.
- ecr: creates a repository for Docker container images and enables image scanning.
