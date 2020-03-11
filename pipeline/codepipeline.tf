resource "aws_codepipeline" "project_codepipeline" {
  name     = "${var.project_name}-codepipeline"
  role_arn = aws_iam_role.codebuild_role.arn

  artifact_store {
    location = aws_s3_bucket.project_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        Owner      = var.git_repository_owner
        Repo       = var.git_repository_name
        Branch     = var.git_repository_branch
        OAuthToken = data.aws_ssm_parameter.github_token.value
      }
    }
  }

  stage {
    name = "Stage"

    action {
      name            = "Frontend"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration = {
        ProjectName = "${var.project_name}-frontend-stage"
      }
    }

    action {
      name            = "Backend"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration = {
        ProjectName = "${var.project_name}-backend-stage"
      }
    }
  }

  stage {
    name = "Prod"

    action {
      name      = "ApprovalStage"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      run_order = 1
      version   = "1"
    }

    action {
      name            = "Frontend"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      run_order       = 2
      version         = "1"
      input_artifacts = ["source"]

      configuration = {
        ProjectName = "${var.project_name}-frontend-prod"
      }
    }

    action {
      name            = "Backend"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      run_order       = 2
      version         = "1"
      input_artifacts = ["source"]

      configuration = {
        ProjectName = "${var.project_name}-backend-prod"
      }
    }
  }
}
