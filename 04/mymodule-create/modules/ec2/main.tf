resource "aws_instance" "this" {
  ami                    = "ami-0199d4b5b8b4fde0e"
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = merge({ Name = "myInstance" }, var.tags)
}
