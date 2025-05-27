provider "aws" {
region = var.region
}

# Create S3 Bucket for KOPS State
resource "aws_s3_bucket" "kops_state_store" {
bucket = var.state_bucket

versioning {
enabled = true
}

tags = {
Name = "KOPS State Store"
}
}

# Create VPC
resource "aws_vpc" "kops_vpc" {
cidr_block = var.vpc_cidr

tags = {
Name = "kops-vpc"
}
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
vpc_id = aws_vpc.kops_vpc.id

tags = {
Name = "kops-igw"
}
}

# Create Public Subnets
resource "aws_subnet" "public_subnets" {
count             = length(var.availability_zones)
vpc_id            = aws_vpc.kops_vpc.id
cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
availability_zone = var.availability_zones[count.index]

tags = {
Name = "kops-public-subnet-${count.index}"
"kubernetes.io/role/elb" = "1"
}
}

# Route Table for Internet Access
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

# IAM Role for EC2 Instances
resource "aws_iam_role" "kops_ec2_role" {
name = "MykubernetesRole"

assume_role_policy = jsonencode({
Version = "2012-10-17",
Statement = [{
    Effect = "Allow",
    Principal = {
    Service = "ec2.amazonaws.com"
    },
    Action = "sts:AssumeRole"
}]
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


