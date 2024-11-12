# Assignment Guide

### CMS server

1. CMS Setup
   - NGINX, PHP-FPM, MySQL installed
   - Basic configuration completed

2. Filebeat Setup
   - Installation and configuration done
   - Collecting logs from:
     * NGINX access logs
     * PHP-FPM logs
     * MySQL error logs
   - Dissect processor configured for NGINX logs

3. Metricbeat Setup
   - Installation and configuration done
   - Collecting metrics from:
     * System (CPU, Memory, Network)
     * NGINX status
     * MySQL performance data

### ELK server

1. Heartbeat Setup
```bash
# Install Heartbeat on Elasticsearch VM
curl -L -O https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-8.15.3-amd64.deb
sudo dpkg -i heartbeat-8.15.3-amd64.deb

# Configure Heartbeat
sudo tee /etc/heartbeat/heartbeat.yml << 'EOF'
heartbeat.monitors:
- type: http
  id: cms-web
  name: CMS Web
  schedule: '@every 10s'
  urls: ["http://your-cms-ip"]
  
- type: tcp
  id: cms-mysql
  name: CMS MySQL
  schedule: '@every 10s'
  hosts: ["your-cms-ip:3306"]

output.elasticsearch:
  hosts: ["localhost:9200"]
EOF

# Start Heartbeat
sudo systemctl enable heartbeat-elastic
sudo systemctl start heartbeat-elastic
```

2. ILM Policies Setup
```bash
# Create ILM policies for different retention periods
# For NGINX and MySQL logs (30 days)
curl -X PUT "localhost:9200/_ilm/policy/30-days-policy" -H 'Content-Type: application/json' -d'
{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "rollover": {
            "max_age": "1d"
          }
        }
      },
      "delete": {
        "min_age": "30d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}'

# For PHP-FPM logs (14 days)
curl -X PUT "localhost:9200/_ilm/policy/14-days-policy" -H 'Content-Type: application/json' -d'
{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "rollover": {
            "max_age": "1d"
          }
        }
      },
      "delete": {
        "min_age": "14d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}'

# Update Filebeat configuration to use ILM policies
sudo tee /etc/filebeat/filebeat.yml << 'EOF'
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/nginx/access.log
  fields:
    log_type: nginx
  fields_under_root: true
  processors:
    - dissect:
        tokenizer: "%{client_ip} - %{user} [%{timestamp}] \"%{method} %{request} HTTP/%{httpversion}\" %{status_code} %{size} \"%{referrer}\" \"%{agent}\""
        field: "message"
        target_prefix: "nginx"

- type: log
  enabled: true
  paths:
    - /var/log/mysql/error.log
  fields:
    log_type: mysql
  fields_under_root: true

- type: log
  enabled: true
  paths:
    - /var/log/php8.1-fpm.log
  fields:
    log_type: php-fpm
  fields_under_root: true

output.elasticsearch:
  hosts: ["10.114.0.3:9200"]
  indices:
    - index: "nginx-logs-%{+yyyy.MM.dd}"
      when.equals:
        log_type: "nginx"
      lifecycle:
        name: "30-days-policy"
    - index: "mysql-logs-%{+yyyy.MM.dd}"
      when.equals:
        log_type: "mysql"
      lifecycle:
        name: "30-days-policy"
    - index: "php-fpm-logs-%{+yyyy.MM.dd}"
      when.equals:
        log_type: "php-fpm"
      lifecycle:
        name: "14-days-policy"

setup.template.enabled: true
setup.template.name: "logs"
setup.template.pattern: "*-logs-*"
setup.template.settings:
  index.number_of_shards: 1
  index.number_of_replicas: 1

logging.level: info
EOF
```

The warning says:

    "Policy 14-days-policy is configured for rollover, but index mysql-logs-2024.11.12 does not have an alias, which is required for rollover."

This means that the ILM policy you are trying to apply is set up to perform rollover operations, which require an alias to work correctly. The rollover process is designed to automatically create new indices once the current index meets specific conditions, such as age or size.

Here are the steps you can take to resolve the issue:
1. Create an Alias for the Index:

To apply a rollover ILM policy, you need to create an alias for your index.

    Navigate to the Dev Tools in Kibana:
        In Kibana, go to "Dev Tools" to execute API commands directly against Elasticsearch.

    Create an Alias for the Index:
        Run the following command to create an alias for your index:

POST /_aliases
{
  "actions": [
    {
      "add": {
        "index": "mysql-logs-2024.11.12",
        "alias": "mysql-logs-alias"
      }
    }
  ]
}

Apply the Alias in the ILM Policy:

    Now that you have created an alias, update your ILM policy to use "mysql-logs-alias" instead of directly referencing the index name.