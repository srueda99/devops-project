# --- AVAILABILITY ZONES ---

data "aws_availability_zones" "available" {
  state = "available"
}

# --- NETWORK ---

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name"    = "devops-vpc"
    "Project" = "devops"
  }
}

# --- SUBNETS ---

resource "aws_subnet" "priv_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.priv_subnet_1_cidr
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]
  depends_on = [
    aws_vpc.main_vpc
  ]
  tags = {
    "Name"                                 = "devops-private-1"
    "Project"                              = "devops"
    "kubernetes.io/cluster/devops-cluster" = "shared"
    "kubernetes.io/role/internal-elb"      = "1"
  }
}

resource "aws_subnet" "priv_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.priv_subnet_2_cidr
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  depends_on = [
    aws_vpc.main_vpc
  ]
  tags = {
    "Name"                                 = "devops-private-2"
    "Project"                              = "devops"
    "kubernetes.io/cluster/devops-cluster" = "shared"
    "kubernetes.io/role/internal-elb"      = "1"
  }
}

resource "aws_subnet" "pub_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.pub_subnet_1_cidr
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]
  depends_on = [
    aws_vpc.main_vpc
  ]
  tags = {
    "Name"                                 = "devops-public-1"
    "Project"                              = "devops"
    "kubernetes.io/cluster/devops-cluster" = "shared"
    "kubernetes.io/role/elb"               = "1"
  }
}

resource "aws_subnet" "pub_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.pub_subnet_2_cidr
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  depends_on = [
    aws_vpc.main_vpc
  ]
  tags = {
    "Name"                                 = "devops-public-2"
    "Project"                              = "devops"
    "kubernetes.io/cluster/devops-cluster" = "shared"
    "kubernetes.io/role/elb"               = "1"
  }
}

# --- GATEWAYS ---

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [
    aws_vpc.main_vpc
  ]
  tags = {
    "Name"    = "devops-eip"
    "Project" = "devops"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  depends_on = [
    aws_vpc.main_vpc
  ]
  tags = {
    "Name"    = "devops-igw"
    "Project" = "devops"
  }
}

resource "aws_nat_gateway" "nat" {
  subnet_id         = aws_subnet.pub_subnet_1.id
  allocation_id     = aws_eip.nat_eip.id
  connectivity_type = "public"
  depends_on = [
    aws_subnet.pub_subnet_1,
    aws_eip.nat_eip,
    aws_internet_gateway.igw
  ]
  tags = {
    "Name"    = "devops-nat"
    "Project" = "devops"
  }
}

# --- ROUTE TABLES ---

resource "aws_route_table" "priv_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.nat.id
      gateway_id                 = null
      vpc_peering_connection_id  = null
      local_gateway_id           = null
      carrier_gateway_id         = null
      core_network_arn           = null
      destination_prefix_list_id = null
      egress_only_gateway_id     = null
      ipv6_cidr_block            = null
      network_interface_id       = null
      transit_gateway_id         = null
      vpc_endpoint_id            = null
    }
  ]
  depends_on = [
    aws_nat_gateway.nat
  ]
  tags = {
    "Name"    = "devops-rtb-private"
    "Project" = "devops"
  }
}

resource "aws_route_table" "pub_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.igw.id
      nat_gateway_id             = null
      vpc_peering_connection_id  = null
      local_gateway_id           = null
      carrier_gateway_id         = null
      core_network_arn           = null
      destination_prefix_list_id = null
      egress_only_gateway_id     = null
      ipv6_cidr_block            = null
      network_interface_id       = null
      transit_gateway_id         = null
      vpc_endpoint_id            = null
    }
  ]
  depends_on = [
    aws_internet_gateway.igw
  ]
  tags = {
    "Name"    = "devops-rtb-public"
    "Project" = "devops"
  }
}

# --- SECURITY GROUP ---

resource "aws_security_group" "default_sg" {
  vpc_id      = aws_vpc.main_vpc.id
  name        = "devops-sg"
  description = "Security Group for DevOps project"
  ingress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = [var.vpc_cidr]
      self             = false
      description      = "VPC"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
    },
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = []
      self             = true
      description      = ""
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
    }
  ]
  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      self             = false
      description      = ""
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
    }
  ]
  depends_on = [
    aws_vpc.main_vpc
  ]
  tags = {
    "Name"    = "devops-sg"
    "Project" = "devops"
  }
}

# --- ASSOCIATIONS ---

resource "aws_route_table_association" "priv_subnet_1_association" {
  subnet_id      = aws_subnet.priv_subnet_1.id
  route_table_id = aws_route_table.priv_route_table.id
  depends_on = [
    aws_subnet.priv_subnet_1,
    aws_route_table.priv_route_table
  ]
}

resource "aws_route_table_association" "priv_subnet_2_association" {
  subnet_id      = aws_subnet.priv_subnet_2.id
  route_table_id = aws_route_table.priv_route_table.id
  depends_on = [
    aws_subnet.priv_subnet_2,
    aws_route_table.priv_route_table
  ]
}

resource "aws_route_table_association" "pub_subnet_1_association" {
  subnet_id      = aws_subnet.pub_subnet_1.id
  route_table_id = aws_route_table.pub_route_table.id
  depends_on = [
    aws_subnet.pub_subnet_1,
    aws_route_table.pub_route_table
  ]
}

resource "aws_route_table_association" "pub_subnet_2_association" {
  subnet_id      = aws_subnet.pub_subnet_2.id
  route_table_id = aws_route_table.pub_route_table.id
  depends_on = [
    aws_subnet.pub_subnet_2,
    aws_route_table.pub_route_table
  ]
}