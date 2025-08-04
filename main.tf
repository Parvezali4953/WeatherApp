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
    cidr_blocks = ["106.201.25.252/32"]  # Replace with your IP
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

resource "aws_cloudwatch_log_group" "weather_logs" {
  name              = "/weather/app/logs"
  retention_in_days = 7
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "HighCPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alarm when CPU exceeds 70% for 5 minutes"
  dimensions = {
    InstanceId = aws_instance.weather_ec2.id
  }
}

resource "aws_s3_bucket" "weather_logs" {
  bucket = "weatherapp-logs"
}

output "ec2_public_ip" {
  value = aws_instance.weather_ec2.public_ip
}

output "elb_dns_name" {
  value = aws_elb.weather_lb.dns_name
}