#!/bin/bash
#sudo apt-get install php8.1-mysql
#sudo apt-get install php8.2-mysql


sudo apt-get install php8.3-mysql
#For mariaDB
sudo apt-get install php8.3-mysqli


sudo add-apt-repository ppa:ondrej/php
sudo add-apt-repository ppa:ondrej/apache2
#sudo apt-get install php8.1-pgsql
#sudo apt-get install php8.2-pgsql
sudo apt-get install php8.3-pgsql

sudo apt update 
sudo systemctl restart apache2