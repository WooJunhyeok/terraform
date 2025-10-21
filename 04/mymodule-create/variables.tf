variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_subnet_az_id" {
  description = "Availability Zone ID (예: use2-az1)"
  type        = string
  default     = "use2-az1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
  default     = "mykeypair"
}

variable "common_tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {
    Project = "mymodule"
    Owner   = "tf-user"
  }
}
