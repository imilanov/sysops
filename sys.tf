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


#Create a route table for a public subnet
resource "aws_route_table" "sysops_public_rt" {
  vpc_id = aws_vpc.sysops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sysops_igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.sysops_igw.id
  }

  tags = {
    Name = "SysOps Public Route Table"
  }
}
#Resource: aws_route_table_association
resource "aws_route_table_association" "_sysops_public_1_rt_a" {
  subnet_id      = aws_subnet.sysops_public_subnet.id
  route_table_id = aws_route_table.sysops_public_rt.id
}#https://sammeechward.com/terraform-vpc-subnets-ec2-and-more/