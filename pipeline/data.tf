data "aws_region" "current" {
}

data "aws_caller_identity" "current" {
}

data "aws_ssm_parameter" "github_token" {
  name = "GITHUB_TOKEN"
}

resource "local_file" "dev_environment" {
  content  = <<-HEREDOC
    PROJECT_NAME=${var.project_name}
    PROJECT_BUCKET=${aws_s3_bucket.project_bucket.id}
    REGION=${data.aws_region.current.name}
    USER_POOL_ID=${aws_cognito_user_pool.dev_user_pool.id}
    USER_POOL_CLIENT=${aws_cognito_user_pool_client.dev_client.id}
    USER_POOL_ENDPOINT=https://${aws_cognito_user_pool.dev_user_pool.endpoint}
    IDENTITY_POOL_ID=${aws_cognito_identity_pool.dev_identity_pool.id}
  HEREDOC
  filename = "${path.module}/../.env"
}

