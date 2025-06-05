provider "aws" {
  region = var.region
}

# -----------------------
# Data Source: Amazon Linux 2 AMI (via SSM Parameter Store)
# -----------------------
data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# -----------------------
# S3 Bucket for KOPS State Store
# -----------------------
resource "aws_s3_bucket" "kops_state_store" {
  bucket = var.state_bucket

  tags = {
    Name = "KOPS State Store"
  }
}

resource "aws_s3_bucket_versioning" "kops_state_versioning" {
  bucket = aws_s3_bucket.kops_state_store.id

  versioning_configuration {
    status = "Enabled"
  }
}

# -----------------------
# VPC and Networking
# -----------------------
resource "aws_vpc" "kops_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "kops-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.kops_vpc.id

  tags = {
    Name = "kops-igw"
  }
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.kops_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                     = "kops-public-subnet-${count.index}"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.kops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "kops-public-rt"
  }
}

resource "aws_route_table_association" "rt_assoc" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# -----------------------
# IAM Role for EC2
# -----------------------
resource "aws_iam_role" "kops_ec2_role" {
  name = "MykubernetesRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "attach_node_policy" {
  role       = aws_iam_role.kops_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.kops_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "kops_instance_profile" {
  name = "chibuzo"
  role = aws_iam_role.kops_ec2_role.name
}

# -----------------------
# Dedicated Subnets for EC2 Master and Worker Nodes
# -----------------------
resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.kops_vpc.id
  cidr_block              = "10.0.20.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ec2-subnet-a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.kops_vpc.id
  cidr_block              = "10.0.30.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "ec2-subnet-b"
  }
}

# -----------------------
# Security Group
# -----------------------
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-sg"
  description = "Allow Kubernetes and SSH"
  vpc_id      = aws_vpc.kops_vpc.id

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
    from_port   = 0
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

# -----------------------
# EC2 Instances for Kubernetes Master and Worker Nodes
# -----------------------
resource "aws_instance" "k8s_master" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type          = "t2.micro"
  key_name               = "my-instance"
  subnet_id              = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.kops_instance_profile.name

  tags = {
    Name = "K8s-Master"
  }
}

resource "aws_instance" "k8s_worker" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type          = "t2.micro"
  key_name               = "my-instance"
  subnet_id              = aws_subnet.subnet_b.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.kops_instance_profile.name

  tags = {
    Name = "K8s-Worker"
  }
}
