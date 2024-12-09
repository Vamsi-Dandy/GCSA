data "aws_iam_policy_document" "dm_kms" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root",
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:user/devsecops",
      ]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_kms_key" "dm" {
  description             = "DM Cloud Infrastructure Key"
  key_usage               = "ENCRYPT_DECRYPT"
  policy                  = data.aws_iam_policy_document.dm_kms.json
  deletion_window_in_days = 10
  enable_key_rotation     = true
  multi_region            = false

  tags = merge(local.tags, {
    Product = "security"
  })
}

resource "aws_kms_alias" "dm" {
  name          = "alias/dm/key"
  target_key_id = aws_kms_key.dm.key_id
}
