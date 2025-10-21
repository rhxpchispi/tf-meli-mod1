# Variables con tipos complejos y valores por defecto problemáticos
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod" # ERROR INTENCIONAL 7: Default a prod
  # default   = "dev"  # CORRECCIÓN 7: Default a desarrollo

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Ambiente debe ser dev, test, o prod."
  }
}

variable "chatbot_name" {
  description = "Name of the chatbot"
  type        = string
  default     = "melibot"
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1" # ERROR INTENCIONAL 8: Regiones diferentes
  # default   = "us-east1"     # CORRECCIÓN 8: Regiones consistentes
}

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "my-gcp-project"
}

variable "gcp_project" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "allow_public_access" {
  description = "Whether to allow public access"
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "Allowed CIDR blocks"
  type        = list(string)
  default     = []
}

#### MEJORAS NECESARIAS:

variable "machine_type" {
  description = "GCP machine type"
  type        = string
  default     = "e2-micro"
}

variable "gcp_image" {
  description = "GCP image family"
  type        = string
  default     = "debian-11"
}

# Agregar a allowed_cidr_blocks
# default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

variable "network" {
  description = "GCP network name"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "GCP subnetwork name"
  type        = string
  default     = null
}

variable "service_account_email" {
  description = "Service account email"
  type        = string
  default     = "default"
}

variable "disk_encryption_key" {
  description = "Disk encryption key"
  type        = string
  sensitive   = true
  default     = null
}