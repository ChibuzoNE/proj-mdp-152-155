variable "aws_region" {
description = "AWS region to deploy resources"
type        = string
default     = "us-east-2"
}

variable "instance_type" {
description = "EC2 instance type"
type        = string
default     = "t2.medium"
}

variable "key_name" {
description = "Key pair name for EC2 instances"
type        = string
default     = "first-instance"
}

variable "vpc_cidr_block" {
description = "CIDR block for the VPC"
type        = string
default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
description = "CIDR block for the public subnet"
type        = string
default     = "10.0.1.0/24"
}

variable "availability_zone" {
description = "Availability zone for the subnet"
type        = string
default     = "us-east-2a"
}

