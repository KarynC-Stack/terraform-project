provider "aws" {
  region = "us-west-2"
}

variable "subnet_cidr_block" {
  description = "The CIDR block for the subnet"
  type = list(string)
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
}

resource "aws_vpc" "development-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "development"
    vpc_env: "development"
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id = aws_vpc.development-vpc.id
  cidr_block = var.subnet_cidr_block[0]
  availability_zone = "us-west-2a"
  tags = {
    Name: "development-subnet-1"
  }
}

data "aws_vpc" "existing_vpc" {
  default = true
  }
  
  resource "aws_subnet" "dev-subnet-2" {
    vpc_id=data.aws_vpc.existing_vpc.id
    cidr_block = var.subnet_cidr_block[1]
    availability_zone = "us-west-2b"
    tags = {
        Name: "development-subnet-2"
    }
  }

output "dev-vpc-id" {
  value = aws_vpc.development-vpc.id
}

output "dev-subnet-id" {
  value = aws_subnet.dev-subnet-1
}