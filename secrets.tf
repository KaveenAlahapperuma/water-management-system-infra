resource "aws_secretsmanager_secret" "backend" {
  name                    = "${var.prefix}/backend"
  description             = "Application secrets for the Spring Boot backend"
  kms_key_id              = aws_kms_key.this["secrets"].arn
  recovery_window_in_days = 0
}