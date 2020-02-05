output "iam_role_name" {
  description = "The IAM role name."
  value       = aws_iam_role.default.id
}

output "iam_role_arn" {
  description = "The IAM role ARN."
  value       = aws_iam_role.default.arn
}

output "ecr_repo_name" {
  description = "The ECR repo name."
  value       = aws_ecr_repository.default.name
}