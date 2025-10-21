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

# ERROR INTENCIONAL 9: Variable sensible sin protección
variable "database_password" {
  description = "Database password"
  type        = string
  default     = "password123"
  # CORRECCIÓN 9: Variable sensible marcada como sensitive
  # sensitive   = true
}

#### MEJORAS NECESARIAS:

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID (optional - uses latest Amazon Linux if not specified)"
  type        = string
  default     = null
}

# Agregar a allowed_cidr_blocks
# default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "key_name" {
  description = "Key pair name"
  type        = string
  default     = null
}