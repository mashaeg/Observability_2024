### Server
```

wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu24.04_all.deb
dpkg -i zabbix-release_7.0-1+ubuntu24.04_all.deb
apt search zabbix
apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
service zabbix-server status
service zabbix-agent status


service mysql status
apt install mysql-server
service mysql status
mysql
mysq> create database zabbix character set utf8mb4 collate utf8mb4_bin;
mysq> create user zabbix@localhost identified by 'password';
mysq> grant all privileges on zabbix.* to zabbix@localhost;
mysq> set global log_bin_trust_function_creators = 1;
mysq> quit;

zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix    #If prompted, enter the password that you've set for your zabbix@localhost user.

mysql
mysq>set global log_bin_trust_function_creators = 0;
mysq>quit;


vim /etc/zabbix/zabbix_server.conf
DBPassword=password       # enter the password that you've set for your zabbix@localhost user.


service zabbix-server start
service zabbix-server status
systemctl enable zabbix-server zabbix-agent apache2


Login: http://your-server-ip-address/zabbix
Change Admin password


```

