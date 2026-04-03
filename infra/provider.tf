provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "srueda-private-content"
    key            = "devops-project/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}