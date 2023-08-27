#!/bin/bash
sudo yum update -y
sudo yum install httpd git -y
sudo git clone https://github.com/jakesgordon/javascript-pong.git
sudo mkdir /var/www/html/pong
sudo cp -R javascript-pong/* /var/www/html/pong
sudo systemctl start httpd
sudo systemctl enable httpd
