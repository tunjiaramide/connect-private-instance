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
  region = "us-east-1"
}


# Create a VPC
resource "aws_vpc" "first-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  tags = {
    Name = "first-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "first-gw" {
  vpc_id = aws_vpc.first-vpc.id
}


# Create Public Route Table
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.first-gw.id
  }
}


# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.first-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}


# Associate public subnet to route table
resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}


# Create Elastic IP
resource "aws_eip" "ip" {
  vpc = true
  tags = {
    Name = "test-elasticIP"
  }
}


# Create nat Gateway and launch in a public subnet
resource "aws_nat_gateway" "test_nat" {
  allocation_id = aws_eip.ip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "test_nat"
  }

}


# Create Private Route Table
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.test_nat.id
  }
}

# Create Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.first-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private_subnet"
  }
}

# Associate private subnet to route table
resource "aws_route_table_association" "private-association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route.id
}


# Launch instance into private
resource "aws_instance" "private_web" {
  ami                  = "ami-0889a44b331db0194" # Amzon linux 2023 comes pre-installed with SSH agent
  instance_type        = "t2.micro"
  subnet_id            = aws_subnet.private_subnet.id
  iam_instance_profile = "AccessSSM_Role"

  tags = {
    Name = "private-web"
  }

}

