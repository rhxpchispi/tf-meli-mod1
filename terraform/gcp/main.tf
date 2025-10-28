terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

resource "google_compute_instance" "chatbot_server" {
  name         = "${var.chatbot_name}-${var.environment}"
  machine_type = "e2-micro"
  zone         = "${var.gcp_region}-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"  
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    echo "Starting GCP chatbot server"
    # Configuración diferente a AWS
    EOF

  tags = ["chatbot", "http-server", "https-server"]  
}

resource "google_compute_firewall" "chatbot_firewall" {
  name    = "${var.chatbot_name}-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = var.allowed_cidr_blocks  # Muy restrictivo comparado con AWS
  target_tags   = ["chatbot"]
}

output "full_details" {
  description = "Complete GCP architecture details"
  value = {
    instance_name = google_compute_instance.chatbot_server.name
    public_ip     = google_compute_instance.chatbot_server.network_interface[0].access_config[0].nat_ip
    private_ip    = google_compute_instance.chatbot_server.network_interface[0].network_ip
    zone          = google_compute_instance.chatbot_server.zone
  }
}
