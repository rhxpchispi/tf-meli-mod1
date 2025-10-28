# Listados de incidentes ordenados por archivos:

## `terraform/aws/main.tf`
Configuración de proveedores con errores intencionales. 
ERROR INTENCIONAL 1: Backend no configurado para estado remoto
CORRECCIÓN 1: 

backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "MeliBot/terraform.tfstate"
    region = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
}

Módulo AWS con múltiples problemas de seguridad y disponibilidad
ERROR INTENCIONAL 13: AMI hardcodeada
ERROR INTENCIONAL 14: Key pair hardcodeada

CORRECCIÓN 13: AMI dinámica o parametrizada (lo toma de mejoras en variables.tf)
CORRECCIÓN 14: Key pair parametrizada (lo toma de mejoras en variables.tf)
ami                    = var.ami_id
instance_type          = var.instance_type
key_name               = var.key_name
  
ERROR INTENCIONAL 15: Sin grupos de seguridad definidos
CORRECCIÓN 15: Agregar security groups

ERROR INTENCIONAL 16: Configuración de aplicación hardcodeada
CORRECCIÓN 16: Encriptado de config (el script user_data.sh debe estar en el repositorio)

user_data = base64encode(templatefile("${path.module}/user_data.sh")), {
    chatbot_name    = var.chatbot_name
    environment     = var.environment
    database_host   = aws_instance.chatbot_server.private_ip
}

root_block_device {
    encrypted = true  # Encriptación habilitada para corrección 16
}

ERROR INTENCIONAL 17: Sin configuración de monitoreo

CORRECCIÓN 17: Monitoreo habilitado
monitoring = true

ERROR INTENCIONAL 18: Reglas de seguridad demasiado permisivas
CORRECCIÓN 18: Reglas de seguridad mínimas necesarias
ingress {
    description = "HTTP access" (o HTTPS, 8080 o cualquiera necesario)
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allow_public_access ? ["0.0.0.0/0"] : var.allowed_cidr_blocks
}
egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0 (limitado totalmente)
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

ERROR INTENCIONAL 19: Recursos no utilizados "aws_eip" "unused_eip"
CORRECCIÓN 19: Solo recursos necesarios. Elastic IP opcional, solo si se necesita IP pública estática

MEJORA en resource "aws_instance" "chatbot_server":
lifecycle {
    ignore_changes = [ami]  # Para actualizaciones de AMI controladas
}

MEJORAS NECESARIAS:

CloudWatch alarms para monitoreo
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.chatbot_name}-${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EC2 CPU utilization"
  alarm_actions       = []  # Configurar SNS topic para notificaciones...

  dimensions = {
    InstanceId = aws_instance.chatbot_server.id
  }
}

Outputs seguros
 output "endpoint_url" {
   description = "Chatbot endpoint URL"
   value       = var.allow_public_access ? "http://${aws_instance.chatbot_server.public_ip}:8080" : "http://${aws_instance.chatbot_server.private_ip}:8080"
 }

 output "database_host" {
   description = "Database host address"
   value       = aws_instance.chatbot_server.private_ip
 }

---

## `terraform/aws/output.tf`
Outputs problemáticos, Outputs que exponen información sensible: "aws_endpoint", "database_connection_string"
ERROR INTENCIONAL 11: Expone credenciales
CORRECCIÓN 11: eliminar por completo el output database_connection_string

Outputs que revelan demasiada información de infraestructura: "full_architecture_details"
ERROR INTENCIONAL 12: Output que expone IPs internas sin necesidad

CORRECCIÓN 12:
Información mínima necesaria para operaciones

output "deployment_summary" {
  description = "Deployment summary"
  value = {
    environment    = var.environment
    aws_region     = var.aws_region
    gcp_region     = var.gcp_region
    chatbot_name   = var.chatbot_name
    deployed_at    = timestamp()
  }
}

---

