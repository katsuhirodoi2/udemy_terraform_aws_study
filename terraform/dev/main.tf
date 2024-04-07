# ------------------------------
# Terraform configuration
# ------------------------------
terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
  backend "s3" {
    bucket  = "tastylog-tfstate-bucket-doik20240327"
    key     = "tastylog-dev.tfstate"
    region  = "ap-northeast-1"
    profile = "<<<AWSCLIで使用するprofile名>>>"
  }
}

# ------------------------------
# Provider
# ------------------------------
provider "aws" {
  profile = "<<<AWSCLIで使用するprofile名>>>"
  region  = "ap-northeast-1"
}

provider "aws" {
  alias   = "virginia"
  profile = "<<<AWSCLIで使用するprofile名>>>"
  region  = "us-east-1"
}

# ------------------------------
# Variables
# ------------------------------
variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "my_ip" {
  type = list(string)
}

variable "domain" {
  type = string
}
