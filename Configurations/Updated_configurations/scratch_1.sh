#!/bin/bash
sudo apt install -y lsb-release gnupg2 ca-certificates apt-transport-https software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo add-apt-repository ppa:ondrej/apache2
sudo apt update


#apt-transort-http all 2.4.11