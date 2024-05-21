#!/bin/bash
cd /opt
sudo git clone https://github.com/Islandora/Crayfish.git crayfish
sudo chown -R www-data:www-data crayfish
sudo -u www-data composer install -d crayfish/Homarus
sudo -u www-data composer install -d crayfish/Houdini
sudo -u www-data composer install -d crayfish/Hypercube
sudo -u www-data composer install -d crayfish/Milliner
sudo -u www-data composer install -d crayfish/Recast
sudo mkdir /var/log/islandora
sudo chown www-data:www-data /var/log/islandora
