locals {
  common_user_data = <<-EOF
    #!/bin/bash
    snap install amazon-ssm-agent --classic
    systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
    systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
    EOF
}


module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "oidc-instance"

  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile_oidc_module.name
  ami                         = "ami-05db0e60504db9e1b"
  vpc_security_group_ids      = [aws_security_group.ssm_and_http.id]
  associate_public_ip_address = true
  user_data                   = local.common_user_data
  tags = {
    Terraform   = "true"
    Environment = "oidc"
  }
}

module "ec2_private_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "private-oidc-instance"

  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.private_subnets[0]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile_oidc_module.name
  ami                         = "ami-05db0e60504db9e1b"
  vpc_security_group_ids      = [aws_security_group.ssm_only.id]
  associate_public_ip_address = false
  user_data                   = local.common_user_data
  tags = {
    Terraform   = "true"
    Environment = "oidc"
  }
}

resource "aws_iam_role" "ec2_ssm_role_module" {
  name = "EC2_SSM_Role_OIDC_module"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role_module.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile_oidc_module" {
  name = "EC2_SSM_Profile_OIDC_module"
  role = aws_iam_role.ec2_ssm_role_module.name
}

resource "aws_security_group" "ssm_only" {
  name        = "ssm_only_sg"
  description = "Security group for instances managed by SSM without inbound access"
  vpc_id      = module.vpc.vpc_id
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ssm-only"
  }
}

resource "aws_security_group" "ssm_and_http" {
  name        = "ssm_and_http"
  description = "Security group for instances managed by SSM with inbound access for http"
  vpc_id      = module.vpc.vpc_id
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ssm-http"
  }
}