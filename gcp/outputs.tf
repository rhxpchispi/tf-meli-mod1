# Outputs que exponen información sensible
output "gcp_endpoint" {
  description = "GCP Chatbot endpoint URL"
  value       = module.gcp.endpoint_url
  sensitive   = false
}

# CORRECCIÓN 11: eliminar por completo el output database_connection_string

# Outputs que revelan demasiada información de infraestructura
output "full_architecture_details" {
  description = "Complete architecture details"
  value = {
    gcp = module.gcp.full_details
  }
}
