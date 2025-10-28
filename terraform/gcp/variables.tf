
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"

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
  default     = "us-central1" 
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

