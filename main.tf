######################################################################
# PROVIDER
#
# Credentials are intentionally not Terraform variables. The AWS provider
# picks them up from the standard credential chain (environment variables
# AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY, an AWS CLI profile, or an
# instance/role identity) - see README for setup.
#######################################################################

provider "aws" {
  region = var.region
}

#########################################################################
# LOCALS - tag each resource provisioned
#########################################################################
locals {
  common_tags = {
    BillingCode = var.billing_code_tag
    Environment = var.environment_tag
  }
}

###########################################################################
# DATA
###########################################################################

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#############################################################################
# RESOURCES
############################################################################

# NETWORKING - create VPC, subnet and internet gateway
resource "aws_vpc" "vpc" {
  cidr_block           = var.network_address_space
  enable_dns_hostnames = true

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-igw" })
}

resource "aws_subnet" "subnet1" {
  cidr_block              = var.subnet1_address_space
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-subnet1" })
}

# ROUTING - create routing table, assign to subnet
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-rtb" })
}

resource "aws_route_table_association" "rta-subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rtb.id
}

# SECURITY GROUP - local firewall for the nginx webserver.
# Rules are separate resources (not inline) so a rule change doesn't force
# recreation of the whole security group.
resource "aws_security_group" "nginx-sg" {
  name        = "nginx_sg"
  description = "Allows inbound SSH (restricted) and HTTPS, and all outbound traffic."
  vpc_id      = aws_vpc.vpc.id

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-nginx" })
}

resource "aws_vpc_security_group_ingress_rule" "nginx-ssh" {
  for_each = toset(var.ssh_allowed_cidr_blocks)

  security_group_id = aws_security_group.nginx-sg.id
  description       = "SSH from trusted CIDRs only"
  cidr_ipv4         = each.value
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "nginx-https" {
  security_group_id = aws_security_group.nginx-sg.id
  description       = "HTTPS from anywhere (public webserver)"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "nginx-egress" {
  security_group_id = aws_security_group.nginx-sg.id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# INSTANCES #
resource "aws_instance" "nginx" {
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  key_name               = var.key_name

  # Bootstrap (nginx install + OS hardening) runs via cloud-init on first
  # boot instead of SSH provisioners - idempotent-ish, doesn't need SSH
  # connectivity from the machine running `terraform apply`, and doesn't
  # print command output (which could include secrets) to the operator's
  # terminal/CI logs.
  user_data = templatefile("${path.module}/scripts/user_data.sh.tftpl", {
    environment_tag = var.environment_tag
  })
  user_data_replace_on_change = true

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-nginx1" })
}
