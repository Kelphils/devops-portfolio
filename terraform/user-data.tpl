#!/bin/bash
# codedeploy_agent installation
sudo apt update -y &&
sudo apt-get install ruby -y
sudo apt-get install wget -y
cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
service codedeploy-agent start
rm install

# cloudwatch_agent installation
cd $HOME
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
git clone https://github.com/Kelphils/devops-portfolio.git
sudo cp $HOME/devops-portfolio/terraform/cw_agent_config.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# nginx installation
cd $HOME
sudo apt install -y nginx
echo "Hello Nginx Demo" > /var/www/html/index.html
