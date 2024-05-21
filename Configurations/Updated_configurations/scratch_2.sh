#!/bin/bash
#sudo apt-get -y install php7.4 php7.4-cli php7.4-common php7.4-curl php7.4-dev php7.4-gd php7.4-imap php7.4-json php7.4-mbstring php7.4-opcache php7.4-xml php7.4-yaml php7.4-zip libapache2-mod-php7.4 php-pgsql php-redis php-xdebug unzip postgresql
# sudo apt-get -y install php8.2 php8.2-cli php8.2-common php8.2-curl php8.2-dev php8.2-gd php8.2-imap php8.2-mbstring php8.2-opcache php8.2-xml php8.2-yaml php8.2-zip libapache2-mod-php8.2 php-pgsql php-redis php-xdebug unzip
# sudo apt -y install php8.1 php8.1-cli php8.1-common php8.1-curl php8.1-dev php8.1-gd php8.1-imap php8.1-mbstring php8.1-opcache php8.1-xml php8.1-yaml php8.1-zip libapache2-mod-php8.1 php-pgsql php-redis php-xdebug unzip
#sudo apt -y install php8.2 php8.2-cli php8.2-common php8.2-curl php8.2-dev php8.2-gd php8.2-imap php8.2-mbstring php8.2-opcache php8.2-xml php8.2-yaml php8.2-zip libapache2-mod-php8.2 php-pgsql php-redis php-xdebug unzip
sudo apt -y install php8.3 php8.3-cli php8.3-common php8.3-curl php8.3-dev php8.3-gd php8.3-imap php8.3-mbstring php8.3-opcache php8.3-xml php8.3-yaml php8.3-zip libapache2-mod-php8.3 php-pgsql php-redis php-xdebug unzip

# sudo a2enmod php8.1
# sudo a2enmod php8.2
sudo a2enmod php8.3

sudo systemctl restart apache2

# set default php to the version we have insalled:
sudo update-alternatives --set php /usr/bin/php8.3
# sudo update-alternatives --set php /usr/bin/php8.1


# Create the file repository configuration for postgres:
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main"  /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key for postgres:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y postgresql
sudo systemctl status postgresql
sudo systemctl restart postgresql
sudo systemctl restart apache2



