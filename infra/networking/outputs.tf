output "vpc_id"            { value = aws_vpc.this.id }

output "public_subnet_ids" { value = [aws_subnet.public_a.id, aws_subnet.public_b.id] }

output "alb_sg_id"         { value = aws_security_group.alb.id }

output "app_sg_id"         { value = aws_security_group.app.id }
