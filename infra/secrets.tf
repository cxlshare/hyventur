# Holds the app's non-code config. The container never receives these as
# plain env vars — only SECRET_NAME is injected at runtime (see ecs.tf), and
# the app fetches + decrypts this value itself via the task IAM role.
resource "aws_secretsmanager_secret" "app_config" {
  name       = "hyventur/app-config"
  kms_key_id = aws_kms_key.app.arn
}

resource "aws_secretsmanager_secret_version" "app_config" {
  secret_id = aws_secretsmanager_secret.app_config.id
  secret_string = jsonencode({
    APP_NAME   = "Hyventur AWS Demo"
    S3_BUCKET  = var.s3_bucket_name
    IMAGE_NAME = var.image_name
  })
}
