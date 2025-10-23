# Web SG: 80 from ALB, 22 from your IPs
resource "aws_security_group" "web" {
  name   = "${var.project}-web-sg"
  vpc_id = var.vpc_id

  # 80 포트: ALB SG에서만 허용
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  # 22 포트: allowed_ssh_cidrs에서 허용
  dynamic "ingress" {
    for_each = var.allowed_ssh_cidrs
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-web-sg" }
}

# DB SG에 Web SG 허용(3306)
resource "aws_security_group_rule" "db_ingress_from_web" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = var.db_sg_id          # target: DB SG
  source_security_group_id = aws_security_group.web.id
}

data "aws_ami" "amz2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon
  filter { 
    name = "name" 
    values = ["al2023-ami-*-kernel-6.1-*"] 
    }
}

locals {
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    dnf -y update
    dnf -y install httpd php php-mysqli
    systemctl enable --now httpd

    cat >/var/www/html/index.php <<'PHP'
    <?php
      $mysqli = new mysqli("${var.db_endpoint}", "${var.db_username}", "${var.db_password}");
      if ($mysqli->connect_errno) { echo "DB Connection Failed: " . $mysqli->connect_error; exit(); }
      echo "<h1>Mini Project 2</h1>";
      echo "ALB → ASG(EC2) → RDS Aurora MySQL (connected)<br/>";
      phpinfo();
    ?>
    PHP
    chown apache:apache /var/www/html/index.php
  EOF
  )
}

resource "aws_iam_role" "ssm" {
  name = "${var.project}-ssm-role"
  assume_role_policy = jsonencode({
    Version="2012-10-17",
    Statement=[{Effect="Allow",Principal={Service="ec2.amazonaws.com"},Action="sts:AssumeRole"}]
  })
}
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "ssm" {
  name = "${var.project}-ssm-profile"
  role = aws_iam_role.ssm.name
}

resource "aws_launch_template" "web" {
  name_prefix   = "${var.project}-lt-"
  image_id      = data.aws_ami.amz2023.id
  instance_type = var.instance_type
  key_name      = var.key_name
  iam_instance_profile { name = aws_iam_instance_profile.ssm.name }
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data     = local.user_data
  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.project}-web" }
  }
}

resource "aws_autoscaling_group" "web" {
  name                      = "${var.project}-asg"
  min_size                  = 2
  max_size                  = 2
  desired_capacity          = 2
  vpc_zone_identifier       = var.app_subnets
  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]
  tag { 
    key="Name" 
    value="${var.project}-web" 
    propagate_at_launch=true 
  }
}
