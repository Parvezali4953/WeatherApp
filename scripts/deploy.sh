#!/bin/bash
apt update -y
apt install -y docker.io git awscli unzip curl
systemctl enable docker
systemctl start docker
cd /opt
git clone https://github.com/Parvezali4953/WeatherApp.git
cd weather-devops
API_KEY=$(aws ssm get-parameter --name "API_KEY" --with-decryption --query "Parameter.Value" --output text)
echo "API_KEY=$API_KEY" > .env
mkdir -p logs

# CloudWatch Agent install
curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# Copy config and start agent
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
cp cloudwatch/cwagent-config.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

docker-compose down || true
docker-compose up -d --build