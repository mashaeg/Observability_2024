# Observability2024
## 1st Assignment: Setting up and Configuring Prometheus, Using Exporters

You need to install and configure Prometheus for system monitoring using Docker. The task involves collecting metrics from all system components, including CMS, Nginx, PHP-FPM, MySQL, and checking service availability using the blackbox exporter.

### Project Structure

- `docker-compose.yml` — main file for launching all services.
- `GAP-1/` — directory containing configurations for Prometheus and Alertmanager.
- `README.md` — documentation for the project.

### Metrics

The system collects metrics from:
- The virtual machine (using Node Exporter).
- CMS availability (using Blackbox Exporter).
- Nginx, PHP-FPM, and MySQL.

### Technologies Used

- Docker 27.1.2, Docker Compose V2
- Prometheus
- Exporters (Node, Blackbox)
- MySQL
- Nginx
- PHP-FPM

### Install WordPress
To install WordPress, visit:  
http://localhost:8080/wp-admin/install.php

### Prometheus Reload
To reload Prometheus configuration, use:
```bash
curl -X POST http://localhost:9090/-/reload
```

### Docker Debugging Commands
To bring services down:  
```bash
docker compose down
```  
To bring services up in detached mode:  
```bash
docker compose up -d
```

### Manual Run for MySQL Exporter
To manually run the MySQL exporter:  
```bash
docker run --rm -it --name mysql_exporter --network maria_monitoring -e DATA_SOURCE_NAME="root:root_password@tcp(db:3306)/" prom/mysqld-exporter:v0.12.1
```

### Check CMS Container IP
To get the IP address of the CMS container:  
```bash
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cms
```
### Port Mappings

Services are exposing the ports and mapping them to the host machine
```bash
services:
  nginx:
    ports:
      - "8080:80"  # Maps host port 8080 to container port 80
  grafana:
    ports:
      - "3000:3000"  # Maps host port 3000 to container port 3000
```
If you want to access services using their container IPs (such as 172.19.0.x), this might not work directly from the host due to Docker’s networking isolation.

### Host Network Mode (If Needed)

If you absolutely need to use container IPs or want to eliminate network isolation, you can use the host network mode in Docker:
```bash
services:
  nginx:
    network_mode: "host"
```
### Push to Git
To push the changes to the Git repository:  
```bash
git push --force origin domz1
```

### Installing Lab: Create VM and Install Docker
To set up the lab environment, create a virtual machine, install Docker, and clone the repository.

### Debug: Fixing File Permissions
Fix file permissions for different components:

- WordPress data:  
  ```bash
  sudo chown -R www-data:www-data /home/maria/wp_data
  ```
- Database data:  
  ```bash
  sudo chown -R 999:root /home/maria/db_data
  ```
- Grafana data:  
  ```bash
  sudo chown -R 472:0 ./grafana_data
  ```

### Sending Custom Metrics to Pushgateway
To send custom metrics to Pushgateway:
```bash
echo "<metric_name> <value>" | curl --data-binary @- http://<pushgateway_address>:<pushgateway_port>/metrics/job/<job_name>/instance/<instance_name>
```
Example:  
```bash
echo "temperature 25" | curl --data-binary @- http://pushgateway:9091/metrics/job/temperature_metrics/instance/pushgateway
```

To query the metrics in Prometheus:  
```promql
temperature{job="pushgateway", instance="pushgateway:9091"}
```
