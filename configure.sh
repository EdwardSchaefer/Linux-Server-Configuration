#!/bin/sh
#configure ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 2200/tcp
sudo ufw allow www
sudo ufw allow ntp
sudo ufw enable

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
cd /var/www/html
sudo git clone -b linux_deployment https://github.com/EdwardSchaefer/Item-Catalog.git catalog

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
sudo -i -u postgres
psql
CREATE USER catalog WITH PASSWORD 'test123';
ALTER USER catalog CREATEDB;
CREATE DATABASE guitars;
\\q
logout

#remove default site
sudo a2dissite 000-default.conf
sudo rm /etc/apache2/sites-available/000-default.conf

#enable catalog site
sudo a2ensite catalog.conf
sudo a2service apache2 restart