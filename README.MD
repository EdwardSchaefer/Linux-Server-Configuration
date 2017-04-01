List of Changes
---------------
* Change port to 2200
	- User Amazon lightsail control panel
* Created user grader
	- sudo adduser grader
* Gave sudo to grader
	- sudo cp /etc/sudoers.d/ubuntu /etc/sudoers.d/grader
	- sudo nano /etc/sudoers.d/grader
	- write: "grader ALL=(ALL) NOPASSWD:ALL"
* Created SSH key pair for grader and added public key to .ssh/authorized_keys
	- go to lightsail account page
	- click create key pair
	- name keypair 'grader' and save to directory that you log in from
	- copy contents to grader.pub
	- (logged into server):
		- mkdir .ssh
		- touch .ssh/authorized_keys
		- nano .ssh/authorized_keys
		- paste contents of grader.pub from clipboard and save (^X)
* Log in as grader
	- (from the directory with the private SSH key):
		- ssh grader@184.73.137.31 -p 2200 -i grader
* Change file permissions on SSH directory and file
	- (From the home directory of grader):
		- chmod 700 .ssh
		- chmod 644 .ssh/authorized_keys
* Disable password based logins
	- sudo nano /etc/ssh/sshd_config
	- change 'PasswordAuthentication yes' to 'PasswordAuthentication no'
* Restart SSH service
	- sudo service ssh restart
* Change timezone to UTC
	- sudo dpkg-reconfigure tzdata to UTC
	- select none of the above for country
	- select UTC for timezone
* Install python 2.7:
	- sudo apt-get install python2.7 (yes)
		- http://askubuntu.com/questions/101591/how-do-i-install-python-2-7-2-on-ubuntu (michael_n)
* Install pip:
	- sudo apt-get install python-pip
	- pip install --upgrade pip
* Install apache2:
	- sudo apt-get install apache2 (yes)
	- sudo apt-get install apache2-dev (yes) (https://github.com/GrahamDumpleton/mod_wsgi)
* Install python wsgi dependencies:
	- sudo apt-get install python-setuptools (yes)
	- sudo apt-get install libapache2-mod-wsgi
	- restart apache2: sudo service apache2 restart (http://blog.udacity.com/2015/03/step-by-step-guide-install-lamp-linux-apache-mysql-python-ubuntu.html)
* Install PostgreSQL:
	- sudo apt-get install postgresql
	- login: sudo -i -u postgres
		- postgresql prompt: psql
		- logout: ctrl+D
* Install sqlalchemy:
	- sudo apt-get install python-sqlalchemy (yes)
* Install Flask:
	- sudo pip install Flask
		- not owned by current user error
	- sudo pip install --upgrade google-api-python-client
		- not owned by current user error
	- pip install requests
* Install virtualenv
	- sudo pip install virtualenv
* Fix Invalid mutex directory error:
	- source /etc/apache2/envvars	(http://askubuntu.com/questions/800214/invalid-mutex-directory-in-argument-fileapache-lock-dir)
* Install mod_wsgi into Python:
	- sudo pip install mod_wsgi
	- Test mod_wsgi:
		- mod_wsgi-express start-server
		- ctrl+c
	- (https://github.com/GrahamDumpleton/mod_wsgi)
* in /var/www/html:
	- sudo git clone https://github.com/EdwardSchaefer/Item-Catalog.git
	- cd Item-Catalog

	///maybe
	- sudo mkdir wsgiscripts
	- cd wsgiscripts
	(in /var/www/html/wsgiscripts):
		- sudo touch catalog.wsgi
		- sudo nano catalog.wsgi:
			>def application(environ, start_response):
		    >status = '200 OK'
		    >output = b'Hello World!'

		    >response_headers = [('Content-type', 'text/plain'),
		    >                    ('Content-Length', str(len(output)))]
		    >start_response(status, response_headers)

		    >return [output]
	///

	/// maybe
	- sudo touch catalog.wsgi
	- sudo nano catalog.wsgi
		- import sys
		- sys.path.insert(0, "/var/www/html/Item-Catalog/")
		- 'import app as application'
	///

	///maybe
	- sudo rm README.md
	- sudo mv * ..
	- sudo mv .git ..
	- cd ..
	- sudo rm -rf Item-Catalog
	///

* Setup a site for the app in apache:
	- (In etc/apache2/sites-available):
		- sudo cp 000-default.conf catalog.conf
		- sudo nano catalog.conf
			>DocumentRoot /var/www/html/Item-Catalog

			><Directory /var/www/html/Item-Catalog>
			>	Order allow,deny
			>	Allow from all
			></Directory>

			>WSGIScriptAlias /Item-Catalog /var/www/html/wsgiscripts/catalog.wsgi

			><Directory /var/www/html/wsgiscripts>
			>	Order allow,deny
			>	Allow from all
			></Directory>

		- sudo service apache2 restart
		- sudo a2ensite catalog.conf
			(to disable: sduo a2dissite catalog.conf)
		- sudo service apache2 reload
		- list active sites: apache2ctl -S

	- (http://modwsgi.readthedocs.io/en/develop/user-guides/quick-configuration-guide.html)

* setting up the app:
	- python database_setup.py
	- sudo python guitars.py
	- mod_wsgi-express start-server catalog.py

Sources Used
------------

*http://blog.udacity.com/2015/03/step-by-step-guide-install-lamp-linux-apache-mysql-python-ubuntu.html
*https://discussions.udacity.com/t/project-5-resources/28343
*https://www.digitalocean.com/community/tutorials/how-to-configure-the-apache-web-server-on-an-ubuntu-or-debian-vps
*https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-14-04
*https://www.digitalocean.com/community/tutorials/how-to-deploy-a-flask-application-on-an-ubuntu-vps
*http://modwsgi.readthedocs.io/en/develop/user-guides/quick-configuration-guide.html