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

# install nodejs 14
# cd /home/ubuntu
# curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
# sudo apt-get install -y nodejs

# # clone repo and install dependencies
# cd /home/ubuntu
# git clone https://github.com/Kelphils/devops-portfolio.git
# cd devops-portfolio
# sudo sh -c 'npm i --force && npm run build'

# sleep 10

# # nginx installation
# cd /home/ubuntu
# sudo apt install -y nginx
# sleep 10
# sudo sh -c 'cp -r /home/ubuntu/devops-portfolio/build/. /var/www/html'
# sudo sh -c 'echo "server {\n  listen 80 default_server;\n  listen [::]:80;\n  server_name localhost;\n  root /var/www/html;\n  index index.html;\n\n  location / {\n    try_files $uri $uri/ /index.html =404;\n  }\n}" > /etc/nginx/sites-available/default'
# sudo nginx -s reload
# service nginx status

# # cloudwatch_agent installation
# cd /home/ubuntu
# wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
# sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
# git clone https://github.com/Kelphils/devops-portfolio.git
# sleep 10
# # Update Cloudwatch agent config with EC2 Tag Name
# sudo sh -c 'sed -ie "s/{tagname}/$TAG_VALUE/g" /home/ubuntu/devops-portfolio/config/cloudwatch/amazon-cloudwatch-agent.json'
# sudo sh -c 'cp /home/ubuntu/devops-portfolio/config/cloudwatch/amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json'
# # sudo sh -c 'cp /home/ubuntu/devops-portfolio/config/cloudwatch/amazon-cloudwatch-agent.json .'

# # start cloudwatch agent
# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# # check if cloudwatch_agent is running
# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status

# remove repo
# sudo rm -rf /home/ubuntu/devops-portfolio

# remove amazon-cloudwatch-agent.deb
# sudo rm -rf /home/ubuntu/amazon-cloudwatch-agent.deb