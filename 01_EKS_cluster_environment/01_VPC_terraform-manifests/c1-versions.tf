terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
# Remote Backend
  backend "s3" {
    bucket         = "online-boutique-dev-tfstate-927749346049-ap-southeast-1-an"
    key            = "vpc/dev/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    use_lockfile = true
  }   
}

provider "aws" {
  region = var.aws_region
}