variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "public_subnet_cidr" {
  type        = string
  description = "Public subnet CIDR block"
}

variable "public_subnet_az_id" {
  type        = string
  description = "AZ ID"
}

variable "tags" {
  type        = map(string)
  description = "Common tags"
  default     = {}
}
