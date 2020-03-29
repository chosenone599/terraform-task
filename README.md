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


Getting Started & Documentation
------------------------------------------------------------------------------------------------------------------------------------
Documentation is available on the Terraform website:

- [Intro](https://www.terraform.io/intro/index.html)
- [Docs](https://www.terraform.io/docs/index.html)


If you're new to Terraform and want to get started creating infrastructure, please check out our Getting Started guides on HashiCorp's learning platform. 

Installation:
-------------------------------------------------------------------------------------------------------------------------------------
Download the 3 files in this Git repository
Edit the terraform.tfvars and enter the required credentials information

From your terraform console run the terraform commands (init, plan, apply)




Results
-------------------------------------------------------------------------------------------------------------------------------------
The deployment will:
- spin up the latest amazon linux EC2 instance
- setup a security group which allows https (443) and ssh (22)
- setup an internet gateway
- setup a single subnet routing table
- the EC2 instance will be started updated with latest packages
- and nginx will be installed and a header writen to the default index.html page
- the os_hardening_script.sh will be copied to the EC2 instances filesystem and executed

