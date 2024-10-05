# TICK Stack with WordPress Monitoring

This project sets up a WordPress site with an extended TICK (Telegraf, InfluxDB, Chronograf, Kapacitor) stack for comprehensive monitoring, all orchestrated using Docker Compose.

## Components

- **WordPress**: Content Management System
- **MySQL**: Database for WordPress
- **Traefik**: Reverse Proxy and Load Balancer
- **InfluxDB**: Time Series Database for storing metrics
- **Chronograf**: Visualization and monitoring tool
- **Kapacitor**: Real-time streaming data processing engine
- **Telegraf**: Agent for collecting and reporting metrics
- **cAdvisor**: Container Advisor for collecting, aggregating, and exporting container resource usage
- **Node Exporter**: Exporter for machine metrics

## Prerequisites

- Docker
- Docker Compose

## Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Create necessary directories:
   ```bash
   mkdir -p influxdb/config influxdb/data influxdb/init kapacitor/replay telegraf wordpress
   ```

3. Set proper permissions:
   ```bash
   sudo chown -R 1000:1000 wordpress
   sudo chmod -R 755 wordpress
   sudo chown -R 1000:1000 ./influxdb/data
   sudo chmod -R 777 ./influxdb/data
   chmod +x influxdb/init/setup.sh  # If you have a setup script
   ```

4. Create `.env` file in the project root:
   ```
   MYSQL_USER=wordpress
   MYSQL_PASSWORD=secure_password
   MYSQL_ROOT_PASSWORD=root_password
   WORDPRESS_DB_NAME=wordpress

   DOCKER_INFLUXDB_INIT_USERNAME=my_admin_user
   DOCKER_INFLUXDB_INIT_PASSWORD=my_secure_password
   DOCKER_INFLUXDB_INIT_ORG=my_org
   DOCKER_INFLUXDB_INIT_BUCKET=my_bucket

   INFLUX_TOKEN=your_influxdb_token_here
   ```

5. Start the stack:
   ```bash
   docker-compose up -d
   ```

## Accessing Services

- WordPress: http://localhost or http://192.168.0.24
- Traefik Dashboard: http://localhost:8080 or http://192.168.0.24:8080
- InfluxDB: http://localhost:8086 or http://192.168.0.24:8086
- Chronograf: http://localhost:8888 or http://192.168.0.24:8888
- cAdvisor: http://localhost:8080 or http://192.168.0.24:8080
- Node Exporter metrics: http://localhost:9100/metrics or http://192.168.0.24:9100/metrics

## Configuration

### Telegraf
Edit `telegraf/telegraf.conf` to adjust metric collection settings. Ensure it's configured to scrape metrics from cAdvisor and Node Exporter.

### Kapacitor
Edit `kapacitor/kapacitor.conf` to configure alerting and data processing rules.

### Traefik
Traefik configuration is defined in `docker-compose.yml` using labels.

### cAdvisor and Node Exporter
These services are typically configured via Docker Compose. Check the `docker-compose.yml` file for their specific configurations.

cAdvisor gives you detailed container-level metrics, while node-exporter gives you system-level metrics. If you want to monitor both the system and the containers, you would need both tools:

- Use cAdvisor to monitor Docker containers and see how each container is consuming CPU, memory, etc.
- Use node-exporter to monitor the health of the macOS machine itself, such as overall CPU usage, memory, and disk I/O.

## Monitoring Setup

1. Access Chronograf at http://localhost:8888
2. Configure InfluxDB connection:
   - URL: `http://influxdb:8086`
   - Organization: `my_org`
   - Token: Use the token from your `.env` file
3. Create dashboards to visualize your metrics
4. Set up data sources for cAdvisor and Node Exporter in Chronograf:
   - cAdvisor: `http://cadvisor:8080`
   - Node Exporter: `http://node-exporter:9100`

## Maintenance and Troubleshooting

### Checking Logs
To view logs for a specific service:
```bash
docker-compose logs [service_name]
```
Replace `[service_name]` with wordpress, db, influxdb, chronograf, kapacitor, telegraf, traefik, cadvisor, or node-exporter.

### Restarting Services
To restart a single service:
```bash
docker-compose restart [service_name]
```

To restart the entire stack:
```bash
docker-compose down
docker-compose up -d
```

### Updating Services
1. Pull the latest images:
   ```bash
   docker-compose pull
   ```
2. Recreate containers:
   ```bash
   docker-compose up -d
   ```

### Common Issues

1. **Kapacitor Connection Failure**:
   - Check Kapacitor logs: `docker-compose logs kapacitor`
   - Verify Kapacitor configuration in `kapacitor.conf`
   - Ensure InfluxDB token is correct in `.env` and `kapacitor.conf`

2. **Telegraf Not Sending Metrics**:
   - Check Telegraf logs: `docker-compose logs telegraf`
   - Verify InfluxDB connection details in `telegraf.conf`
   - Ensure Telegraf is configured to scrape cAdvisor and Node Exporter metrics

3. **cAdvisor or Node Exporter Metrics Not Visible**:
   - Check their respective logs: `docker-compose logs cadvisor` or `docker-compose logs node-exporter`
   - Verify they're running: `docker-compose ps`
   - Ensure Telegraf is configured to collect their metrics

4. **WordPress Not Accessible**:
   - Check Traefik logs: `docker-compose logs traefik`
   - Verify Traefik labels in `docker-compose.yml`

## Backup and Restore

### Backing Up
1. WordPress:
   ```bash
   docker-compose exec db mysqldump -u root -p wordpress > wordpress_backup.sql
   ```
2. InfluxDB:
   Use the InfluxDB backup command or export data through Chronograf.

### Restoring
1. WordPress:
   ```bash
   cat wordpress_backup.sql | docker exec -i <mysql_container_name> mysql -u root -p wordpress
   ```
2. InfluxDB:
   Use the InfluxDB restore command or import data through Chronograf.

## Security Considerations

- Change all default passwords in the `.env` file
- Secure the Traefik dashboard in production environments
- Regularly update all services to patch security vulnerabilities
- Use HTTPS in production with Let's Encrypt certificates (configurable via Traefik)
- Consider network segmentation to limit access to monitoring services

## Customization

- To add custom plugins or themes to WordPress, place them in the `wordpress` directory
- To modify InfluxDB initialization, edit scripts in the `influxdb/init` directory
- To add custom Telegraf plugins, modify the `telegraf.conf` file
- Adjust cAdvisor and Node Exporter settings in `docker-compose.yml` as needed

For more detailed customization options, refer to the official documentation of each service.
