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

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
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

variable "database_password" {
  description = "Database password"
  type        = string
  default     = "password123"
}