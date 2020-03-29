# terraform-task

Project Name:
------------------------------------------------------------------------------------------------------------------------------------
Terrraform EC2 instance deployment


Description:
------------------------------------------------------------------------------------------------------------------------------------
A terraform file which deploys a single EC2 linux instance to AWS.
As part of the deployment, nginx will also be installed.

The project contains the following three files:

- os_hardening_script.sh : Linux OS hardening script which disables some uncessary services and secures cron
- terraform.tf           : Terraform deployment file which deploys and configures the VPC with a Linux EC2 nginx instance
- terraform.tfvars      : Variables file which AWS credentials and resource tagging info gets added to.


Installation:
-------------------------------------------------------------------------------------------------------------------------------------

