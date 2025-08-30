resource "aws_security_group" "alb" {
  name        = "${var.project}-${var.environment}-alb-sg"
  description = "ALB SG"
  vpc_id      = aws_vpc.this.id

  ingress { 
    from_port = 80 
    to_port = 80 
    protocol = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
  egress  { 
    from_port = 0  
    to_port = 0  
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = { Name = "${var.project}-${var.environment}-alb-sg" }
}

resource "aws_security_group" "app" {
  name        = "${var.project}-${var.environment}-app-sg"
  description = "App SG"
  vpc_id      = aws_vpc.this.id

  ingress { 
    from_port = 5000 
    to_port = 5000 
    protocol = "tcp" 
    security_groups = [aws_security_group.alb.id] 
  }
  egress  { 
    from_port = 0    
    to_port = 0    
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = { Name = "${var.project}-${var.environment}-app-sg" }
}
