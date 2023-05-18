variable "rds_name" {
  description = "Project-prefix, e.g. \"demo\""
}

variable "secret_name" {
  description = "Project-prefix, e.g. \"demo\""
}

variable "rds_proxy_name" {
  description = "the name of RDS Proxy Name, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "instance_class" {
  description = "Cluster instance class"
}

variable "vpc_id" {
  description = "The VPC the cluser should be created in"
}

variable "vpc_cidr_blocks" {
  description = "VPC CIDR Block"
}

variable "private_subnets" {
  description = "List of private subnet IDs"
}

variable "public_subnets" {
  description = "List of private subnet IDs"
}


# variable "db_subnet_group_id" {
#  description = "Subnet Group ID"
# }

variable "rds_user_name" {
  description = "List of CIDR block"
}

variable "rds_user_password" {
  description = "Subnet Group ID"
}

variable "iam_role_path" {
  description = "The path to the role"
  type        = string
  default     = null
}

variable "iam_role_force_detach_policies" {
  description = "Specifies to force detaching any policies the role has before destroying it"
  type        = bool
  default     = true
}

variable "iam_role_max_session_duration" {
  description = "The maximum session duration (in seconds) that you want to set for the specified role"
  type        = number
  default     = 43200 # 12 hours
}

variable "iam_role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the role"
  type        = string
  default     = null
}

variable "lcms-sg-id" {
  description = "LCMS security group id"
}
