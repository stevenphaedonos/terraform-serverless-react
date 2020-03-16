resource "aws_codebuild_project" "stage_frontend_codebuild" {
  name          = "${var.project_name}-frontend-stage"
  build_timeout = "30"
  service_role  = aws_iam_role.codebuild_role.arn

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:1.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "REACT_APP_BACKEND_URL"
      value = "https://api.stage.${var.domain}"
    }

    environment_variable {
      name  = "REACT_APP_FRONTEND_URL"
      value = "https://stage.${var.domain}"
    }

    environment_variable {
      name  = "REACT_APP_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "REACT_APP_USER_POOL_ID"
      value = aws_cognito_user_pool.dev_user_pool.id
    }

    environment_variable {
      name  = "REACT_APP_USER_POOL_CLIENT"
      value = aws_cognito_user_pool_client.dev_client.id
    }

    environment_variable {
      name  = "REACT_APP_IDENTITY_POOL_ID"
      value = aws_cognito_identity_pool.dev_identity_pool.id
    }

    environment_variable {
      name  = "PROJECT_BUCKET"
      value = aws_s3_bucket.project_bucket.id
    }

    environment_variable {
      name  = "CLOUDFRONT_DISTRO"
      value = aws_cloudfront_distribution.stage_distribution.id
    }

    environment_variable {
      name  = "STAGE"
      value = "stage"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "pipeline/buildspec/frontend.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}

resource "aws_codebuild_project" "stage_backend_codebuild" {
  name          = "${var.project_name}-backend-stage"
  build_timeout = "30"
  service_role  = aws_iam_role.codebuild_role.arn

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:1.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "BACKEND_DOMAIN"
      value = "api.stage.${var.domain}"
    }

    environment_variable {
      name  = "FRONTEND_DOMAIN"
      value = "stage.${var.domain}"
    }

    environment_variable {
      name  = "DOMAIN_CERT_ARN"
      value = aws_acm_certificate_validation.domain_cert_validation.certificate_arn
    }

    environment_variable {
      name  = "HOSTED_ZONE_ID"
      value = aws_route53_zone.hosted_zone.id
    }

    environment_variable {
      name  = "USER_POOL_ENDPOINT"
      value = "https://${aws_cognito_user_pool.dev_user_pool.endpoint}"
    }

    environment_variable {
      name  = "PROJECT_NAME"
      value = var.project_name
    }

    environment_variable {
      name  = "PROJECT_BUCKET"
      value = aws_s3_bucket.project_bucket.id
    }

    environment_variable {
      name  = "STAGE"
      value = "stage"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "pipeline/buildspec/backend.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}

resource "aws_codebuild_project" "prod_frontend_codebuild" {
  name          = "${var.project_name}-frontend-prod"
  build_timeout = "30"
  service_role  = aws_iam_role.codebuild_role.arn

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:1.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "REACT_APP_BACKEND_URL"
      value = "https://api.${var.domain}"
    }

    environment_variable {
      name  = "REACT_APP_FRONTEND_URL"
      value = "https://${var.domain}"
    }

    environment_variable {
      name  = "REACT_APP_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "REACT_APP_USER_POOL_ID"
      value = aws_cognito_user_pool.prod_user_pool.id
    }

    environment_variable {
      name  = "REACT_APP_USER_POOL_CLIENT"
      value = aws_cognito_user_pool_client.prod_client.id
    }

    environment_variable {
      name  = "REACT_APP_IDENTITY_POOL_ID"
      value = aws_cognito_identity_pool.prod_identity_pool.id
    }

    environment_variable {
      name  = "PROJECT_BUCKET"
      value = aws_s3_bucket.project_bucket.id
    }

    environment_variable {
      name  = "CLOUDFRONT_DISTRO"
      value = aws_cloudfront_distribution.prod_distribution.id
    }

    environment_variable {
      name  = "STAGE"
      value = "prod"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "pipeline/buildspec/frontend.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}

resource "aws_codebuild_project" "prod_backend_codebuild" {
  name          = "${var.project_name}-backend-prod"
  build_timeout = "30"
  service_role  = aws_iam_role.codebuild_role.arn

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:1.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "BACKEND_DOMAIN"
      value = "api.${var.domain}"
    }

    environment_variable {
      name  = "FRONTEND_DOMAIN"
      value = var.domain
    }

    environment_variable {
      name  = "DOMAIN_CERT_ARN"
      value = aws_acm_certificate_validation.domain_cert_validation.certificate_arn
    }

    environment_variable {
      name  = "HOSTED_ZONE_ID"
      value = aws_route53_zone.hosted_zone.id
    }

    environment_variable {
      name  = "USER_POOL_ENDPOINT"
      value = "https://${aws_cognito_user_pool.prod_user_pool.endpoint}"
    }

    environment_variable {
      name  = "PROJECT_NAME"
      value = var.project_name
    }

    environment_variable {
      name  = "PROJECT_BUCKET"
      value = aws_s3_bucket.project_bucket.id
    }

    environment_variable {
      name  = "STAGE"
      value = "prod"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "pipeline/buildspec/backend.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}
