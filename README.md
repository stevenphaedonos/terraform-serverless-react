# terraform-serverless-react

## Description

- Boilerplate code to launch a serverless web application with a ReactJS frontend and Python backend
- Infrastructure described as code using Terraform
- Simplified development environment via Docker (and Docker Compose)

## Architecture

| Component      | Notes                                                                                                                                                                                             |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Frontend       | - Bootstrapped by [create-react-app](https://github.com/facebook/create-react-app) <br/> - [Material UI](https://github.com/mui-org/material-ui) Framework <br/> - Deployed via AWS S3/CloudFront |
| Backend        | - [Serverless Framework](https://github.com/serverless/serverless) with Python handlers <br/> - Deployed via AWS Lambda/API Gateway                                                               |
| Authentication | AWS Cognito via [aws-amplify](https://github.com/aws-amplify/amplify-js)                                                                                                                          |
| CI/CD pipeline | AWS CodePipeline + GitHub hook + AWS CodeBuild                                                                                                                                                    |
| Domain         | DNS delegated to AWS Route53 using ACM for SSL certificate management                                                                                                                             |

## Configuration

### GitHub Access Token

- [GitHub access token](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line) stored in AWS Parameter Store with name `GITHUB_TOKEN`
- The CodePipeline source is configured as a GitHub hook that uses this token

## Terraform

### `variables.tf`

- The following parameters must be provided in `pipeline/variables.tf`
- Refer to `pipeline/variables.tf.dist` for examples

| Parameter             | Description                                                                                                                                                                                                              |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| project_name          | Lower-case project name                                                                                                                                                                                                  |
| domain                | - Domain name of the project (e.g. example.com) <br/> - The following 4 records will become web-accessible: <br/> `https://${domain}`, `https://api.${domain}`, `https://stage.${domain}`, `https://api.stage.${domain}` |
| project_bucket        | Location to store project files (Serverless deployment, compiled frontend)                                                                                                                                               |
| git_repository_owner  | Username of the GitHub account which owns the GitHub code repository                                                                                                                                                     |
| git_repository_name   | Name of the GitHub code repository                                                                                                                                                                                       |
| git_repository_branch | Name of the branch to be deployed (commits to this branch will trigger the CI/CD pipeline)                                                                                                                               |

### `terraform.tf`

- The following parameters must be provided in `pipeline/terraform.tf`
- Refer to `pipeline/terraform.tf.dist` for examples

| Parameter           | Description                                                                                                       |
| ------------------- | ----------------------------------------------------------------------------------------------------------------- |
| <YOUR_REGION>       | [AWS region name](https://docs.aws.amazon.com/general/latest/gr/rande.html) in which to deploy the infrastructure |
| <YOUR_STATE_BUCKET> | AWS S3 bucket in which to store the [Terraform state file](https://www.terraform.io/docs/backends/types/s3.html)  |
| <YOUR_STATE_FILE>   | The name to give the Terraform state file in the specified state bucket                                           |
| <YOUR_STATE_REGION> | The [AWS region name](https://docs.aws.amazon.com/general/latest/gr/rande.html) of the specified state bucket     |

## Development

1. Configure the project as described in [Configuration](##Configuration)
2. From the `pipeline` directory, run `terraform init` followed by `terraform apply`
    - The infrastructure for the project will be deployed
    - An .env file will be added to the project root directory with details of the dev environment resources (this file is used to inject environment variables into the dev Docker containers)
3. From the project root directory, run `docker-compose up --build`
4. Pushing a commit to the [`git_repository_branch`](###`variables.tf`) will trigger a deployment to stage, and then to prod (after manual approval)
