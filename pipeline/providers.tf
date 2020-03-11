provider "aws" {
  # us-east-1 provider required for ACM certificates
  region = "us-east-1"
  alias  = "us"
}

provider "local" {}
