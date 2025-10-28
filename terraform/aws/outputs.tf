output "endpoint_url" {
  value = "http://${aws_instance.chatbot_server.public_ip}:8080"
}

output "database_host" {
  value = aws_instance.chatbot_server.private_ip
}

output "full_details" {
  value = {
    instance_id = aws_instance.chatbot_server.id
    public_ip   = aws_instance.chatbot_server.public_ip
    private_ip  = aws_instance.chatbot_server.private_ip
  }
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.chatbot_server.id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.chatbot_sg.id
}

output "aws_endpoint" {
  description = "AWS Chatbot endpoint URL"
  value       = module.aws.endpoint_url
  sensitive   = false
}

output "database_connection_string" {
  description = "Database connection string"
  value       = "server=${module.aws.database_host};password=${var.database_password}"
  sensitive   = false 
}

output "full_architecture_details" {
  description = "Complete architecture details"
  value = {
    aws = module.aws.full_details
  }
}