## `terraform/aws/variables.tf`
Variables con tipos complejos y valores por defecto problemáticos
ERROR INTENCIONAL 7: Default a prod "environment"
CORRECCIÓN 7: Default a desarrollo
default   = "dev"

ERROR INTENCIONAL 9: Variable sensible sin protección "database_password"
CORRECCIÓN 9: Variable sensible marcada como sensitive
 sensitive   = true

MEJORAS NECESARIAS:

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

Agregar a allowed_cidr_blocks
 default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

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

---

## `terraform/gcp/main.tf`
Configuración de proveedores con errores intencionales
Módulo GCP con problemas de consistencia y configuración
Mejora:
 machine_type = var.machine_type

ERROR INTENCIONAL 20: Boot disk sin encryption "google_compute_instance" "chatbot_server"
CORRECCIÓN 20: Boot disk con encryption
    disk_encryption_key_raw = var.disk_encryption_key

ERROR INTENCIONAL 21: Imagen específica
CORRECCIÓN 21: 
    image = var.gcp_image
    size  = 20
    type  = "pd-ssd"

Mejoras: network_interface
 network    = var.network
 subnetwork = var.subnetwork

ERROR INTENCIONAL 22: Configuración de red inconsistente con AWS
CORRECCIÓN 22: Configuración de red consistente
 dynamic "access_config" {
   for_each = var.allow_public_access ? [1] : []
   content {
     // Ephemeral public IP
   }
 }

ERROR INTENCIONAL 23: Sin service account configurada
CORRECCIÓN 23: Service account configurada apropiadamente

 service_account {
   email  = var.service_account_email
   scopes = ["cloud-platform"]
 }

 metadata_startup_script = templatefile("${path.module}/startup_script.sh", {
   chatbot_name  = var.chatbot_name
   environment   = var.environment
 }) (el script startup_script.sh debe estar en el repositorio)

ERROR INTENCIONAL 24: Tags demasiado genéricos
CORRECCIÓN 24: Tags específicos
 tags = ["${var.chatbot_name}", "${var.environment}", "chatbot-instance"]

ERROR INTENCIONAL 25: Reglas de firewall demasiado restrictivas "google_compute_firewall" "chatbot_firewall"
CORRECCIÓN 25: Reglas de firewall consistentes con AWS
 allow {
  protocol = "tcp"
   ports    = ["80", "443", "8080"] (el puerto que sea necesario)
 }

Mejora:
  source_ranges = var.allow_public_access ? ["0.0.0.0/0"] : var.allowed_cidr_blocks
  target_tags   = ["${var.chatbot_name}"]


ERROR INTENCIONAL 26: Sin configuración de backup o snapshots
CORRECCIÓN 26: Configuración de backup con snapshots
 resource "google_compute_snapshot" "chatbot_snapshot" {
   name        = "${var.chatbot_name}-${var.environment}-snapshot-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
   source_disk = google_compute_instance.chatbot_server.name
   zone        = "${var.gcp_region}-a"
  
   labels = {
     environment = var.environment
     automated   = "true"
   }
 
   storage_locations = ["us"]
 }

MEJORAS NECESARIAS:

Stackdriver monitoring

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

---

## `terraform/gcp/output.tf`
Outputs que exponen información sensible "gcp_endpoint"
CORRECCIÓN 11: eliminar por completo el output database_connection_string

Outputs que revelan demasiada información de infraestructura "full_architecture_details"

---

## `terraform/gcp/variables.tf`
Variables con tipos complejos y valores por defecto problemáticos "environment"

ERROR INTENCIONAL 7: Default a prod
CORRECCIÓN 7: Default a desarrollo
  default   = "dev"  

ERROR INTENCIONAL 8: Regiones diferentes "gcp_region"
CORRECCIÓN 8: Regiones consistentes
 default   = "us-east1"    

MEJORAS NECESARIAS:

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

Agregar a allowed_cidr_blocks
 default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

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
