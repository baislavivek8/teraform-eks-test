module "vpc" {
  source             = "./vpc"
  name               = var.name
  environment        = var.environment
  cidr               = var.cidr
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
}

module "eks" {
  source          = "./eks"
  name            = var.name
  environment     = var.environment
  region          = var.region
  k8s_version     = var.k8s_version
  vpc_id          = module.vpc.id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
  kubeconfig_path = var.kubeconfig_path
}

# module "s3_cdn" {
#   source              = "./s3_cdn"
#   name                = var.name
#   environment         = var.environment
#   region              = var.region
# }

# module "jenkins" {
#   source              = "./jenkins"
#   name                = var.name
#   environment         = var.environment
#   vpc_id              = module.vpc.id
#   private_subnets     = module.vpc.private_subnets
#   //public_subnets     = module.vpc.public_subnets
#   instance_class      = "t3a.micro"
#   //pemkey              = var.jenkins_pam_file
# }

# module "sonar" {
#   source              = "./sonar"
#   name                = var.name
#   environment         = var.environment
#   vpc_id              = module.vpc.id
#   private_subnets     = module.vpc.private_subnets
#   //public_subnets     = module.vpc.public_subnets
#   instance_class      = var.sonar_instance_class
#   pemkey              = var.sonar_pam_file
# }
# module "api_gateway" {
#   source              = "./api_gateway"
#   name                = var.name
#   environment         = var.environment
#   #main_domain         = var.main_domain
#   #api_certificate_arn = var.api_gateway_certificate_arn
#   #zone_id             = var.hosted_zone_id
# }

# module "security_group" {
#   source             = "./security_groups"
#   environment        = var.environment
#   vpc_id             = module.vpc.id
# }

# module "rds" {
#   source                = "./rds"
#   rds_name              = var.rds_name
#   rds_proxy_name        = var.rds_proxy_name
#   secret_name           = var.rds_secret_name
#   environment           = var.environment
#   instance_class        = var.rds_instance_class
#   vpc_id                = module.vpc.id
#   private_subnets       = module.vpc.private_subnets
#   public_subnets        = module.vpc.public_subnets
#   rds_user_name         = var.rds_username
#   rds_user_password     = var.rds_userpassword 
#   lcms-sg-id            = module.security_group.skilrock_common_sg_eks
# }

# module "waf2_global" {
#   source            = "./waf2_global"
#   environment       = var.environment
#   #api_arn           = module.api_gateway.api_gateway_arn
#   #allow_default_action = true # set to allow if not specified
#   visibility_config = {
#     metric_name = "waf-setup-waf-main-metrics"
#   }

#   rules = [
#     {
#       name     = "AWSManagedRulesCommonRuleSet-rule-1"
#       priority = "1"
#       override_action = "none"
#       visibility_config = {
#         metric_name                = "AWSManagedRulesCommonRuleSet-metric"
#       }

#       managed_rule_group_statement = {
#         name        = "AWSManagedRulesCommonRuleSet"
#         vendor_name = "AWS"
#         excluded_rule = [
#           "SizeRestrictions_QUERYSTRING",
#           "SizeRestrictions_BODY",
#           "GenericRFI_QUERYARGUMENTS"
#         ]
#       }
#     },
#     {
#       name     = "AWSManagedRulesKnownBadInputsRuleSet-rule-2"
#       priority = "2"
#       override_action = "count"
#       visibility_config = {
#         metric_name = "AWSManagedRulesKnownBadInputsRuleSet-metric"
#       }
#       managed_rule_group_statement = {
#         name        = "AWSManagedRulesKnownBadInputsRuleSet"
#         vendor_name = "AWS"
#       }
#     },
#     {
#       name     = "AWSManagedRulesPHPRuleSet-rule-3"
#       priority = "3"
#       override_action = "none"
#       visibility_config = {
#         cloudwatch_metrics_enabled = false
#         metric_name                = "AWSManagedRulesPHPRuleSet-metric"
#         sampled_requests_enabled   = false
#       }
#       managed_rule_group_statement = {
#         name        = "AWSManagedRulesPHPRuleSet"
#         vendor_name = "AWS"
#       }
#     },
#     ### Byte Match Rule
#     {
#       name     = "ByteMatchRule-4"
#       priority = "4"
#       action = "count"
#       visibility_config = {
#         cloudwatch_metrics_enabled = false
#         metric_name                = "ByteMatchRule-metric"
#         sampled_requests_enabled   = false
#       }

