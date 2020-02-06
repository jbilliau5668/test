# ---------------------------------------------------------------------------------------------------------------------
# SET TERRAFORM REQUIREMENTS/VARIABLES FOR RUNNING THIS MODULE
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"

  allowed_account_ids = [
    "${var.aws_account_id}"
  ]
}

locals {
  application_string = "${lower(var.environment)}-${var.app_id}-${lower(var.application_name)}"
  namespace          = var.namespace == "" ? var.application_name : var.namespace

  iac_tags = {
    iac                           = "terraform"
    module                        = "aws-eks-app-tf"
    app-id                        = var.app_id
    application                   = lower(var.application_name)
    environment                   = lower(var.environment)
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE RESOURCES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecr_repository" "default" {
  name = local.application_string
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "default" {
  repository = aws_ecr_repository.default.name


  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "Testing",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.stream_account_id}:root"
      },
      "Action": [
        "ecr:*"
      ]
    }
  ]
}
EOF

}

resource "aws_ecr_lifecycle_policy" "default" {
  repository = aws_ecr_repository.default.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images more than 30 versions old",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 60
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF

}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE IAM ROLE, POLICIES
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "default" {
  name = "role-${local.application_string}-${var.aws_region}"
  tags = local.iac_tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.aws_account_id}:oidc-provider/${var.oidc_string}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${var.oidc_string}:sub": "system:serviceaccount:${local.namespace}:${var.application_name}"
        }
      }
    }
  ]
}
EOF

}