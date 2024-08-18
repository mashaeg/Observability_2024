# Flask App with Prometheus Monitoring

This repository contains a simple Flask application that exposes Prometheus metrics for monitoring. The application is containerized using Docker for easy deployment.

## Features

- **Flask Web Application**: Serves a basic API with a couple of endpoints.
- **Prometheus Integration**: Exposes metrics at the `/metrics` endpoint for monitoring.
- **Dockerized**: Easily deploy the application using Docker.

## Endpoints

- `/`: Returns a "Hello, world!" message.
- `/api/data`: Returns a JSON object with sample data.
- `/metrics`: Exposes Prometheus metrics (automatically added by the app, no manual interaction required).

## Prometheus Metrics

The application collects the following Prometheus metrics:

- `app_request_count`: A counter that tracks the number of requests by method, endpoint, and HTTP status.
- `app_request_latency_seconds`: A histogram that measures the latency of requests by method and endpoint.

### Prometheus Configuration

To scrape the metrics from this application, add the following job to your `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'flask_app'
    metrics_path: /metrics
    static_configs:
      - targets: ['localhost:5000']
