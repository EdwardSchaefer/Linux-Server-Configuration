This repository contains the instructions to configure a server to host an 
application on Amazon Lightsail. Following the instructions closely should 
result in creating a functional web server which functions similarly. The 
Lightsail server was initialized as a default Ubuntu system. Apache2 was 
installed to serve the http. mod_wsgi was used to serve the application. 
The original app was a catalog of guitars which was originally configured 
to run on a [Vagrant](https://www.vagrantup.com/) virtual machine. The 
catalog app used a combination of Python 2.7, Flask, SQLalchemy, and SQLite. 
To better work with Apache2, the original catalog app was modified to use 
PostgreSQL/psycopg2, along with other minor modifications.

This repository also contains a shell script file that automates most of
the manual instructions listed in this README. Simply copy and paste the 
contents of configure.sh into the field presented after clicking '+ Add 
launch script' when creating an Amazon Lightsail instance.

App address: http://ec2-54-175-196-141.compute-1.amazonaws.com/

IP Address: 107.23.27.33:2200

Version History
---------------
* 4/12/17 - Initial Commit
* 10/10/17 - Fix 2 typos
* 10/10/17 - Changed path of sshd_config to full path
* 10/18/17 - Added double space after block quotes to format them for Markdown
* 10/18/17 - Changed quotes to clarify how to restart Apache
* 10/18/17 - Used backticks to display closing tags in Markdown
* 10/26/17 - Changed URL to most recent deployment
* 11/01/17 - Added configure.sh shell script with ufw configuration
* 11/01/17 - Added installation of most apt-get (non-pip) packages
* 11/02/17 - Added installation of Python/pip packages
* 11/03/17 - Scripted apache2 configuration file, enabled site
* 11/03/17 - Changed servername/serveradmin to localhost, disabled/removed 
	default apache site
* 11/03/17 - Scripted setting up PostgreSQL database
* 11/03/17 - Set git clone of Item-Catalog repo to default branch
* 11/04/17 - Renamed folder to clone into from 'catalog' to 'html'
* 11/04/17 - Fixed typo 'a2service' to 'service'
* 11/06/17 - Made PostgreSQL commands non-interactive to work with shell script
* 11/06/17 - Changed git clone directory structure to conform to path of 
	json client secrets
* 11/07/17 - Added python commands to deploy the application

List of Files
-------------
* README.md: This README file
* configure.sh: A shell script to automate most of the configuration steps

Configuration
-------------

* Setup SSH Keypair
	- Generate SSH Keypair on local machine by opening up command prompt:
		- "ssh-keygen"
		- Enter path to where the keypair will be generated
		- Hit 'enter' to have no passphrase, then again
* Create Amazon Lightsail instance
	- In browser, under 'resources', click 'Create Instance'
		- For 'Pick your instance image', choose 'OS Only' and 'Ubuntu'
		- Under 'SSH key pair manager', select 'Upload key pair', 
			then choose the public key your created (with .pub extension)
		- For 'Choose your instance plan', choose '$5 month'
		- Under 'Name your instance', give the server a valid name
		- Click 'Create'
* Log into the server with SSH from the command line
	- Enter the following with "sshkey" being whatever you named your keypair, 
		and the numbers following "@" as the IP address: "ssh ubuntu@107.23.27.33 -p 22 -i sshkey"
	- Type 'yes' if promted about the authenticity of the host, then hit enter
* Allow SSH connections on port 2200 and disable password based authentication
	- In the Lightsail console in the browser, go to 'Networking' tab under server instance
	- Click 'add another'
	- Select options: Application: 'Custom', Protocol: 'TPC', Port range: '2200'
	- Edit the SSH daemon configuration file:
		- In the shell, type "sudo nano /etc/ssh/sshd_config"
		- Change the line to "PasswordAuthentication no"
		- Change the line to "Port 2200"
		- Save/exit Nano
		- "sudo service ssh restart" 
* Configure Uncomplicated Firewall
	- "sudo ufw default deny incoming"
	- "sudo ufw default allow outgoing"
	- "sudo ufw allow ssh"
	- "sudo ufw allow 2200/tcp"
	- "sudo ufw allow www"
	- "sudo ufw allow ntp"
	- "sudo ufw enable"
* Create user grader
	- "sudo adduser grader"
	- Enter a password and retype it when promted
	- Leave values for personal info blank
* Give sudo to grader
	- Create a sudoers file for grader
		- "sudo touch /etc/sudoers.d/grader"
		- "sudo nano /etc/sudoers.d/grader"
		- write "grader ALL=(ALL) NOPASSWD:ALL" and save/exit nano
		- "sudo chmod 0440 /etc/sudoers.d/grader" to change permissions
* Create an SSH key pair for grader and add public key to /home/grader/.ssh/authorized_keys
	- Logout (ctrl+D)
	- Generate SSH Keypair on local machine by opening up command prompt:
		- "ssh-keygen"
		- Enter path to where the keypair will be generated
		- Hit 'enter' to have no passphrase, then again
	- Log in as ubuntu: "ssh ubuntu@107.23.27.33 -p 2200 -i sshkey"
	- Install public key for grader
		- "sudo mkdir /home/grader/.ssh"
		- "sudo touch /home/grader/.ssh/authorized_keys"
		- "sudo nano /home/grader/.ssh/authorized_keys"
		- paste contents of grader.pub (or whatever you named the keypair) from clipboard and save/exit
* Log in as grader
	- (from the directory with the private SSH key):
		- ssh grader@184.73.137.31 -p 2200 -i grader
* Change file permissions and ownership on SSH directories and files
	- "sudo chmod 700 /home/ubuntu/.ssh"
	- "sudo chmod 644 /home/ubuntu/.ssh/authorized_keys"
	- "sudo chmod 700 /home/grader/.ssh"
	- "sudo chmod 644 /home/grader/.ssh/authorized_keys"
	- "sudo chown grader /home/grader/.ssh"
	- "sudo chgrp grader /home/grader/.ssh"
	- "sudo chown grader /home/grader/.ssh/authorized_keys"
	- "sudo chgrp grader /home/grader/.ssh/authorized_keys"
* Change timezone to UTC
	- "sudo dpkg-reconfigure tzdata"
	- select none of the above for country
	- select UTC for timezone

Installation
------------

* Update packages:
	- "sudo apt-get update"  
* Install python 2.7:
	- "sudo apt-get install python2.7"
* Install pip:
	- "sudo apt-get install python-pip"
	- "pip install --upgrade pip"
* Install apache2:
	- "sudo apt-get install apache2"
	- "sudo apt-get install apache2-dev"
* Install python wsgi dependencies:
	- "sudo apt-get install python-setuptools"
	- "sudo apt-get install libapache2-mod-wsgi"
	- restart apache2: "sudo service apache2 restart"
* Install PostgreSQL:
	- "sudo apt-get install postgresql"
	- login: "sudo -i -u postgres"
		- postgresql prompt: "psql"
		- list roles: "\du"
		- logout: ctrl+D
* Install sqlalchemy:
	- "sudo apt-get install python-sqlalchemy"
* Install psycopg2:
	- "sudo apt-get install python-psycopg2"
* Install Flask:
	- "sudo pip install Flask"
	- "sudo pip install --upgrade google-api-python-client"
	- "sudo pip install requests"
* Install mod_wsgi into Python:
	- "sudo pip install mod_wsgi"

Site Setup
----------

* Clone linux_deployment branch of the application
	- "cd /var/www/html"
	- "sudo git clone -b linux_deployment https://github.com/EdwardSchaefer/Item-Catalog.git catalog"

* Create a wsgi script:	
	- "sudo touch catalog.wsgi"
	- "sudo nano catalog.wsgi" and enter the following code:
		>#!/usr/bin/python  
		>import sys  
		>import logging  
		>logging.basicConfig(stream=sys.stderr)  
		>sys.path.insert(0,"/var/www/html/")  
		>  
		>from catalog import app as application  
		>application.secret_key = 'super_secret_key'  
* Setup a site for the app in apache:
	- "cd /etc/apache2/sites-available"  
	- "sudo touch catalog.conf"  
	- "sudo nano catalog.conf" and enter the following code:  
		><VirtualHost *:80>  
		>        ServerName 107.23.27.33  
		>        ServerAdmin admin@107.23.27.33  
		>        WSGIScriptAlias / /var/www/html/catalog.wsgi  
		>        <Directory /var/www/html/wsgiscripts/>  
		>                Order allow,deny  
		>                Allow from all  
		>        `</Directory>`  
		>        Alias /static /var/www/html/catalog/static  
		>        <Directory /var/www/html/catalog/static/>  
		>                Order allow,deny  
		>                Allow from all  
		>        `</Directory>`  
		>        ErrorLog ${APACHE_LOG_DIR}/error.log  
		>        LogLevel warn  
		>        CustomLog ${APACHE_LOG_DIR}/access.log combined  
		>`</VirtualHost>`  

	- "sudo a2ensite catalog.conf"
		(to disable: "sudo a2dissite catalog.conf")
	- "sudo service apache2 reload"

* Configure PostgreSQL
	- "sudo -i -u postgres"
	- "psql"
	- "CREATE USER catalog WITH PASSWORD 'test123';"
	- "ALTER USER catalog CREATEDB;"
	- "CREATE DATABASE guitars;"
	- ctrl+D to logout of the psql prompt
	- ctrl+D to logout of the postgres account

* If neccessary, use these commands to operate postgresql:
	- show connections on guitars: "SELECT * FROM pg_stat_activity WHERE datname = 'guitars';"
	- terminate connections: "SELECT pg_terminate_backend (pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'guitars';"
	- drop guitars: "DROP DATABASE guitars;"

* setting up the app:
	- "python database_setup.py"
	- "sudo python guitars.py"
	- "sudo python catalog.py"

Changes to original catalog project
-----------------------------------

* Created "linux_deployment" branch to work on Ubuntu server
* Configured SQLAlchemy to work with PostgreSQL instead of SQLite
	- Changed "engine = create_engine('SQLite:///guitars.db') to "engine = create_engine('postgresql+psycopg2://catalog:test123@localhost:5432/guitars')
* Change description of Jackson guitars bridges to fit within PostgreSQL 50 character limit
* Changed CLIENT_ID variable to have a full path so it works with wsgi_mod

Sources Used
------------

* [A Step by Step Guide to Install LAMP (Linux, Apache, MySQL, Python) on Ubuntu](http://blog.udacity.com/2015/03/step-by-step-guide-install-lamp-linux-apache-mysql-python-ubuntu.html)
* [How To Configure the Apache Web Server on an Ubuntu or Debian VPS](https://www.digitalocean.com/community/tutorials/how-to-configure-the-apache-web-server-on-an-ubuntu-or-debian-vps)
* [How To Install and Use PostgreSQL on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-14-04)
* [How To Secure PostgreSQL on an Ubuntu VPS](https://www.digitalocean.com/community/tutorials/how-to-secure-postgresql-on-an-ubuntu-vps)
* [How To Deploy a Flask Application on an Ubuntu VPS](https://www.digitalocean.com/community/tutorials/how-to-deploy-a-flask-application-on-an-ubuntu-vps)
* [mod_wsgi quickstart](http://modwsgi.readthedocs.io/en/develop/user-guides/quick-configuration-guide.html)
* [Project 5 resources from Kirk Brunson](https://discussions.udacity.com/t/project-5-resources/28343)