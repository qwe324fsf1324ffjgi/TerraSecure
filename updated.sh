#!/bin/bash

# Update the system and install Python and other dependencies
sudo yum update -y
sudo yum install -y python3 python3-pip git

# Clone your Python app repository (replace with your GitHub repo URL)
git clone https://github.com/qwe324fsf1324ffjgi/python-app.git
cd python-app  # Replace with the correct directory name after cloning

# Install the Python app dependencies
pip3 install -r requirements.txt

# Create a systemd service to manage the Flask app
echo "[Unit]
Description=Python Flask App
After=network.target

[Service]
ExecStart=/usr/bin/python3 /home/ec2-user/python-app/app.py
WorkingDirectory=/home/ec2-user/python-app
User=ec2-user
Group=ec2-user
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=python-flask-app

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/python-flask-app.service

# Reload systemd to recognize the new service
sudo systemctl daemon-reload

# Start the Flask app service
sudo systemctl start python-flask-app

# Enable the Flask app to start on boot
sudo systemctl enable python-flask-app

# Check the status of the Flask app service
sudo systemctl status python-flask-app

# Install CloudWatch Logs agent
# Install AWS CloudWatch Logs agent using the CloudWatch Agent (the recommended method)
sudo yum install -y amazon-cloudwatch-agent

# Create configuration file for the CloudWatch agent
sudo mkdir -p /etc/awslogs

# Configure CloudWatch logs (you may need to tweak settings for your region)
echo "[general]" | sudo tee /etc/awslogs/awslogs.conf
echo "state_file = /var/lib/awslogs/agent-state" | sudo tee -a /etc/awslogs/awslogs.conf
echo "[/var/log/python_app.log]" | sudo tee -a /etc/awslogs/awslogs.conf
echo "log_group_name = python-app-logs" | sudo tee -a /etc/awslogs/awslogs.conf

# Obtain the instance ID using the metadata service (necessary for CloudWatch Logs stream name)
token=$(curl -s -X PUT http://169.254.169.254/latest/api/token -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
instance_id=$(curl -s -H "X-aws-ec2-metadata-token: $token" http://169.254.169.254/latest/meta-data/instance-id)
echo "log_stream_name = $instance_id" | sudo tee -a /etc/awslogs/awslogs.conf

echo "file = /var/log/python_app.log" | sudo tee -a /etc/awslogs/awslogs.conf

# Start the CloudWatch agent service
sudo systemctl start amazon-cloudwatch-agent

# Enable the CloudWatch agent to start on boot
sudo systemctl enable amazon-cloudwatch-agent

# Check if the CloudWatch agent is running properly
sudo systemctl status amazon-cloudwatch-agent
