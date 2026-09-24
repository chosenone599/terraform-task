# terraform-task

Project Name:
------------------------------------------------------------------------------------------------------------------------------------
Terrraform EC2 Webserver test deployment


Description:
------------------------------------------------------------------------------------------------------------------------------------
This project contains some terraform files which deploys an enviroment on AWS containing a EC2 linux instance running nginx web server.


The project contains the following files:

- main.tf                       : Provider, data sources, and the VPC/subnet/routing/security-group/instance resources. All AWS resources are tagged with a description and a billing code reference which can be reconciled against a project
- variables.tf                  : Typed input variable declarations (no default credentials or secrets)
- outputs.tf                    : Terraform outputs
- versions.tf                   : Pinned Terraform/provider version requirements and remote-backend guidance
- terraform.tfvars.example      : Template for your local terraform.tfvars (resource tagging info, key pair name, allowed SSH CIDRs)
- scripts/user_data.sh.tftpl    : Instance bootstrap script (nginx install + OS hardening), run by cloud-init on first boot


Getting Started & Documentation
------------------------------------------------------------------------------------------------------------------------------------
Documentation is available on the Terraform website:

- [Intro](https://www.terraform.io/intro/index.html)
- [Docs](https://www.terraform.io/docs/index.html)


If you're new to Terraform and want to get started creating infrastructure, please check out our Getting Started guides on HashiCorp's learning platform. 

Installation:
-------------------------------------------------------------------------------------------------------------------------------------
- Clone this repository
- Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in `key_name`, `ssh_allowed_cidr_blocks` (restrict this to your own IP - never `0.0.0.0/0`), `environment_tag`, and `billing_code_tag`. `terraform.tfvars` is gitignored - never commit it.
- Provide AWS credentials via the standard AWS provider credential chain rather than in any Terraform file: environment variables (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN`), an AWS CLI profile (`AWS_PROFILE`), or an assumed/instance role.
- From your terraform console run the terraform (init, plan, apply) commands to deploy the environment on AWS
- Local state is used here for solo experimentation only; before sharing this environment with a team, configure the remote backend documented in `versions.tf`.




Results
-------------------------------------------------------------------------------------------------------------------------------------
The deployment will:
- spin up a Linux EC2 instance from the latest available Amazon Linux ami
- setup a single public subnet and routing table
- setup a Security Group which allows only https (443, from anywhere) and ssh (22, only from `ssh_allowed_cidr_blocks`). This acts as the local firewall.
- setup an internet gateway for connectivity over the internet
- the EC2 instance will be launched with a cloud-init `user_data` script (`scripts/user_data.sh.tftpl`) that updates O/S packages, installs nginx, writes a "greeting" index.html page, and applies the OS hardening steps (removes unnecessary services, locks down cron) - all on first boot, with no SSH access from the machine running `terraform apply` required.
- the output of the terraform apply will be the public dns address for the EC2 instance which when accessed via a http browser will display a "greeting" message




