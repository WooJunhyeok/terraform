resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = { Name = "${var.project}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.project}-igw" }
}

# Public subnets + route
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_cidrs : idx => { cidr=cidr, az=var.azs[idx] } }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = { Name = "${var.project}-pub-${each.value.az}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.project}-rt-public" }
}
resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# NAT (간단히 1개)
resource "aws_eip" "nat" { domain = "vpc" }
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id
  tags = { Name = "${var.project}-nat" }
}

# Private APP subnets
resource "aws_subnet" "private_app" {
  for_each = { for idx, cidr in var.private_app_cidrs : idx => { cidr=cidr, az=var.azs[idx] } }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = { Name = "${var.project}-app-${each.value.az}" }
}
resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.project}-rt-app" }
}
resource "aws_route" "app_nat" {
  route_table_id         = aws_route_table.private_app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
resource "aws_route_table_association" "app_assoc" {
  for_each       = aws_subnet.private_app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_app.id
}

# Private DB subnets (인터넷 없음)
resource "aws_subnet" "private_db" {
  for_each = { for idx, cidr in var.private_db_cidrs : idx => { cidr=cidr, az=var.azs[idx] } }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = { Name = "${var.project}-db-${each.value.az}" }
}
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.project}-rt-db" }
}
resource "aws_route_table_association" "db_assoc" {
  for_each       = aws_subnet.private_db
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_db.id
}