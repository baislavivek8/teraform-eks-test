/* IMPORTANT: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html */

resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                                                   = "${var.name}-vpc-eks-${var.environment}"
    Product                                                = var.name
    Environment                                            = var.environment
    "kubernetes.io/cluster/${var.name}-ks-cluster-${var.environment}" = "shared"
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.name}-igw-eks-${var.environment}"
    Product     = var.name
    Environment = var.environment
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_nat_gateway" "main" {
  count         = length(var.private_subnets)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name        = "${var.name}-nat-eks-${var.environment}-${format("%03d", count.index+1)}"
    Product     = var.name
    Environment = var.environment
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_eip" "nat" {
  count = length(var.private_subnets)
  vpc = true

  tags = {
    Name        = "${var.name}-eip-eks-${var.environment}-${format("%03d", count.index+1)}"
    Product     = var.name
    Environment = var.environment
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  count             = length(var.private_subnets)

  tags = {
    Name                                                   = "${var.name}-private-subnet-eks-${var.environment}-${format("%03d", count.index+1)}",
    Product                                                = var.name
    Environment                                            = var.environment
    "kubernetes.io/cluster/${var.name}-ks-cluster-${var.environment}" = "shared"
    "kubernetes.io/role/internal-elb"                      = "1"
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.public_subnets)
  map_public_ip_on_launch = true

  tags = {
    Name                                                   = "${var.name}-public-subnet-eks-${var.environment}-${format("%03d", count.index+1)}",
    Product                                                = var.name
    Environment                                            = var.environment
    "kubernetes.io/cluster/${var.name}-ks-cluster-${var.environment}" = "shared",
    "kubernetes.io/role/elb"                               = "1"
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.name}-routing-table-public-eks-${var.environment}"
    Product     = var.name
    Environment = var.environment
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.name}-routing-table-private-eks-${var.environment}-${format("%03d", count.index+1)}"
    Product     = var.name
    Environment = var.environment
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_route" "private" {
  count                  = length(compact(var.private_subnets))
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# resource "aws_db_subnet_group" "main" {
#   name        = "${var.name}-subnet-group-eks-${var.environment}"
#   description = "skilrock RDS subnet group"
#   subnet_ids  = ["${element(aws_subnet.public.*.id,0)}", "${element(aws_subnet.public.*.id,1)}", "${element(aws_subnet.public.*.id,2)}"]
# }

# resource "aws_elasticache_subnet_group" "main" {
#   name        = "${var.name}-cache-subnet-group-eks-${var.environment}"
#   subnet_ids  = ["${element(aws_subnet.public.*.id,0)}", "${element(aws_subnet.public.*.id,1)}", "${element(aws_subnet.public.*.id,2)}"]
# }

/*resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.vpc-flow-logs-role.arn
  #log_destination = aws_cloudwatch_log_group.vpc.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}*/

/*resource "aws_cloudwatch_log_group" "vpc" {
  name              = "/aws/vpc/${var.name}-flow-eks-${var.environment}/flow"
  retention_in_days = 30

  tags = {
    Name        = "${var.name}-vpc-cloudwatch-log-group-eks-${var.environment}"
    Product     = var.name
    Environment = var.environment
  }
}*/

resource "aws_iam_role" "vpc-flow-logs-role" {
  name = "${var.name}-IAM-vpc-flow-logs-role-eks-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc-flow-logs-policy" {
  name = "${var.name}-IAM-vpc-flow-logs-policy-eks-${var.environment}"
  role = aws_iam_role.vpc-flow-logs-role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

output "id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public
}

output "private_subnets" {
  value = aws_subnet.private
}

#output "db_subnet_group" {
#  value = aws_db_subnet_group.main.id
#}

# output "cache_subnet_group" {
#   value = aws_elasticache_subnet_group.main.id
# }