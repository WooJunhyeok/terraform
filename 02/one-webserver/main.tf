# provider 설정
provider "aws" {
  region = var.my_region
}

# ec2 instance 생성
# * webserver 구성 => user_data
# * security group 생성

resource "aws_instance" "example" {
  ami           = var.my_ami_ubuntu2204
  instance_type = var.my_instance_type
  vpc_security_group_ids = [aws_security_group.allow_8080.id]
  user_data_replace_on_change = var.my_userdata_changed
  tags = var.my_webserver_tags

  user_data     = <<EOF
#!/bin/bash
sudo apt -y install apache2
echo "WEB" | sudo tee /var/www/html/index.html
sudo systemctl enable --now apache2
EOF
}

resource "aws_security_group" "allow_8080" {
  name        = "allow_8080"
  description = "Allow 8080 inbound traffic and all outbound traffic"

  tags = var.my_sg_tags
}

# security group ingress rule
resource "aws_vpc_security_group_ingress_rule" "allow_8080_ipv4" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.my_http
  to_port           = var.my_http
  ip_protocol       = "tcp"
}

# security group egress rule
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

##########################
# Variable 정의
##########################
# variable "my_region" {
#   description = "AWS Region"
#   type = string
#   default = "us-east-2"
# }

# variable "my_ami_ubuntu2204" {
#   description = "AWS My AMI - Ubuntu 22.04 LTS(x86_64)"
#   type = string
#   default = "ami-0cfde0ea8edd312d4"
# }

# # output variable
# output "myweb_public_ip" {
#   description = "My webserver Public IP"
#   value       = aws_instance.example.public_ip
# }