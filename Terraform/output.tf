output "build_server_public_ip" {
description = "Public IP of the Build Server (Maven)"
value       = aws_instance.build_server.public_ip
}

output "tomcat_server_public_ip" {
description = "Public IP of the Tomcat Runtime Server"
value       = aws_instance.tomcat_server.public_ip
}

output "build_server_ssh_command" {
description = "SSH command to connect to the Build Server"
value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.build_server.public_ip}"
}

output "tomcat_server_ssh_command" {
description = "SSH command to connect to the Tomcat Server"
value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.tomcat_server.public_ip}"
}

output "tomcat_app_url" {
description = "URL to access the deployed application"
value       = "http://${aws_instance.tomcat_server.public_ip}:8080/yourapp"
}

output "vpc_id" {
description = "ID of the created VPC"
value       = aws_vpc.main.id
}

