# Outputs que exponen información sensible
output "aws_endpoint" {
  description = "AWS Chatbot endpoint URL"
  value       = module.aws.endpoint_url
  sensitive   = false
}

output "database_connection_string" {
  description = "Database connection string"
  value       = "server=${module.aws.database_host};password=${var.database_password}"
  sensitive   = false # ERROR INTENCIONAL 11: Expone credenciales
}

# CORRECCIÓN 11: eliminar por completo el output database_connection_string

# Outputs que revelan demasiada información de infraestructura
output "full_architecture_details" {
  description = "Complete architecture details"
  value = {
    aws = module.aws.full_details # ERROR INTENCIONAL 12: Output que expone IPs internas sin necesidad
  }
}

# CORRECCIÓN 12:
# Información mínima necesaria para operaciones
# output "deployment_summary" {
#   description = "Deployment summary"
#   value = {
#     environment    = var.environment
#     aws_region     = var.aws_region
#     gcp_region     = var.gcp_region
#     chatbot_name   = var.chatbot_name
#     deployed_at    = timestamp()
#   }
# }