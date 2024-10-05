# TICK Stack with WordPress: Setup and Debugging Guide

## 1. Ensuring WordPress and Traefik are Working Properly

Confirm that WordPress is accessible through the Traefik reverse proxy at the correct host (e.g., localhost or 192.168.0.24).

Use the following docker-compose configuration snippet for WordPress and Traefik:

```yaml
wordpress:
  image: wordpress:latest
  container_name: wordpress
  restart: unless-stopped
  env_file: .env
  environment:
    - WORDPRESS_DB_HOST=db:3306
    - WORDPRESS_DB_USER=$MYSQL_USER
    - WORDPRESS_DB_PASSWORD=$MYSQL_PASSWORD
    - WORDPRESS_DB_NAME=$WORDPRESS_DB_NAME
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.wordpress.rule=Host(`localhost`) || Host(`192.168.0.24`)"
    - "traefik.http.routers.wordpress.entrypoints=web"
    - "traefik.http.services.wordpress.loadbalancer.server.port=80"
  depends_on:
    - db
```

## 2. Collecting System and Application Metrics with Telegraf

Telegraf is responsible for collecting metrics from various system components:

- WordPress (via NGINX through Traefik)
- MySQL
- cAdvisor for Docker container monitoring
- node-exporter for system-level metrics

Update your `telegraf.conf` to ensure you are collecting all necessary metrics:

```toml
# System Metrics
[[inputs.cpu]]
[[inputs.mem]]
[[inputs.disk]]

# MySQL Metrics
[[inputs.mysql]]
  servers = ["$MYSQL_USER:$MYSQL_PASSWORD@tcp(db:3306)/"]

# NGINX Metrics (via Traefik)
[[inputs.nginx]]
  urls = ["http://localhost:8080/nginx_status"]

# Docker Container Metrics (via cAdvisor)
[[inputs.prometheus]]
  urls = ["http://cadvisor:8080/metrics"]

# System Metrics (via node-exporter)
[[inputs.prometheus]]
  urls = ["http://node-exporter:9100/metrics"]

# InfluxDB Output
[[outputs.influxdb_v2]]
  urls = ["http://influxdb:8086"]
  token = "$INFLUX_TOKEN"
  organization = "$INFLUX_ORG"
  bucket = "$INFLUX_BUCKET"
```

## 3. Verifying Metrics are Sent to InfluxDB

Ensure that metrics are being sent from Telegraf to InfluxDB. You can check this in the Telegraf logs:

```bash
docker logs telegraf
```

Look for entries such as:

```
Wrote batch of 1000 metrics in X ms
```

## 4. Creating a Dashboard in Chronograf

1. Access Chronograf via your browser (http://localhost:8888) and create a new dashboard.
2. Add graphs to track:
   - CPU usage, memory, and disk space from node-exporter
   - WordPress requests and errors from Traefik/NGINX
   - Database performance metrics from MySQL
   - Container performance from cAdvisor

## 5. Setting Up Alerting in Kapacitor

Create Kapacitor alerts for:
- High CPU usage: Set a threshold for CPU usage above 90%
- WordPress 500 errors: Monitor error responses from WordPress
- Database connection issues: Alert when there are too many failed MySQL connections

Here's an example TICKscript for alerting on high CPU usage:

```
stream
    |from()
        .measurement('cpu')
        .where(lambda: "cpu" == 'cpu-total')
    |alert()
        .crit(lambda: "usage_idle" < 10)
        .log('/var/log/cpu_alerts.log')
        .email('your_email@example.com')
```

## Final Steps

1. Ensure WordPress is working via Traefik: Confirm that you can access your CMS.
2. Collect all metrics in Telegraf: Ensure the right input plugins are configured and metrics are visible in Chronograf.
3. Create useful dashboards in Chronograf that visualize critical aspects of system and CMS performance.
4. Set up Kapacitor alerts for critical issues such as high CPU usage, container failures, and 500 errors from WordPress.

## Debugging

To delete all data for the mysql measurement, use a very broad time range that includes all data points (from a very early date until now):

```bash
docker exec -it influxdb influx delete \
  --org my_org \
  --bucket my_bucket \
  --start '1970-01-01T00:00:00Z' \
  --stop $(date -u +"%Y-%m-%dT%H:%M:%SZ") \
  --predicate '_measurement="mysql"'
```

- `--start '1970-01-01T00:00:00Z'`: This start time is the Unix epoch, meaning it will include all data.
- `--stop $(date -u +"%Y-%m-%dT%H:%M:%SZ")`: This dynamically inserts the current date and time as the stop time.
- `--predicate '_measurement="mysql"'`: This ensures that only the mysql measurement is deleted.