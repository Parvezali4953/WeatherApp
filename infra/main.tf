provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0f918f7e67a3323f0" # Update with the latest Amazon Linux 2 AMI ID
  instance_type = "t2.micro"
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data              = file("../scripts/deploy.sh")

  root_block_device {
    volume_size = 25
    volume_type = "gp3"
  }

  tags = {
    Name = "FlaskWeatherApp"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ssm_parameter" "api_key" {
  name  = "API_KEY"
  type  = "SecureString"
  value = var.weather_api_key
}