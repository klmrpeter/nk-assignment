terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.13.1"
    }
  }
  backend "s3" {
    bucket         = "nokia-assignment-tf-bucket"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
  }
}