provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source               = "./modules/vpc-network"
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

module "ec2_instances" {
  source              = "./modules/servers"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_id   = module.vpc.private_subnet_ids[0] # Use the first private subnet
  ssh_key_name        = var.ssh_key_name
  my_ip               = var.my_ip
}