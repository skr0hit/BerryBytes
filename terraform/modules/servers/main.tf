# AMI for Amazon Linux 2
data "aws_ami" "amazon_linux" {
  most_recent = true   # Gets the latest AMI version from AWS
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

# 1. Security Group for Bastion/Public Hosts
resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  vpc_id      = var.vpc_id
  description = "Allow SSH from my IP" 

  ingress {                     # This rule will allow me to SSH into the Bashtion host (Only my IP is allowed in Inbound Rules)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Security Group for Private Instance
resource "aws_security_group" "private_app" {
  name        = "private-app-sg"
  vpc_id      = var.vpc_id
  description = "Allow SSH from the bastion host"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Create 2 Public EC2 Instances (one will be our bastion)
resource "aws_instance" "public" {
  count                  = 2
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_ids[count.index]
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = "public-instance-${count.index + 1}"
  }
}

# 4. Create 1 Private EC2 Instance
resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = var.private_subnet_id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.private_app.id]

  tags = {
    Name = "private-instance"
  }
}