resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.project}-${var.environment}-igw" }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = { Name = "${var.project}-${var.environment}-public-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags = { Name = "${var.project}-${var.environment}-public-b" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route { 
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_internet_gateway.igw.id 
  }
  tags = { Name = "${var.project}-${var.environment}-public-rt" }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# 1. EIP for NAT Gateway
resource "aws_eip" "nat" {
  tags = { Name = "${var.project}-${var.environment}-nat-eip" }
}

# 2. NAT Gateway
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id # NAT Gateway lives in the Public Subnet A
  tags = { Name = "${var.project}-${var.environment}-nat" }
  depends_on    = [aws_internet_gateway.igw]
}

# 3. Private Subnet A
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.3.0/24" # Next available range
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false # CRITICAL: No public IPs
  tags = { Name = "${var.project}-${var.environment}-private-a" }
}

# 4. Private Subnet B
resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.4.0/24" # Next available range
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false # CRITICAL: No public IPs
  tags = { Name = "${var.project}-${var.environment}-private-b" }
}

# 5. Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  # Route all outbound traffic (0.0.0.0/0) through the NAT Gateway
  route { 
    cidr_block = "0.0.0.0/0" 
    nat_gateway_id = aws_nat_gateway.this.id 
  }
  tags = { Name = "${var.project}-${var.environment}-private-rt" }
}

# 6. Private Route Table Associations
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}
