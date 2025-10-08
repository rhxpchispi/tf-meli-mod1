# Configuración de proveedores con errores intencionales
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }

  # ERROR INTENCIONAL 1: Backend no configurado para estado remoto
  # CORRECCIÓN 1: 
  # backend "s3" {
  #   bucket = "my-terraform-state-bucket"
  #   key    = "MeliBot/terraform.tfstate"
  #   region = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

# Configuración insegura de proveedores
provider "aws" {
  region = var.aws_region

  # Simulación sin credenciales reales
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  # ERROR INTENCIONAL 2: Credenciales hardcodeadas (NUNCA hacer esto)
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  # CORRECCIÓN 2: Credenciales via variables o environment variables
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  # ERROR INTENCIONAL 3: Sin configuración de credenciales
  credentials = jsonencode({
    type            = "service_account"
    project_id      = var.gcp_project
    client_email    = "terraform@${var.gcp_project}.iam.gserviceaccount.com"
    auth_uri        = "https://accounts.google.com/o/oauth2/auth"
    token_uri       = "https://oauth2.googleapis.com/token"
    universe_domain = "googleapis.com"
  })
  
  # CORRECCIÓN 3: Credenciales via archivo o environment variables
  # credentials = file(var.gcp_credentials_file) (el archivo tiene que estar en el repositorio)
}

# Módulos con configuraciones inconsistentes
module "aws" {
  source = "./modules/aws"

  environment  = var.environment
  chatbot_name = var.chatbot_name
  aws_region   = var.aws_region
  vpc_id       = var.aws_vpc_id
  subnet_id    = var.aws_subnet_id

  # ERROR INTENCIONAL 4: Configuración de seguridad inconsistente
  allow_public_access = true
  allowed_cidr_blocks = ["0.0.0.0/0"] # Demasiado permisivo

  # CORRECCIÓN 4: Configuración de seguridad consistente y segura
  # instance_type        = var.instance_type
  # ami_id               = data.aws_ami.latest_amazon_linux.id (TODO: Data sources para AMIs dinámicas)

  # allow_public_access  = var.allow_public_access
  # allowed_cidr_blocks  = var.allowed_cidr_blocks
  # key_name             = var.aws_key_name
}

module "gcp" {
  source = "./modules/gcp"

  environment    = var.environment
  chatbot_name   = var.chatbot_name
  gcp_region     = var.gcp_region
  gcp_project_id = var.gcp_project_id

  # ERROR INTENCIONAL 5: Configuración de red inconsistente con AWS
  allow_public_access = false
  allowed_cidr_blocks = ["10.0.0.0/8"]

  # CORRECCIÓN 5: Configuración de red consistente con AWS
  # machine_type         = var.machine_type
  # gcp_image            = var.gcp_image

  # allow_public_access  = var.allow_public_access
  # allowed_cidr_blocks  = var.allowed_cidr_blocks
  # network              = var.gcp_network
  # subnetwork           = var.gcp_subnetwork
}

# ERROR INTENCIONAL 6: Dependencia circular implícita
resource "null_resource" "multicloud_sync" {
  depends_on = [module.aws, module.gcp]

  provisioner "local-exec" {
    command = "echo 'Chatbot deployed to both clouds'"
  }
}

# CORRECCIÓN 6: Dependencias explícitas y correctas
# resource "null_resource" "multicloud_validation" {
# triggers = {
# aws_instance  = module.aws.instance_id
# gcp_instance  = module.gcp.instance_id
# }

# provisioner "local-exec" {
# command = "echo 'Chatbot validation completed for both clouds'"
# }
# }