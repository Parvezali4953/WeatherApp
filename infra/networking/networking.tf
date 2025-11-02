# infra/networking/networking.tf

# -----------------------------------------------------------------------------
# 1. Virtual Private Cloud (VPC)
#
# This creates an isolated virtual network in your AWS account where you can
# launch your resources.
# -----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Project     = var.project_name
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# 2. Public Subnets and Internet Gateway
#
# Public subnets are connected to the internet. We will place our public-facing
# Application Load Balancer in these subnets.
# -----------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

# Creates two public subnets in different Availability Zones for high availability.
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = "${var.aws_region}${element(["a", "b"], count.index)}"
  map_public_ip_on_launch = true # Instances launched here get a public IP.

  tags = {
    Name = "${var.project_name}-${var.environment}-public-${element(["a", "b"], count.index)}"
  }
}

# The public route table directs internet-bound traffic to the Internet Gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # Represents all internet traffic.
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

# Associates the public route table with our public subnets.
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------------------------
# 3. Private Subnets and NAT Gateway
#
# Private subnets are NOT connected directly to the internet. Our ECS tasks
# will live here for security. The NAT Gateway allows tasks to initiate
# outbound connections (e.g., to call the weather API) but prevents the
# internet from initiating connections to them.
# -----------------------------------------------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-${var.environment}-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Place the NAT Gateway in a public subnet.

  tags = {
    Name = "${var.project_name}-${var.environment}-nat"
  }

  depends_on = [aws_internet_gateway.main]
}

# Creates two private subnets in different Availability Zones.
resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 101}.0/24" # Use a different IP range.
  availability_zone       = "${var.aws_region}${element(["a", "b"], count.index)}"
  map_public_ip_on_launch = false # CRITICAL: No public IPs for instances.

  tags = {
    Name = "${var.project_name}-${var.environment}-private-${element(["a", "b"], count.index)}"
  }
}

# The private route table directs internet-bound traffic to the NAT Gateway.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt"
  }
}

# Associates the private route table with our private subnets.
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# -----------------------------------------------------------------------------
# 4. Security Groups
#
# These act as virtual firewalls for our resources, controlling inbound and
# outbound traffic at the instance/task level.
# -----------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Controls traffic for the Application Load Balancer."
  vpc_id      = aws_vpc.main.id

  # Ingress: Allow HTTP traffic from anywhere on the internet.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: Allow the ALB to send traffic anywhere (to the ECS tasks).
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-${var.environment}-ecs-tasks-sg"
  description = "Controls traffic for the ECS Fargate tasks."
  vpc_id      = aws_vpc.main.id

  # Ingress: Allow traffic ONLY from the ALB's security group on the app port.
  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Egress: Allow tasks to send traffic anywhere (needed to reach the NAT Gateway).
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
