# Customer-managed key used to encrypt the Secrets Manager secret that holds
# the app's runtime credentials (S3 bucket, image key, app name). The task
# role is granted kms:Decrypt via IAM policy (see iam.tf) rather than by
# naming it in the key policy, which avoids a KMS<->IAM circular dependency.
resource "aws_kms_key" "app" {
  description             = "CMK for ${var.app_name} POC app secrets"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableIAMUserPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "app" {
  name          = "alias/${var.app_name}"
  target_key_id = aws_kms_key.app.key_id
}
