resource "aws_security_group" "skilrock_sg" {
  name        = "skilrock-common-sg-eks-${var.environment}"
  description = "Allow kubernetes custer traffic only"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    self             = true
  }
  

  tags = {
    Product = "skilrock"
    Environment = var.environment
  }
}

output "skilrock_common_sg_eks" {
  description = "ID of the skilrock Security Group ID "
  value       = aws_security_group.skilrock_sg.id
}
