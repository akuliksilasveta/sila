#!/bin/bash -e
ZABBIX_SERVER="zabbix.silasveta.local"
ZABBIX_SERVER2="zabbix.silasveta.local,zabbix1.silasveta.local,zabbix2.silasveta.local,zabbix3.silasveta.local"

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

        sed -i "/^Server=/c\Server=10.1.2.0/24" /etc/zabbix/zabbix_agentd.conf
        sed -i "/^ServerActive=/c\ServerActive=${ZABBIX_SERVER2}" /etc/zabbix/zabbix_agentd.conf
        sed -i "/^Hostname=/c\#Hostname=" /etc/zabbix/zabbix_agentd.conf
        sed -i "/^# HostnameItem=system.hostname/c\HostnameItem=system.hostname[host]" /etc/zabbix/zabbix_agentd.conf
        sed -i "/^# HostInterfaceItem=/c\HostInterfaceItem=system.hostname[fqdn,lower]" /etc/zabbix/zabbix_agentd.conf

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
          sed -i "/^ServerActive=/c\ServerActive=${ZABBIX_SERVER2}" /etc/zabbix/zabbix_agentd.conf
          sed -i "/^#HostnameItem=system.hostname/c\HostnameItem=system.hostname[host]" /etc/zabbix/zabbix_agentd.conf
          sed -i "/^# HostInterfaceItem=/c\HostInterfaceItem=system.hostname[fqdn,lower]" /etc/zabbix/zabbix_agentd.conf
          service zabbix-agent restart
fi
