### Host with Zabbix Agent
```
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu24.04_all.deb
dpkg -i zabbix-release_7.0-1+ubuntu24.04_all.deb
apt update
apt install zabbix-agent
vim /etc/zabbix/zabbix_agentd.conf     

->>>>>>Edit parameters for Server, ServerActive, Hostname and save
Hostname=Host-A
Server= ZABBIX SERVER IP
ServerActive= ABBIX SERVER IP

service zabbix-agent restart

sudo apt install zabbix-sender

#Test the Zabbix Sender
zabbix_sender -z 10.114.0.2 -p 10051 -s "Host-A" -k "otus_important_metrics[metric1]" -o 95

#Debugging:

tail -f /var/log/zabbix/zabbix_server.log
tail -f /var/log/zabbix/zabbix_agentd.log

```