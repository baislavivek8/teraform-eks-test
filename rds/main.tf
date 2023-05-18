#data "aws_region" "current" {}

resource "aws_security_group" "rds_sg" {
  name        = "skilrock-rds-cluster-sg-eks-${var.environment}"
  description = "skilrock-rds-cluster-sg-eks-${var.environment}"
  vpc_id      = var.vpc_id
    
    ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    
    cidr_blocks = [
     var.vpc_cidr_blocks
    ]
  }

  tags = {
    Product = "skilrock"
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "main" {
  name        = "skilrock-rds-cluster-sbntg-eks-${var.environment}"
  description = "skilrock-rds-cluster-sbntg-eks-${var.environment}"
  subnet_ids  = var.private_subnets.*.id      # change subnet to DB only 

  tags = {
    Product = "skilrock"
    Environment = var.environment
  }

}

resource "aws_rds_cluster_parameter_group" "default" {
  name        = "skilrock-rds-cluster-pg-eks-${var.environment}"
  family      = "aurora-mysql5.7"
  description = "skilrock-rds-cluster-pg-eks-${var.environment}"
  parameter {
    name  = "server_audit_events"
    value = "CONNECT,QUERY,QUERY_DCL,QUERY_DDL,QUERY_DML,TABLE"
  }
  parameter {
    name  = "server_audit_logging"
    value = "1"
  }
  parameter {
    name  = "server_audit_logs_upload"
    value = "1"
  }
tags = {
    Product = "skilrock"
    Environment = var.environment
  }

}

resource "aws_db_parameter_group" "default" {
  name   = "skilrock-rds-pg-eks-${var.environment}"
  family = "aurora-mysql5.7"
  description = "lcms-tp-rds-pg-eks-${var.environment}"

  tags = {
    Product = "lcms-tp"
    Environment = var.environment
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                       = 2
  identifier                  = "skilrock-rds-eks-${var.environment}-${count.index}"
  cluster_identifier          = aws_rds_cluster.aakash_rds.id
  instance_class              = var.instance_class
  engine                      = "aurora-mysql"
  engine_version              = "5.7.mysql_aurora.2.07.2"
  apply_immediately           = false
  auto_minor_version_upgrade  = false
  db_parameter_group_name     = aws_db_parameter_group.default.name

  tags = {
    Product = "skilrock"
    Environment = var.environment
  }
}

resource "aws_rds_cluster" "aakash_rds" {
  cluster_identifier                  = "skilrock-rds-cluster-eks-${var.environment}"
  engine                              = "aurora-mysql"
  engine_version                      = "5.7.mysql_aurora.2.07.2"
  database_name                       = "lcms"
  master_username                     = var.rds_user_name
  master_password                     = var.rds_user_password
  storage_encrypted                   = true
  apply_immediately                   = true
  skip_final_snapshot                 = false
  final_snapshot_identifier           = "skilrock-rds-cluster-eks-${var.environment}"
  snapshot_identifier                 = "skilrock-rds-cluster-eks-${var.environment}"
  deletion_protection                 = true
  backup_retention_period             = 7
  vpc_security_group_ids              = [aws_security_group.rds_sg.id,var.lcms-sg-id,var.tp-sg-id]
  db_subnet_group_name                = aws_db_subnet_group.main.id
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.default.name
  enabled_cloudwatch_logs_exports     = ["audit", "error", "general", "slowquery"]

  tags = {
    Product = "lcms-tp"
    Environment = var.environment
  }
}

/*resource "aws_secretsmanager_secret" "rds_secret" {
  name = "${var.secret_name}-${var.environment}"
}*/

# resource "aws_db_proxy" "tt_rds_proxy" {
#   name                   = "${var.rds_proxy_name}-${var.environment}"
#   debug_logging          = false
#   engine_family          = "MYSQL"
#   idle_client_timeout    = 28740
#   require_tls            = true
#   role_arn               = aws_iam_role.this.arn
#   vpc_security_group_ids = [aws_security_group.proxy_sg.id]
#   vpc_subnet_ids         = var.private_subnets.*.id

#   auth {
#     auth_scheme = "SECRETS"
#     description = "Test Taking RDS Proxy"
#     iam_auth    = "DISABLED"
#     secret_arn  = var.secret_arn
#   }

#  tags = {
#     Product = "tt"
#     Environment = var.environment
#   }
# }

# resource "aws_db_proxy_default_target_group" "tt_rds_proxy" {
#   db_proxy_name = aws_db_proxy.tt_rds_proxy.name

#   connection_pool_config {
#     connection_borrow_timeout    = 120
#     init_query                   = "SET x=1, y=2"
#     max_connections_percent      = 80
#     max_idle_connections_percent = 80
#     session_pinning_filters      = ["EXCLUDE_VARIABLE_SETS"]
#   }
# }

# resource "aws_db_proxy_target" "tt_rds_proxy" {
#   db_instance_identifier = aws_db_instance.aakash_rds.id
#   db_proxy_name          = aws_db_proxy.tt_rds_proxy.name
#   target_group_name      = aws_db_proxy_default_target_group.tt_rds_proxy.name
# }


######################################################################################

# resource "aws_security_group" "proxy_sg" {
#   name        = "rds-proxy-sg"
#   description = "Allow kubernetes custer traffic only"
#   vpc_id      = var.vpc_id
  
#   ingress {
#     from_port = 3306
#     to_port   = 3306
#     protocol  = "tcp"

#     cidr_blocks = [
#      var.vpc_cidr_blocks
#     ]
#   }
#   tags = {
#     Product = "tt"
#     Environment = var.environment
#   }
# }
################################################################################
# IAM Role
################################################################################

# data "aws_iam_policy_document" "rds_proxy" {
#   statement {
#     effect    = "Allow"
#     actions   = ["kinesis:*"]
#     resources = ["*"]
#   }

# }

# resource "aws_iam_policy" "rds_proxy" {
#   name   = "tt-tp-IAM-Policy-rds-proxy-eks-${var.environment}"
#   path   = "/"
#   policy = data.aws_iam_policy_document.rds_proxy.json
# }

# resource "aws_iam_role_policy_attachment" "attach_kinesis_policy_to_kinesis_role" {
#   role       = aws_iam_role.this.name
#   policy_arn = aws_iam_policy.rds_proxy.arn
# }

# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     sid     = "RDSAssume"
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["rds.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "this" {
#   name        = "tt-IAM-RDS-Proxy-role-eks-${var.environment}"
#   description = "Test Taking RDS Proxy IAM Role"
#   path        = var.iam_role_path

#   assume_role_policy    = data.aws_iam_policy_document.assume_role.json
#   force_detach_policies = var.iam_role_force_detach_policies
#   max_session_duration  = var.iam_role_max_session_duration
#   permissions_boundary  = var.iam_role_permissions_boundary
# }

#####################################################################################################