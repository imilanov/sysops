#https://sammeechward.com/terraform-vpc-subnets-ec2-and-more/
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
  availability_zone = "us-east-1a"

  tags = {
    Name = "SysOps Public Subnet"
  }
}

resource "aws_subnet" "sysops_private_subnet" {
  vpc_id            = aws_vpc.sysops_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

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
}

#Create security groups to allow specific traffic
resource "aws_security_group" "sysops_web_sg" {
  name   = "SysOps HTTP and SSH"
  vpc_id = aws_vpc.sysops_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Instance EC2
resource "aws_instance" "sysops_web_instance" {
  ami           = "ami-05fa00d4c63e32376"
  instance_type = "t2.micro"
  key_name      = "sysops"

  subnet_id                   = aws_subnet.sysops_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.sysops_web_sg.id]
  associate_public_ip_address = true

  # Web server
  user_data = <<-EOF
  #!/bin/bash -ex

  amazon-linux-extras install nginx1 -y
  echo "<h1>$(curl https://api.kanye.rest/?format=text)</h1>" >  /usr/share/nginx/html/index.html 
  systemctl enable nginx
  systemctl start nginx
  EOF

  tags = {
    "Name" : "Sys Ops Web Server"
  }


}