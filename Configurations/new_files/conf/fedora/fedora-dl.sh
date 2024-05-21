#!/bin/bash
sudo wget -O fcrepo.war https://github.com/fcrepo/fcrepo/releases/download/fcrepo-6.4.1/fcrepo-webapp-6.4.1.warsudo mv fcrepo.war /opt/tomcat/webapps
sudo wget -O fcrepo.war https://github.com/fcrepo/fcrepo/releases/download/fcrepo-6.5.0/fcrepo-webapp-6.5.0.war
sudo mv fcrepo.war /opt/tomcat/webapps
sudo chown tomcat:tomcat /opt/tomcat/webapps/fcrepo.war
sudo systemctl start tomcat

