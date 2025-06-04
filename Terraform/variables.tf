variable "region" {
default = "us-east-1"
}

variable "cluster_name" {
default = "k8s-prod.chybuz.com"
}

variable "state_bucket" {
default = "chybuz-k8s-bucket"
}

variable "availability_zones" {
default = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
default = "10.0.0.0/16"
}
