# provider 
# ###############################################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.8.0"
    }
  }

  backend "s3" {
    bucket = ""
    key    = "terraform.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    endpoints = { s3 = "" }
  }
}

provider "aws" {
  profile = ""
  region  = ""
}

# resource
# ###############################################################################

# default security group allow 22

resource "aws_security_group" "group-default-allow-ssh" {
  name        = "group-default-allow-ssh"
  vpc_id      = data.aws_vpc.vpc-uswest2-default.id

  tags = {
    Name = "group-default-allow-ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress-default-allow-ssh" {
  security_group_id = aws_security_group.group-default-allow-ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "egress-default-allow-all" {
  security_group_id = aws_security_group.group-default-allow-ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

data "aws_vpc" "vpc-uswest2-default" {
  id = "vpc"
}

data "aws_subnets" "subnets-uswest2-default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.vpc-uswest2-default.id]
  }
}

data "aws_ami" "ubuntu-2404-lts" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_eip" "eip-00" {
  instance = aws_instance.ec2-00.id
  domain   = "vpc"
  tags = {
    Name = "eip-00"
  }
}

resource "aws_eip_association" "eip_assoc-00" {
  instance_id   = aws_instance.ec2-00.id
  allocation_id = aws_eip.eip-00.id
}

# terraform plan befor terraform apple and change ami
resource "aws_instance" "ec2-00" {
  ami           = data.aws_ami.ubuntu-2404-lts.id
  instance_type = "c5.2xlarge"

  tags = {
    Name = "ec2-00"
  }

  force_destroy = false
  monitoring = true

  root_block_device {
    volume_size = 1024
    volume_type = "gp3"
  }

  key_name = "default"
  vpc_security_group_ids = [aws_security_group.group-default-allow-ssh.id]

  user_data_base64 = "cloud_init base64"
}