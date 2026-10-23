locals {
  kms_keys = toset(["eks", "rds", "secrets", "ebs"])
}

resource "aws_kms_key" "this" {
  for_each                = local.kms_keys
  description             = "${var.prefix} ${each.key} encryption key"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags                    = { Name = "${var.prefix}-${each.key}" }
}

resource "aws_kms_alias" "this" {
  for_each      = local.kms_keys
  name          = "alias/${var.prefix}-${each.key}"
  target_key_id = aws_kms_key.this[each.key].key_id
}