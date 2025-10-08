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

# ERROR INTENCIONAL 9: Variable sensible sin protección
variable "database_password" {
  description = "Database password"
  type        = string
  default     = "password123"
  # CORRECCIÓN 9: Variable sensible marcada como sensitive
  # sensitive   = true
}

# Variable compleja con estructura problemática
variable "chatbot_config" {
  description = "Chatbot configuration"
  type = object({
    version  = string
    features = map(string)
    scaling = object({
      min_instances = number
      max_instances = number
    })
  })

  default = {
    version = "1.0"
    features = {
      "ai_enabled"   = "true"
      "multilingual" = "false"
    }
    scaling = {
      min_instances = 1
      max_instances = 10 # ERROR INTENCIONAL 10: Límites de escalado muy altos
    }
  }
}

# Variable compleja corregida
# variable "chatbot_config" {
#   description = "Chatbot configuration"
#   type = object({
#     version    = string
#     features   = map(string)
#     scaling    = object({
#       min_instances = number
#       max_instances = number
#     })
#     health_check = object({
#       enabled  = bool
#       path     = string
#       port     = number
#     })
#   })

#   default = {
#     version = "1.0"
#     features = {
#       "ai_enabled"    = "true"
#       "multilingual"  = "false"
#     }
#     scaling = {
#       min_instances = 1
#       max_instances = 3  # CORRECCIÓN 10: Límites de escalado realistas
#     }
#     health_check = {
#       enabled = true
#       path    = "/health"
#       port    = 8080
#     }
#   }
# }

# Lista con valores problemáticos
variable "allowed_regions" {
  description = "Regions where deployment is allowed"
  type        = list(string)
  default     = ["us-east-1", "eu-west-1", "asia-southeast1"] # Mezcla formatos AWS/GCP
  # default     = ["us-east-1", "us-west-1", "europe-west1"]  # Formatos consistentes
}

#### MEJORAS NECESARIAS:

# Credenciales via variables (mejores prácticas)
variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
  default     = null
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
  default     = null
}

variable "gcp_credentials_file" {
  description = "Path to GCP credentials file"
  type        = string
  sensitive   = true
  default     = null
}

# Configuración de instancias
variable "instance_type" {
  description = "AWS instance type"
  type        = string
  default     = "t3.micro"
}

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

# Configuración de red
variable "allow_public_access" {
  description = "Whether to allow public access"
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "Allowed CIDR blocks for ingress"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"] # Rangos privados por defecto

  validation {
    condition = alltrue([
      for cidr in var.allowed_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All CIDR blocks must be valid."
  }
}

# Variables de infraestructura existente
variable "aws_vpc_id" {
  description = "AWS VPC ID"
  type        = string
  default     = null
}

variable "aws_subnet_id" {
  description = "AWS Subnet ID"
  type        = string
  default     = null
}

variable "aws_key_name" {
  description = "AWS Key Pair name"
  type        = string
  default     = null
}

variable "gcp_network" {
  description = "GCP Network name"
  type        = string
  default     = "default"
}

variable "gcp_subnetwork" {
  description = "GCP Subnetwork name"
  type        = string
  default     = null
}