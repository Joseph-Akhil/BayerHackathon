terraform {
  required_version = ">= 1.5"

  backend "s3" {
    bucket         = "patient-appointment-akhil-eks-tf-state"
    key            = "eks/terraform.tfstate"
    region         = "eu-central-1"
    #dynamodb_table = "akhil-tf-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}