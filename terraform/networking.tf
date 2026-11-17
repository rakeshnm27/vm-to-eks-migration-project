
# --------------------------------------------------
# VPC
# --------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# --------------------------------------------------
# Internet Gateway
# --------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# --------------------------------------------------
# Public Subnets
# --------------------------------------------------

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.project_name}-public-${each.key}"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# --------------------------------------------------
# Private Subnets
# --------------------------------------------------

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name                                        = "${var.project_name}-private-${each.key}"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# --------------------------------------------------
# Public Route Table
# --------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# --------------------------------------------------
# Public Route Table Associations
# --------------------------------------------------

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# --------------------------------------------------
# NAT Gateway Elastic IPs
# One EIP per Availability Zone
# --------------------------------------------------

resource "aws_eip" "nat" {
  for_each = local.public_subnets

  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip-${each.key}"
  }
}

# --------------------------------------------------
# NAT Gateways
# One NAT Gateway per Availability Zone
# --------------------------------------------------

resource "aws_nat_gateway" "main" {
  for_each = local.public_subnets

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  depends_on = [
    aws_internet_gateway.main
  ]

  tags = {
    Name = "${var.project_name}-nat-${each.key}"
  }
}

# --------------------------------------------------
# Private Route Tables
# One route table per Availability Zone
# --------------------------------------------------

resource "aws_route_table" "private" {
  for_each = local.private_subnets

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[each.key].id
  }

  tags = {
    Name = "${var.project_name}-private-rt-${each.key}"
  }
}

# --------------------------------------------------
# Private Route Table Associations
# --------------------------------------------------

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

