from flask import Flask, jsonify, request
from prometheus_client import make_wsgi_app, Counter, Histogram
from werkzeug.middleware.dispatcher import DispatcherMiddleware
import time

# Create a Flask application
app = Flask(__name__)

# Define Prometheus metrics
REQUEST_COUNT = Counter(
    'app_request_count', 'Application Request Count',
    ['method', 'endpoint', 'http_status']
)
REQUEST_LATENCY = Histogram(
    'app_request_latency_seconds', 'Application Request Latency',
    ['method', 'endpoint']
)

# Define a route for the root endpoint
@app.route('/')
def hello():
    start_time = time.time()
    
    # Simulate some processing
    time.sleep(0.1)  # Sleep for 0.1 seconds
    
    # Prepare response
    response = jsonify(message="Hello, world!")
    
    # Record metrics
    REQUEST_COUNT.labels('GET', '/', 200).inc()
    REQUEST_LATENCY.labels('GET', '/').observe(time.time() - start_time)
    
    return response

# Define a route for a different endpoint
@app.route('/api/data', methods=['GET'])
def get_data():
    start_time = time.time()
    
    # Simulate some processing
    time.sleep(0.2)  # Sleep for 0.2 seconds
    
    # Prepare response
    data = {"data": [1, 2, 3, 4, 5]}
    response = jsonify(data)
    
    # Record metrics
    REQUEST_COUNT.labels('GET', '/api/data', 200).inc()
    REQUEST_LATENCY.labels('GET', '/api/data').observe(time.time() - start_time)
    
    return response

# Add Prometheus metrics as a WSGI middleware
app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
    '/metrics': make_wsgi_app()
})

# Start the Flask application
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
