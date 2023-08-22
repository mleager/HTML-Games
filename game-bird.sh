#!/bin/bash
sudo yum update -y
sudo yum install -y httpd git
sudo git clone https://github.com/nebez/floppybird.git
sudo mkdir /var/www/html/floppybird
sudo cp -R floppybird/* /var/www/html/floppybird
sudo systemctl start httpd
sudo systemctl enable httpd
