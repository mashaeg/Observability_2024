
# Checking Metrics for WordPress and MySQL

## WordPress HTTP Metrics

### Available Fields
- `content_length`: Size of the response content.
- `http_response_code`: HTTP status code (e.g., 200, 404).
- `response_time`: Time taken to get the response from the server.
- `result_type`: Describes whether the request was a success or failure.

### Example Queries

- **Check for Failed Requests (404 errors)**:
    ```bash
    influx query 'from(bucket: "my_bucket") |> range(start: -24h) |> filter(fn: (r) => r._measurement == "wordpress_http") |> filter(fn: (r) => r.status_code == "404")'
    ```

- **Monitor Response Times**:
    ```bash
    influx query 'from(bucket: "my_bucket") |> range(start: -24h) |> filter(fn: (r) => r._measurement == "wordpress_http") |> filter(fn: (r) => r._field == "response_time")'
    ```

- **Check Overall Success or Failure**:
    ```bash
    influx query 'from(bucket: "my_bucket") |> range(start: -24h) |> filter(fn: (r) => r._measurement == "wordpress_http") |> filter(fn: (r) => r._field == "result_type") |> group(columns: ["_value"]) |> count()'
    ```

---

## MySQL Metrics

### Available Fields
- `threads_running`: Number of active threads in MySQL.
- `tls_library_version`: TLS library version in use.
- `uptime`: Total uptime of MySQL since the last restart.
- `uptime_since_flush_status`: Time since the last status flush in MySQL.

### Example Queries

- **Check Active MySQL Threads (`threads_running`)**:
    ```bash
    influx query 'from(bucket: "my_bucket") |> range(start: -24h) |> filter(fn: (r) => r._measurement == "mysql") |> filter(fn: (r) => r._field == "threads_running")'
    ```

- **Check MySQL Uptime (`uptime`)**:
    ```bash
    influx query 'from(bucket: "my_bucket") |> range(start: -24h) |> filter(fn: (r) => r._measurement == "mysql") |> filter(fn: (r) => r._field == "uptime")'
    ```

- **Check `uptime_since_flush_status`**:
    ```bash
    influx query 'from(bucket: "my_bucket") |> range(start: -24h) |> filter(fn: (r) => r._measurement == "mysql") |> filter(fn: (r) => r._field == "uptime_since_flush_status")'
    ```

---

## Visualization and Alerts

### Chronograf Visualizations
- Create dashboards for WordPress HTTP metrics (response time, status code distribution).
- Monitor MySQL performance (queries, threads running, uptime).

### Kapacitor Alerts
- Set alerts for high `threads_running` or high response times in WordPress.

# InfluxDB CLI Setup Instructions

To set up the InfluxDB CLI and connect it to your InfluxDB instance, follow these steps:

## 1. Install InfluxDB CLI

### For macOS (using Homebrew):
```bash
brew update
brew install influxdb
```

### For Linux:
```bash
wget https://dl.influxdata.com/influxdb/releases/influxdb2-2.x.x-linux-amd64.tar.gz
tar xvfz influxdb2-2.x.x-linux-amd64.tar.gz
sudo cp influxdb2-2.x.x-linux-amd64/influx /usr/local/bin/
```

### For Windows:
Download the InfluxDB client from the [InfluxData Downloads page](https://portal.influxdata.com/downloads/).

---

## 2. Configure CLI with InfluxDB

To configure the CLI with your InfluxDB instance, run the following command:

```bash
influx config create --config-name onboarding \
    --host-url "http://192.168.0.24:8086" \
    --org "4afd0e5e3410d10b" \
    --token "i6GA5aHLZcW6GTj7gGFuOYmtnyWdS-hVGuEguxO0GR9T2l4gmfA4wncxOWYMDJYCEx9Ajx_1U0P21i7CRgjGWw==" \
    --active
```

Replace the **host URL**, **organization ID**, and **token** with your InfluxDB instance details.

---

## 3. Using the CLI

### Check CLI Version:
```bash
influx version
```

### Test the Connection:
```bash
influx ping
```

### Basic Commands:

- **List all available buckets**:
  ```bash
  influx bucket list
  ```

- **Query the database**:
  ```bash
  influx query 'from(bucket: "my_bucket") |> range(start: -1h)'
  ```

- **Create a new bucket**:
  ```bash
  influx bucket create --name new_bucket --org "your_org_name"
  ```

---

## 4. Switch Between Configurations

If you have multiple configurations, you can switch between them using:

```bash
influx config ls  # List all configurations
influx config set --config-name onboarding  # Set an active configuration
```

This allows you to switch easily between different environments (e.g., local, production).