#       byte_match_statement = {
#         field_to_match = {
#           uri_path = "{}"
#         }
#         positional_constraint = "STARTS_WITH"
#         search_string         = "/path/to/match"
#         priority              = 0
#         type                  = "NONE"
#       }
#     },
#     ### Geo Match Rule
#     {
#       name     = "GeoMatchRule-5"
#       priority = "5"
#       action = "allow"
#       visibility_config = {
#         cloudwatch_metrics_enabled = false
#         metric_name                = "GeoMatchRule-metric"
#         sampled_requests_enabled   = false
#       }
#       geo_match_statement = {
#         country_codes = ["NL", "GB", "US"]
#       }
#     },
#     ### IP Set Rule example
#    /* {
#       name     = "IpSetRule-6"
#       priority = "6"
#       action = "allow"
#       visibility_config = {
#         cloudwatch_metrics_enabled = false
#         metric_name                = "IpSetRule-metric"
#         sampled_requests_enabled   = false
#       }
#       ip_set_reference_statement = {
#         arn = "arn:aws:wafv2:eu-west-1:111122223333:regional/ipset/ip-set-test/a1bcdef2-1234-123a-abc0-1234a5bc67d8"
#       }
#     },*/
#     ### IP Rate Based Rule example
#     {
#       name     = "IpRateBasedRule-7"
#       priority = "6"
#       action = "block"
#       visibility_config = {
#         cloudwatch_metrics_enabled = false
#         metric_name                = "IpRateBasedRule-metric"
#         sampled_requests_enabled   = false
#       }

#       rate_based_statement = {
#         limit              = 100
#         aggregate_key_type = "IP"
#         # Optional scope_down_statement to refine what gets rate limited
#         scope_down_statement = {
#           not_statement = {
#             byte_match_statement = {
#               field_to_match = {
#                 uri_path = "{}"
#               }
#               positional_constraint = "STARTS_WITH"
#               search_string         = "/path/to/match"
#               priority              = 0
#               type                  = "NONE"
#             }
#           }
#         }
#       }
#     },
#     ### NOT rule (can be applied to byte_match, geo_match, and ip_set rules)
#     {
#       name     = "NotByteMatchRule-8"
#       priority = "7"
#       action = "count"
#       visibility_config = {
#         cloudwatch_metrics_enabled = false
#         metric_name                = "NotByteMatchRule-metric"
#         sampled_requests_enabled   = false
#       }

#       not_statement = {
#         byte_match_statement = {
#           field_to_match = {
#             uri_path = "{}"
#           }
#           positional_constraint = "STARTS_WITH"
#           search_string         = "/path/to/match"
#           priority              = 0
#           type                  = "NONE"
#         }
#       }
#     }
#   ]
# }

# module "waf2_regional" {
#   source            = "./waf2_regional"
#   environment       = var.environment
#   //api_arn           = module.api_gateway.lcms_api_gateway_arn
#   #allow_default_action = true # set to allow if not specified
#   visibility_config = {
#     metric_name = "skilrock-waf-setup-waf-main-metrics"
#   }

#   rules = [
#     {
#       name     = "AWSManagedRulesCommonRuleSet-rule-1"
#       priority = "1"
#       override_action = "none"
#       visibility_config = {
#         metric_name                = "AWSManagedRulesCommonRuleSet-metric"
#       }

