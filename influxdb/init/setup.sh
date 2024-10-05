#!/bin/bash
set -e

# Check if InfluxDB is already set up
if influx bucket list > /dev/null 2>&1; then
    echo "InfluxDB is already set up. Skipping initialization."
else
    # Initialize InfluxDB with a user, organization, and bucket
    influx setup --username my_admin_user \
                 --password my_secure_password\
                 --org my_org \
                 --bucket my_bucket \
                 --retention 30d \
                 --force
fi

# You can add additional setup commands here if needed