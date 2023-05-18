variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "region" {
  description = "the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
}

variable "availability_zones" {
  description = "a comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both private_subnets and public_subnets have to be defined as well"
}

variable "cidr" {
  description = "The CIDR block for the VPC."
}

variable "private_subnets" {
  description = "a list of CIDRs for private subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
}

variable "public_subnets" {
  description = "a list of CIDRs for public subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
}

# variable "jenkins_instance_class" {
#   description = "a list of CIDRs for public subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
# }

# variable "jenkins_pam_file" {
#   description = "a list of CIDRs for public subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
# }

# variable "sonar_instance_class" {
#   description = "a list of CIDRs for public subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
# }

# variable "sonar_pam_file" {
#   description = "a list of CIDRs for public subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
# }

# variable "input_vpc_id" {
#   description = "Input VPC ID"
# }

# variable "input_cidr" {
#   description = "The CIDR block for the VPC."
# }

# variable "input_private_subnets" {
#   description = "a list of CIDRs for private subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
# }

# variable "input_db_private_subnets" {
#   description = "a list of CIDRs for DB private subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
# }

# variable "input_public_subnets" {
#   description = "a list of CIDRs for public subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
# }

variable "kubeconfig_path" {
  description = "Path where the config file for kubectl should be written to"
}

variable "k8s_version" {
  description = "kubernetes version"
}
