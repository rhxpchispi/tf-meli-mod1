terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_instance" "chatbot_server" {
  ami                    = "ami-0c02fb55956c7d316"  
  instance_type          = "t2.micro"
  key_name               = "my-key-pair"  
  vpc_security_group_ids = [aws_security_group.chatbot_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Starting chatbot server"
              export DB_PASSWORD="hardcoded_password"
              ./start-chatbot.sh
              EOF

  tags = {
    Name        = "${var.chatbot_name}-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_security_group" "chatbot_sg" {
  name_prefix = "${var.chatbot_name}-${var.environment}-sg"
  
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
}

resource "aws_eip" "unused_eip" {
  instance = aws_instance.chatbot_server.id
  domain   = "vpc"
}