resource "aws_cognito_user_pool" "dev_user_pool" {
  name = "${var.project_name}-user-pool-dev"

  tags = {
    Project     = var.project_name
    Environment = "dev"
  }
}

resource "aws_cognito_user_pool_client" "dev_client" {
  name = "${var.project_name}-client-dev"

  user_pool_id = aws_cognito_user_pool.dev_user_pool.id
}

resource "aws_cognito_identity_pool" "dev_identity_pool" {
  identity_pool_name               = var.project_name
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    provider_name = aws_cognito_user_pool.dev_user_pool.endpoint
    client_id     = aws_cognito_user_pool_client.dev_client.id
  }

  tags = {
    Project     = var.project_name
    Environment = "dev"
  }
}

resource "aws_cognito_user_group" "dev_admin_group" {
  name         = "admin"
  user_pool_id = aws_cognito_user_pool.dev_user_pool.id
}

resource "aws_cognito_user_pool" "prod_user_pool" {
  name = "${var.project_name}-user-pool-prod"

  tags = {
    Project     = var.project_name
    Environment = "prod"
  }
}

resource "aws_cognito_user_pool_client" "prod_client" {
  name = "${var.project_name}-client-prod"

  user_pool_id = aws_cognito_user_pool.prod_user_pool.id
}

resource "aws_cognito_identity_pool" "prod_identity_pool" {
  identity_pool_name               = var.project_name
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    provider_name = aws_cognito_user_pool.prod_user_pool.endpoint
    client_id     = aws_cognito_user_pool_client.prod_client.id
  }

  tags = {
    Project     = var.project_name
    Environment = "prod"
  }
}

resource "aws_cognito_user_group" "prod_admin_group" {
  name         = "admin"
  user_pool_id = aws_cognito_user_pool.prod_user_pool.id
}
