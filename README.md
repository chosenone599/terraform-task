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
- terraform.tf           : Terraform deployment file which deploys and configures the VPC with a Linux EC2 nginx instance, one subnet, a security group. All the aws rewsources are also tagged with a description and a billing code reference which can be reconciled against a project 
- terraform.tfvars      : Variables file which AWS credentials and resource tagging info gets added to.


Getting Started & Documentation
------------------------------------------------------------------------------------------------------------------------------------
Documentation is available on the Terraform website:

- [Intro](https://www.terraform.io/intro/index.html)
- [Docs](https://www.terraform.io/docs/index.html)


If you're new to Terraform and want to get started creating infrastructure, please check out our Getting Started guides on HashiCorp's learning platform. 

Installation:
-------------------------------------------------------------------------------------------------------------------------------------
- Download the 3 files in this Git repository
- Edit the terraform.tfvars and enter the required AWS credentials information
- From your terraform console run the terraform  (init, plan, apply) commands to deploy the enivonment on AWS




Results
-------------------------------------------------------------------------------------------------------------------------------------
The deployment will:
- spin up a Linux EC2 instance from the latest available Amazon Linux ami
- setup a single public subnet and routing table
- setup a Security Group which allows only https (443) and ssh (22).  This acts as the local firewall.
- setup an internet gateway for connectivity over the internet
- the EC2 instance will be lauched and then updated with latest O/S packages
- nginx will then be installed and a "greeting" text written to the default index.html page
- the os_hardening_script.sh will be copied to the EC2 instances filesystem and executed, post-build. The decision to harden post-build is to account for a scenario where a hardend pre-baked machine image might negate the ability to install or configure certain software.
- the output of the terraform apply will be the public dns address for the EC2 instance which when accessed via a http browser will display a "greeting" message




