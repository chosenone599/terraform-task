#######################################################################################
#  VARIABLES - values are sourced from terraform.tfvars (copy terraform.tfvars.example
#  to terraform.tfvars and fill it in; that file is gitignored and must never be
#  committed). AWS credentials are intentionally NOT variables here - see README.
#######################################################################################

variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-west-2"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair, used for SSH access to the instance."
  type        = string
}

variable "network_address_space" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet1_address_space" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.1.0.0/24"
}

variable "ssh_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the instance over SSH (port 22). Restrict this to known/trusted source IPs - do not use 0.0.0.0/0 outside of short-lived, disposable test environments."
  type        = list(string)

  validation {
    condition     = !contains(var.ssh_allowed_cidr_blocks, "0.0.0.0/0")
    error_message = "ssh_allowed_cidr_blocks must not include 0.0.0.0/0. Restrict SSH to known source IPs."
  }
}

variable "billing_code_tag" {
  description = "Billing code applied to all resources for cost tracking/reconciliation."
  type        = string
}

variable "environment_tag" {
  description = "Environment name applied to all resources (also used in the nginx greeting page)."
  type        = string
}
