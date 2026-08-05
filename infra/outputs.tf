output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "secrets_manager_secret_name" {
  value = aws_secretsmanager_secret.app_config.name
}

output "kms_key_arn" {
  value = aws_kms_key.app.arn
}

output "github_actions_deploy_role_arn" {
  description = "Set as the role-to-assume in the GitHub Actions workflow"
  value       = aws_iam_role.github_actions_deploy.arn
}
