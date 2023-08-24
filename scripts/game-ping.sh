#!/bin/bash

# Install HTTPD & Git
sudo yum update -y
sudo yum install httpd git -y

# Clone Git Repo into HTTPD 
sudo git clone https://github.com/jakesgordon/javascript-pong.git
sudo mkdir /var/www/html/pong
sudo cp -R javascript-pong/* /var/www/html/pong

# Start & Enable HTTPD
sudo systemctl start httpd
sudo systemctl enable httpd
