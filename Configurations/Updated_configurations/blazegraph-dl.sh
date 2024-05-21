#!/bin/bash
sudo mkdir -p /opt/blazegraph/data
sudo mkdir /opt/blazegraph/conf
sudo chown -R tomcat:tomcat /opt/blazegraph
cd /opt
sudo wget -O blazegraph.war https://repo1.maven.org/maven2/com/blazegraph/bigdata-war/2.1.5/bigdata-war-2.1.5.war
sudo mv blazegraph.war /opt/tomcat/webapps
sudo chown tomcat:tomcat /opt/tomcat/webapps/blazegraph.war