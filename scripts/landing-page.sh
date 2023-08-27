#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo aws s3 cp s3://html-games-ml /var/www/html --recursive
sudo systemctl start httpd
sudo systemctl enable httpd
