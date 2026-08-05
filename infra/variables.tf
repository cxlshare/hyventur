variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-2"
}

variable "app_name" {
  description = "Base name used for the ECR repo, ECS cluster/service/task family, and log group"
  type        = string
  default     = "hyventur-demo"
}

variable "environment" {
  description = "Runtime variable injected into the task definition; identifies which environment this deployment of the shared image represents"
  type        = string
  default     = "poc"
}

variable "s3_bucket_name" {
  description = "Existing S3 bucket the app reads its demo image from"
  type        = string
  default     = "hyventur-demo-images"
}

variable "image_name" {
  description = "Object key of the demo image inside the S3 bucket"
  type        = string
  default     = "sample.jpg"
}

variable "container_port" {
  description = "Port the Flask app listens on inside the container"
  type        = number
  default     = 5000
}

variable "github_repo" {
  description = "GitHub repo (org/name) allowed to assume the CI deploy role via OIDC"
  type        = string
  default     = "cxlshare/hyventur"
}

variable "github_branch" {
  description = "Branch allowed to assume the CI deploy role via OIDC"
  type        = string
  default     = "main"
}
