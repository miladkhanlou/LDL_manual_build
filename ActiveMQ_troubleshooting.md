## 1. JETTY CANT BE FOUND, ERRORS:
### ERRORS:
- Failed to load: C;ass path resource[activemq.xml], reason: Exeption parsing xml document from path resource [/opt/activemq//conf/jetty.xml]

- java.lang.RuntimeException: failed to execute start task. Reason org.springframework.beans.factory.BeanDefinitionStoreException: IOException parsing XML document from class path resource [/opt/activemq//conf/jetty.xml]

- org.springframework.beans.factory.BeanDefinitionStoreException: IOException parsing XML document from class path resource [/opt/activemq//conf/jetty.xml]


### Handle The Error:
- **Cause:** The jetty.xml was not configured correctly in activemq.xml. Therefore, it can not be found.

- **Troubleshoot:**
    - 1. Fix the activemq code in /opt/activemq/bin in line 91: *(Check this)*
        - ```nano +91 /opt/activemq/bin/activemq```

        - change ```echo "$REAL_DIR/"``` to ```echo "$REAL_DIR"``` 

    - 2. Manually add the Activemq directories in setenv:

        - ```nano /opt/activemq/bin/setenv```

        - add following:
    ```sh
    ACTIVEMQ_HOME="/opt/activemq"
    ACTIVEMQ_BASE="$ACTIVEMQ_HOME"
    ACTIVEMQ_CONF="$ACTIVEMQ_BASE/conf"
    ACTIVEMQ_DATA="$ACTIVEMQ_BASE/data"
    ACTIVEMQ_TMP="$ACTIVEMQ_BASE/tmp"
    ```

    - 3. Set propriate permissions:
```sh
chown -R activemq:activemq /opt/activemq
chmod 755 -R /opt/activemq
```

    - 4. Check if jetty configured like bellow in activemq.xml:
```sh
        <import resource="jetty.xml"/>
```

***************************************************************************************************************************************************************************
## 2. Broker is in slave mode wainting a lock to be acquired:
### ERROR:
Database /opt/activemq/data/kahadb/lock is locked by another server. this broker is now in slave mode wainting a lock to be acquired

### Handle The Error:
- **Causes:**
    - Having multiple broker instances with insufficient configuration for multiple

    - If single broker instance and still encounter this issue, it might be due to a leftover lock file from a previous instance that didn't shut down cleanly.

- **Troubleshoot:**
    - Removing the lock file manually can resolve this in such cases. ```rm /opt/activemq/data/kahadb/lock```
    
    - Create startup script and add to setenv: **(CHECK IT)**
        - nano /opt/tomcat/bin/start-activemq.sh

        - Add the Following Content to the Script and chmod it:

        - ```chmod +x /path/to/start-activemq.sh```

        - Run the Custom Script to Start ActiveMQ instead of wrting /bin/activemq start
```sh
#!/bin/bash

# Define the path to the lock file
LOCK_FILE="/opt/activemq/data/kahadb/lock"

Check if the lock file exists and remove it if it does
if [ -f "$LOCK_FILE" ]; then
    echo "Removing leftover lock file..."
    rm -f "$LOCK_FILE"
fi

# Start ActiveMQ
/opt/activemq/bin/activemq start
```

- Check for Duplicate Brokers in activemq.xml

    - Ensure there is *only one* <broker> element defined in your configuration:

    - Configure for multiple clusters:
        - configure an ActiveMQ broker for a Shared File System Master-Slave setup using the KahaDB persistence adapter

        - If using a shared file system for KahaDB and multiple brokers are configured to access the same directory, only one broker can be active (master) at a time.

        - The other brokers will detect the lock and wait in slave mode until the lock is released (e.g., if the master broker fails).

        - If you intend to use a Shared File System Master-Slave setup, ensure that:
            - Only one broker is intended to be active at a time.
            - The shared directory is correctly configured in all brokers.
```sh
<broker xmlns="http://activemq.apache.org/schema/core" brokerName="shared-broker" useJmx="true">
    <persistenceAdapter>
        <kahaDB directory="/sharedFileSystem/sharedBrokerData"/>
    </persistenceAdapter>
    <transportConnectors>
        <transportConnector name="openwire" uri="tcp://0.0.0.0:61616"/>
    </transportConnectors>
</broker>
```

- 4. Inspect the Network Connector:

    - If you are using network connectors, ensure they are correctly configured to avoid any conflicts or issues with clustering that might cause multiple instances to start.
```sh
<networkConnector name="connector1" uri="static:(tcp://remote-broker:61616)"/>
```

- 5. Check for Clustering Configurations:
    - If you are using Master/Slave clustering, verify that the configurations are correctly set up to avoid any issues with locking.

***************************************************************************************************************************************************************************
## 3. Activemq stop will can not resolve created pid:
### ERROR:
failed to resolve jmxURL for pid 164069 using default JMX url.

Connecting to service:jmx:rmi:///jndi/rmi:///localhost:1099/jmmxrmi

ERROR: java.lang.NullPointerException: can not invoke "java.lang.Throwable.getCause()" because "Cause " is null

### Handle The Error:
- **Cause:**
    - insufficient configuration

- **Troubleshoot:**
    - 1. After service stoped, Terminate PID Manually
```sh
ps aux | grep activemq
/opt/activemq/bin/activemq stop
sudo lsof -i :61616
sudo kill -9 PID_NUMBER
```

***************************************************************************************************************************************************************************
## 4. Failed to start Apache ActiveMQ:
### ERROR:
Failed to start Apache ActiveMQ (localhost, ID:ldl-los-43711-1718305784516-0:1) | org.apache.activemq.broker.BrokerService | main

java.io.IOException: Transport Connector could not be registered in JMX: java.io.IOException: Failed to bind to server *socket: tcp://0.0.0.0:61616?maximumConnections=1000&wireFormat.maxFrameSize=104857600* due to: java.net.BindException: *Address already in use.*

### Handle The Error:
- **Cause:**
    - Service PID could not be Removed by stoping activemq and services that is still running on 61616

- **Troubleshoot:**
```sh
ps aux | grep activemq
/opt/activemq/bin/activemq stop
sudo lsof -i :61616
sudo kill -9 PID_NUMBER
```

***************************************************************************************************************************************************************************
## 5. Activemq not reachable at port 8161:
### Handle The Error:
- **Cause:**
    - Wrong IP, you can not access it from anywhere.

- **Troubleshoot:**
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
## 6. Directory permissions:
- data: Read, write, and execute for the user running the ActiveMQ process.
```chmod 755 /path/to/activemq/data```

- conf: Read and execute for the user running the ActiveMQ process. later change to 500. owner=5, grouppermission(0), otherUsers(0) 
```chmod 755 /path/to/activemq/conf```

- bin: Read, write, and execute for the user running the ActiveMQ process.
```chmod 755 /path/to/activemq/conf```

***************************************************************************************************************************************************************************
## 7. Testing the installation Using the administrative interface:
- ***Open the administrative interface***
```sh
URL: http://127.0.0.1:8161/admin/
Login: admin
Passwort: admin
Navigate to “Queues”
Add a queue name and click create
Send test message by klicking on “Send to”
```

- ***Logfile and console output:***
/opt/activemq/data/activemq.log

- ***Listen port:***
netstat -nl|grep 61616

***************************************************************************************************************************************************************************
## 8. Documentation Links:
- ```https://activemq.apache.org/components/classic/documentation/getting-started#OnUnix:```
- ```https://activemq.apache.org/components/classic/documentation/unix-shell-script```
- ```https://activemq.apache.org/components/classic/documentation/web-console```
