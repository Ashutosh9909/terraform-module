terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "ap-south-1"
  profile = "aws-demo"
}

data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu" {
  owners      = ["308897073973"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "template_file" "init" {
  template = "${file("${path.module}/userdata.tpl")}"
}

resource "aws_instance" "my-test-instance" {

  count                   = 2
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = var.instance_type
  key_name                = "mykeypair"
  vpc_security_group_ids  = [var.security_group]
  subnet_id               = "${element(var.subnets, count.index)}"
  user_data               = data.template_file.init.rendered

  tags = {
    Name = "my-instance-${count.index + 1}"
  }
}