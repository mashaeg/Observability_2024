#!/bin/bash

# Step 1: Generate LLD discovery data for Zabbix
cat << EOF
{
    "data": [
        { "{#METRICNAME}": "metric1" },
        { "{#METRICNAME}": "metric2" },
        { "{#METRICNAME}": "metric3" }
    ]
}
EOF

# Step 2: Define variables for Zabbix server and host
agenthost="Host-A"
zserver="10.114.0.2"  # Replace with your actual Zabbix server IP address
zport="10051"         # Zabbix server port

# Step 3: Create an empty data file for zabbix_sender
cat /dev/null > /usr/local/zdata.txt

# Step 4: Loop through each metric and generate a random value for it
for metric in "metric1" "metric2" "metric3"; do
    randnum="$(($RANDOM % 100 + 1))"  # Generate a random number between 1 and 100
    # Append the hostname, metric key, and value to the zdata.txt file
    echo "$agenthost otus_important_metrics[$metric] $randnum" >> /usr/local/zdata.txt
done

# Step 5: Use zabbix_sender to send the data to the Zabbix server
zabbix_sender -vv -z $zserver -p $zport -i /usr/local/zdata.txt >> /usr/local/zsender.log 2>&1
