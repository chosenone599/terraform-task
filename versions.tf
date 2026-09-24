terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local state is fine for solo, throwaway experimentation, but never for
  # team or production use (no locking, no encryption, no audit trail).
  # Before sharing this environment, configure a remote backend, e.g.:
  #
  # backend "s3" {
  #   bucket       = "my-terraform-state"
  #   key          = "poc/nginx-webserver/terraform.tfstate"
  #   region       = "eu-west-2"
  #   encrypt      = true
  #   use_lockfile = true # native S3 locking, Terraform 1.10+
  # }
}
