provider "aws" {
  region = var.aws_region
}

# สร้าง Key Pair สำหรับ SSH
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.example.public_key_openssh

  lifecycle {
    ignore_changes = [public_key]
  }
}

resource "local_file" "private_key" {
  content         = tls_private_key.example.private_key_pem
  filename        = "${path.module}/${var.key_name}.pem"
  file_permission = "0400"
}

# Security Group สำหรับ Currency Converter API
resource "aws_security_group" "app_sg" {
  name_prefix = "currency_converter_sg"
  description = "Security Group for Currency Converter API"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Currency Converter API Port
  ingress {
    from_port   = 3009
    to_port     = 3009
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance สำหรับ Currency Converter
resource "aws_instance" "currency_converter" {
  ami                    = "ami-0ba8d27d35e9915fb"
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              echo "Starting Currency Converter Setup"

              export DEBIAN_FRONTEND=noninteractive

              # Update system
              sudo -E apt-get update -y

              # Install Node.js 20.x LTS
              sudo curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
              sudo -E apt-get install -y nodejs
              sudo apt-get install -y git

              # Create app directory
              cd /home/ubuntu
              git clone https://github.com/Rednoselittledog/devops68-currency-converter.git
              cd devops68-currency-converter

              # Install dependencies and run
              npm install
              nohup npm start > app.log 2>&1 &

              echo "Currency Converter API Started on port 3009"
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "Currency Converter API"
  }
}
