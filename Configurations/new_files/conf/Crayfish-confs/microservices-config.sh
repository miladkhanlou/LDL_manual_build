#!/bin/bash

#Homarus Configs
#sudo rm -r /opt/crayfish/Homarus/cfg
sudo mkdir /opt/crayfish/Homarus/cfg
sudo cp /mnt/hgfs/shared/conf/Crayfish-confs/homarus.config.yaml /opt/crayfish/Homarus/cfg/config.yaml
#houdini Configs
sudo cp /mnt/hgfs/shared/conf/Crayfish-confs/houdini.services.yaml /opt/crayfish/Houdini/config/services.yaml
sudo cp /mnt/hgfs/shared/conf/Crayfish-confs/crayfish_commons.yml /opt/crayfish/Houdini/config/packages/crayfish_commons.yml
sudo cp /mnt/hgfs/shared/conf/Crayfish-confs/monolog.yml /opt/crayfish/Houdini/config/packages/monolog.yml
sudo cp /mnt/hgfs/shared/conf/Crayfish-confs/security.yml /opt/crayfish/Houdini/config/packages/security.yml
#Hypercube Configs
sudo mkdir /opt/crayfish/Hypercube/cfg
sudo cp /mnt/hgfs/shared/conf/Crayfish-confs/hypercube.config.yaml /opt/crayfish/Hypercube/cfg/config.yaml
#Milliner Configs
sudo mkdir /opt/crayfish/Milliner/cfg/
sudo cp /mnt/hgfs/shared/conf/Crayfish-confs/milliner.config.yaml /opt/crayfish/Milliner/cfg/config.yaml
#Recast Configs
sudo mkdir /opt/crayfish/Recast/cfg
sudo cp /mnt/hgfs/shared/conf/Crayfish-confs/recast.config.yaml /opt/crayfish/Recast/cfg/config.yaml

#Permissions
sudo chown www-data:www-data /opt/crayfish/Homarus/cfg/config.yaml
sudo chmod 644 /opt/crayfish/Homarus/cfg/config.yaml
sudo chown www-data:www-data /opt/crayfish/Houdini/config/services.yaml
sudo chmod 644 /opt/crayfish/Houdini/config/services.yaml
sudo chown www-data:www-data /opt/crayfish/Houdini/config/packages/crayfish_commons.yml
sudo chmod 644 /opt/crayfish/Houdini/config/packages/crayfish_commons.yml
sudo chown www-data:www-data /opt/crayfish/Houdini/config/packages/monolog.yml
sudo chmod 644 /opt/crayfish/Houdini/config/packages/monolog.yml
sudo chown www-data:www-data /opt/crayfish/Houdini/config/packages/security.yml
sudo chmod 644 /opt/crayfish/Houdini/config/packages/security.yml
sudo chown www-data:www-data /opt/crayfish/Hypercube/cfg/config.yaml
sudo chmod 644 /opt/crayfish/Hypercube/cfg/config.yaml
sudo chown www-data:www-data /opt/crayfish/Recast/cfg/config.yaml
sudo chmod 644 /opt/crayfish/Recast/cfg/config.yaml
sudo chown www-data:www-data /opt/crayfish/Milliner/cfg/config.yaml
sudo chmod 644 /opt/crayfish/Milliner/cfg/config.yaml


#apache Configs
sudo cp /mnt/hgfs/shared/conf/Crayfish-confs/Homarus.conf /etc/apache2/conf-available/Homarus.conf
sudo chmod 644 /etc/apache2/conf-available/Homarus.conf
sudo chown root:root /etc/apache2/conf-available/Homarus.conf
sudo cp /mnt/hgfs/shared/conf/Crayfish-confs/Houdini.conf /etc/apache2/conf-available/Houdini.conf
sudo chmod 644 /etc/apache2/conf-available/Houdini.conf
sudo chown root:root /etc/apache2/conf-available/Houdini.conf
sudo cp /mnt/hgfs/shared/conf/Crayfish-confs/Hypercube.conf /etc/apache2/conf-available/Hypercube.conf
sudo chmod 644 /etc/apache2/conf-available/Hypercube.conf
sudo chown root:root /etc/apache2/conf-available/Hypercube.conf
sudo cp /mnt/hgfs/shared/conf/Crayfish-confs/Milliner.conf /etc/apache2/conf-available/Milliner.conf
sudo chmod 644 /etc/apache2/conf-available/Milliner.conf
sudo chown root:root /etc/apache2/conf-available/Milliner.conf
sudo cp /mnt/hgfs/shared/conf/Crayfish-confs/Recast.conf /etc/apache2/conf-available/Recast.conf
sudo chmod 644 /etc/apache2/conf-available/Recast.conf
sudo chown root:root /etc/apache2/conf-available/Recast.conf