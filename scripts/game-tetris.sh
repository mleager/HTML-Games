#!/bin/bash
sudo yum update -y
sudo yum install -y httpd git
sudo git clone https://github.com/jakesgordon/javascript-tetris.git
sudo mkdir /var/www/html/tetris
sudo cp -R javascript-tetris/* /var/www/html/tetris
sudo systemctl start httpd
sudo systemctl enable httpd
