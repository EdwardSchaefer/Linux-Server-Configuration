#!/bin/sh
#configure ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 2200/tcp
sudo ufw allow www
sudo ufw allow ntp
sudo ufw enable

#add user 'grader' with no password or personal info
sudo adduser --disabled-password --gecos "" grader
#give sudo to grader
sudo touch /etc/sudoers.d/grader
cat << EOF | sudo tee -a /etc/sudoers.d/grader
grader ALL=(ALL) NOPASSWD:ALL
EOF
sudo chmod 0440 /etc/sudoers.d/grader
#create ssh directory and authorized_keys file for grader
sudo mkdir /home/grader/.ssh
sudo touch /home/grader/.ssh/authorized_keys
#set ownership/groups/permissions on ssh files and folders
sudo chmod 700 /home/ubuntu/.ssh
sudo chmod 644 /home/ubuntu/.ssh/authorized_keys
sudo chmod 700 /home/grader/.ssh
sudo chmod 644 /home/grader/.ssh/authorized_keys
sudo chown grader /home/grader/.ssh
sudo chgrp grader /home/grader/.ssh
sudo chown grader /home/grader/.ssh/authorized_keys
sudo chgrp grader /home/grader/.ssh/authorized_keys

#Update packages:
sudo apt-get update -y
#Install python 2.7:
sudo apt-get install python2.7 -y
#Install pip:
sudo apt-get install python-pip -y
#Install apache2:
sudo apt-get install apache2 -y
sudo apt-get install apache2-dev -y
#Install python wsgi dependencies:
sudo apt-get install python-setuptools -y
sudo apt-get install libapache2-mod-wsgi -y
#restart apache2:
sudo service apache2 restart
#Install sqlalchemy
sudo apt-get install python-sqlalchemy -y
#Install psycopg2:
sudo apt-get install python-psycopg2 -y
#Install PostgreSQL:
sudo apt-get install postgresql -y

#upgrade pip
pip install --upgrade pip
#install Flask:
sudo pip install Flask
#upgrade Google API Python client
sudo pip install --upgrade google-api-python-client
#install
sudo pip install requests
#Install mod_wsgi into Python:
sudo pip install mod_wsgi

#clone the repository
cd /var/www
sudo rm -rf html
sudo git clone https://github.com/EdwardSchaefer/Item-Catalog.git html

#set up the site in apache
sudo touch /etc/apache2/sites-available/catalog.conf
cat << EOF > /etc/apache2/sites-available/catalog.conf
<VirtualHost *:80>
ServerName localhost
ServerAdmin admin@localhost
WSGIScriptAlias / /var/www/html/catalog.wsgi
<Directory /var/www/html/wsgiscripts/>
Order allow,deny
Allow from all
</Directory>
Alias /static /var/www/html/catalog/static
<Directory /var/www/html/catalog/static/>
Order allow,deny
Allow from all
</Directory>
ErrorLog ${APACHE_LOG_DIR}/error.log
LogLevel warn
CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

#setup postgres database
sudo -u postgres psql -c "CREATE USER catalog WITH PASSWORD 'test123'";
sudo -u postgres psql -c "ALTER USER catalog CREATEDB";
sudo -u postgres psql -c "CREATE DATABASE guitars";

#deploy the application
python /var/www/html/catalog/database_setup.py
sudo python /var/www/html/catalog/guitars.py

#remove default site
sudo a2dissite 000-default.conf
sudo rm /etc/apache2/sites-available/000-default.conf

#enable catalog site
sudo a2ensite catalog.conf
sudo service apache2 restart