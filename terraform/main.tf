terraform/main.tf

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Generate a key pair for SSH access
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Persist the private key locally for the user
resource "local_file" "private_key" {
  filename = "${path.module}/${var.key_name}.pem"
  content  = tls_private_key.ssh_key.private_key_pem
  file_permission = "0600"
}

module "vpc" {
  source = "./modules/vpc"
  cidr_block = var.vpc_cidr
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
}

# Data source for Ubuntu 22.04 AMI

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

module "ec2" {
  source = "./modules/ec2"
  instance_name = var.instance_name
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnets[0]
  sg_ids        = [module.security_group.default_sg_id]
  user_data     = file("${path.module}/user_data.sh")
  key_name      = var.key_name
  depends_on = [aws_key_pair.ssh]
}

output "instance_public_ip" {
  value = module.ec2.public_ip
}

output "instance_public_dns" {
  value = module.ec2.public_dns
}

output "private_key_path" {
  value = local_file.private_key.filename
}
