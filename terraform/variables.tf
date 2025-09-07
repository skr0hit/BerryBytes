variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "ssh_key_name" {
  description = "The name of your EC2 key pair for SSH access"
  type        = string
}

variable "my_ip" {
  description = "Your local IP address to allow for SSH access"
  type        = string
}