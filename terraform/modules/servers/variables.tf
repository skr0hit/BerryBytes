variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for EC2 instances"
  type        = list(string)
}

variable "private_subnet_id" {
  description = "A single private subnet ID for the private EC2 instance"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair to use"
  type        = string
}

variable "my_ip" {
  description = "Your local IP address for SSH access"
  type        = string
}