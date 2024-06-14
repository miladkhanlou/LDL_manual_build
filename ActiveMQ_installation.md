# ActiveMQ installation

## Remove activemq:
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

************************************************************************************************************************************************************************************
## Re install activemq:
************************************************************************************************************************************************************************************
- **Link to Unix Developer’s Release:**
```https://activemq.apache.org/components/classic/documentation```
************************************************************************************************************************************************************************************
getting-started#OnUnix:
- **Create ActiveMQ User:**
```sudo useradd -m -d /opt/activemq -s /bin/false activemq```
************************************************************************************************************************************************************************************
- **Download and untar ActiveMQ:**
```sh
cd /opt/activemq
sudo wget https://repository.apache.org/content/repositories/snapshots/org/apache/activemq/apache-activemq/6.2.0-SNAPSHOT/apache-activemq-6.2.0-20240611.154103-9-bin.tar.gz
sudo tar zxvf apache-activemq-6.2.0-20240611.154103-9-bin.tar.gz
sudo mv apache-activemq-6.2.0-SNAPSHOT/* .
sudo rm -rf apache-activemq-6.2.0-SNAPSHOT apache-activemq-6.2.0-20240611.154103-9-bin.tar.gz
```
************************************************************************************************************************************************************************************
- **Set ownership for the ActiveMQ directory:**
```sh
sudo chown -R activemq:activemq /opt/activemq
sudo chmod -R 755 /opt/activemq #whole folder or just /bin/activemq
sudo chmod -R 755 /opt/activemq/bin/activemq
```
***************************************************************************************************************************************************************************
- **Set Up Environment Variables, Add the following to /etc/default/activemq:**
```sh
sudo sed -i 's/^ACTIVEMQ_USER=""/ACTIVEMQ_USER="activemq"/' /opt/activemq/bin/setenv
sudo cp /opt/activemq/bin/setenv /etc/default/activemq
sudo chmod -R 755 /etc/default/activemq
sudo nano /etc/default/activemq
```

***************************************************************************************************************************************************************************
- ***Move Data, Temp, and Config Directories (Optional):***
Move the data, tmp, and conf directories to a different location with more available space.
***************************************************************************************************************************************************************************
- **Create a symlink to the init script and enable the service:**
```sh
sudo ln -snf /opt/activemq/bin/activemq /etc/init.d/activemq #Do we need this if we run it from /bin/activemq? no maybe!
sudo update-rc.d activemq defaults
```
***************************************************************************************************************************************************************************
- **correct permissions to activemq and check symlink:**
```sh
ls -l /etc/init.d/activemq
```

- ```sudo systemctl daemon-reload```

***************************************************************************************************************************************************************************
- **Copy to /etc/systemd/system/activemq.service adn reload daemon:**
```sh
[Unit]
Description=Apache ActiveMQ
After=network.target

[Service]
Type=forking
User=activemq
Group=activemq
ExecStart=/opt/activemq/bin/activemq start
ExecStop=/opt/activemq/bin/activemq stop
Restart=always

[Install]
WantedBy=multi-user.target
```
```sudo systemctl daemon-reload```
***************************************************************************************************************************************************************************
- **Start the ActiveMQ Service:**
```sh
/opt/activemq/bin start
or
sudo systemctl start activemq.service #To start with system control
or
sudo service activemq start #To start with system control
```
***Ckeck started on the port:*** you should see activemq is running on port 61616 with ```netstat -a | grep 61616```

***NOTE:*** You may need to manually set activemq installation dirs in setenv. And fix activemq code for extra '/'.


***************************************************************************************************************************************************************************
### Errors:
### If you encounters issues in directory generating, fix from activemq code:**
```nano bin/activemq```

in getActiveMQHome function -> delete '/' from echo "$REAL_DIR"

***************************************************************************************************************************************************************************
### If you got a big chuncks of errors, it might be the fact that 61616 is in process:**
```sh
sudo lsof -i :61616
sudo kill -9 PID_NUMBER
```
***************************************************************************************************************************************************************************
### Warning for allocated space:**
- Check disk space: 
```sh
df -h /usr/share/apache-activemq-6.1.2/data
nano bin/setenv #change 64 to 512
ACTIVEMQ_OPTS_MEMORY="-Xms512M -Xmx1G"
```

OR move the data directory to a partition with more available space and update the ACTIVEMQ_DATA environment variable accordingly. and Update update the setenv script and activemq.xml configuration file to reflect the new path.
```sh
df -h #to find the directory with more space
sudo mkdir -p /mnt/data/activemq-data #other storage attached to VM
sudo mv /usr/share/apache-activemq-6.1.2/data/* /mnt/data/activemq-data/

#Update the setenv Script and activemq.xml Configuration:
setenv: ACTIVEMQ_DATA
activemq.xml: kahaDB directory="${activemq.data}"/>
```

***************************************************************************************************************************************************************************
### Web Console not reachable:**
- In the event that you are running a standalone broker and the Web Console is not reachable, check that the following lines are included in your ActiveMQ Classic config xml:

    - ```nano /opt/activemq/conf/jetty.xml```
    - Change value to of host to 0.0.0.0:
```sh
<bean id="jettyPort" class="org.apache.activemq.web.WebConsolePort" init-method="start">
    <!-- the default port number for the web console -->
    <property name="host" value="0.0.0.0"/>
    <property name="port" value="8161"/>
</bean>
```
***************************************************************************************************************************************************************************
## 7. Testing the installation Using the administrative interface:
- ***Open the administrative interface***

URL: http://127.0.0.1:8161/admin/
Login: admin
Passwort: admin
Navigate to “Queues”
Add a queue name and click create
Send test message by klicking on “Send to”

- ***Logfile and console output:***
[activemq_install_dir]/data/activemq.log

- ***Listen port:***
netstat -nl|grep 61616

***************************************************************************************************************************************************************************
## 8. Documentation Links:
https://activemq.apache.org/components/classic/documentation/getting-started#OnUnix:
https://activemq.apache.org/components/classic/documentation/unix-shell-script
https://activemq.apache.org/components/classic/documentation/web-console
