provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# VPC
resource "aws_vpc" "sysops_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "sysops_VPC"
  }
}

#Subnet
resource "aws_subnet" "sysops_public_subnet" {
  vpc_id            = aws_vpc.sysops_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "1a"

  tags = {
    Name = "SysOps Public Subnet"
  }
}

resource "aws_subnet" "sysops_private_subnet" {
  vpc_id            = aws_vpc.sysops_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "1a"

  tags = {
    Name = "SysOps Private Subnet"
  }
}

# IGW
resource "aws_internet_gateway" "sysops_igw" {
  vpc_id = aws_vpc.sysops_vpc.id

  tags = {
    Name = "SysOps Internet Gateway"
  }
}