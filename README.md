Django Application

# Installation

## 1. Clone the repository

```sh
git clone https://github.com/zharuk-alex/microservice-project.git
git checkout lesson-7
```

## 2. Initialize Terraform and deploy infrastructure

```sh
terraform init
terraform apply
```

### (Optional) Connect to S3 backend for state storage:

1. Uncomment the block in `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-goit"
    key            = "goit/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

2. Reinitialize terraform:

```sh
terraform init -reconfigure
terraform plan
terraform apply
```

3. Check the state of all resources:

```sh
terraform state list
```

---

## 3. Connect to the Kubernetes cluster

```sh
aws eks --region <your-region> update-kubeconfig --name <cluster-name>
kubectl get nodes
kubectl get pods
```

---

## 4. Build and push Docker image to ECR

```sh
docker buildx build --platform linux/amd64 --no-cache -t django-app:latest .

docker tag django-app:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/goit-ecr:latest

aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com

docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/goit-ecr:latest
```

---

## 5. Deploy Django application to Kubernetes via Helm

```sh
cd charts/django-app
helm upgrade --install my-django-release .
```

---

## 6. Access the application

1. Find out the external DNS name (External IP/Hostname):

```sh
kubectl get svc my-django-release-django
```

2. Open in your browser:
   ```
   http://<EXTERNAL-IP>:8000
   ```
   or for AWS LoadBalancer:
   ```
   http://<EXTERNAL-HOSTNAME>:8000
   ```

---

## 7. Delete resources

```sh
terraform destroy
```

---

#### modules:

- **s3-backend:** creates an S3 bucket for tfstate and DynamoDB for state locking.
- **vpc:** builds a VPC with subnets, gateway, and routing.
- **ecr:** creates a repository for Docker images and enables image scanning.
- **eks:** creates a Kubernetes cluster (EKS) and associated roles/authorization.
