provider "aws" {
  region = "us-west-2"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable env_prefix {}
variable avail_zone {}
variable my_ip {}
variable instance_type {}
variable public_key_path {}

resource "aws_key_pair" "ssh-key" {
    key_name = "app-key-pair"
    public_key = file(var.public_key_path)
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = "us-west-2a"
  tags = {
    Name: "${var.env_prefix}-subnet-1"
  }
}

 resource "aws_route_table" "myapp-route-aws_route_table" {
    vpc_id = aws_vpc.myapp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name = "${var.env_prefix}-rtb"
    }
 }

 resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name = "${var.env_prefix}-igw"
    }
 }

 resource "aws_route_table_association" "a-rtb-subnet" {
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-route-aws_route_table.id
 }

 resource "aws_default_security_group" "default-sg" {
   vpc_id = aws_vpc.myapp-vpc.id
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [var.my_ip]# Add your IP address
      }
    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        name: "${var.env_prefix}-sg"
    }
 }


data "aws_ami" "latest-ami" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
 }

 output "aws_ami" {
   value = data.aws_ami.latest-ami.id
 }

output "ec2_public_ip" {
    value = aws_instance.myapp-server.public_ip
}

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-ami.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.avail_zone
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    user_data = file("entrypoint.sh")
    
    tags = {
        Name = "${var.env_prefix}-server"
    }
 }

