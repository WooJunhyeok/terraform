module "net" {
  source           = "./modules/net"
  project          = var.project
  vpc_cidr         = var.vpc_cidr
  azs              = var.azs
  public_cidrs     = var.public_cidrs
  private_app_cidrs= var.private_app_cidrs
  private_db_cidrs = var.private_db_cidrs
}

module "db" {
  source             = "./modules/db"
  project            = var.project
  vpc_id             = module.net.vpc_id
  db_subnet_ids = module.net.private_db_subnet_ids
  db_username   = var.db_username
  db_password   = var.db_password  # 순환 참조 방지 위해 아래로 이동하려면 trick 필요
  # ↑ 순서 때문에 첫 apply에서 아직 없음 → 일단 임시로 net 모듈이 app SG도 만들게 하거나,
  #   1) 먼저 db 모듈에서 SG를 만들고 ec2 모듈이 그 SG를 참조하도록 하자(아래 방식採用)
}

module "lb" {
  source         = "./modules/lb"
  project        = var.project
  vpc_id         = module.net.vpc_id
  public_subnets = module.net.public_subnet_ids
  allowed_ingress_cidrs = ["0.0.0.0/0"]
}

module "ec2" {
  source             = "./modules/ec2"
  project            = var.project
  vpc_id             = module.net.vpc_id
  app_subnets        = module.net.private_app_subnet_ids
  instance_type      = var.instance_type
  key_name           = var.key_name
  allowed_ssh_cidrs  = var.allowed_ssh_cidrs
  target_group_arn   = module.lb.tg_arn
  db_endpoint        = module.db.cluster_writer_endpoint
  db_username        = var.db_username
  db_password        = var.db_password
  alb_sg_id          = module.lb.alb_sg_id
  db_sg_id           = module.db.db_sg_id
}
