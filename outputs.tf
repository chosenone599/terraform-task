##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
  description = "Public DNS name of the nginx EC2 instance."
  value       = aws_instance.nginx.public_dns
}
