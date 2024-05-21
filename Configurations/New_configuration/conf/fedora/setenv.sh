#setenv.sh
export CATALINA_HOME="/opt/tomcat"
export JAVA_HOME="/usr/lib/jvm/java-17.0.1-openjdk-amd64"
export JAVA_OPTS="-Djava.awt.headless=true -server -Xmx1500m -Xms1000m"
#export JAVA_OPTS="-Djava.awt.headless=true -Dfcrepo.config.file=/opt/fcrepo/config/fcrepo.properties -DconnectionTimeout=-1 -server -Xmx1500m -Xms1000m"
#export JAVA_OPTS="-Djava.awt.headless=true -Dfcrepo.config.file=/opt/fcrepo/config/fcrepo.properties -DconnectionTimeout=-1 -Dlogback.configurationFile=/opt/fcrepo/config/fcrepo-logback.xml -server -Xmx1500m -Xms1000m"
#export JAVA_OPTS="-Djava.awt.headless=true -Dfcrepo.config.file=/opt/fcrepo/config/fcrepo.properties -DconnectionTimeout=-1 -Dlogback.configurationFile=/opt/fcrepo/config/fcrepo-logback.xml -Dcom.bigdata.rdf.sail.webapp.ConfigParams.propertyFile=/opt/blazegraph/conf/RWStore.properties -Dlog4j.configuration=file:/opt/blazegraph/conf/log4j.properties -server -Xmx1500m -Xms1000m"


#export JAVA_OPTS="-Djava.awt.headless=true -Dfcrepo.config.file=/opt/fcrepo/config/fcrepo.properties -DconnectionTimeout=-1 -Dcom.bigdata.rdf.sail.webapp.ConfigParams.propertyFile=/opt/blazegraph/conf/RWStore.properties -Dlog4j.configuration=file:/opt/blazegraph/conf/log4j.properties -server -Xmx1500m -Xms1000m"
