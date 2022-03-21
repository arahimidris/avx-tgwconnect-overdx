variable "vpc_cidr" {}
variable "aws_region" {}
variable "name" {}
variable "aws_account_name" {}
variable "create_ec2" {}
variable "iam_instance_profile" {}
variable "vm_admin_password" {}
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "amzn2-ami-hvm*"
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  name            = var.name
  cidr            = var.vpc_cidr
  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = [cidrsubnet(var.vpc_cidr, 4, 0), cidrsubnet(var.vpc_cidr, 4, 1)]
  # public_subnets  = [cidrsubnet(var.vpc_cidr, 4, 2), cidrsubnet(var.vpc_cidr, 4, 3)]
  intra_subnets                 = [cidrsubnet(var.vpc_cidr, 4, 4), cidrsubnet(var.vpc_cidr, 4, 5)]
  intra_subnet_suffix           = "tgw"
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${var.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${var.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${var.name}-default" }
  enable_dns_hostnames          = true
  enable_dns_support            = true

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  #   enable_flow_log                      = true
  #   create_flow_log_cloudwatch_log_group = true
  #   create_flow_log_cloudwatch_iam_role  = true
  #   flow_log_max_aggregation_interval    = 60
}




################################################################################
# VPC Endpoints Module
################################################################################

module "vpc_endpoints" {
  source             = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  count              = var.create_ec2 ? 1 : 0
  vpc_id             = module.vpc.vpc_id
  security_group_ids = [aws_security_group.this_vpc_endpoint.id]
  subnet_ids         = module.vpc.private_subnets
  endpoints = {
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      # subnet_ids          = module.vpc_nonprod.private_subnets
      tags = { Name = "${var.name}-ssm-endpoint" }
    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
      # subnet_ids          = module.vpc_nonprod.private_subnets
      tags = { Name = "${var.name}-ssmmessages-endpoint" }
    },
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = true
      # subnet_ids          = module.vpc_nonprod.private_subnets
      tags = { Name = "${var.name}-ec2messages-endpoint" }
    }
  }
}
################################################################################
# Supporting Resources
################################################################################


resource "aws_security_group" "this_vpc_endpoint" {
  name        = "${var.name}-sg-vpcendpoint"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  tags = { Name = "${var.name}-sg-endpoint" }
}


# ---------------------------------------------------------------------------------------------------------------------
# Create ec2
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "this_ec2" {
  count       = var.create_ec2 ? 1 : 0
  name        = "${var.name}-ec2-sg"
  description = "Allow all traffic from VPCs inbound and all outbound"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.name}-sg-ec2" }
}

resource "aws_instance" "this" {
  count                       = var.create_ec2 ? 1 : 0
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.micro"
  iam_instance_profile        = var.iam_instance_profile
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.this_ec2[0].id]
  associate_public_ip_address = false
  depends_on                  = [module.vpc_endpoints]

  user_data = <<EOF
#!/bin/bash
sudo sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
sudo systemctl restart sshd
echo ec2-user:${var.vm_admin_password} | sudo chpasswd
EOF

  tags = { Name = "${var.name}-ec2" }
}

output "ec2_ip" {
  value = var.create_ec2 ? aws_instance.this[0].private_ip : "null"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "intra_subnets" {
  value = module.vpc.intra_subnets
}
