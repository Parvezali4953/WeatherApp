provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "weather_ec2" {
  ami           = "ami-0f918f7e67a3323f0"  # Update with latest Amazon Linux 2 AMI
  instance_type = "t2.micro"
  tags = {
    Name = "FlaskWeatherApp"
  }
  key_name      = "awskey"  # Replace with your EC2 key pair
  security_groups = [aws_security_group.weather_sg.name]
}

resource "aws_security_group" "weather_sg" {
  name        = "weather-sg"
  description = "Security group for Weather App"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.9/32"]  # Replace with your IP
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "weather_lb" {
  name               = "WeatherLB"
  availability_zones = ["ap-south-1a", "ap-south-1b"]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  instances          = [aws_instance.weather_ec2.id]
  security_groups    = [aws_security_group.weather_sg.id]
}

resource "aws_ssm_parameter" "ec2_ip" {
  name  = "/weather/app/ec2_ip"
  type  = "String"
  value = aws_instance.weather_ec2.public_ip
}

output "ec2_public_ip" {
  value = aws_instance.weather_ec2.public_ip
}

output "elb_dns_name" {
  value = aws_elb.weather_lb.dns_name
}