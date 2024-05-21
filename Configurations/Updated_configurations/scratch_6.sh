#!/bin/bash
#scratch_6

sudo cp /mnt/hgfs/shared/setenv.sh /opt/tomcat/bin/
sudo chmod 755 /opt/tomcat/bin/setenv.sh
sudo cp /mnt/hgfs/shared/tomcat.service /etc/systemd/system/tomcat.service
sudo chmod 755 /etc/systemd/system/tomcat.service
sudo systemctl start tomcat
sudo systemctl status tomcat

#check your cantaloupe version
#sudo wget -O /opt/cantaloupe.zip https://github.com/cantaloupe-project/cantaloupe/releases/download/v5.0.5/cantaloupe-5.0.5.zip
sudo wget -O /opt/cantaloupe.zip https://github.com/cantaloupe-project/cantaloupe/releases/download/v5.0.6/cantaloupe-5.0.6.zip
sudo unzip /opt/cantaloupe.zip
sudo mkdir /opt/cantaloupe_config

#sudo cp cantaloupe-5.0.5/cantaloupe.properties.sample /opt/cantaloupe_config/cantaloupe.properties
#sudo cp cantaloupe-5.0.5/delegates.rb.sample /opt/cantaloupe_config/delegates.rb
sudo cp cantaloupe-5.0.6/cantaloupe.properties.sample /opt/cantaloupe_config/cantaloupe.properties
sudo cp cantaloupe-5.0.6/delegates.rb.sample /opt/cantaloupe_config/delegates.rb
sudo cp /mnt/hgfs/shared/cantaloupe.service /etc/systemd/system/cantaloupe.service
sudo chmod 755 /etc/systemd/system/cantaloupe.service
sudo systemctl enable cantaloupe
sudo systemctl start cantaloupe
