


terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  #   backend configuration for the terraform state in S3 bucket with the DynamoDb table as the backend and encryption, locking enabled
  #  Always remember to run terraform init command like this due to backend.hcl file include
  # terraform init -backend-config=backend.hcl
  backend "s3" {
    bucket = "static-website-hosting-terraform-state"
    key    = "modules/nginx-react/terraform.tfstate"
  }
}


#  configure the aws provider
provider "aws" {
  region = "us-east-1"
  # profile = "default"
  default_tags {
    tags = {
      terraform = "ManagedBy-${var.Owner}-${var.project}"
    }
  }
}
