# Describes adapted build using shared folders and scripts to manually build islandora.

**Notes**

This build is adapted from [official islandora documentation](https://islandora.github.io/documentation/installation/manual/introduction/) reading it is encouraged.
- check download links for new versions of software components.
- in the shared folder many confFig files and scripts are included to automate repeated steps. 
- enable shared folders in the virtual machine settings use the LSU Ondrive "shared folders"
- formatted code in this document is intended to be executed in the command line of the viIsrtual machine IE:
- `whoami`
- document assumes familiarity with CLI, file edititing and permissions
- Download vmware, and an [ubuntu server 22.04 image](https://ubuntu.com/download/server).

**Pre-BUILD Requirements**

- download vmware
- https://www.vmware.com/products/workstation-pro/workstation-pro-evaluation.html
- LSU has a way to get a license: https://software.grok.lsu.edu/Article.aspx?articleId=20512
- LSU OneDrive link to [shared](https://lsumail2.sharepoint.com/:f:/r/sites/Team-LIB-WebDev/Shared%20Documents/LDL/LDL-2/islandora8_Build_Instructions/shared_vmware_files_for_building/real_shared?csf=1&web=1&e=0fvyiQ)

- create a vmware machine 
- choose ubuntu server 22.04 iso 
- 20 GB on one file for disk size 
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
 
- execute in the vmware cli after shared folders are connected:
- ```sh /mnt/hgfs/shared/scratch_2.sh```
the above command runs the following script the :
>```
>#!/bin/bash
>sudo apt -y install php8.1 php8.1-cli php8.1-common php8.1-curl php8.1-dev php8.1-gd php8.1-imap php8.1-mbstring php8.1-opcache php8.1-xml php8.1-yaml php8.1-zip libapache2-mod-php8.1 php-pgsql php-redis php-xdebug unzip
>sudo a2enmod php8.1
>sudo systemctl restart apache2
># set default php to the version we have insalled:
>sudo update-alternatives --set php /usr/bin/php8.1
># Create the file repository configuration for postgres:
>sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
># Import the repository signing key for postgres:
>wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
>sudo apt-get update
>sudo apt-get install -y postgresql
>sudo systemctl status postgresql
>sudo systemctl restart postgresql
>sudo systemctl restart apache2
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

-when using nano you press (CTL+o) to save (CTL+x) to close

- ```sudo systemctl restart postgresql```

## Install Composer

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

## Add the islandora-starter-site project

- `cd /opt/drupal`
- `sudo -u www-data composer create-project islandora/islandora-starter-site:1.5.0`
- ```cd /opt/drupal/islandora-starter-site```

## Install and symlink Drush
  
- ```sudo -u www-data composer require drush/drush```
- ```sudo ln -s /opt/drupal/islandora-starter-site/vendor/bin/drush /usr/local/bin/drush```

confirm link:

- ```ls -lart /usr/local/bin/drush```

Expected output will link to /home/wwc/drupal-project/vendor/bin/drush

# copy and configure apache conf files:

- ```sudo cp /mnt/hgfs/shared/ports.conf /etc/apache2/ports.conf```
- ```sudo cp /mnt/hgfs/shared/000-default.conf /etc/apache2/sites-enabled/000-default.conf```
>```
><VirtualHost *:80>
>  ServerName localhost
>  DocumentRoot "/opt/drupal/islandora-starter-site/web"
>  <Directory "/opt/drupal/islandora-starter-site/web">
>    Options Indexes FollowSymLinks MultiViews
>    AllowOverride all
>    Require all granted
>  </Directory>
>  # Ensure some logging is in place.
>  ErrorLog "/var/log/apache2/localhost_error.log"
>  CustomLog "/var/log/apache2/localhost_access.log" combined
></VirtualHost>
>```

put the following the drupal.conf and 000-default.conf in sites-available directory.
You can comment out or delete everything in the file:
- ```sudo nano /etc/apache2/sites-available/drupal.conf```
>```
>Alias /drupal "/opt/drupal/islandora-starter-site/web"
>DocumentRoot "/opt/drupal/islandora-starter-site/web"
><Directory /opt/drupal/islandora-starter-site>
>    AllowOverride All
>    Require all granted
></Directory>
>```
- ```sudo nano /etc/apache2/sites-available/000-default.conf```
>```
>Alias /drupal "/opt/drupal/islandora-starter-site/web"
>DocumentRoot "/opt/drupal/islandora-starter-site/web"
><Directory /opt/drupal/islandora-starter-site>
>    AllowOverride All
>    Require all granted
></Directory>
>```
Then run:
- ```sudo systemctl restart apache2``` 
- ```sudo a2ensite drupal```
- ```sudo a2enmod rewrite```
- ```sudo systemctl restart apache2```
- ```sudo chown -R www-data:www-data /opt/drupal/islandora-starter-site/web```
- ```sudo chmod -R 755 /opt/drupal/islandora-starter-site/web```

***create a database***

- ```sudo -u postgres psql```

#from within the postgres cli change to drupal10:
>```
>create database drupal10 encoding 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' TEMPLATE template0;
>create user drupal with encrypted password 'drupal';
>grant all privileges on database drupal10 to drupal;
>```

type ```\q``` to quit

For DRUPAL 10:

- ```sudo -u postgres psql```
- from within the postgres cli:
>```
>\c drupal10
>CREATE EXTENSION pg_trgm;
>\q
>```
### Add PDO extentions for postgresql and mysql:
look for pdo_mysql.ini file. 
- ```cd /etc/php/8.1/apache2/conf.d```
if it doesn't exixt, run the PDO-extensions.sh to install the extensions for postgresql and mysql:
- ```sh /mnt/hgfs/shared/PDO-extensions.sh```

### Configure postgresql authentication:
copy the file bellow to postgresql directory to add the User and Database authentication:
- ```cp /mnt/hgfs/shared/pg_hba.conf /etc/postgresql/14/main/```

### Make sure postgresql and apache2 are both active:
- ```sudo systemctl restart postgresql apache2```
- ```sudo systemctl status postgresql apache2```

### install a drupal site

- Needed to change

- ```sudo -u postgres psql```
- from within the postgres cli:
>```
>ALTER DATABASE drupal10;
>SET bytea_output = 'escape';
>\q
>```

- Then reset postgresql

```sudo systemctl restart postgresql```

- Then use one of these site install commands:

```sudo -u www-data drush site-install --existing-config --db-url="pgsql://drupal:drupal@127.0.0.1:5432/drupal10"```

or

```sudo drush -y site-install standard --db-url="pgsql://drupal:drupal@127.0.0.1:5432/drupal10" --site-name="LDL 2.0" --account-name=islandora --account-pass=islandora```


### install tomcat and cantaloupe

- ```sudo apt -y install openjdk-11-jdk openjdk-11-jre```

- ```update-alternatives --list java```

The above should output something like "/usr/lib/jvm/java-11-openjdk-amd64/bin/java"

note this path for later use as JAVA_HOME. it is the same as the path above without "/bin/java". "/usr/lib/jvm/java-11-openjdk-amd64"

- ```sudo addgroup tomcat```
- ```sudo adduser tomcat --ingroup tomcat --home /opt/tomcat --shell /usr/bin```

choose a password
ie: password: "tomcat"
press enter for all default user prompts
type y for yes

find the tar.gz here: https://tomcat.apache.org/download-90.cgi
copy the TOMCAT_TARBALL_LINK as of 09-06-23 it was: https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.80/bin/apache-tomcat-9.0.80.tar.gz
copy the TOMCAT_TARBALL_LINK as of 02-07-24 it was: https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz


- ```sh /mnt/hgfs/shared/scratch_5.sh```

scratch_5.sh (if the tomcat tarball link is different you must change the path in the script or run the commands in the scratch_5 alt section):

>```
>#!/bin/bash
>cd /opt
>#O not 0
>sudo wget -O tomcat.tar.gz https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz
>sudo tar -zxvf tomcat.tar.gz
>#don't miss the star*
>sudo mv /opt/apache-tomcat-9.0.85/* /opt/tomcat
>sudo chown -R tomcat:tomcat /opt/tomcat
>```


- ```sh /mnt/hgfs/shared/scratch_6.sh```

scratch_6.sh contents (if Cantaloupe version changes change the version number in this file):

>```
>sudo cp /mnt/hgfs/shared/setenv.sh /opt/tomcat/bin/
>sudo chmod 755 /opt/tomcat/bin/setenv.sh
>sudo cp /mnt/hgfs/shared/tomcat.service /etc/systemd/system/tomcat.service 
>sudo chmod 755 /etc/systemd/system/tomcat.service
>#check your cantaloupe version 
>sudo wget -O /opt/cantaloupe.zip https://github.com/cantaloupe-project/cantaloupe/releases/download/v5.0.5/cantaloupe-5.0.5.zip
>sudo unzip /opt/cantaloupe.zip
>sudo mkdir /opt/cantaloupe_config
>sudo cp cantaloupe-5.0.5/cantaloupe.properties.sample /opt/cantaloupe_config/cantaloupe.properties
>sudo cp cantaloupe-5.0.5/delegates.rb.sample /opt/cantaloupe_config/delegates.rb
>sudo touch /etc/systemd/system/cantaloupe.service 
>sudo chmod 755 /etc/systemd/system/cantaloupe.service
>sudo cp /mnt/hgfs/shared/cantaloupe.service /etc/systemd/system/cantaloupe.service
>sudo systemctl enable cantaloupe
>sudo systemctl start cantaloupe
>```

check that unzip step worked ``` ls /opt/cantaloupe*``` or something...

you may need to reload cantaloupe: 

- ```sudo systemctl daemon-reload```


### Installing fedora

- ```sudo systemctl stop tomcat```
- ```sudo mkdir -p /opt/fcrepo/data/objects```
- ```sudo mkdir /opt/fcrepo/config```
- ```sudo chown -R tomcat:tomcat /opt/fcrepo```
- ```sudo -u postgres psql```

execute these commands within the psql database:

>```
>create database fcrepo encoding 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' TEMPLATE template0;
>create user fedora with encrypted password 'fedora';
>grant all privileges on database fcrepo to fedora;
>\q
>```

- ```sudo sh /mnt/hgfs/shared/fedora-config.sh```

fedora-config.sh contains:

>```
>sudo cp /mnt/hgfs/shared/i8_namespace.cnd /opt/fcrepo/config/i8_namespace.cnd
>sudo chown tomcat:tomcat /opt/fcrepo/config/i8_namespace.cnd
>sudo chmod 644 /opt/fcrepo/config/i8_namespace.cnd
>sudo touch /opt/fcrepo/config/allowed_hosts.txt
>sudo chown tomcat:tomcat /opt/fcrepo/config/allowed_hosts.txt
>sudo chmod 644 /opt/fcrepo/config/allowed_hosts.txt
>sudo -u tomcat echo "http://localhost:80/" >> /opt/fcrepo/config/allowed_hosts.txt
>sudo cp /mnt/hgfs/shared/repository.json /opt/fcrepo/config/
>sudo chown tomcat:tomcat /opt/fcrepo/config/repository.json
>sudo chmod 644 /opt/fcrepo/config/repository.json
>sudo cp /mnt/hgfs/shared/fcrepo-config.xml /opt/fcrepo/config/
>sudo chmod 644 /opt/fcrepo/config/fcrepo-config.xml
>sudo chown tomcat:tomcat /opt/fcrepo/config/fcrepo-config.xml
>sudo cp /mnt/hgfs/shared/tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml
>sudo chmod 600 /opt/tomcat/conf/tomcat-users.xml
>sudo chown tomcat:tomcat /opt/tomcat/conf/tomcat-users.xml
>```

double check /opt/fcrepo/config/allowed_hosts.txt got created

- ```cat /opt/fcrepo/config/allowed_hosts.txt```

copy setenv.sh from /mnt/hgfs/shared/ to /opt/tomcat/bin/

- ```sudo cp /mnt/hgfs/shared/setenv.sh /opt/tomcat/bin/```

- ```sudo nano /opt/tomcat/bin/setenv.sh```

uncomment line 5, comment line 4 (CTL-c) shows line number
save (CTL-o) exit (CTL+x)


- ```sudo chown tomcat:tomcat /opt/tomcat/bin/setenv.sh```


### Downloading fedora

you may want to check
visit: https://github.com/fcrepo/fcrepo/releases choose the latest version and ajust the commands below if needed

- run this command:
- ```sh /mnt/hgfs/shared/fedora-dl.sh```
>```
>#!/bin/bash
>sudo wget -O fcrepo.war https://github.com/fcrepo/fcrepo/releases/download/fcrepo-6.4.0/fcrepo-webapp-6.4.0.war
>sudo mv fcrepo.war /opt/tomcat/webapps
>sudo chown tomcat:tomcat /opt/tomcat/webapps/fcrepo.war
>sudo systemctl restart tomcat
>```

### Downloading islandora syn

check here for link: https://github.com/Islandora/Syn/releases/ copy the link (if changed from syn-1.1.1) and replace the link in the command below:

- run the command:
- ```sh /mnt/hgfs/shared/syn-dl.sh```
>```
>#!/bin/bash
>sudo wget -P /opt/tomcat/lib https://github.com/Islandora/Syn/releases/download/v1.1.1/islandora-syn-1.1.1-all.jar
>sudo chown -R tomcat:tomcat /opt/tomcat/lib
>sudo chmod -R 640 /opt/tomcat/lib
>```

run the syn-confing.sh to ensure the library has the correct permissions:

- ```sudo sh /mnt/hgfs/shared/syn-config.sh```

syn-config.sh contents:

>```
>#!/bin/bash
>
>sudo chown -R tomcat:tomcat /opt/tomcat/lib
>sudo chmod -R 640 /opt/tomcat/lib
>sudo mkdir /opt/keys
>sudo openssl genrsa -out "/opt/keys/syn_private.key" 2048
>sudo openssl rsa -pubout -in "/opt/keys/syn_private.key" -out "/opt/keys/syn_public.key"
>sudo chown www-data:www-data /opt/keys/syn*
>sudo cp /mnt/hgfs/shared/syn-settings.xml /opt/fcrepo/config/
>#sudo cp /mnt/hgfs/shared/syn-settings.xml /opt/syn
>sudo chown tomcat:tomcat /opt/fcrepo/config/syn-settings.xml
>sudo chmod 600 /opt/fcrepo/config/syn-settings.xml
>#sudo chown tomcat:tomcat /opt/syn/syn-settings.xml
>#sudo chmod 600 /opt/syn/syn-settings.xml
>sudo chmod 600 /opt/fcrepo/config/syn-settings.xml
>```
 
edit the context.xml file:

- ```sudo nano /opt/tomcat/conf/context.xml```

Add this line  before the closing </Context> tag:
>```
>    <Valve className="ca.islandora.syn.valve.SynValve" pathname="/opt/fcrepo/config/syn-settings.xml"/>
></Context>
>```

(note above for spelling errors: valve V A L V E not Value)

- ```sudo systemctl restart tomcat```

### installing blazegraph

- run this script:
- ```sh /mnt/hgfs/shared/blazegraph-dl.sh```
>```
>#!/bin/bash
>
>sudo mkdir -p /opt/blazegraph/data
>sudo mkdir /opt/blazegraph/conf
>sudo chown -R tomcat:tomcat /opt/blazegraph
>cd /opt
>sudo wget -O blazegraph.war https://repo1.maven.org/maven2/com/blazegraph/bigdata-war/2.1.5/bigdata-war-2.1.5.war
>sudo mv blazegraph.war /opt/tomcat/webapps
>sudo chown tomcat:tomcat /opt/tomcat/webapps/blazegraph.war
>```

- run blazegraph_conf.sh: 
- ```sh /mnt/hgfs/shared/blazegraph_conf.sh```
>```
>#!/bin/bash
>sudo cp /mnt/hgfs/shared/log4j.properties /opt/blazegraph/conf/
>sudo chown tomcat:tomcat /opt/blazegraph/conf/log4j.properties
>sudo chmod 644 /opt/blazegraph/conf/log4j.properties
>sudo cp /mnt/hgfs/shared/RWStore.properties /opt/blazegraph/conf
>sudo cp /mnt/hgfs/shared/blazegraph.properties /opt/blazegraph/conf
>sudo cp /mnt/hgfs/shared/inference.nt /opt/blazegraph/conf
>sudo chown -R tomcat:tomcat /opt/blazegraph/conf
>sudo chmod -R 644 /opt/blazegraph/conf
>```

- ```sudo nano /opt/tomcat/bin/setenv.sh```

comment out line 5 uncomment line 6

save (CTL+o) quit (CTL+x)

- ```sudo systemctl restart tomcat```
- ```sudo curl -X POST -H "Content-Type: text/plain" --data-binary @/opt/blazegraph/conf/blazegraph.properties http://localhost:8080/blazegraph/namespace```

If this worked correctly, Blazegraph should respond with "CREATED: islandora" to let us know it created the islandora namespace.

- ```sudo curl -X POST -H "Content-Type: text/plain" --data-binary @/opt/blazegraph/conf/inference.nt http://localhost:8080/blazegraph/namespace/islandora/sparql```

If this worked correctly, Blazegraph should respond with some XML letting us
know it added the 2 entries from inference.nt to the namespace.


### installing solr

- run this command:
- ```sh /mnt/hgfs/shared/solr-dl.sh```
>```
>#!/bin/bash
>
>cd /opt
>
>sudo wget https://dlcdn.apache.org/lucene/solr/8.11.3/solr-8.11.3.tgz
>
>sudo tar -xzvf solr-8.11.3.tgz
>
>sudo solr-8.11.3/bin/install_solr_service.sh solr-8.11.3.tgz
>```

-  type q to quit...

- Install search_api
- ```cd /opt/drupal/islandora-starter-site/```
- ```sudo -u www-data composer require drupal/search_api_solr:^4.2```
- ```drush -y en search_api_solr```

increase filesize (optional?)

- ```sudo su```
- ```sudo echo "fs.file-max = 65535" >> /etc/sysctl.conf```
- ```sudo sysctl -p```

(CTL + D) to exit root.

create solr core

- ```cd /opt/solr```
- ```sudo mkdir -p /var/solr/data/islandora8/conf```
- ```sudo cp -r example/files/conf/* /var/solr/data/islandora8/conf```
- ```sudo chown -R solr:solr /var/solr```
- ```sudo -u solr bin/solr create -c islandora8 -p 8983```

#had to cd into /opt/solr/exmaple/files/conf 
#ran
#sudo cp -r . /var/solr/data/islandora8/conf

A warning will print:

warning using _default configset with data driven scheme functionality. NOT RECOMMENDED for production use. To turn off: bin/solr/ config -c islandora8 -p 8983 -action set-user-property -property update.autoCreateFields -value false

should also say:
"Created new core 'islandora8'

### Configure the drupal search api

#### start here

- navigate to : XXX.XXX.XXX.XXX:80/user/login
- then: XXX.XXX.XXX.XXX:80/admin/config/search/search-api
- click add server

these are the options: see documentation for help:
- https://islandora.github.io/documentation/installation/manual/installing_solr/

**enable the config settings in the gui**

Server name: islandora8

Enabled: X

backend: Solr 

Standard X

solr core: islandora8 

solr path: /

click Save

Note: You can ignore the error about an incompatible Solr schema; we're going to set this up in the next step. 

#### apply solr configs

- click back into the vm
- ```cd /opt/drupal/islandora-starter-site```
- ```sudo -u www-data drush solr-gsc islandora8 /opt/drupal/islandora-starter-site/solrconfig.zip```
- ```unzip -d ~/solrconfig solrconfig.zip```
- ```sudo cp ~/solrconfig/* /var/solr/data/islandora8/conf```
- ```sudo systemctl restart solr```

 **configure index via gui***

adding an index
- In gui navigate XXX.XXX.XXX.XXX or localhost:80/admin/config/search/search-api/add-index
 
Index name: Islandora 8 Index

Content: X

File: X

Server: islandora8

Enabled X

click Save


### crayfish microservices

click back into vm

- ```sh /mnt/hgfs/shared/crayfish_reqs.sh```

let this execute: takes a while... maybe take a hydration break. It's running the following:

>```
>sudo add-apt-repository -y ppa:lyrasis/imagemagick-jp2
>sudo apt update
>sudo apt -y install imagemagick tesseract-ocr ffmpeg poppler-utils
>cd /opt
>sudo git clone https://github.com/Islandora/Crayfish.git crayfish
>sudo chown -R www-data:www-data crayfish
>sudo -u www-data composer install -d crayfish/Homarus
>sudo -u www-data composer install -d crayfish/Houdini
>sudo -u www-data composer install -d crayfish/Hypercube
>sudo -u www-data composer install -d crayfish/Milliner
>sudo -u www-data composer install -d crayfish/Recast
>sudo mkdir /var/log/islandora
>sudo chown www-data:www-data /var/log/islandora
>```

### moving config files over 

- ```sh /mnt/hgfs/shared/microservices-config.sh```

runs the following script:

>```
>#!/bin/bash
>sudo cp /mnt/hgfs/shared/homarus.config.yaml /opt/crayfish/Homarus/cfg/config.yaml
>sudo cp /mnt/hgfs/shared/houdini.services.yaml /opt/crayfish/Houdini/config/services.yaml
>sudo cp /mnt/hgfs/shared/crayfish_commons.yml /opt/crayfish/Houdini/config/packages/crayfish_commons.yml
>sudo cp /mnt/hgfs/shared/monolog.yml /opt/crayfish/Houdini/config/packages/monolog.yml
>sudo cp /mnt/hgfs/shared/security.yml /opt/crayfish/Houdini/config/packages/security.yml
>sudo cp /mnt/hgfs/shared/hypercube.config.yaml /opt/crayfish/Hypercube/cfg/config.yaml 
>sudo cp /mnt/hgfs/shared/milliner.config.yaml /opt/crayfish/Milliner/cfg/config.yaml
>sudo cp /mnt/hgfs/shared/recast.config.yaml /opt/crayfish/Recast/cfg/config.yaml
>sudo chown www-data:www-data /opt/crayfish/Homarus/cfg/config.yaml
>sudo chmod 644 /opt/crayfish/Homarus/cfg/config.yaml
>sudo chown www-data:www-data /opt/crayfish/Houdini/config/services.yaml
>sudo chmod 644 /opt/crayfish/Houdini/config/services.yaml
>sudo chown www-data:www-data /opt/crayfish/Houdini/config/packages/crayfish_commons.yml
>sudo chmod 644 /opt/crayfigsh/Houdini/config/packages/crayfish_commons.yml
>sudo chown www-data:www-data /opt/crayfish/Houdini/config/packages/monolog.yml
>sudo chmod 644 /opt/crayfish/Houdini/config/packages/monolog.yml
>sudo chown www-data:www-data /opt/crayfish/Houdini/config/packages/security.yml
>sudo chmod 644 /opt/crayfish/Houdini/config/packages/security.yml
>sudo chown www-data:www-data /opt/crayfish/Hypercube/cfg/config.yaml 
>sudo chmod 644 /opt/crayfish/Hypercube/cfg/configl.yaml 
>sudo chown www-data:www-data /opt/crayfish/Milliner/cfg/config.yaml
>sudo chmod 644 /opt/crayfish/Milliner/cfg/config.yaml
>sudo chown www-data:www-data /opt/crayfish/Recast/cfg/config.yaml
>sudo chmod 644 /opt/crayfish/Recast/cfg/config.yaml
>```

configure apache confs for microservices

- ```sh /mnt/hgfs/shared/microservices-conf.sh```

microservices-conf.sh will be copying a lot of config files from the shared folder

>```
>#!/bin/bash
>sudo cp /mnt/hgfs/shared/Houdini.conf /etc/apache2/conf-available/Houdini.conf
>sudo chown root:root /etc/apache2/conf-available/Houdini.conf 
>sudo chmod 644 /etc/apache2/conf-available/Houdini.conf
>sudo cp /mnt/hgfs/shared/Homarus.conf /etc/apache2/conf-available/Homarus.conf 
>sudo chown root:root /etc/apache2/conf-available/Homarus.conf 
>sudo chmod 644 /etc/apache2/conf-available/Homarus.conf 
>sudo cp /mnt/hgfs/shared/Hypercube.conf /etc/apache2/conf-available/Hypercube.conf 
>sudo chown root:root /etc/apache2/conf-available/Hypercube.conf 
>sudo chmod 644 /etc/apache2/conf-available/Hypercube.conf 
>sudo cp /mnt/hgfs/shared/Milliner.conf /etc/apache2/conf-available/Milliner.conf
>sudo chown root:root /etc/apache2/conf-available/Milliner.conf
>sudo chmod 644 /etc/apache2/conf-available/Milliner.conf
>sudo cp /mnt/hgfs/shared/Recast.conf /etc/apache2/conf-available/Recast.conf 
>sudo chown root:root /etc/apache2/conf-available/Recast.conf 
>sudo chmod 644 /etc/apache2/conf-available/Recast.conf 
>```

### Enable microservices

- ```sudo a2enconf Homarus Houdini Hypercube Milliner Recast```
- ```sudo systemctl restart apache2```

### Installing ActiveMQ Karaf and Alpaca

check apache-activemq version (last was 5.18.1)

- ```sudo apt install -y activemq```
- ```cd /opt```

- run this script:
- ```sh /mnt/hgfs/shared/activemq-dl.sh```
>```
>#!/bin/bash
>
>cd /opt
>
>sudo wget  http://archive.apache.org/dist/activemq/5.18.1/apache-activemq-5.18.1-bin.tar.gz
>
>sudo tar -xvzf apache-activemq-5.18.1-bin.tar.gz
>
>sudo mv apache-activemq-5.18.1 activemq
>
>sudo chown -R activemq:activemq /opt/activemq
>
>sudo cp /mnt/hgfs/shared/activemq.service /etc/systemd/system/activemq.service
>```


check activemq.service file

- ```cat /etc/systemd/system/activemq.service```

The file should contain this text:
>```
>[Unit]
>Description=Apache ActiveMQ
>After=network.target
>[Service]
>Type=forkings
>User=activemq
>Group=activemq
>
>ExecStart=/opt/activemq/bin/activemq start
>ExecStop=/opt/activemq/bin/activemq stop
>
>[Install]
>WantedBy=multi-user.target
>```

- ```sudo systemctl daemon-reload```
- ```sudo systemctl start activemq```
- ```sudo systemctl enable activemq```


check activemq version (5.16.1-1 as of writing):

- ```sudo apt-cache policy activemq```

### karaf section

- ```sudo addgroup karaf```
- ```sudo adduser karaf --ingroup karaf --home /opt/karaf --shell /usr/bin```

- (CTL-D twice to exit and apply groups)

- make password karaf
- enter on all prompts
- type y and enter.

Note:  The latest karaf does not work with the version of activemq, apache-camel and islandora-karaf (https://karaf.apache.org/download.html)
Islandora Documentation recommends 4.2.x. Other versions are available, <u>but they don't work with the other software below.</u>

best link for now: 
- https://dlcdn.apache.org/karaf/4.2.16/apache-karaf-4.2.16.tar.gz

- run this script:
- ```sh /mnt/hgfs/shared/karaf-dl.sh```

>```
>#!/bin/bash
>
>cd /opt
>#sudo wget -O karaf.tar.gz https://dlcdn.apache.org/karaf/4.2.16/apache-karaf-4.2.16.tar.gz
>sudo wget -O karaf.tar.gz https://dlcdn.apache.org/karaf/4.4.6/apache-karaf-4.4.6.tar.gz
>sudo tar -xzvf karaf.tar.gz
>#sudo chown -R karaf:karaf apache-karaf-4.2.16
>sudo chown -R karaf:karaf apache-karaf-4.4.6
>#sudo mv apache-karaf-4.2.16/* /opt/karaf
>sudo mv apache-karaf-4.4.6/* /opt/karaf
>```

double check for /mnt/hgfs/shared -```sudo vmhgfs-fuse.host/ /mnt/hgfs/ -o allow_other -o uid=1000```

- run this script:
- ```sudo sh /mnt/hgfs/shared/karaf-stuff.sh```

will run the following:

>```
>sudo mkdir /var/log/karaf
>sudo chown karaf:karaf /var/log/karaf
>#sudo mkdir /opt/karaf/etc 
>sudo cp /mnt/hgfs/shared/org.pos4j.pax.logging.cfg /opt/karaf/etc/org.pos4j.pax.logging.cfg
>sudo chown karaf:karaf /opt/karaf/etc/org.pos4j.pax.logging.cfg
>sudo chmod 644 /opt/karaf/etc/org.pos4j.pax.logging.cfg
>```

- ```sudo su```
- ```sudo echo '#!/bin/sh' >> /opt/karaf/bin/setenv```
- ```sudo echo 'export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"' >> /opt/karaf/bin/setenv```


Ctl-D to log out of su

- ```export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"```
- ```sudo chown karaf:karaf /opt/karaf/bin/setenv```
- ```sudo chmod 755 /opt/karaf/bin/setenv```
- ```sudo nano /opt/karaf/etc/users.properties```

#uncomment lines:
Before:

    32 | # karaf = karaf,_g_:admingroup

    33 | # _g_\:admingroup = group,admin,manager,viewer,systembundles,ssh

After:

    32 | karaf = karaf,_g_:admingroup

    33 | _g_\:admingroup = group,admin,manager,viewer,systembundles,ssh


- ```sudo -u karaf /opt/karaf/bin/start```

You may want to wait a bit for Karaf to start.
run these commands to confirm that the process for karaf is running:

- ```ps aux | grep karaf```

- ```sudo sh /mnt/hgfs/shared/karaf-more.sh```

will run this:

>```
> /opt/karaf/bin/client feature:install wrapper
> /opt/karaf/bin/client wrapper:install
> /opt/karaf/bin/stop
> sudo systemctl enable /opt/karaf/bin/karaf.service
> sudo systemctl start karaf
> sudo systemctl status karaf
>```

(to quit type q)

### Alpaca

notes:
the version of activemq from before: ACTIVEMQ_KARAF_VERSION  5.16.1-1
visit https://mvnrepository.com/artifact/org.apache.camel.karaf/apache-camel look for the latest version of Apache Camel 2.x.x
APACHE_CAMEL_VERSION [https://repo1.maven.org/maven2/org/apache/camel/karaf/apache-camel/2.25.4/apache-camel-2.25.4](https://repo1.maven.org/maven2/org/apache/camel/karaf/apache-camel/2.25.4/)
visit https://mvnrepository.com/artifact/ca.islandora.alpaca/islandora-karaf
confirm that the ISLANDORA_KARAF_VERSION is still 1.0.5

JENA_OSGI_VERSION The latest version of the Apache Jena 3.x OSGi features 3.17.0 (note /xml/ not .xml)

- run this script:
- ```sh /mnt/hgfs/shared/karaf-repo-add.sh```

- ```sudo -u karaf nano /opt/karaf/etc/ca.islandora.alpaca.http.client.cfg```

edit the file to contain this text:

>```
>token.value=islandora
>```

- ```sudo chmod 644 /opt/karaf/etc/ca.islandora.alpaca.http.client.cfg```

- ```sh /mnt/hgfs/shared/karaf-config.sh```

executes the following file copies:

>```
>!/bin/bash
>sudo cp /mnt/hgfs/shared/org.fcrepo.camel.indexing.triplestore.cfg /opt/karaf/etc/org.fcrepo.camel.indexing.triplestore.cfg
>sudo chown karaf:karaf /opt/karaf/etc/org.fcrepo.camel.indexing.triplestore.cfg
>sudo chmod 644 /opt/karaf/etc/org.fcrepo.camel.indexing.triplestore.cfg
>sudo cp /mnt/hgfs/shared/ca.islandora.alpaca.indexing.triplestore.cfg /opt/karaf/etc/ca.islandora.alpaca.indexing.triplestore.cfg 
>sudo chown karaf:karaf /opt/karaf/etc/ca.islandora.alpaca.indexing.triplestore.cfg 
>sudo chmod 644 /opt/karaf/etc/ca.islandora.alpaca.indexing.triplestore.cfg 
>sudo cp /mnt/hgfs/shared/ca.islandora.alpaca.indexing.fcrepo.cfg /opt/karaf/etc/ca.islandora.alpaca.indexing.fcrepo.cfg
>sudo chown karaf:karaf /opt/karaf/etc/ca.islandora.alpaca.indexing.fcrepo.cfg
>sudo chmod 644 /opt/karaf/etc/ca.islandora.alpaca.indexing.fcrepo.cfg
>```

- ```sh /mnt/hgfs/shared/karaf-blueprints.sh```

 more configuration via file copying and permissions

>```
>#!/bin/bash
>sudo cp /mnt/hgfs/shared/ca.islandora.alpaca.connector.ocr.blueprint.xml /opt/karaf/deploy/ca.islandora.alpaca.connector.ocr.blueprint.xml
>sudo chown karaf:karaf /opt/karaf/deploy/ca.islandora.alpaca.connector.ocr.blueprint.xml
>sudo chmod 644 /opt/karaf/deploy/ca.islandora.alpaca.connector.ocr.blueprint.xml
>sudo cp /mnt/hgfs/shared/ca.islandora.alpaca.connector.houdini.blueprint.xml /opt/karaf/deploy/ca.islandora.alpaca.connector.houdini.blueprint.xml
>sudo chown karaf:karaf /opt/karaf/deploy/ca.islandora.alpaca.connector.houdini.blueprint.xml
>sudo chmod 644 /opt/karaf/deploy/ca.islandora.alpaca.connector.houdini.blueprint.xml
>sudo cp /mnt/hgfs/shared/ca.islandora.alpaca.connector.homarus.blueprint.xml /opt/karaf/deploy>/ca.islandora.alpaca.connector.homarus.blueprint.xml
>sudo chown karaf:karaf /opt/karaf/deploy/ca.islandora.alpaca.connector.homarus.blueprint.xml
>sudo chmod 644 /opt/karaf/deploy/ca.islandora.alpaca.connector.homarus.blueprint.xml
>sudo cp /mnt/hgfs/shared/ca.islandora.alpaca.connector.fits.blueprint.xml /opt/karaf/deploy/ca.islandora.alpaca.connector.fits.blueprint.xml
>sudo chown karaf:karaf /opt/karaf/deploy/ca.islandora.alpaca.connector.fits.blueprint.xml
>sudo chmod 644 /opt/karaf/deploy/ca.islandora.alpaca.connector.fits.blueprint.xml
>```

- ```sudo sh /mnt/hgfs/shared/karaf-features.sh```

wait for it to finish, it takes a while...
the script contains:

>```
>/opt/karaf/bin/client feature:install camel-blueprint
>/opt/karaf/bin/client feature:install activemq-blueprint
>/opt/karaf/bin/client feature:install fcrepo-service-activemq
># This again should not be strictly necessary, since this isn't the triplestore
># we're using, but is being included here to resolve the aforementioned
># missing link in the dependency chain.
>/opt/karaf/bin/client feature:install jena
>/opt/karaf/bin/client feature:install fcrepo-camel
>/opt/karaf/bin/client feature:install fcrepo-indexing-triplestore
>/opt/karaf/bin/client feature:install islandora-http-client
>/opt/karaf/bin/client feature:install islandora-indexing-triplestore
>/opt/karaf/bin/client feature:install islandora-indexing-fcrepo
>/opt/karaf/bin/client feature:install islandora-connector-derivative
>```

### configure drupal

copy the settings.php file from shared folders

- ```sudo cp /mnt/hgfs/shared/settings.php /opt/drupal/islandora-starter-site/web/sites/default/settings.php```
- ```sudo chmod 555 /opt/drupal/islandora-starter-site/web/sites/default/settings.php```
- ```drush cr -y```

- visit /admin/config/media/file-system to select the flysystem from the dropdown.
- Click Save

## Require JWT

- ```sudo -u www-data composer require "drupal/jwt:^2.0"```
- ```drush en -y jwt```

### Adding a JWT Configuration to Drupal

To allow our installation to talk to other services via Syn, we need to establish a Drupal-side JWT configuration using the keys we generated at that time.

Log onto your site as an administrator at /user, then navigate to /admin/config/system/keys/add. Some of the settings here are unimportant, but pay close attention to the Key type, which should match the key we created earlier (an RSA key), and the File location, which should be the ultimate location of the key we created for Syn on the filesystem, /opt/keys/syn_private.key.

Change Provider Settings

Key Provider:  File

#### Adding a JWT RSA Key

Click Save to create the key.
enter: /opt/keys/syn_private.key

Once this key is created, navigate to /admin/config/system/jwt to select the key you just created from the list. Note that before the key shows up in the Private Key list, you need to select that key's type in the Algorithm section, namely RSASSA-PKCS1-v1_5 using SHA-256 (RS256).

#### Configuring the JWT RSA Key for Use

See instructions:
- https://islandora.github.io/documentation/installation/manual/configuring_drupal/#adding-a-jwt-configuration-to-drupal

visit http://[your-site-ip-address]/admin/config/system/jwt

### Install Islandora modules:

You will need this step if you installed the drupal reccomendede project instead of the islandora-starter-site

- ```sh /mnt/hgfs/shared/islandora_install_3.sh```

>```
>cd /opt/drupal
># Since islandora_defaults is near the bottom of the dependency chain, requiring
># it will get most of the modules and libraries we need to deploy a standard
># Islandora site.
>sudo -u www-data composer require "drupal/flysystem:^2.0@alpha"
>sudo -u www-data composer require "islandora/islandora:^2.4"
>sudo -u www-data composer require "islandora/controlled_access_terms:^2"
>sudo -u www-data composer require "islandora/openseadragon:^2"
>
># These can be considered important or required depending on your site's
># requirements; some of them represent dependencies of Islandora submodules.
>sudo -u www-data composer require "drupal/pdf:1.1"
>sudo -u www-data composer require "drupal/rest_oai_pmh:^2.0@beta"
>sudo -u www-data composer require "drupal/search_api_solr:^4.2"
>sudo -u www-data composer require "drupal/facets:^2"
>sudo -u www-data composer require "drupal/content_browser:^1.0@alpha" ## TODO do we need this?
>sudo -u www-data composer require "drupal/field_permissions:^1"
>sudo -u www-data composer require "drupal/transliterate_filenames:^2.0"
>
># These tend to be good to enable for a development environment, or just for a
># higher quality of life when managing Islandora. That being said, devel should
># NEVER be enabled on a production environment, as it intentionally gives the
># user tools that compromise the security of a site.
>sudo -u www-data composer require drupal/restui:^1.21
>sudo -u www-data composer require drupal/console:~1.0
>sudo -u www-data composer require drupal/devel:^2.0
>sudo -u www-data composer require drupal/admin_toolbar:^2.0
>```

#### follow drupal config instructions:
- https://islandora.github.io/documentation/installation/manual/configuring_drupal/#islandora
- We had to run this to get activemq starting broker tcp://localhost:61613 connection working
- ```sudo systemctl restart tomcat```

#### config canaloupe

- ```sudo -u www-data composer require "islandora/openseadragon"```

- ```drush en -y openseadragon```

- ```drush en -y islandora_iiif```

- ```sudo systemctl start cantaloupe```

-  https://islandora.github.io/documentation/installation/manual/configuring_drupal/#configuring-islandora-iiif

navigate to ```/admin/config/islandora/iiif```

Set IIIF Image Server Location:
- http://localhost:8182/iiif/2

Nav to openseadragon
- http://[your-site-ip-address]/admin/config/media/openseadragon

- add to IIIf Image server location: 
- http://localhost:8182/iiif/2
- select IIIF Manifest from dropdown?
- save

# navigate to flysystem settings

-Visit http://[your-site-ip-address]/admin/config/media/file-system

- choose the flysystem button and save (scroll down)

#give the admin fedoraAdmin role

- ```cd /opt/drupal/islandora-starter-site```
- ```sudo -u www-data drush -y urol "fedoraadmin" admin```

# run this to get taxonomy populated
- ```sudo -u www-data drush -y -l localhost --userid=1 mim --all```


### Require islandora workbench should be able to skip this

https://github.com/mjordan/islandora_workbench_integration

- ```cd /opt/drupal/islandora-starter-site```
- ```sudo -u www-data composer require "mjordan/islandora_workbench_integration:dev-main"```
- ```drush en -y islandora_workbench_integration```

#### enable rest endpoints for workbench then rebuild the cache

- ```drush cim -y --partial --source=/opt/drupal/islandora-starter-site/web/modules/contrib/islandora_workbench_integration/config/optional```

- ```drush cr -y```

- outside of your virtual machine open a terminal to clone islandora workbench

- ```cd ~/Documents/``` (example directory)
- ```git clone https://github.com/mjordan/islandora_workbench```

- edit a config.yml file with the http://your-virtualmachine-ip-address in the config

- a working config file could look something like this:

>```
>Task: create
>host: "http://your-virtualmachine-ip-addr"
>username: islandora
>password: islandora
>input_csv: path-to-your-input.csv
>allow_adding_terms: True
>allow_missing_files: True
>```

For more information see the [islandora_workbench_docs](https://mjordan.github.io/islandora_workbench_docs)


### upload size and max post size

- ```sudo nano /etc/php/8.1/apache2/php.ini```
- change ```post_max_size = 8M``` to ```post_max_size = 200M```
- change ```upload_max_filesize = 8M``` to ```upload_max_filesize = 200M```
- change  ```max_file_uploads = 200``` to an appropriate number (1000?)
- ```sudo systemctl restart apache2```

### add and enable drupal 'group' module and 'groupmedia'

- ```cd /opt/drupal/islandora-starter-site```
- ```sudo -u www-data composer require 'drupal/group:^3.0'```
- ```sudo -u www-data composer require drupal/group_permissions```
- ```sudo -u www-data composer require 'drupal/gnode'```
- ```sudo -u www-data composer require 'drupal/groupmedia'```
- ```sudo -u www-data composer require 'digitalutsc/islandora_group:^2.x-dev'```
- ```drush en -y group groupmedia gnode group_permissions islandora_group```

- or
- ```cd /opt/drupal/islandora-starter-site```
- ```sh /mnt/hgfs/shared/group-install.sh```

# after configuring settings.php we add jwt

- ```sudo -u www-data composer require "drupal/jwt:^2.0"```

- ```drush en -y jwt```

# Follow instructions to setup jwt with our key: 

https://islandora.github.io/documentation/installation/manual/configuring_drupal/#adding-a-jwt-configuration-to-drupal

#Had to change JWT location (something changed our key location, likely drush site:install...)

- /admin/config/system/keys/manage/islandora_rsa_key

- path change back to:

- ```/opt/keys/syn_private.key```

# enable openseadragon and islandora

- ```drush en -y openseadragon```

- ```drush en -y islandora```


# to get repository item and needed taxonomies:

- ```drush site:install --existing-config```

- ```sudo systemctl start cantaloupe```

# navigate to admin/config/media/openseadragon

add the location of the cantaloupe iiif endpoint:

- http://localhost:8182/iiif/2

- Save

- ```cd /opt/drupal/islandora-starter-site```

- ```sudo -u www-data drush -y urol "fedoraadmin" admin```

- ```sudo -u www-data drush -y -l localhost --userid=1 mim --all```


# enable views

- ```drush -y views:enable display_media```


-  ```drush cim -y --partial --source=modules/contrib/islandora_workbench_integration/config/optional```


# edit php.ini to make file upload sizes work

- ```sudo nano /etc/php/8.2/apache2/php.ini```

- post_max_size = 200M
 
- upload_max_filesize = 200M 

- upload_max_filesize = 200M

- change max_file_uploads = 2000

- ```sudo systemctl restart apache2```


# workbench ingest:

You'll need to have working csv with metadata and filepaths, a yml file that refrences the csv.

You'll need to Edit the csv to contain taxonomy id terms for two different csv headers:

Check the taxonomy terms 
/admin/structure/taxonomy/manage/resource_types/overview
/admin/structure/taxonomy/manage/islandora_models/overview

taxonomy:			CSV Header:
Resource Type  =>   field_resource_type

taxonomy:			CSV Header:
islandora models => field_model 

from outside the vm:

- ```cd islandora_workbench```
- ```./workbench --config milad-and-will-config.yml```






