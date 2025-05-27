output "s3_bucket_name" {
value = aws_s3_bucket.kops_state_store.bucket
}

output "vpc_id" {
value = aws_vpc.kops_vpc.id
}

output "subnet_ids" {
value = [for subnet in aws_subnet.public_subnets : subnet.id]
}

# Outputs
output "k8s_master_ip" {
value = aws_instance.k8s_master.public_ip
}

output "k8s_worker_ip" {
value = aws_instance.k8s_worker.public_ip
}