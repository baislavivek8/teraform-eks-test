data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "sonar-sg" {
  name              = "${var.name}-${var.environment}-sonar-sg"
  description       = "${var.name}-${var.environment}-sonar-security group"
  vpc_id = var.vpc_id
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 9000
    protocol = "tcp"
    to_port = 9000
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "sonar" {
  ami                           = "ami-079b5e5b3971bd10d"
  instance_type                 = var.instance_class
  subnet_id                     = var.private_subnets[0].id
  //subnet_id                     = var.public_subnets[0].id
  //iam_instance_profile          = "${aws_iam_instance_profile.ec2_ecr_profile.name}"
  key_name                      = var.pemkey
  vpc_security_group_ids        = [aws_security_group.sonar-sg.id]
#   user_data = <<EOF
# #!/bin/bash
# sudo apt-get update -y
# sudo apt install docker.io -y
# sudo snap install docker -y
# sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
# echo "$(<kubectl.sha256) kubectl" | sha256sum --check
# sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# ################ helm ###############
# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
# chmod 700 get_helm.sh
# ./get_helm.sh
# sudo apt install unzip
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install
# EOF
  root_block_device {
    delete_on_termination = true
    volume_size = 10
    volume_type = "gp2"
  }
  tags = {
    Project = "${var.name}-${var.environment}"
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ami, tags]
  }
  depends_on = [ aws_security_group.sonar-sg ]
}