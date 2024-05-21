#!/bin/bash
cd /opt
#O not 0
sudo mkdir tomcat
sudo wget -O tomcat.tar.gz https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz
sudo tar -zxvf tomcat.tar.gz
#don't miss the star*
sudo mv /opt/apache-tomcat-9.0.85/* /opt/tomcat
sudo chown -R tomcat:tomcat /opt/tomcat
