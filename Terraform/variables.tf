variable "region" {
default = "us-east-2"
}

variable "cluster_name" {
default = "k8s-prod.chybuz.com"
}

variable "state_bucket" {
default = "Chibuzo-k8s-bucket"
}

variable "availability_zones" {
default = ["us-east-2a", "us-east-2b"]
}

variable "vpc_cidr" {
default = "10.0.0.0/16"
}
