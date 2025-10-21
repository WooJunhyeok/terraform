###############################################################
# Miniproject 1 - Developer Environment Configuration
###############################################################
# 1. VPC
#   * VPC 생성
#   * Internet Gateway 생성 및 VPC에 연결
# 2. Public Subnet
# 3. Routing Table
#   * Public Subnet에 대한 Route Table 생성
#   * Public Subnet에 Routing Table 연결
# 4. EC2 Instance
#   * Security Group 생성
#   * EC2 생성
###############################################################

##############################################
# 1. VPC
#   * VPC 생성
#   * Internet Gateway 생성 및 VPC에 연결
##############################################
# VPC 생성
# * enable_dns_support = true
# * enable_dns_hostnames = true
# * VPC cidr_block = 10.123.0.0/16
resource "aws_vpc" "myVPC" {
  cidr_block       = "10.123.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "myVPC"
  }
}

#   * Internet Gateway 생성 및 VPC에 연결
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myIGW"
  }
}

##############################################
# 2. Public Subnet
##############################################
# Public Subnet 생성
# * map_public_ip_on_launch = true
# * public_subnet cidr_block = 10.123.1.0/24
resource "aws_subnet" "myPubSN" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.123.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "myPubSN"
  }
}

##############################################
# 3. Routing Table
#   * Public Subnet에 대한 Route Table 생성
#   * Public Subnet에 Routing Table 연결
##############################################
# Routing Table 생성
resource "aws_route_table" "myPubRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }

  tags = {
    Name = "myPubRT"
  }
}

resource "aws_route_table_association" "myPubRTassoc" {
  subnet_id      = aws_subnet.myPubSN.id
  route_table_id = aws_route_table.myPubRT.id
}

##############################################
# 4. EC2 Instance
#   * Security Group 생성
#   * EC2 생성
##############################################
# Security Group 생성
# * Inbound Rule: ALL or SSH(22), HTTP(80), HTTPS(443)
# * Outbound Role: ALL
resource "aws_security_group" "allow_all_traffic" {
  name        = "allow_all_traffic"
  description = "Allow ALL inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "allow_all_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ingress_all_traffic" {
  security_group_id = aws_security_group.allow_all_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
#   from_port         = 0
#   to_port           = 0
}

resource "aws_vpc_security_group_egress_rule" "allow_egress_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_all_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#   * EC2 생성
#       * AMI: Amazon Linux 2023 AMI
#       * Instance Type: t3.micro
#       * Key Pair: mykeypair
#       * Security Group: allow_all_traffic

data "aws_ami" "ubuntu2404" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_key_pair" "myDeveloper-key" {
  key_name   = "myDeveloper-key"
  public_key = file("~/.ssh/devkey.pub")
}

# EC2 생성
resource "aws_instance" "myEC2" {
  ami           = data.aws_ami.ubuntu2404.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.allow_all_traffic.id]
  subnet_id = aws_subnet.myPubSN.id
  key_name = aws_key_pair.myDeveloper-key.key_name

  user_data = file("user_data.tpl")

  tags = {
    Name = "myEC2"
  }
    provisioner "local-exec" {
    command        = templatefile("linux-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/devkey"
    })
    interpreter    = ["bash", "-c"]
    # interpreter  = ["Powershell", "-Command"]
  }
}

