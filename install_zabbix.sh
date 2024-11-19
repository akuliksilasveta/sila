#!/bin/bash -e
ZABBIX_SERVER="zabbix.silasveta.local"
HOSTNAME="hostname"

if [ "$UID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Only run it if we can (ie. on Ubuntu/Debian)
if [ -x /usr/bin/apt-get ]; then
        apt-get remove -y zabbix-agent
        apt-get purge -y zabbix-agent
        sudo apt -y remove needrestart      

        wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_latest+debian12_all.deb
        dpkg -i zabbix-release_latest+debian12_all.deb
        apt-get update
        apt-get install zabbix-agent

        sed -i "/^Server=/c\Server=${ZABBIX_SERVER}" /etc/zabbix/zabbix_agentd.conf
        sed -i "/^ServerActive=/c\ServerActive=${ZABBIX_SERVER}" /etc/zabbix/zabbix_agentd.conf
        sed -i "/^Hostname=/c\Hostname=${HOSTNAME}" /etc/zabbix/zabbix_agentd.conf

        sed -i "s/# StartAgents=3/StartAgents=5/;
            s/# HostMetadata=/HostMetadataItem=release/;
            s/# UserParameter=/UserParameter=release, uname -s/" /etc/zabbix/zabbix_agentd.conf
        systemctl unmask zabbix-agent.service
        systemctl unmask zabbix-agent
        service zabbix-agent restart  
fi

# Only run it if we can (ie. on RHEL/CentOS)
if [ -x /usr/bin/yum ]; then
          yum -y update
          rpm -ivh https://repo.zabbix.com/zabbix/7.0/rhel/9/x86_64/zabbix-release-latest.el9.noarch.rpm
          yum -y install zabbix-agent
          chkconfig zabbix-agent on
          sed -i "/^Server=/c\Server=${ZABBIX_SERVER}" /etc/zabbix/zabbix_agentd.conf
          sed -i "/^ServerActive=/c\ServerActive=${ZABBIX_SERVER}" /etc/zabbix/zabbix_agentd.conf
          sed -i "s/Hostname=Zabbix\ server/Hostname=$HOSTNAME/" /etc/zabbix/zabbix_agentd.conf
          service zabbix-agent restart
fi
