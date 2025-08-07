#!/bin/bash

set -e

# -------------------------
# 1. Update & Install Packages
# -------------------------
echo "> Updating system packages"
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl unzip git docker.io docker-compose

# -------------------------
# 2. Start Docker service
# -------------------------
sudo systemctl start docker
sudo systemctl enable docker

# -------------------------
# 3. Clone your app repo (if not already cloned)
if [ ! -d /opt/weather-devops ]; then
    git clone https://github.com/Parvezali4953/WeatherApp.git /opt/weather-devops
    echo "✅ Repo cloned successfully."
else
    echo "📁 Repo already exists, skipping clone."
fi

# -------------------------
# 4. Ensure logs directory exists (for app logs)
# -------------------------
echo "> Creating logs directory"
mkdir -p app/logs

# -------------------------
# 5. Run Docker Compose
# -------------------------
echo "> Running docker-compose"
docker-compose down || true
docker-compose up -d --build

# -------------------------
# 6. Install CloudWatch Agent
# -------------------------
echo "> Installing CloudWatch Agent"
cw_pkg="AmazonCloudWatchAgent.zip"
mkdir -p /opt/aws && cd /opt/aws || exit
curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/$cw_pkg
unzip -o $cw_pkg
sudo ./install

# -------------------------
# 7. Copy CloudWatch Config & Start Agent
# -------------------------
cp /opt/weather-devops/cloudwatch/cwagent-config.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.d/file_amazon-cloudwatch-agent.json
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.d/file_amazon-cloudwatch-agent.json \
  -s

# -------------------------
# 8. Done
# -------------------------
echo "> Deployment complete"
