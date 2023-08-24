#!/bin/bash
sudo yum update -y
sudo yum install -y httpd git
sudo git clone https://github.com/gabrielecirulli/2048.git
sudo mkdir /var/www/html/2048
sudo cp -R 2048/* /var/www/html/2048
sudo systemctl start httpd
sudo systemctl enable httpd
