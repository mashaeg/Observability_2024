# TICK Stack and WordPress Setup Manual

## System Requirements

### Droplet Specifications
- Ubuntu 22.04 LTS
- Minimum 2GB RAM (4GB recommended)
- 2 vCPUs
- 50GB disk space

### Firewall Configuration

#### Inbound Rules
| Type | Port | Source |
|------|------|--------|
| SSH  | 22   | Your IP |
| HTTP | 80   | Anywhere (0.0.0.0/0) |

#### Outbound Rules
| Type | Destination |
|------|-------------|
| All traffic | Anywhere (0.0.0.0/0, ::/0) |

**Note**: Ports 8086, 8888, and 9092 are used internally through Docker's network and don't need to be opened in the firewall.

## Installation Steps

### 1. Initial Server Setup
```bash
# SSH into your droplet
ssh root@your_droplet_ip

# Update system
apt-get update && apt-get upgrade -y

# Install required packages
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    git

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### 2. Project Structure Setup
```bash
# Create project directory
mkdir -p ~/TICK-1
cd ~/TICK-1

# Create required directories
mkdir -p {telegraf,kapacitor,influxdb,nginx/conf.d}
mkdir -p kapacitor/replay
mkdir -p kapacitor/tasks

# Set permissions for kapacitor
chmod 777 kapacitor/replay
chmod 777 kapacitor/tasks
```

### 3. Configuration Files Setup
Create the following configuration files:
1. `.env`
2. `docker-compose.yml`
3. `nginx/conf.d/default.conf`
4. `telegraf/telegraf.conf`
5. `kapacitor/kapacitor.conf`

### 4. Deploy Stack
```bash
# Start the stack
docker-compose up -d

# Verify deployment
docker-compose ps
docker-compose logs -f

# Check WordPress availability
curl http://localhost
# or open in browser: http://your_droplet_ip
```

## Monitoring Setup

### Verify Metrics Flow
```bash
# Check Telegraf logs
docker-compose logs telegraf

# Check InfluxDB buckets
docker-compose exec influxdb influx bucket list

# Verify data flow
docker-compose exec influxdb influx query 'from(bucket:"my_bucket") |> range(start: -1m) |> filter(fn: (r) => r._measurement == "cpu")'
```

### Chronograf Setup

1. Create SSH tunnel:
```bash
# On your local machine
ssh -L 8888:localhost:8888 root@your_droplet_ip
```

2. Access Chronograf UI at `http://localhost:8888`

3. Configure Data Source:
   - Click "Configuration" > "Add Connection"
   - Connection URL: `http://influxdb:8086`
   - Organization: `my_org`
   - Token: Your INFLUX_TOKEN from .env
   - Default Bucket: `my_bucket`

### Kapacitor Alert Configuration

1. Create alerts directory:
```bash
mkdir -p kapacitor/tasks
chmod 755 kapacitor/tasks
```

2. Configure alerts:
```bash
# Create alerts file
nano kapacitor/tasks/alerts.tick

# Set permissions
chmod 644 kapacitor/tasks/alerts.tick

# Load alerts
docker exec -it kapacitor kapacitor define cpu_alert -tick /var/lib/kapacitor/tasks/alerts.tick
docker exec -it kapacitor kapacitor enable cpu_alert
```

3. Verify configuration:
```bash
# Check tasks directory
docker exec -it kapacitor ls -la /var/lib/kapacitor/tasks

# Define alert
docker exec -it kapacitor kapacitor define cpu_alert \
    -tick /var/lib/kapacitor/tasks/alerts.tick \
    -dbrp my_bucket.autogen
```

## Dashboard Setup

### Create Monitoring Dashboard

1. Create a new dashboard in Chronograf with the following metrics:
   - CPU Usage (%)
   - Memory Usage (%)
   - WordPress Response Time (ms)
   - MySQL Connections

2. Configure each metric with appropriate:
   - Visualization type
   - Thresholds
   - Units
   - Time ranges

### Alert Configuration

Setup the following alerts:

1. **CPU Usage Alert**
   - Threshold: > 80%
   - Message Template:
   ```
   Host: {{.TaskName}}
   Current Usage: {{index .Fields "value"}}%
   Time: {{.Time}}
   Please check system processes if usage remains high.
   ```

2. **Memory Usage Alert**
   - Threshold: > 85%
   - Message Template:
   ```
   Host: {{.TaskName}}
   Memory Usage: {{index .Fields "value"}}%
   Time: {{.Time}}
   Please check memory-intensive processes.
   ```

3. **WordPress 500 Errors Alert**
   - Condition: Response code = 500
   - Message Template:
   ```
   Host: {{.TaskName}}
   Error Code: {{index .Fields "value"}}
   Time: {{.Time}}
   Action Required: Check WordPress logs and server status.
   ```

4. **WordPress Availability Alert**
   - Type: Deadman
   - Message Template:
   ```
   Host: {{.TaskName}}
   Status: WordPress Service Down
   Time: {{.Time}}
   Action Required:
   - Check if WordPress container is running
   - Check server connectivity
   - Verify application logs
   ```

### Slack Integration

1. Create Slack webhook:
   - Go to slack.com/apps
   - Search for "Incoming WebHooks"
   - Add to Slack
   - Choose alerts channel
   - Copy Webhook URL

2. Configure in Chronograf:
   - Add Slack handler
   - Input Webhook URL
   - Set default channel
   - Configure organization name