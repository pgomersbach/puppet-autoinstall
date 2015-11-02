#!/bin/bash

echo "Post install started on `date`" > /root/manifest
echo "Wait for network connection" >> /root/manifest
sleep 20

SYSTYPE=$( cat /etc/systemtype )

if [ "$SYSTYPE" == "puppetmaster" ]
then
  echo "This is a puppetmaster" >> /root/manifest
  echo "Getting pupperlabs repo" >> /root/manifest
  wget -q "http://apt.puppetlabs.com/pubkey.gpg" -O- | apt-key add -
  echo "deb http://apt.puppetlabs.com/ squeeze main" >> /etc/apt/sources.list
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get -y --force-yes install git puppet rails rubygems mysql-server libdbd-mysql-ruby libmysql-ruby1.8
  echo "Install active record gem" >> /root/manifest
  gem install --no-rdoc --no-ri activerecord --version 3.0.11
  apt-get -y --force-yes install libmysqlclient15-dev
  echo "Install mysql record gem" >> /root/manifest
  gem install --no-rdoc --no-ri mysql
  CMD="create database puppet; grant all on puppet.* to puppet@'localhost' identified by 'password';"
  mysql -u root -e "$CMD"
  /usr/bin/git clone https://code.google.com/p/puppet-autoinstall/ /root/puppet-autoinstall
  cp -a /root/puppet-autoinstall/* /etc/puppet
  echo include puppet, puppet::server, foreman, foreman_proxy | puppet apply --modulepath /etc/puppet/modules/install
  cp /etc/puppet/files/puppet-server.conf /etc/puppet/puppet.conf
  cp /etc/puppet/files/fileserver.conf /etc/puppet/fileserver.conf
  /etc/init.d/puppetmaster stop
  sed -i 's/START=yes/START=no/g' /etc/default/puppetmaster
  rm -rf /var/lib/puppet/ssl/*
  /usr/bin/puppet cert generate foreman.rely.nl
  /usr/sbin/a2enmod headers
  /etc/init.d/apache2 restart
  sed -i 's/START=no/START=yes/g' /etc/default/foreman
  cd /usr/share/foreman
  /usr/bin/rake db:migrate RAILS_ENV=development
  /usr/bin/rake puppet:import:puppet_classes[batch] RAILS_ENV=production
  sed -i 's/START=no/START=yes/g' /etc/default/puppet
  /etc/init.d/foreman start
  /etc/init.d/puppet start

elif [ "$SYSTYPE" == "slave" ]
then
  echo "This is a slave" >> /root/manifest
  if [ -e /usr/bin/yum ]; then
  	echo "yum available" >> /root/manifest
	VERSION=$(awk '{printf "%d\n", $3}' /etc/*-release | uniq)
	echo "OS version = $VERSION" >> /root/manifest
	yum -y -q install wget
	if [ "$VERSION" == "5" ]
	then 
		rpm -Uh http://mirror.nl.leaseweb.net/epel/5/x86_64/epel-release-5-4.noarch.rpm
		wget http://puppet-autoinstall.googlecode.com/git/files/puppet.repo5 -O /etc/yum.repos.d/puppet.repo
	else
		rpm -Uh http://mirror.nl.leaseweb.net/epel/6/x86_64/epel-release-6-5.noarch.rpm
		wget http://puppet-autoinstall.googlecode.com/git/files/puppet.repo6 -O /etc/yum.repos.d/puppet.repo
	fi
	yum -y -q install puppet
	/sbin/chkconfig puppet on
  elif [ -e /usr/bin/apt-get ]; then
  	echo "apt-get available" >> /root/manifest
	echo "Getting pupperlabs repo" >> /root/manifest
	wget -q "http://apt.puppetlabs.com/pubkey.gpg" -O- | apt-key add -
	echo "deb http://apt.puppetlabs.com/ squeeze main" >> /etc/apt/sources.list
	apt-get update
  	apt-get -y install puppet-common=2.7.20-1puppetlabs1 puppet=2.7.20-1puppetlabs1 curl
	sed -i 's/START=no/START=yes/g' /etc/default/puppet
  else
  	echo "no suitable package manager" >> /root/manifest
  	exit 1
  fi

  wget http://puppet-autoinstall.googlecode.com/git/files/puppet.conf -O /etc/puppet/puppet.conf
  rm -rf /var/lib/puppet/ssl/*
  /etc/init.d/puppet start
elif [ "$SYSTYPE" == "develop" ]
then
  echc "This is a developer workstation" >> /root/manifest
  apt-get update
  apt-get -y install git puppet
  /usr/bin/git clone https://code.google.com/p/puppet-autoinstall/ /root/puppet-autoinstall
else
  echo "Unsupported OS" >> /root/manifest
  exit 255
fi



if [ -e "/etc/rc.local.org" ]
then
  cp /etc/rc.local.org /etc/rc.local
	echo "rc.local.org restored" >> /root/manifest
else
	 echo "rc.local.org not found" >> /root/manifest
fi

echo "Post install completed on `date`" >> /root/manifest

exit 0


