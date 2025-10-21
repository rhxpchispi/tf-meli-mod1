# Configuración de proveedores con errores intencionales
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

# Módulo AWS con múltiples problemas de seguridad y disponibilidad
resource "aws_instance" "chatbot_server" {
  ami                    = "ami-0c02fb55956c7d316"  # ERROR INTENCIONAL 13: AMI hardcodeada
  instance_type          = "t2.micro"
  key_name               = "my-key-pair"  # ERROR INTENCIONAL 14: Key pair hardcodeada

  # CORRECCIÓN 13: AMI dinámica o parametrizada (lo toma de mejoras en variables.tf)
  # CORRECCIÓN 14: Key pair parametrizada (lo toma de mejoras en variables.tf)
  # ami                    = var.ami_id
  # instance_type          = var.instance_type
  # key_name               = var.key_name
  
  # ERROR INTENCIONAL 15: Sin grupos de seguridad definidos
  vpc_security_group_ids = [aws_security_group.chatbot_sg.id]

  # CORRECCIÓN 15: (agregado más abajo)

  user_data = <<-EOF
              #!/bin/bash
              echo "Starting chatbot server"
              # ERROR INTENCIONAL 16: Configuración de aplicación hardcodeada
              export DB_PASSWORD="hardcoded_password"
              ./start-chatbot.sh
              EOF

  # CORRECCIÓN 16: Encriptado de config (el script user_data.sh debe estar en el repositorio)
  # user_data = base64encode(templatefile("${path.module}/user_data.sh", {
  #   chatbot_name    = var.chatbot_name
  #   environment     = var.environment
  #   database_host   = aws_instance.chatbot_server.private_ip
  # }

  # root_block_device {
  #   encrypted = true  # Encriptación habilitada para corrección 16
  # }

  # ERROR INTENCIONAL 17: Sin configuración de monitoreo

  # CORRECCIÓN 17: Monitoreo habilitado
  # monitoring = true

  tags = {
    Name        = "${var.chatbot_name}-${var.environment}"
    Environment = var.environment
  }

  # MEJORA:
  # lifecycle {
  #   ignore_changes = [ami]  # Para actualizaciones de AMI controladas
  # }
}

resource "aws_security_group" "chatbot_sg" {
  name_prefix = "${var.chatbot_name}-${var.environment}-sg"
  
  # ERROR INTENCIONAL 18: Reglas de seguridad demasiado permisivas
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks  # Hereda el 0.0.0.0/0 del módulo padre
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"  # Todos los protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }

  # CORRECCIÓN 18: Reglas de seguridad mínimas necesarias
  # ingress {
  #   description = "HTTP access" (o HTTPS, 8080 o cualquiera necesario)
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = var.allow_public_access ? ["0.0.0.0/0"] : var.allowed_cidr_blocks
  # }
  # egress {
  #   description = "Outbound traffic"
  #   from_port   = 0
  #   to_port     = 0 (limitado totalmente)
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

}

# ERROR INTENCIONAL 19: Recursos no utilizados
resource "aws_eip" "unused_eip" {
  instance = aws_instance.chatbot_server.id
  domain   = "vpc"
}

# CORRECCIÓN 19: Solo recursos necesarios
# Elastic IP opcional, solo si se necesita IP pública estática

# Outputs problemáticos
output "endpoint_url" {
  value = "http://${aws_instance.chatbot_server.public_ip}:8080"
}

output "database_host" {
  value = aws_instance.chatbot_server.private_ip
}

output "full_details" {
  value = {
    instance_id = aws_instance.chatbot_server.id
    public_ip   = aws_instance.chatbot_server.public_ip
    private_ip  = aws_instance.chatbot_server.private_ip
  }
}

#### MEJORAS NECESARIAS:

# CloudWatch alarms para monitoreo
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

# Outputs seguros
# output "endpoint_url" {
#   description = "Chatbot endpoint URL"
#   value       = var.allow_public_access ? "http://${aws_instance.chatbot_server.public_ip}:8080" : "http://${aws_instance.chatbot_server.private_ip}:8080"
# }

# output "database_host" {
#   description = "Database host address"
#   value       = aws_instance.chatbot_server.private_ip
# }

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.chatbot_server.id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.chatbot_sg.id
}