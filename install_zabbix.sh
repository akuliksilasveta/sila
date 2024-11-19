#/bih/bash
ZABBIX_SERVER="zabbix.silasveta.local"        #Main P4-zabbix server

if [[ $EUID -ne 0 ]]; then
        echo "must run as root" 1>&2
        exit 1
else
        apt-get remove -y zabbix-agent
        apt-get purge -y zabbix-agent
        sudo apt -y remove needrestart

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
        systemctl enable zabbix-agent.service
        systemctl restart zabbix-agent.service
fi
