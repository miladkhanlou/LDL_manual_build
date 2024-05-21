#!/bin/bash
#Configuring Logging
sudo cp /mnt/hgfs/shared/log4j.properties /opt/blazegraph/conf/
sudo chown tomcat:tomcat /opt/blazegraph/conf/log4j.properties
sudo chmod 644 /opt/blazegraph/conf/log4j.properties
#Adding a Blazegraph Configuration
sudo cp /mnt/hgfs/shared/RWStore.properties /opt/blazegraph/conf
sudo chown tomcat:tomcat /opt/blazegraph/conf/RWStore.properties
sudo chmod 644 /opt/blazegraph/conf/RWStore.properties
sudo cp /mnt/hgfs/shared/blazegraph.properties /opt/blazegraph/conf
sudo chown tomcat:tomcat /opt/blazegraph/conf/blazegraph.properties
sudo chmod 644 /opt/blazegraph/conf/blazegraph.properties
sudo cp /mnt/hgfs/shared/inference.nt /opt/blazegraph/conf
sudo chown tomcat:tomcat /opt/blazegraph/conf/inference.nt
sudo chmod 644 /opt/blazegraph/conf/inference.nt

sudo chown -R tomcat:tomcat /opt/blazegraph/conf
sudo chmod -R 644 /opt/blazegraph/conf
