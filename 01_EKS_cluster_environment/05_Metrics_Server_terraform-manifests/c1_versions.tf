terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.20"
    }
  }

  # Remote backend configuration using S3 
  backend "s3" {
    bucket         = "online-boutique-dev-tfstate-927749346049-ap-southeast-1-an"         
    key            = "metrics-server/dev/terraform.tfstate"            
    region         = "ap-southeast-1"                            
    encrypt        = true                                   
    use_lockfile   = true     
  }
}

provider "aws" {
  # AWS region to use for all resources (from variables)
  region = var.aws_region
}
