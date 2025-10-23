variable "region"           { 
    type = string  
    default = "ap-northeast-2" 
    }
variable "project"          { 
    type = string  
    default = "mini2" 
    }
variable "vpc_cidr"         { 
    type = string  
    default = "10.0.0.0/16" 
    }
variable "public_cidrs"     { 
    type = list(string) 
    default = ["10.0.0.0/24","10.0.1.0/24"] 
    }
variable "private_app_cidrs"{ 
    type = list(string) 
    default = ["10.0.10.0/24","10.0.11.0/24"] 
    }
variable "private_db_cidrs" { 
    type = list(string) 
    default = ["10.0.20.0/24","10.0.21.0/24"] 
    }
variable "azs"              { 
    type = list(string) 
    default = ["ap-northeast-2a","ap-northeast-2c"] 
    }

# EC2/ASG
variable "instance_type" { 
    type = string 
    default = "t3.micro" 
    }
variable "key_name"      { 
    type = string 
    default = null 
    } # 있으면 입력
variable "allowed_ssh_cidrs" { 
    type = list(string) 
    default = ["0.0.0.0/0"] 
    }

# DB (학습환경이니 간단설정)
variable "db_username" { 
    type = string 
    default = "adminuser" 
    }
variable "db_password" { 
    type = string 
    default = "ChangeMeStrong!123" 
    sensitive = true 
    }
