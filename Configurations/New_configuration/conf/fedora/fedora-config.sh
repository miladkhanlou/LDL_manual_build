#!/bin/bash
sudo cp /mnt/hgfs/shared/conf/fedora/i8_namespaces.yml /opt/fcrepo/config/
sudo chown tomcat:tomcat /opt/fcrepo/config/i8_namespaces.yml
sudo chmod 644 /opt/fcrepo/config/i8_namespaces.yml

sudo cp /mnt/hgfs/shared/conf/fedora/allowed_external_hosts.txt /opt/fcrepo/config/
sudo chown tomcat:tomcat /opt/fcrepo/config/allowed_external_hosts.txt
sudo chmod 644 /opt/fcrepo/config/allowed_external_hosts.txt

sudo cp /mnt/hgfs/shared/conf/fedora/fcrepo.properties /opt/fcrepo/config/
sudo chown tomcat:tomcat /opt/fcrepo/config/fcrepo.properties
sudo chmod 640 /opt/fcrepo/config/fcrepo.properties

#extra from our build instructions
sudo cp /mnt/hgfs/shared/repository.json /opt/fcrepo/config/repository.json
sudo chown tomcat:tomcat /opt/fcrepo/config/repository.json
sudo chmod 644 /opt/fcrepo/config/repository.json

#fcrepo.properties
sudo cp /mnt/hgfs/shared/conf/fedora/fcrepo.properties /opt/fcrepo/config/ 
sudo chown tomcat:tomcat /opt/fcrepo/config/fcrepo.properties
sudo chmod 644 /opt/fcrepo/config/fcrepo.properties 