# Remove activemq:
```sh
sudo systemctl stop activemq
sudo apt-get remove --purge activemq
sudo rm -rf /usr/share/activemq
sudo userdel -r activemq
sudo groupdel activemq
sudo rm -rf /etc/activemq
sudo rm -rf /var/lib/activemq
sudo rm -rf /var/log/activemq
```
# Re install activemq:
### Create ActiveMQ User:
```sudo useradd -m activemq -d /srv/activemq```

### Download ActiveMQ:
```sh
cd /srv/activemq
sudo wget https://archive.apache.org/dist/activemq/6.1.2/apache-activemq-6.1.2-bin.tar.gz
sudo tar -zxvf apache-activemq-6.1.2-bin.tar.gz
sudo mv apache-activemq-6.1.2 activemq
```

### Create Symbolic Link:
```sh
sudo ln -snf activemq current
sudo chown -R activemq:activemq activemq
```

### Set Up Environment Variables, Add the following to /etc/default/activemq:
```sh
cp /srv/activemq/current/bin/setenv /etc/default/activemq
sudo sed -i 's/^ACTIVEMQ_USER=""/ACTIVEMQ_USER="activemq"/' /etc/default/activemq
sudo chmod 644 /etc/default/activemq
sudo nano /etc/default/activemq
```

### Move Data, Temp, and Config Directories (Optional):
Move the data, tmp, and conf directories to a different location if needed.

## Configuring init:
### 1) Regular way(working)
#### Install Init Script:
```sudo ln -snf /srv/activemq/current/bin/activemq /etc/init.d/activemq```

#Activate Init Script at System Startup:
```sudo update-rc.d activemq defaults```

#Start the ActiveMQ Service:
```sudo service activemq start```
-----------------------------

### 2) if not worked with current init configureation:(active(exited))
##### Global Default Configuration:
The init script configuration file is located at /etc/default/activemq. This file contains all default configuration variables required for the ActiveMQ broker to run properly.

##### Edit Configuration File:
```sudo nano /etc/default/activemq```

```sh
ACTIVEMQ_USER="activemq"
ACTIVEMQ_HOME="/srv/activemq/current"
ACTIVEMQ_BASE="/srv/activemq"
ACTIVEMQ_CONF="/srv/activemq/conf"
ACTIVEMQ_DATA="/srv/activemq/data"
ACTIVEMQ_OPTS_MEMORY="-Xms512M -Xmx1G"
ACTIVEMQ_OPTS="$ACTIVEMQ_OPTS_MEMORY"
```

#### Permissions:
```sudo chmod 644 /etc/default/activemq```





