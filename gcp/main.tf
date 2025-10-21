# Configuración de proveedores con errores intencionales
terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}


# Módulo GCP con problemas de consistencia y configuración
resource "google_compute_instance" "chatbot_server" {
  name         = "${var.chatbot_name}-${var.environment}"
  machine_type = "e2-micro"
  # machine_type = var.machine_type
  zone         = "${var.gcp_region}-a"

  # ERROR INTENCIONAL 20: Boot disk sin encryption
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"  # ERROR INTENCIONAL 21: Imagen específica
      
      # CORRECCIÓN 21: 
      # image = var.gcp_image
      # size  = 20
      # type  = "pd-ssd"
    }
    # CORRECCIÓN 20: Boot disk con encryption
    # disk_encryption_key_raw = var.disk_encryption_key
  }

  network_interface {
    network = "default"
    # network    = var.network
    # subnetwork = var.subnetwork
    
    # ERROR INTENCIONAL 22: Configuración de red inconsistente con AWS
    access_config {
      // Ephemeral IP
    }

    # CORRECCIÓN 22: Configuración de red consistente
    # dynamic "access_config" {
    #   for_each = var.allow_public_access ? [1] : []
    #   content {
    #     // Ephemeral public IP
    #   }
    # }
  }

  # ERROR INTENCIONAL 23: Sin service account configurada
  service_account {
    scopes = ["cloud-platform"]
  }

  # CORRECCIÓN 23: Service account configurada apropiadamente

  # service_account {
  #   email  = var.service_account_email
  #   scopes = ["cloud-platform"]
  # }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    echo "Starting GCP chatbot server"
    # Configuración diferente a AWS
    EOF

  # metadata_startup_script = templatefile("${path.module}/startup_script.sh", {
  #   chatbot_name  = var.chatbot_name
  #   environment   = var.environment
  # }) (el script startup_script.sh debe estar en el repositorio)

  tags = ["chatbot", "http-server", "https-server"]  # ERROR INTENCIONAL 24: Tags demasiado genéricos

  # CORRECCIÓN 24: Tags específicos
  # tags = ["${var.chatbot_name}", "${var.environment}", "chatbot-instance"]
}

# ERROR INTENCIONAL 25: Reglas de firewall demasiado restrictivas
resource "google_compute_firewall" "chatbot_firewall" {
  name    = "${var.chatbot_name}-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  # CORRECCIÓN 25: Reglas de firewall consistentes con AWS
  # allow {
  #   protocol = "tcp"
  #   ports    = ["80", "443", "8080"] (el puerto que sea necesario)
  # }

  source_ranges = var.allowed_cidr_blocks  # Muy restrictivo comparado con AWS
  target_tags   = ["chatbot"]

  # source_ranges = var.allow_public_access ? ["0.0.0.0/0"] : var.allowed_cidr_blocks
  # target_tags   = ["${var.chatbot_name}"]
}

# ERROR INTENCIONAL 26: Sin configuración de backup o snapshots

# CORRECCIÓN 26: Configuración de backup con snapshots
# resource "google_compute_snapshot" "chatbot_snapshot" {
#   name        = "${var.chatbot_name}-${var.environment}-snapshot-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
#   source_disk = google_compute_instance.chatbot_server.name
#   zone        = "${var.gcp_region}-a"
  
#   labels = {
#     environment = var.environment
#     automated   = "true"
#   }
# 
#   storage_locations = ["us"]
# }

output "full_details" {
  description = "Complete GCP architecture details"
  value = {
    instance_name = google_compute_instance.chatbot_server.name
    public_ip     = google_compute_instance.chatbot_server.network_interface[0].access_config[0].nat_ip
    private_ip    = google_compute_instance.chatbot_server.network_interface[0].network_ip
    zone          = google_compute_instance.chatbot_server.zone
  }
}

#### MEJORAS NECESARIAS:

# Stackdriver monitoring
resource "google_monitoring_alert_policy" "high_cpu" {
  display_name = "High CPU Usage - ${var.chatbot_name}"
  combiner     = "OR"
  
  conditions {
    display_name = "CPU utilization"

    condition_threshold {
      filter     = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
      duration   = "120s"
      comparison = "COMPARISON_GT"
      threshold_value = 0.8

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 2
      }
    }
  }

  documentation {
    content = "CPU utilization is high on chatbot instance ${var.chatbot_name}-${var.environment}"
  }
}

# Outputs
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