#       managed_rule_group_statement = {
#         name        = "AWSManagedRulesCommonRuleSet"
#         vendor_name = "AWS"
#         excluded_rule = [
#           "SizeRestrictions_QUERYSTRING",
#           "SizeRestrictions_BODY",
#           "GenericRFI_QUERYARGUMENTS"
#         ]
#       }
#     },
#     {
#       name     = "AWSManagedRulesKnownBadInputsRuleSet-rule-2"
#       priority = "2"
#       override_action = "count"
#       visibility_config = {
#         metric_name = "AWSManagedRulesKnownBadInputsRuleSet-metric"
#       }
#       managed_rule_group_statement = {
#         name        = "AWSManagedRulesKnownBadInputsRuleSet"
#         vendor_name = "AWS"
#       }
#     },
#     {
#       name     = "AWSManagedRulesPHPRuleSet-rule-3"
#       priority = "3"
#       override_action = "none"
#       visibility_config = {
#         cloudwatch_metrics_enabled = false
#         metric_name                = "AWSManagedRulesPHPRuleSet-metric"
#         sampled_requests_enabled   = false
#       }
#       managed_rule_group_statement = {
#         name        = "AWSManagedRulesPHPRuleSet"
#         vendor_name = "AWS"
#       }
#     },
#     ### Byte Match Rule
#     {
#       name     = "ByteMatchRule-4"
#       priority = "4"
#       action = "count"
#       visibility_config = {
#         cloudwatch_metrics_enabled = false
#         metric_name                = "ByteMatchRule-metric"
#         sampled_requests_enabled   = false
#       }

#       byte_match_statement = {
#         field_to_match = {
#           uri_path = "{}"
#         }
#         positional_constraint = "STARTS_WITH"
#         search_string         = "/path/to/match"
#         priority              = 0
#         type                  = "NONE"
#       }
#     },
#     ### Geo Match Rule
#     {
#       name     = "GeoMatchRule-5"
#       priority = "5"
#       action = "allow"
#       visibility_config = {
#         cloudwatch_metrics_enabled = false
#         metric_name                = "GeoMatchRule-metric"
#         sampled_requests_enabled   = false
#       }
#       geo_match_statement = {
#         country_codes = ["NL", "GB", "US"]
#       }
#     },
#     ### IP Set Rule example
#    /* {
#       name     = "IpSetRule-6"
#       priority = "6"
#       action = "allow"
#       visibility_config = {
#         cloudwatch_metrics_enabled = false
#         metric_name                = "IpSetRule-metric"
#         sampled_requests_enabled   = false
#       }
#       ip_set_reference_statement = {
#         arn = "arn:aws:wafv2:eu-west-1:111122223333:regional/ipset/ip-set-test/a1bcdef2-1234-123a-abc0-1234a5bc67d8"
#       }
#     },*/
#     ### IP Rate Based Rule example
#     {
#       name     = "IpRateBasedRule-7"
#       priority = "6"
#       action = "block"
#       visibility_config = {
#         cloudwatch_metrics_enabled = false
#         metric_name                = "IpRateBasedRule-metric"
#         sampled_requests_enabled   = false
#       }

#       rate_based_statement = {
#         limit              = 100
#         aggregate_key_type = "IP"
#         # Optional scope_down_statement to refine what gets rate limited
#         scope_down_statement = {
#           not_statement = {
#             byte_match_statement = {
#               field_to_match = {
#                 uri_path = "{}"
#               }
#               positional_constraint = "STARTS_WITH"
#               search_string         = "/path/to/match"
#               priority              = 0
#               type                  = "NONE"
#             }
#           }
#         }
#       }
#     },
#     ### NOT rule (can be applied to byte_match, geo_match, and ip_set rules)
#     {
#       name     = "NotByteMatchRule-8"
#       priority = "7"
#       action = "count"
#       visibility_config = {
#         cloudwatch_metrics_enabled = false
#         metric_name                = "NotByteMatchRule-metric"
#         sampled_requests_enabled   = false
#       }

#       not_statement = {
#         byte_match_statement = {
#           field_to_match = {
#             uri_path = "{}"
#           }
#           positional_constraint = "STARTS_WITH"
#           search_string         = "/path/to/match"
#           priority              = 0
#           type                  = "NONE"
#         }
#       }
#     }
#   ]
# }