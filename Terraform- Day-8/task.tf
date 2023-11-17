terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

}

# Create 3 subnets in different AZs
resource "aws_subnet" "subnet_a" {
  count = 3
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = element(["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"], count.index)
  availability_zone = element(["ap-south-1a", "ap-south-1b", "ap-south-1c"], count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-${count.index}"
  }
}
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id
  name        = "my_security_group"
  description = "Example security group for demonstration purposes"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_security_group"
  }
}
# Launch EC2 instances in two different subnets
resource "aws_instance" "instance_a" {
  count = 2
  ami = "ami-02a2af70a66af6dfb"
  instance_type = "t2.micro"
  subnet_id = element(aws_subnet.subnet_a[*].id, count.index % 3)
  security_groups = [aws_security_group.my_security_group.id]
  key_name = "Devopskeypair"
  tags = {
    Name = "instance-${count.index}"
  }

}
# Output the public IP addresses of the instances
output "instance_ips" {
  value = aws_instance.instance_a[*].public_ip
}
