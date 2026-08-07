# Hyventur Python ECS Demo

Python 3.14 Flask app running on ECS Fargate that renders an image from S3. Same container image is reused across environments — everything environment-specific is injected at deploy time.

## Architecture

```
GitHub (push to main)
   -> GitHub Actions (assumes AWS role via OIDC, no static keys)
   -> build/push image to ECR
   -> force new ECS deployment

ECS Fargate task
   -> execution role: pulls image from ECR, ships logs to CloudWatch
   -> task role: reads Secrets Manager secret (KMS-encrypted),
                 generates a presigned S3 URL for the demo image
   -> Flask app serves the page with that presigned URL
```

- **Runtime variables** (`AWS_REGION`, `ENVIRONMENT`, `SECRET_NAME`) are set on the ECS task definition, not baked into the image — the same image works for dev/staging/prod by pointing `SECRET_NAME` at a different secret.
- **Credentials**: the app never holds an AWS access key. It assumes the ECS task IAM role (via the container credentials endpoint) to call Secrets Manager and S3. The secret itself (`hyventur/app-config`: `APP_NAME`, `S3_BUCKET`, `IMAGE_NAME`) is encrypted at rest with a dedicated KMS CMK (`alias/hyventur-demo`).
- **S3 access**: the bucket (`hyventur-demo-images`) blocks all public access. The app generates a short-lived (5 min) presigned URL via `boto3` rather than relying on a public bucket policy.

## Repo layout

```
app.py, config.py, templates/, static/   Flask app
Dockerfile, .dockerignore                python:3.14-slim + gunicorn
requirements.txt                         Flask, boto3, gunicorn
infra/                                   Terraform: ECR, ECS, IAM, KMS, Secrets Manager, GitHub OIDC
.github/workflows/deploy.yml             CI/CD: build -> push to ECR -> deploy to ECS
```

## Deployed POC (us-east-2, account 833179915312)

| Resource | Name |
|---|---|
| ECR repo | `hyventur-demo` |
| ECS cluster / service | `hyventur-demo-cluster` / `hyventur-demo` |
| Secrets Manager secret | `hyventur/app-config` |
| KMS key alias | `alias/hyventur-demo` |
| S3 bucket | `hyventur-demo-images` (existing, referenced not managed by Terraform) |

The service runs one Fargate task with a public IP on port 5000 (no ALB — POC only). Find the current IP with:

```bash
TASK=$(aws ecs list-tasks --cluster hyventur-demo-cluster --region us-east-2 --query 'taskArns[0]' --output text)
ENI=$(aws ecs describe-tasks --cluster hyventur-demo-cluster --tasks $TASK --region us-east-2 \
  --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text)
aws ec2 describe-network-interfaces --network-interface-ids $ENI --region us-east-2 \
  --query 'NetworkInterfaces[0].Association.PublicIp' --output text
```

## Deploying infra changes

```bash
cd infra
terraform init
terraform plan
terraform apply
```

State is local (`infra/terraform.tfstate`, gitignored) — fine for a single-operator POC; move to a remote backend (e.g. S3 + DynamoDB lock) before more than one person touches this.

## CI/CD

Pushing to `main` (excluding `infra/**`) builds the image, pushes `latest` and a git-sha tag to ECR, then forces a new ECS deployment. The workflow assumes `hyventur-demo-github-actions-deploy` via GitHub's OIDC provider — no AWS keys are stored as GitHub secrets.

## Local development

```bash
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
export AWS_REGION=us-east-2 ENVIRONMENT=local SECRET_NAME=hyventur/app-config
# requires AWS credentials with secretsmanager:GetSecretValue + kms:Decrypt + s3:GetObject
python app.py
```


