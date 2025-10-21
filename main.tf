
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