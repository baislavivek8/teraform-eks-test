variable "enabled" {
  type        = bool
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources"
  default     = true
}


variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "cdn_arn" {
  type        = string
  description = "CDN ARN"
  default     = ""
}

variable "rules" {
  description = "List of WAF rules."
  type        = any
  default     = []
}

variable "visibility_config" {
  description = "Visibility config for WAFv2 web acl. https://www.terraform.io/docs/providers/aws/r/wafv2_web_acl.html#visibility-configuration"
  type        = map(string)
  default     = {}
}


/*variable "create_logging_configuration" {
  type        = bool
  description = "Whether to create logging configuration in order start logging from a WAFv2 Web ACL to Amazon Kinesis Data Firehose."
  default     = false
}*/

/*variable "log_destination_configs" {
  type        = list(string)
  description = "The Amazon Kinesis Data Firehose Amazon Resource Name (ARNs) that you want to associate with the web ACL. Currently, only 1 ARN is supported."
  default     = []
}*/

