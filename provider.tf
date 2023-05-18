provider "aws" {
  version = ">= 3.50"
  region  = var.region
  profile = "default"
  assume_role {
         role_arn     = "arn:aws:iam::020310215158:role/Skilrock-Terraform"
     }
}