**Pre-BUILD Requirements**

- download vmware
- https://www.vmware.com/products/workstation-pro/workstation-pro-evaluation.html
- LSU has a way to get a license: https://software.grok.lsu.edu/Article.aspx?articleId=20512
- LSU OneDrive link to [shared](https://lsumail2.sharepoint.com/:f:/r/sites/Team-LIB-WebDev/Shared%20Documents/LDL/LDL-2/islandora8_Build_Instructions/shared_vmware_files_for_building/real_shared?csf=1&web=1&e=0fvyiQ)

- create a vmware machine 
- choose ubuntu server 22.04 iso 
- 100 GB on one file for disk size 
- the vm must have network access (right click the vm, go to settings>network adapter, select "Bridged", then save)
- go through the os installation process
- set your username and password
- finish the OS installation
- when the installation finishes, you should accept the prompt to reboot the machine.
- when the vm boots, log in with you username and password you set.

***network debugging***

- try the "vmware-netcfg" command on the host machine if you have trouble connecting. 
- you may need to change between bridged and host-only connections (
- check your network connection in the command line with 
- ```ping www.google.com```
- if you get bytes back you're connection is good.

***enable shared folders on the virtual machine***
- (right click the vm, go to settings, click the options tab, select "Always Enabled" for shared folders
- (select a path to the "shared" folder from LSU OneDrive, click save)
- I keep my path simple and put the files in a folder called 'shared'
- my path is /mnt/hgfs/shared within the vm, if you use a different path, change it in all commands that use '/mnt/hgfs/shared'


### Begin Build

These commands should all be executed in sequence from within the vmware CLI:

- ```sudo apt -y update```
- ```sudo apt -y upgrade```
- ```sudo apt -y install apache2 apache2-utils```
- ```sudo a2enmod ssl```
- ```sudo a2enmod rewrite```
- ```sudo systemctl restart apache2```
- ```sudo usermod -a -G www-data `whoami` ```
- ```sudo usermod -a -G `whoami` www-data```

- Log out of the vm (CTL-D) (this is neccessary for group settings to be applied)
- Log back in

- ```ls /mnt/hgfs/shared```
- you should see the shared folders from LSU OneDrive. if you don't see the shared folder, run this command in the vmware cli:
- if bad mount point '/mnt/hgfs/' no such file or directory
- ```mkdir /mnt/hgfs/``` 
- ```sudo vmhgfs-fuse .host:/ /mnt/hgfs/ -o allow_other -o uid=1000```


- execute in the vmware cli after shared folders are connected:
- ```sh /mnt/hgfs/shared/scratch_1.sh```
the above command runs a script containing the following:
>```
>#!/bin/bash
>sudo apt install -y lsb-release gnupg2 ca-certificates apt-transport-https software-properties-common
>sudo add-apt-repository ppa:ondrej/php
>sudo add-apt-repository ppa:ondrej/apache2
>sudo apt update
>``` 
 
# Install php and postgresql:
- ```sh /mnt/hgfs/shared/scratch_2.sh```
the above command runs the following script the :
>```
>#!/bin/bash
>sudo apt -y install php8.3 php8.3-cli php8.3-common php8.3-curl php8.3-dev php8.3-gd php8.3-imap php8.3-mbstring php8.3-opcache php8.3-xml php8.3-yaml php8.3-zip libapache2-mod-php8.3 php-pgsql php-redis php-xdebug unzip
>sudo a2enmod php8.3
>sudo systemctl restart apache2
># set default php to the version we have insalled:
>sudo update-alternatives --set php /usr/bin/php8.3
>#install Postgresql
>sudo apt install -y postgresql-common
>sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
>sudo apt install -y postgresql-15
>```

Edit the postgresql.conf file starting at line 687

- ```sudo nano +687 /etc/postgresql/14/main/postgresql.conf```

change line 687 from 
>```
>#bytea_output = 'hex'
>```

change to
>```
>bytea_output = 'escape'
>```
- ```sudo systemctl restart postgresql```

# Setting Up PostgreSQL Database and User for Drupal 10:
***create up a drupal10 database and user***

- ```sudo -u postgres psql```

from within the postgres cli change to drupal10:
>```
>create database drupal10 encoding 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' TEMPLATE template0;
>create user drupal with encrypted password 'drupal';
>/q
>```

***Grant privileges, Enable extension,Modify database setting***
- ```sudo -u postgres psql```
>/c drupal10
>GRANT ALL PRIVILEGES ON DATABASE drupal10 TO drupal;
>GRANT CREATE ON SCHEMA public TO drupal;
>CREATE EXTENSION pg_trgm;
>\q

- ***Modify database setting***
>```
>ALTER DATABASE drupal10;
>SET bytea_output = 'escape';
>\q
>```
- ```sudo systemctl restart postgresql```
- ***Editing pg_hba.conf for User Authentication in PostgreSQL***
>cp /mnt/hgfs/shared/pg_hba.conf /etc/postgresql/15/main/
- Adds the following authentication settings for PostgreSQL users and databases on localhost. Note: Do not copy the configurations below into the pg_hba.conf file, as the indentations are incorrect.
>```
># Database administrative login by Unix domain socket
>local	  all		           all			                                  md5
>#local	  DATABASE		   USER			                                  METHOD
>```

# Install Composer

- ```sh /mnt/hgfs/shared/scratch_3.sh```

scratch_3.sh contents:
>```
>#!/bin/bash
>curl "https://getcomposer.org/installer" > composer-install.php
>chmod +x composer-install.php
>php composer-install.php
>sudo mv composer.phar /usr/local/bin/composer
>sudo mkdir /opt/drupal
>sudo chown www-data:www-data /opt/drupal
>sudo chmod 775 /opt/drupal
>sudo chown -R www-data:www-data /var/www/
>```


# Configure apache server settings:
- ```sudo cp /mnt/hgfs/shared/ports.conf /etc/apache2/ports.conf```
- ***Apache virtual host configuration***
- We edit the default virtual host configuration file located in /etc/apache2/sites-available/ and /etc/apache2/sites-enabled/.
- ```sudo cp /mnt/hgfs/shared/000-default.conf /etc/apache2/sites-enabled/000-default.conf```
- ```sudo cp /mnt/hgfs/shared/000-default.conf /etc/apache2/sites-available/000-default.conf```
- Copy command above edits the default virtual host configuration file located in /etc/apache2/sites-available/ and /etc/apache2/sites-enabled/.
>```
><VirtualHost *:80>
> ServerName localhost
> DocumentRoot "/opt/drupal/islandora-starter-site/web"
> <Directory "/opt/drupal/islandora-starter-site/web">
>   Options Indexes FollowSymLinks MultiViews
>   AllowOverride all
>   Require all granted
> </Directory>
> # Ensure some logging is in place.
> ErrorLog "/var/log/apache2/localhost_error.log"
> CustomLog "/var/log/apache2/localhost_access.log" combined
></VirtualHost>
>```
>
***Now We create a Drupal virtual host configuration file using***
- ```sudo nano /etc/apache2/sites-available/drupal.conf```
>```
>Alias /drupal "/opt/drupal"
>DocumentRoot "/opt/drupal"
><Directory /opt/drupal>
>    AllowOverride All
>    Require all granted
></Directory>
>```
- ***Later in the installation steps, when we create an Islandora Starter Site project, we need to edit the root directory in the Apache configuration files as shown below:***

#### 1. Edit drupal.conf:
>```
>Alias /drupal "/opt/drupal/islandora-starter-site/web"
>DocumentRoot "/opt/drupal/islandora-starter-site/web"
><Directory /opt/drupal/islandora-starter-site>
>```

#### 2. Edit 000-default.conf:
>```
> DocumentRoot "/opt/drupal/islandora-starter-site/web"
> <Directory "/opt/drupal/islandora-starter-site/web">
>```

#### Configuring and Securing Apache for Drupal Deployment
- ```sudo systemctl restart apache2``` 
- ```sudo a2ensite drupal```
- ```sudo a2enmod rewrite```
- ```sudo systemctl restart apache2```
- ```sudo chown -R www-data:www-data /opt/drupal```
- ```sudo chmod -R 755 /opt/drupal```


#### Add PDO extentions for postgresql and mysql:
- ```sh /mnt/hgfs/shared/PDO-extensions.sh```
The following shell script will execute the commands below:
>```
>sudo apt-get install php8.3-mysql
>sudo apt-get install php8.3-pgsql
>#For mariaDB
>sudo apt-get install php8.3-mysqli
>sudo add-apt-repository ppa:ondrej/php
>sudo add-apt-repository ppa:ondrej/apache2
>sudo apt update
>sudo systemctl restart apache2
>```

### Make sure postgresql and apache2 are both active:
- ```sudo systemctl restart postgresql apache2```
- ```sudo systemctl status postgresql apache2```


# install tomcat and cantaloupe
### Install JAVA 17.0.1 
- ***Create directory for Java installation:***
>```
>sudo mkdir /usr/lib/jvm
>cd /usr/lib/jvm
>```
- ***Download and extract the Java archive:***
>```
>sudo wget -O openjdk-17.0.1.tar.gz https://download.java.net/java/GA/jdk17.0.1/2a2082e5a09d4267845be086888add4f/12/GPL/openjdk-17.0.1_linux-x64_bin.tar.gz
>sudo tar -zxvf openjdk-17.0.1.tar.gz
>sudo mv jdk-17.0.1 java-17.0.1-openjdk-amd64
>```
- ***Set executable permissions and create a symbolic link:***
>```
>sudo chmod +x /usr/lib/jvm/java-17.0.1-openjdk-amd64/bin/java
>sudo ln -s /usr/lib/jvm/java-17.0.1-openjdk-amd64/bin/java /usr/bin/java
>```
- ***Verify the Java installation:***
>```
>java --version
>```
- ***Configure alternatives to manage different Java versions:***
>```
>sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-17.0.1-openjdk-amd64/bin/java 1
>update-alternatives --list java
>```
The output should include a line similar to: "/usr/lib/jvm/java-11-openjdk-amd64/bin/java"
note this path for later use as JAVA_HOME. it is the same as the path above without "/bin/java". "/usr/lib/jvm/java-117.0.1-openjdk-amd64"- ***Add Java_HOME in default environment variables***
- ***Add JAVA_HOME to Default Environment Variables:***
>```
>echo 'export JAVA_HOME=/usr/lib/jvm/java-17.0.1-openjdk-amd64' >> ~/.bashrc
>echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
>source ~/.bashrc
>```

### Install Tomcat:
- ***create tomcat user:***
- ```sudo addgroup tomcat```
- ```sudo adduser tomcat --ingroup tomcat --home /opt/tomcat --shell /usr/bin```
choose a password
ie: password: "tomcat"
press enter for all default user prompts
type y for yes

- ***install tomcat***
find the tar.gz here: https://tomcat.apache.org/download-90.cgi
copy the TOMCAT_TARBALL_LINK as of 09-06-23 it was: https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.80/bin/apache-tomcat-9.0.80.tar.gz
copy the TOMCAT_TARBALL_LINK as of 02-07-24 it was: https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz
- ```sh /mnt/hgfs/shared/scratch_5.sh```
The following shell script will execute the commands below:
>```
>cd /opt
>sudo mkdir tomcat
>sudo wget -O tomcat.tar.gz https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz
>sudo tar -zxvf tomcat.tar.gz
>sudo mv /opt/apache-tomcat-9.0.85/* /opt/tomcat
>sudo chown -R tomcat:tomcat /opt/tomcat
>```
scratch_5.sh (if the tomcat tarball link is different you must change the path in the script or run the commands in the scratch_5 alt section):

- ```sh /mnt/hgfs/shared/scratch_6.sh```

- ***Copy environment variables that includes java home to tomcat/bin***
>```
>//Make sure version of openjdk java is correct in JAVA_HOME:
>sudo cp /mnt/hgfs/shared/setenv.sh /opt/tomcat/bin/
>sudo chmod 755 /opt/tomcat/bin/setenv.sh
>sudo cp /mnt/hgfs/shared/tomcat.service /etc/systemd/system/tomcat.service
>sudo chmod 755 /etc/systemd/system/tomcat.service
>sudo systemctl start tomcat
>sudo systemctl enable tomcat
>sudo systemctl status tomcat
>```
- ***NOTE: Setenv fixed and updated***

### Cantatloupe:
- ***Install Cantaloupe 5.0.6***
if Cantaloupe version changes, change the version number
>```
>sudo wget -O /opt/cantaloupe.zip https://github.com/cantaloupe-project/cantaloupe/releases/download/v5.0.6/cantaloupe-5.0.6.zip
>sudo unzip /opt/cantaloupe.zip
>sudo mkdir /opt/cantaloupe_config
>```
- ***copy the configurations into cantaloupe_config***
- sudo cp cantaloupe-5.0.6/cantaloupe.properties.sample /opt/cantaloupe_config/cantaloupe.properties
- sudo cp cantaloupe-5.0.6/delegates.rb.sample /opt/cantaloupe_config/delegates.rb

- ***Copy cantaloupe service syetem directory, check the version of your cantaloup in cantaloupe.service***
>```
>sudo cp /mnt/hgfs/shared/cantaloupe.service /etc/systemd/system/cantaloupe.service
>sudo chmod 755 /etc/systemd/system/cantaloupe.service
>```
- ***Enable Cantaloupe***
>```
>sudo systemctl enable cantaloupe
>sudo systemctl start cantaloupe
>sudo systemctl daemon-reload
>```
- ***Configure Cantaloupe URL(Important)***
>```
>sudo nano /opt/cantaloupe_config/cantaloupe.properties
>base_uri = http://127.0.0.1:8182/iiif/2
>```
- ***Restart and Check the status***
>```
>sudo systemctl restart cantaloupe
>sudo systemctl status cantaloupe
>```

### Installing fedora
- ***stop tomcat and create fcrepo directy***
- ```sudo systemctl stop tomcat```
- ```sudo mkdir -p /opt/fcrepo/data/objects```
- ```sudo mkdir /opt/fcrepo/config```
- ```sudo chown -R tomcat:tomcat /opt/fcrepo```
- ```sudo -u postgres psql```

- ***Create fcrepo database, user, password in postgresql or maridb:***
sudo -u postgres psql
>```
>create database fcrepo encoding 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' TEMPLATE template0;
>create user fedora with encrypted password 'fedora';
>grant all privileges on database fcrepo to fedora;
>\q
>```

- ***Adding fedora configurations:***
- ```sudo sh /mnt/hgfs/shared/fedora-config.sh```
- ***NOTE: fedora-config.sh updated! fcrepo.properties was not added and configured, there are undefined values!***

fedora-config.sh contains:
>```
>#!/bin/bash
>sudo cp /mnt/hgfs/shared/conf/fedora/i8_namespaces.yml /opt/fcrepo/config/
>sudo chown tomcat:tomcat /opt/fcrepo/config/i8_namespaces.yml
>sudo chmod 644 /opt/fcrepo/config/i8_namespaces.yml
>sudo cp /mnt/hgfs/shared/conf/fedora/allowed_external_hosts.txt /opt/fcrepo/config/
>sudo chown tomcat:tomcat /opt/fcrepo/config/allowed_external_hosts.txt
>sudo chmod 644 /opt/fcrepo/config/allowed_external_hosts.txt
>sudo cp /mnt/hgfs/shared/conf/fedora/fcrepo.properties /opt/fcrepo/config/
>sudo chown tomcat:tomcat /opt/fcrepo/config/fcrepo.properties
>sudo chmod 640 /opt/fcrepo/config/fcrepo.properties
>sudo cp /mnt/hgfs/shared/repository.json /opt/fcrepo/config/repository.json
>sudo chown tomcat:tomcat /opt/fcrepo/config/repository.json
>sudo chmod 644 /opt/fcrepo/config/repository.json
>#fcrepo.properties(Recently added)
>sudo cp /mnt/hgfs/shared/conf/fedora/fcrepo.properties /opt/fcrepo/config/ 
>sudo chown tomcat:tomcat /opt/fcrepo/config/fcrepo.properties
>sudo chmod 644 /opt/fcrepo/config/fcrepo.properties 
>```

- double check /opt/fcrepo/config/allowed_hosts.txt got created
```cat /opt/fcrepo/config/allowed_hosts.txt```
- ***NOTE: Setenv fixed and updated***

- ***Adding the Fedora Variables to JAVA_OPTS, change setenv:***
```sudo nano /opt/tomcat/bin/setenv.sh```

uncomment line 5, comment line 4 (CTL-c) shows line number
save (CTL-o) exit (CTL+x)

- ```sudo chown tomcat:tomcat /opt/tomcat/bin/setenv.sh```

- ***Edit and Ensuring Tomcat Users Are In Place***
Add following to xml after version="1.0" in <tomcat-users>:
- ``sudo nano /opt/tomcat/conf/tomcat-users.xml``
>```
>  <role rolename="tomcat"/>
>  <role rolename="fedoraAdmin"/>
>  <role rolename="fedoraUser"/>
>  <user username="tomcat" password="TOMCAT_PASSWORD" roles="tomcat"/>
>  <user username="fedoraAdmin" password="FEDORA_ADMIN_PASSWORD" roles="fedoraAdmin"/>
>  <user username="fedoraUser" password="FEDORA_USER_PASSWORD" roles="fedoraUser"/>
>```
- ***tomcat users permissions:***
>```
>sudo chmod 600 /opt/tomcat/conf/tomcat-users.xml
>sudo chown tomcat:tomcat /opt/tomcat/conf/tomcat-users.xml
>```

#### downloade fedora Latest Release:
```sh /mnt/hgfs/shared/fedora-dl.sh```
The following shell script will execute the commands below
>```
>#!/bin/bash
>sudo wget -O fcrepo.war https://github.com/fcrepo/fcrepo/releases/download/fcrepo-6.4.0/fcrepo-webapp-6.4.0.war
>sudo mv fcrepo.war /opt/tomcat/webapps
>sudo chown tomcat:tomcat /opt/tomcat/webapps/fcrepo.war
>sudo systemctl restart tomcat
>```

you may want to check
visit: https://github.com/fcrepo/fcrepo/releases choose the latest version and ajust the commands below if needed


# Syn:
### Download syn:
check here for link: https://github.com/Islandora/Syn/releases/ copy the link (if changed from syn-1.1.1) and replace the link in the command below:
- run the command:
- ```sh /mnt/hgfs/shared/syn-dl.sh```
>```
>#!/bin/bash
>sudo wget -P /opt/tomcat/lib https://github.com/Islandora/Syn/releases/download/v1.1.1/islandora-syn-1.1.1-all.jar
>sudo chown -R tomcat:tomcat /opt/tomcat/lib
>sudo chmod -R 640 /opt/tomcat/lib
>```
### Generating an SSL Key for Syn and Placing the Syn Settings:
- ```sudo sh /mnt/hgfs/shared/syn-config.sh```
The following shell script will execute the commands below:
>```
>#!/bin/bash
>sudo mkdir /opt/keys
>sudo openssl genrsa -out "/opt/keys/syn_private.key" 2048
>sudo openssl rsa -pubout -in "/opt/keys/syn_private.key" -out "/opt/keys/syn_public.key"
>sudo chown www-data:www-data /opt/keys/syn*
>sudo mkdir /opt/syn
>sudo cp /mnt/hgfs/shared/syn-settings.xml /opt/fcrepo/config/
>sudo chown tomcat:tomcat /opt/fcrepo/config/syn-settings.xml
>sudo chmod 600 /opt/fcrepo/config/syn-settings.xml
>```
### Adding the Syn Valve to Tomcat | Enable the Syn Valve for all of Tomcat:
- ```sudo nano /opt/tomcat/conf/context.xml```
Add this line before the closing tag:
>```
><Valve className="ca.islandora.syn.valve.SynValve" pathname="/opt/fcrepo/config/syn-settings.xml"/>
></Context>
>```
- ```sudo systemctl restart tomcat```
### Redhat logging:
>``` 
>sudo cp /mnt/hgfs/shared/conf/fedora/fcrepo-logback.xml /opt/fcrepo/config/
>sudo chmod 644 /opt/fcrepo/config/fcrepo-logback.xml
>sudo chown tomcat:tomcat /opt/fcrepo/config/fcrepo-logback.xml
>```
>
- Then alter your $JAVA_OPTS like above to include:
- ```sudo nano /opt/tomcat/bin/setenv.sh```
- Comment line 5 and uncomment line 6
- **Before:** export JAVA_OPTS="-Djava.awt.headless=true -Dfcrepo.config.file=/opt/fcrepo/config/fcrepo.properties -DconnectionTimeout=-1 -server -Xmx1500m -Xms1000m"
- **After:** export JAVA_OPTS="-Djava.awt.headless=true -Dfcrepo.config.file=/opt/fcrepo/config/fcrepo.properties -Dlogback.configurationFile=/opt/fcrepo/config/fcrepo-logback.xml -DconnectionTimeout=-1 -server -Xmx1500m -Xms1000m"

# installing blazegraph
### Creating a Working Space for Blazegraph and install Blazegraph:
- ```sh /mnt/hgfs/shared/blazegraph-dl.sh```
>```
>sudo mkdir -p /opt/blazegraph/data
>sudo mkdir /opt/blazegraph/conf
>sudo chown -R tomcat:tomcat /opt/blazegraph
>cd /opt
>sudo wget -O blazegraph.war https://repo1.maven.org/maven2/com/blazegraph/bigdata-war/2.1.5/bigdata-war-2.1.5.war
>sudo mv blazegraph.war /opt/tomcat/webapps
>sudo chown tomcat:tomcat /opt/tomcat/webapps/blazegraph.war
>```
### Configuring Logging and Adding Blazegraph Configurations:
- ```sh /mnt/hgfs/shared/blazegraph_conf.sh```
The following shell script will execute the commands below:
>```
>#!/bin/bash
>#Configuring Logging
>sudo cp /mnt/hgfs/shared/log4j.properties /opt/blazegraph/conf/
>sudo chown tomcat:tomcat /opt/blazegraph/conf/log4j.properties
>sudo chmod 644 /opt/blazegraph/conf/log4j.properties
>#Adding a Blazegraph Configuration
>sudo cp /mnt/hgfs/shared/RWStore.properties /opt/blazegraph/conf
>sudo chown tomcat:tomcat /opt/blazegraph/conf/RWStore.properties
>sudo chmod 644 /opt/blazegraph/conf/RWStore.properties
>sudo cp /mnt/hgfs/shared/blazegraph.properties /opt/blazegraph/conf
>sudo chown tomcat:tomcat /opt/blazegraph/conf/blazegraph.properties
>sudo chmod 644 /opt/blazegraph/conf/blazegraph.properties
>sudo cp /mnt/hgfs/shared/inference.nt /opt/blazegraph/conf
>sudo chown tomcat:tomcat /opt/blazegraph/conf/inference.nt
>sudo chmod 644 /opt/blazegraph/conf/inference.nt
>sudo chown -R tomcat:tomcat /opt/blazegraph/conf
>sudo chmod -R 644 /opt/blazegraph/conf
>```
### Specifying the RWStore.properties in JAVA_OPTS:
- ```sudo nano /opt/tomcat/bin/setenv.sh```
Comment line 6 and uncomment line 7:

- **Before:** export JAVA_OPTS="-Djava.awt.headless=true -Dfcrepo.config.file=/opt/fcrepo/config/fcrepo.properties -DconnectionTimeout=-1 -server -Xmx1500m -Xms1000m"
- **After:** export JAVA_OPTS="-Djava.awt.headless=true -Dfcrepo.config.file=/opt/fcrepo/config/fcrepo.properties -Dlogback.configurationFile=/opt/fcrepo/config/fcrepo-logback.xml -DconnectionTimeout=-1 Dcom.bigdata.rdf.sail.webapp.ConfigParams.propertyFile=/opt/blazegraph/conf/RWStore.properties -Dlog4j.configuration=file:/opt/blazegraph/conf/log4j.properties -server -Xmx1500m -Xms1000m"
- sudo systemctl restart tomcat
### Installing Blazegraph Namespaces and Inference:
- ```sudo curl -X POST -H "Content-Type: text/plain" --data-binary @/opt/blazegraph/conf/blazegraph.properties http://localhost:8080/blazegraph/namespace```

If this worked correctly, Blazegraph should respond with **"CREATED: islandora"** to let us know it created the islandora namespace.

- ```sudo curl -X POST -H "Content-Type: text/plain" --data-binary @/opt/blazegraph/conf/inference.nt http://localhost:8080/blazegraph/namespace/islandora/sparql```

If this worked correctly, Blazegraph should respond with some XML letting us know it added the 2 entries from inference.nt to the namespace.

# installing solr
#### Check JAVA_HOME:
- ```sudo nano ~/.bashrc```
>```
>export JAVA_HOME=/usr/lib/jvm/java-17.0.1-openjdk-amd64
>export PATH=$JAVA_HOME/bin:$PATH
>```
- ```source ~/.bashrc```

#### download 9.x solr:
>```
>cd /opt
>sudo wget https://www.apache.org/dyn/closer.lua/solr/solr/9.6.0/solr-9.6.0.tgz?action=download```
>sudo mv solr-9.6.0.tgz?action=download solr-9.6.0.tgz```
>sudo tar xzf solr-9.6.0.tgz solr-9.6.0/bin/install_solr_service.sh --strip-components=2
>```
#### Install Solr:
run following as root to extract and install solr:

- ```sudo bash ./install_solr_service.sh solr-9.6.0.tgz -i /opt -d /var/solr -u solr -s solr -p 8983```

##### Runnig the above command will do the following:
- extracted solr-9.6.0 to /opt
- symlink /opt.solr -> /opt/solr-9.6.0
- installed /etc/init.d/solr script 
- installed /etc/default/solr.in.sh
- service solr installed
##### to customize solr startup configuration go to this directory /etc/default/solr.in.sh:
- SOLR_PID_DIR="/var/solr"
- SOLR_HOME="/var/solr/data"
- LOG4J_PROPS="/var/solr/log4j2.xml"
- SOLR_LOGS_DIR="/var/solr/logs"
- SOLR_PORT="8983"
  
#### Adjust Kernel Parameters:

- ```sudo su```
- ```sudo echo "fs.file-max = 65535" >> /etc/sysctl.conf```
- ```sudo sysctl -p```

#### Create Solr Core

- ```sudo mkdir -p /var/solr/data/islandora8```
- ```sudo mkdir -p /var/solr/data/islandora8/conf```
- ```cp /mnt/shared/solr_9.x_config/* /var/solr/data/islandora10/conf/```
- ```sudo chown -R solr:solr /var/solr```
- ```cd /opt/solr```
- ```sudo -u solr bin/solr create -c islandora10 -p 8983```
**We will configure index via gui after site installed***

# Crayfish microservices
#### Adding this PPA to your system:
- ```sudo add-apt-repository -y ppa:lyrasis/imagemagick-jp2```
- ```sudo apt-get update```
- ```sudo apt-get -y install imagemagick tesseract-ocr ffmpeg poppler-utils```

#### Cloning and Installing Crayfish:
- ```sh /mnt/hgfs/shared/crayfish_reqs.sh```

It's running the following:
>```
>cd /opt
>sudo git clone https://github.com/Islandora/Crayfish.git crayfish```
>sudo chown -R www-data:www-data crayfish```
>sudo -u www-data composer install -d crayfish/Homarus
>sudo -u www-data composer install -d crayfish/Houdini
>sudo -u www-data composer install -d crayfish/Hypercube
>sudo -u www-data composer install -d crayfish/Milliner
>sudo -u www-data composer install -d crayfish/Recast
>```
#### Preparing Logging:
- ```sudo mkdir /var/log/islandora```
- ```sudo chown www-data:www-data /var/log/islandora```

#### moving config files over:
- ```sh /mnt/hgfs/shared/conf/Crayfish-confs/microservices-config.sh```

Folowing command will move Crayfish Microservices Config files and Apache Config files over.
- ```sudo a2enconf Homarus Houdini Hypercube Milliner Recast```
- ```sudo systemctl reload apache2```

# ActiveMQ/Alpaca/Karaf/Crayfish:
### 1. ActiveMQ:
#### The latest ActiveMQ manual installation:
>```
>cd /usr/share/
>sudo wget https://archive.apache.org/dist/activemq/6.1.2/apache-activemq-6.1.2-bin.zip
>sudo unzip apache-activemq-6.1.2-bin.zip
>sudo mv apache-activemq-6.1.2 activemq
>```
- Create directories:
>```
>sudo mkdir -p /var/lib/activemq
>sudo mkdir -p /var/lib/activemq/conf
>```

#### Create an ActiveMQ System User and Set Permissions:
>```
>cd /usr/share/activemq
>sudo useradd -r activemq -d /var/lib/activemq -s /sbin/nologin
>sudo chown -R activemq:activemq /var/lib/activemq
>sudo chown -R activemq:activemq /usr/share/activemq
>```

#### Set Up Service:
- ```sudo cp /mnt/hgfs/shared/activemq.service /etc/systemd/system/activemq.service```
- reload systemd to recognize the new service ```sudo systemctl daemon-reload```

#### Enable an start Service:
>```
>sudo systemctl enable activemq
>sudo systemctl start activemq
>sudo systemctl status activemq
>```

#### Set manual ActiveMQ as default ActiveMQ:
add activemq bin directory to default environment variable:
>```
>sudo ~/.bashrc
>export PATH=$PATH:/usr/share/activemq/bin
>source ~/.bashrc
>```

#### Create a symbolic link For ActiveMQ:
- ```sudo ln -s /usr/share/activemq/bin/activemq /usr/local/bin/activemq```
- Check ActiveMQ Version to make sure it is installed and system can find the right service version:
- ```activemq --version```

#### ActiveMQ ConfigurationL(Important)
ActiveMQ expected to be listening for STOMP messages at a tcp url. If not the default tcp://127.0.0.1:61613, this will have to be set:
- ```sudo nano /usr/share/activemq/conf/activemq.xml```
- Inside the <transportConnectors> element, find the configuration for the STOMP transport connector and change the stomp url to 127.0.0.1:61613
- ```name="stomp" uri="stomp://127.0.0.1:61613"```

# 2. Karaf 
karaf is not been used to install latest Alpaca Microservices any more, We will install alpaca Microservices in a another way later

# 3. Alpaca:
Check Alpaca installation in offial Islandora Github:

- (https://islandora.github.io/documentation/installation/manual/installing-alpaca/)

# Download and Scaffold Drupal, Create a project using the Islandora Starter Site:
#### install php-intl 8.3:
```sudo apt-get install php8.3-intl```

#### create islandora starter site project(Check with dockerized to see if we need latest version maybe?)
- ```cd /opt/drupal```
- ```sudo composer create-project islandora/islandora-starter-site:1.8.0```
- ```cd /opt/drupal/islandora-starter-site```

#### Install drush using composer at islandora-starter-site
- ```sudo chown -R www-data:www-data /opt/drupal/islandora-starter-site```
- ```sudo chmod 777 -R /opt/drupal/islandora-starter-site```
- ```sudo -u www-data composer require drush/drush```
- ```sudo ln -s /opt/drupal/islandora-starter-site/vendor/bin/drush /usr/local/bin/drush```
- ```ls -lart /usr/local/bin/drush```

#### Configure Settings.php and add Flysystem's fedora and trusted host:
```sudo nano web/sites/default/settings.php```
>```
>$settings['trusted_host_patterns'] = [
>  'localhost',
>  'YOUR_IP',
>];
>
>$settings['flysystem'] = [
>  'fedora' => [
>    'driver' => 'fedora',
>    'config' => [
>      'root' => 'http://127.0.0.1:8080/fcrepo/rest/',
>    ],
>  ],
>];
>```
#### Fix Apache configurations root directories:
- Fix path in apache **000.default.conf** and drupal.conf to **/opt/drupal/islandora-starter-site/web**, in **site-available** and **site-enabled**:
#### 1. Edit drupal.conf:
```sudo nano /etc/apache2/sites-available/drupal.conf```

Bellow is the lines that need to be set to in drupal.conf.
>```
>Alias /drupal "/opt/drupal/islandora-starter-site/web"
>DocumentRoot "/opt/drupal/islandora-starter-site/web"
><Directory /opt/drupal/islandora-starter-site>
>```

#### 2. Edit 000-default.conf:
sudo cp /mnt/hgfs/shared/000-default.conf /etc/apache2/sites-enabled/000-default.conf
sudo cp /mnt/hgfs/shared/000-default.conf /etc/apache2/sites-available/000-default.conf
Bellow is the lines that need to be set to in 000-default.conf.
>```
> DocumentRoot "/opt/drupal/islandora-starter-site/web"
> <Directory "/opt/drupal/islandora-starter-site/web">
>```

Then restart apache2 ```sudo systemctl restart apache2```

#### change permission on the web directory:
- ```sudo chown -R www-data:www-data /opt/drupal/islandora-starter-site/web```
- ```sudo chmod -R 755 /opt/drupal/islandora-starter-site/web```

#### Again, make sure you have already done followings:
- You should have granted all privileges to the user Drupal when created the table and databases before site install so that these are all permissions on user to create tables on database.
- You should have installed PDO extention before site install.

# Install the site using composer or drush:
- **1. install using Composer:**
  - ```composer exec -- drush site:install --existing-config```
 
- **2. Install with Drush:**
  - ```sudo -u www-data drush site-install --existing-config --db-url="pgsql://drupal:drupal@127.0.0.1:5432/drupal10"```
#### Change default username and password:
- ```sudo drush upwd admin admin```

# Add a user to the fedoraadmin role:(Optional)
for example, giving the default admin user the role:

#### 1. Using Composer:
- ```cd /opt/drupal/islandora-starter-site```
- ```composer exec -- drush user:role:add fedoraadmin admin```
 
#### 2. Using Drush:**
- cd /opt/drupal/islandora-starter-site
- sudo -u www-data drush -y urol "fedoraadmin" admin

# Configure the locations of external services:
Some, we already configured in prerequsits, but we will make sure all the configurations are in place.
#### Check following configurations before moving forward:
- check if your services like cantaloupe, apache, tomcat, databases are available and working
- check if you have already configured the cantaloup IIIF base URL to http://127.0.0.1:8182/iiif/2
- check if you have already configured activemq.xml in name="stomp" uri="tcp://127.0.0.1:61613"

#### solr search_api installation and fiele size:
- ```sudo -u www-data composer require drupal/search_api_solr```

### Configurations:
#### 1. Configure Cantaloupe OpenSeaDragon:
- In GUI:
- Navigate to ```http://[your-site-ip-address]/admin/config/media/openseadragon```

- set location of the cantaloupe iiif endpoint to http://localhost:8182/iiif/2

- select IIIF Manifest from dropdown

- save

- In settings.php:
  - $settings['openseadragon.settings']['iiif_server'] = 'http://127.0.0.1:8182/iiif/2';

#### Configure Cantaloupe for Islandora IIIF:
- In GUI:
  - /admin/config/islandora/iiif
  - set location of the cantaloupe: http://127.0.0.1:8182/iiif/2
- In settings.php:
  - $settings['islandora_iiif.settings']['iiif_server'] = 'http://127.0.0.1:8182/iiif/2';

#### Configure ActiveMQ, islandora message broker sertting url:
- In GUI:
  - /admin/config/islandora/core
  - set brocker URL to tcp://127.0.0.1:61613 

- In settings.php:
  - $settings['islandora.settings']['broker_url'] = 'tcp://127.0.0.1:61613';

- If activeMQ was not active check activemq.service:
  - sudo netstat -tuln | grep LISTEN
  - Check if 61613 is active and being listed to
 
#### Configure solr:
- **Check for bellow configuration:**
  - Check solr is availabe at port 8983: sudo netstat -tuln | grep LISTEN
  - Check solr is running if not run: sudo /opt/solr/bin/start 
  - Then restart: sudo systemctl restart solr
  - Check if your solr core is installed!

- **In GUI**: Navigate to admin/config/search/search-api edit the existing server or create one:
  - backend: Solr
  - Solr Connector: Standard
  - Solr core: islandora8
- **In settings.php:**
  - Set search_api.server.default_solr_server backend_config.connector_config.host
    - $settings['search_api.server.default_solr_server']['backend_config']['connector_config']['host'] = '127.0.0.1';

  - Solr port: Set search_api.server.default_solr_server backend_config.connector_config.port
    - $settings['search_api.server.default_solr_server']['backend_config']['connector_config']['port'] = '8983';
   
  - Solr, core name: Set search_api.server.default_solr_server backend_config.connector_config.core
    - $settings['search_api.server.default_solr_server']['backend_config']['connector_config']['core'] = 'islandora8';
 
#### Check syn/jwt configuration
#### keys must be available at /opt/keys/syn_private.key
 - Symlinking the private key to /opt/drupal/keys/private.key
   - ```sudo ln -s /opt/keys/syn_private.key /usr/local/bin/drush```
- **In GUI:**
  - First, Navigate to /admin/config/system/keys/add
    - key type: JWT RSA KEy
    - JWT Algorithm: RSAASA-PKCXS1-v1_5 Using SHA-256(RS256)
    - Key Provider: file
    - File location: /opt/keys/syn_private.key
    - Save
   
 - Then, Navigate to /admin/config/system/jwt
    - Select the key you justy created
    - Save configuration

#### Select default Flysystem:
visit /admin/config/media/file-system to select the flysystem from the dropdown.


# Run the migrations command and Enabling EVA Views:
run the migration tagged with islandora  to populate some taxonomies.

#### Run the migrations taged with islandora:
- ```composer exec -- drush migrate:import --userid=1 --tag=islandora```

#### Enabling EVA Views:
- ```drush -y views:enable display_media```

# instrall group modules and dependencies:
- ```cd /opt/drupal/islandora-starter-site```
- ```sudo -u www-data composer require digitalutsc/islandora_group```
- ```sudo -u www-data composer require 'drupal/rules:^3.0@alpha'```
- ```drush en -y islandora_group gnode```
#### Rebuild Cache:
- ```drush cr```

# Group Configuration:
#### group type:
- set available content and install group media and group media image and all:

Navigate to ```configuration -> access controll -> islandora access and select islandora_access```

#### create a group:
- Navigate to ```structure -> content types -> repository item -> manage fields -> create a access terms -> type is Reference -> Reference type: Taxonomy term, Vocabulary: Islandora Access```

#### Media type:
- Navigate to ```structure -> mediatypes -> edit one of the media types -> edit -> manage fields -> create a field -> create a access terms -> type is Reference -> Reference type = Islandora Access```

#### Media types Access term:
- for each media type we need to have access terms so we re use the one we created

Navigate to ```configuration -> access controll -> islandora access and select islandora_access -> select islandora_access```

#### Groups role and group role permissions:
- Groups must be created with the Administrator role, insider and ousider, and individual user. 
  - If not, the groups created will not be hidden from the administrator account. 
- If you find yourself unable to delete a group type due to hidden groups 
   - Edit the Roles under the group type and creat an Outsider Administrator Role that can see and delete individual groups 

#### Fix the destination for each media type (Important for media ingestion for each media types):
- Navigate ```Structure>Media types```
 
- for each media type edit the field that type is file and set Upload destination to the Public files instead of fedora:
   - Example: for audio: field_media_audio_file
   - Except image, and specifically, field_media_image that file type is image

- Ensure you have set maxiumum file size
   - we can do it at this point if where we're editing each mediaTypes 
   - might be doable in settings.php, when we setting flysystem to fedora
   - might any settings that we define the destination such as apache php.ini

- restart apache and tomcat, daemon-reload, cache rebuild

# re-islandora Workbench to be on V1.0.0:
#### Remove dev version and install V1 cause dev version is not determined by workbench anymore:
- remove mjordan/islandora_workbench_integration from composer.json and update composer

```composer update```

#### Re-install and enable(Running command bellow will get V1 ) 
- ```sudo -u www-data composer require mjordan/islandora_workbench_integration```
- ```drush en -y islandora_workbench_integration```
- ```drush cr```
- ```sudo systemctl restart apache2 tomcat postgresql```
- ```sudo systemctl daemon-reload```

#### enable rest endpoints for workbench then rebuild the cache:
- ```drush cim -y --partial --source=/opt/drupal/islandora-starter-site/web/modules/contrib/islandora_workbench_integration/config/optional```
- ```drush cr -y```

#### If you had issue with number of file uploads check apache setting at /etc/php/8.3/apache2/php.ini
- ```sudo nano /etc/php/8.3/apache2/php.ini```
- ```max_file_uploads = ???```

# Fix postgresql mimic_implicite error fix after islandora_group, islandora workbench installation:
mimic_implicite for postgresql error occures while creating new content, After groupmedia module installaion, causes the content not to be created in postgresql database

#### Copy the fixed postgresql edited php files over:
- ```sudo cp /mnt/hgfs/shared/conf/postgreSQL/pgsql-drivers/core-module-pgsql-src-Driver/Connection.php /opt/drupal/islandora-starter-site/web/core/modules/pgsql/src/Driver/Database/pgsql/```
- ```sudo cp /mnt/hgfs/shared/conf/postgreSQL/pgsql-drivers/core-module-pgsql-src-Driver/Select.php /opt/drupal/islandora-starter-site/web/core/modules/pgsql/src/Driver/Database/pgsql/```
- ```drush cr```
- ```sudo systemctl daemon-reload```
- ```sudo systemctl restart apache2 postgresql```
- ```sudo systemctl status apache2 postgresql```

# Configure default Flysystem

# Run workbench ingest:
- after running our transformation tools, we now run the workbench to ingest our content to the server:
   - ```cd islandora_workbench```
   - ./workbench --config LDLingest.yml```
