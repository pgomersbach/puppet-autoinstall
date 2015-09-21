#!/bin/bash
#kind: finish

#oses:
#- Debian 6.0
#- Debian 7.0
#- Ubuntu 10.04
#- Ubuntu 12.04
#- Ubuntu 13.04
#- CentOS 6
hostname=$(hostname -f) 

if [ -f /usr/bin/dpkg ]
then
  wget http://apt.puppetlabs.com/puppetlabs-release-stable.deb
  dpkg -i puppetlabs-release-stable.deb
  apt-get --yes --quiet update
  apt-get --yes -o Dpkg::Options::="--force-confold" --quiet install git puppet-common puppet
fi

# centos
if [ -f /bin/rpm ]
then
  rpm -Uhv --force http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm
  curl -O http://apt.sw.be/redhat/el6/en/x86_64/extras/RPMS/git-1.7.10-1.el6.rfx.x86_64.rpm
  curl -O http://apt.sw.be/redhat/el6/en/x86_64/extras/RPMS/perl-Git-1.7.10-1.el6.rfx.x86_64.rpm
  curl -O http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
  rpm -i --force epel-release-6*.rpm
  yum -y install perl-DBI rsync openssh-clients wget
  rpm -i --force git-1.7.10-1.el6.rfx.x86_64.rpm perl-Git-1.7.10-1.el6.rfx.x86_64.rpm
  yum -y install puppet
fi


cat << EOF > /etc/puppet/puppet.conf
#kind: snippet
#name: puppet.conf
[main]
vardir = /var/lib/puppet
logdir = /var/log/puppet
rundir = /var/run/puppet
ssldir = /var/lib/puppet/ssl

[agent]
pluginsync      = true
report          = true
ignoreschedules = true
daemon          = false
ca_server       = foreman.rely.nl
certname        = dummyhostname
environment     = production
server          = foreman.rely.nl

EOF

sed -i "s/^certname        = dummyhostname/certname        = $hostname/" /etc/puppet/puppet.conf

if [ -f /bin/rpm ]
then
  chkconfig puppet on
fi

if [ -f /usr/bin/dpkg ]
then
  /bin/sed -i 's/^START=no/START=yes/' /etc/default/puppet
fi

/bin/touch /etc/puppet/namespaceauth.conf
/usr/bin/puppet agent --enable
/usr/bin/puppet agent --config /etc/puppet/puppet.conf
/etc/init.d/puppet start
