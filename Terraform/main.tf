provider "aws" {
region = var.aws_region
}

# ✅ Dynamically fetch latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
most_recent = true
owners      = ["amazon"]

filter {
name   = "name"
values = ["amzn2-ami-hvm-*-x86_64-gp2"]
}

filter {
name   = "virtualization-type"
values = ["hvm"]
}
}

resource "aws_vpc" "main" {
cidr_block           = var.vpc_cidr_block
enable_dns_support   = true
enable_dns_hostnames = true
tags = {
Name = "main-vpc"
}
}

resource "aws_internet_gateway" "igw" {
vpc_id = aws_vpc.main.id
tags = {
Name = "main-igw"
}
}

resource "aws_subnet" "public" {
vpc_id                  = aws_vpc.main.id
cidr_block              = var.subnet_cidr_block
availability_zone       = var.availability_zone
map_public_ip_on_launch = true
tags = {
Name = "public-subnet"
}
}

resource "aws_route_table" "public" {
vpc_id = aws_vpc.main.id

route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.igw.id
}

tags = {
Name = "public-route-table"
}
}

resource "aws_route_table_association" "public" {
subnet_id      = aws_subnet.public.id
route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "instance_sg" {
name        = "instance-security-group"
description = "Allow SSH and HTTP traffic"
vpc_id      = aws_vpc.main.id

ingress {
description = "SSH"
from_port   = 22
to_port     = 22
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

ingress {
description = "HTTP"
from_port   = 8080
to_port     = 8080
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
Name = "instance-sg"
}
}

resource "aws_instance" "build_server" {
ami                         = data.aws_ami.amazon_linux.id
instance_type               = var.instance_type
key_name                    = var.key_name
subnet_id                   = aws_subnet.public.id
vpc_security_group_ids      = [aws_security_group.instance_sg.id]
associate_public_ip_address = true

metadata_options {
http_endpoint = "enabled"
http_tokens   = "required"
}

root_block_device {
encrypted   = true
volume_size = 20
volume_type = "gp3"
}

user_data = <<-EOF
            #!/bin/bash
            yum update -y
            echo "Build server is ready" > /var/www/html/index.html
            EOF

tags = {
Name = "Build-Server"
}
}

resource "aws_instance" "tomcat_server" {
ami                         = data.aws_ami.amazon_linux.id
instance_type               = var.instance_type
key_name                    = var.key_name
subnet_id                   = aws_subnet.public.id
vpc_security_group_ids      = [aws_security_group.instance_sg.id]
associate_public_ip_address = true

metadata_options {
http_endpoint = "enabled"
http_tokens   = "required"
}

root_block_device {
encrypted   = true
volume_size = 20
volume_type = "gp3"
}

user_data = <<-EOF
            #!/bin/bash
            yum update -y
            echo "Tomcat server placeholder" > /var/www/html/index.html
            EOF

tags = {
Name = "Tomcat-Server"
}
}

resource "aws_instance" "jenkins_docker" {
ami                         = data.aws_ami.amazon_linux.id
instance_type               = var.instance_type
key_name                    = var.key_name
subnet_id                   = aws_subnet.public.id
vpc_security_group_ids      = [aws_security_group.instance_sg.id]
associate_public_ip_address = true

metadata_options {
http_endpoint = "enabled"
http_tokens   = "required"
}

root_block_device {
encrypted   = true
volume_size = 20
volume_type = "gp3"
}

user_data = <<-EOF
            #!/bin/bash
            yum update -y
            echo "Build server is ready" > /var/www/html/index.html
            EOF

tags = {
Name = "jenkins_docker"
}
}

resource "aws_instance" "k8s_master" {
ami           = "ami-0c55b159cbfafe1f0"
instance_type = "t2.medium"
key_name      = "first-instance"
vpc_security_group_ids = [aws_security_group.k8s_sg.id]
subnet_id     = aws_subnet.subnet_a.id

tags = {
Name = "K8s-Master"
}
}

resource "aws_instance" "k8s_worker" {
ami           = "ami-0c55b159cbfafe1f0"
instance_type = "t2.medium"
key_name      = "first-instance"
vpc_security_group_ids = [aws_security_group.k8s_sg.id]
subnet_id     = aws_subnet.subnet_b.id

tags = {
Name = "K8s-Worker"
}
}

resource "aws_vpc" "k8s_vpc" {
cidr_block = "10.0.0.0/16"
enable_dns_support = true
enable_dns_hostnames = true
}

resource "aws_subnet" "subnet_a" {
vpc_id            = aws_vpc.main.id
cidr_block        = "10.0.20.0/24"
availability_zone = "us-east-2a"
}

resource "aws_subnet" "subnet_b" {
vpc_id            = aws_vpc.main.id
cidr_block        = "10.0.30.0/24"
availability_zone = "us-east-2b"
}

resource "aws_security_group" "k8s_sg" {
name        = "k8s-sg"
description = "Allow Kubernetes ports"
vpc_id      = aws_vpc.main.id

ingress {
from_port   = 22
to_port     = 22
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

ingress {
from_port   = 6443
to_port     = 6443
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

ingress {
from_port   = 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    34,1          Top
to_port     = 0
protocol    = "-1"
cidr_blocks = ["10.0.0.0/16"]
}

egress {
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}
