terraform {
  required_version = "~>1.0.1"
  backend "s3" {
   bucket         = "skilrock-ks-cluster-prod-state"
   key            = "state/terraform.tfstate"
   region         = "ap-south-1"
   encrypt        = true
   kms_key_id     = "alias/skilrock-ks-cluster-prod-state"
   dynamodb_table = "skilrock-ks-cluster-prod-state"
 }
}
