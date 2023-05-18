# resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
#   role       = aws_iam_role.fargate_pod_execution_role.name
# }

# resource "aws_iam_role" "fargate_pod_execution_role" {
#   name                  = "iam-fargate-pod-execution-role-eks-${var.environment}"
#   force_detach_policies = true

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": [
#           "eks.amazonaws.com",
#           "eks-fargate-pods.amazonaws.com"
#           ]
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
# lifecycle {
#     create_before_destroy = true
#     ignore_changes        = [tags]
#   }
# }

# # resource "aws_eks_fargate_profile" "uat" {
# #   cluster_name           = aws_eks_cluster.main.name
# #   fargate_profile_name   = "fp-uat"
# #   pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
# #   subnet_ids             = var.private_subnets.*.id

# #   selector {
# #     namespace = "uat"
# #   }
  
# #   timeouts {
# #     create = "30m"
# #     delete = "60m"
# #   }
# #   lifecycle {
# #     create_before_destroy = true
# #     ignore_changes        = [tags]
# #   }
# # }

# # resource "aws_eks_fargate_profile" "qa" {
# #   cluster_name           = aws_eks_cluster.main.name
# #   fargate_profile_name   = "fp-qa"
# #   pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
# #   subnet_ids             = var.private_subnets.*.id

# #   selector {
# #     namespace = "qa"
# #   }
  
# #   timeouts {
# #     create = "30m"
# #     delete = "60m"
# #   }
# #   lifecycle {
# #     create_before_destroy = true
# #     ignore_changes        = [tags]
# #   }
# # }


# output "pod_execution_role" {
#   description = "fargate_pod_execution_role for cloudwatch logging "
#   value       = aws_iam_role.fargate_pod_execution_role.name
# }



# #####################################################################################

# data "aws_iam_policy_document" "aws_fargate_logging_policy" {
#   statement {
#     sid = "1"

#     actions = [
#       "logs:CreateLogStream",
#       "logs:CreateLogGroup",
#       "logs:DescribeLogStreams",
#       "logs:PutLogEvents",
#     ]

#     resources = [
#       "*",
#     ]
#   }
# }

# resource "aws_iam_policy" "aws_fargate_logging_policy" {
#   name   = "${var.name}-ks-cluster-aws_fargate_logging_policy-${var.environment}"
#   path   = "/"
#   policy = data.aws_iam_policy_document.aws_fargate_logging_policy.json
# }

# resource "aws_iam_role_policy_attachment" "aws_fargate_logging_policy_attach_role" {
#   role       = aws_iam_role.fargate_pod_execution_role.name
#   policy_arn = aws_iam_policy.aws_fargate_logging_policy.arn
# }