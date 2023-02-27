# create the aws backup for the dynamodb table

resource "aws_kms_key" "dynamodb_backup_kms_key" {
  count                   = var.aws_backup ? 1 : 0
  description             = "Vault Dynamodb backup kms key for ${var.env}"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "dynamodb_backup_kms_key_alias" {
  count         = var.aws_backup ? 1 : 0
  name          = "alias/dynamodb-backup-kms-key-${var.env}"
  target_key_id = aws_kms_key.dynamodb_backup_kms_key[count.index].key_id
}

resource "aws_backup_vault" "dynamodb_backup_vault" {
  count       = var.aws_backup ? 1 : 0
  name        = "dynamodb-backup-vault-${var.env}"
  kms_key_arn = aws_kms_key.dynamodb_backup_kms_key[count.index].arn
}

resource "aws_backup_plan" "dynamodb_backup_plan" {
  count = var.aws_backup ? 1 : 0
  name  = "dynamodb-backup-plan-${var.env}"

  rule {
    rule_name         = "dynamodb-backup-daily-rule"
    target_vault_name = aws_backup_vault.dynamodb_backup_vault[count.index].name
    schedule          = "cron(0 5 * * ? *)"
    lifecycle {
      delete_after = 7
    }
  }

  rule {
    rule_name         = "dynamodb-backup-weekly-rule"
    target_vault_name = aws_backup_vault.dynamodb_backup_vault[count.index].name
    schedule          = "cron(30 5 ? * SUN *)"
    lifecycle {
      delete_after = 84
    }
  }

  rule {
    rule_name         = "dynamodb-backup-monthly-rule"
    target_vault_name = aws_backup_vault.dynamodb_backup_vault[count.index].name
    schedule          = "cron(0 6 ? * 1#1 *)"
    lifecycle {
      delete_after = 1095
    }
  }

  rule {
    rule_name         = "dynamodb-backup-yearly-rule"
    target_vault_name = aws_backup_vault.dynamodb_backup_vault[count.index].name
    schedule          = "cron(30 6 ? JAN 1#1 *)"
    lifecycle {
      delete_after = 5475
    }
  }

}

resource "aws_iam_role" "backup-role" {
  count              = var.aws_backup ? 1 : 0
  name               = "dynamodb-backup-role-${var.env}"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_backup_selection" "dynamodb_backup_selection" {
  count        = var.aws_backup ? 1 : 0
  iam_role_arn = aws_iam_role.backup-role[count.index].arn
  name         = "dynamodb_backup_selection_${var.env}"
  plan_id      = aws_backup_plan.dynamodb_backup_plan[count.index].id

  resources = [
    aws_dynamodb_table.vault-backend.arn
  ]
}
