output "endpoint_url" {
  description = "Chatbot endpoint URL"
  value       = var.allow_public_access ? "http://${google_compute_instance.chatbot_server.network_interface[0].access_config[0].nat_ip}:8080" : "http://${google_compute_instance.chatbot_server.network_interface[0].network_ip}:8080"
}

output "instance_id" {
  description = "GCE instance ID"
  value       = google_compute_instance.chatbot_server.instance_id
}

output "internal_ip" {
  description = "Internal IP address"
  value       = google_compute_instance.chatbot_server.network_interface[0].network_ip
}


output "gcp_endpoint" {
  description = "GCP Chatbot endpoint URL"
  value       = module.gcp.endpoint_url
  sensitive   = false
}

output "full_architecture_details" {
  description = "Complete architecture details"
  value = {
    gcp = module.gcp.full_details
  }
}
