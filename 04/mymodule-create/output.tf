output "vpc_id" {
  value = module.net.vpc_id
}

output "subnet_id" {
  value = module.net.public_subnet_id
}

output "security_group_id" {
  value = module.net.sg_id
}

output "instance_id" {
  value = module.ec2.instance_id
}

output "public_ip" {
  value = module.ec2.public_ip
}
