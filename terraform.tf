#######################################################################################
#  VARIABLES - the values are being sourced from the terraform.tfvars which resides in
#  the same directory as this file.
########################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {}
variable "region" {
    default = "eu-west-2"
}

# define CIDR and subnet
variable "network_address_space" {
    default = "10.1.0.0/16"
}
variable "subnet1_address_space" {
    default = "10.1.0.0/24"
}
# define tags and billing code for easier cost tracking
variable "billing_code_tag" {}
variable "environment_tag" {} 

######################################################################
# Providers - being sourced from terraform.tfvars
#######################################################################
  
provider "aws" {
   access_key = var.aws_access_key
   secret_key = var.aws_secret_key
   region     = var.region
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

data "aws_availability_zones" "available" {}

data "aws_ami" "aws-linux" {
   most_recent = true
   owners      = ["amazon"] 

  filter {
      name = "name"
      values = ["amzn-ami-hvm*"]
  } 

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
   
  filter {
      name = "virtualization-type"
      values = ["hvm"]
  }
}
  
#############################################################################
# RESOURCES
############################################################################

# NETWORKING - create VCP, subnet and internetGateway
resource "aws_vpc" "vpc" {
    cidr_block      = var.network_address_space
    enable_dns_hostnames = "true"

     tags = merge(local.common_tags, { Name = "${var.environment_tag}-vpc" })
}

resource "aws_internet_gateway" "igw" {
    vpc_id      = aws_vpc.vpc.id

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-igw" })
}

resource "aws_subnet" "subnet1" {
    cidr_block      = var.subnet1_address_space
    vpc_id          = aws_vpc.vpc.id
    map_public_ip_on_launch = "true"
    availability_zone   = data.aws_availability_zones.available.names[0]

    tags = merge(local.common_tags, { Name = "${var.environment_tag}-subnet1" })
}

# ROUTING - create routing table assign both subnet
resource "aws_route_table" "rtb" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = merge(local.common_tags, { Name = "${var.environment_tag}-rtb" })
}

resource "aws_route_table_association" "rta-subnet1" {
    subnet_id       = aws_subnet.subnet1.id
    route_table_id  = aws_route_table.rtb.id
}



# SECURITY GROUPS - local firewall allowing access to ports 22 and 443 for nginx webserver#

# Nginx security group
resource "aws_security_group" "nginx-sg" {
    name    = "nginx_sg"
    vpc_id  = aws_vpc.vpc.id

# SSH access from anywhere
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

# Http access from VPC #
    ingress {
        from_port   = 443 
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
 # outbound access for everyone 
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]

    }
    tags = merge(local.common_tags, { Name = "${var.environment_tag}-nginx" })

}

# INSTANCES #
resource "aws_instance" "nginx" {
    ami             = data.aws_ami.aws-linux.id
    instance_type   = "t2.micro"
    subnet_id       = aws_subnet.subnet1.id
    vpc_security_group_ids  = [aws_security_group.nginx-sg.id]
    key_name                = var.key_name

    connection {
        type        = "ssh"
        host        = self.public_ip
        user        = "ec2-user"
        private_key = file(var.private_key_path)

    }

    provisioner "file"  {
        source   = "os_hardening_script.sh"
        destination = "/tmp/os_hardening_script.sh"
   }

    provisioner "remote-exec" {
        inline = [
            "sudo yum update -y",
            "sudo yum install nginx -y",
            "sudo systemctl enable nginx --now",
            "echo '<html><head><title>Hello Joe!</title></head></html>' | sudo tee /usr/share/nginx/html/index.html ",
            "chmod +x /tmp/os_hardening_script.sh",
            "sudo /tmp/os_hardening_script.sh",
    ]
  }
  tags = merge(local.common_tags, { Name = "${var.environment_tag}-nginx1" })
}

##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
    value = aws_instance.nginx.public_dns
}
