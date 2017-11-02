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
sudo apt-get install postgresql -yt

#upgrade pip
pip install --upgrade pip
#install Flask:
sudo pip install Flask
#upgrade Google API Python client
sudo pip install --upgrade google-api-python-client
#install requests
sudo pip install requests
#Install mod_wsgi into Python:
sudo pip install mod_wsgi