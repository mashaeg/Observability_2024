# Project Overview

Docker Compose setup for integrating VictoriaMetrics as a scalable and efficient storage solution for Prometheus metrics.

## Requirements

The objective was to enhance our Prometheus setup with a long-term storage solution that could handle the retention and querying of metrics efficiently. The specific requirements included:

- **Remote Storage Integration**: Integrate a remote storage solution to handle metrics collected by Prometheus.
- **Retention Policy**: Set a retention period of 2 weeks for metrics.
- **Label Addition**: Ensure that all metrics stored include an additional label `site: prod` to indicate the production environment.

## Implemented Solution

### Services Added/Modified

1. **VictoriaMetrics**:
   - Added VictoriaMetrics as the remote storage for Prometheus.
   - Configured with a retention period of two weeks.

2. **Prometheus**:
   - Configured `remote_write` to send metrics to VictoriaMetrics.
   - Added global external label to append `site: prod` to all metrics.

### Docker Compose Changes

Added the following service to `docker-compose.yml`:

```yaml
victoria_metrics:
  image: victoriametrics/victoria-metrics:v1.84.0
  container_name: victoria_metrics
  volumes:
    - ./victoria_data:/victoria-metrics-data
  ports:
    - "8428:8428"
  command:
    - '-retentionPeriod=2w'
  networks:
    - monitoring

###
Query Metrics Directly: /api/v1/query endpoint
Logs: docker logs victoria_metrics
Prometheus Targets/Service Discovery: http://<prometheus-host>:9090/targets  ##remote_write endpoint

### find container IP
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' viktoria_metrics

