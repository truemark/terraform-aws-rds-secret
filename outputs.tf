output "password" {
  value = join("", random_password.secret.*.result)
  sensitive = true
}

output "secret_id" {
  value = join("", aws_secretsmanager_secret.secret.*.id)
}

output "secret_arn" {
  value = join("", aws_secretsmanager_secret.secret.*.arn)
}
